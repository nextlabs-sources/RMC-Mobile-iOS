//
//  NXFileMarker.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 8/22/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXFileMarker.h"
#import "NXSyncHelper.h"
#import "NXFavoriteMarkFilesAsFavoriteAPI.h"
#import "NXFavoriteUnMarkFilesAsFavoriteAPI.h"
#import "NXMyVaultFile.h"
#import "NXFavFileStorage.h"
#import "NXFavoriteGetAllFavoriteFilesInReposAPI.h"
#import "NXLProfile.h"
#define SYNC_INTERVAL 6 // seconds

@interface NXFileMarker()
@property(nonatomic, strong) dispatch_queue_t markerOptQueue;
@property(nonatomic, strong) NXSyncHelper *syncHelper;

@property(nonatomic, strong) NSThread *workThread;
@property(nonatomic, assign) BOOL shouldExitWorkThread;
@property(nonatomic, assign) BOOL isStarted;
@property(nonatomic, strong) NSTimer *workTimer;

@property(nonatomic, assign) NSTimeInterval lastOperationTimeStamp;
@property(nonatomic, assign) BOOL isWorkTimerFirstStart;
@end

@implementation NXFileMarker
- (instancetype)init
{
    if (self = [super init]) {
        _markerOptQueue = dispatch_queue_create("com.skydrm.rmc.NXFileMarker", DISPATCH_QUEUE_SERIAL);
        _syncHelper = [[NXSyncHelper alloc] init];
        _isWorkTimerFirstStart = YES;
    }
    return self;
    
}

- (void)dealloc
{
    DLog(@"NXFileMarker dealloc");
}

#pragma mark - Sync
-(NSThread *)workThread
{
    if (_workThread == nil) {
        _workThread = [[NSThread alloc] initWithTarget:self selector:@selector(workThreadEntryPoint:) object:nil];
        [_workThread start];
    }
    
    return _workThread;
}

-(void)workThreadEntryPoint:(id)__unused object
{
    NSRunLoop* loop = [NSRunLoop currentRunLoop];
    do
    {
        @autoreleasepool
        {
            [loop runUntilDate:[NSDate dateWithTimeIntervalSinceNow: 1.0]];
            if (self.shouldExitWorkThread) {
                break;
            }
            
            [NSThread sleepForTimeInterval:1.0f];
        }
    }while (true);
}

-(void)startSyncFavFromRMS
{
    if (!self.isStarted) {
        self.shouldExitWorkThread = NO;
        [self startTimer];
    }
}

-(void)startTimer
{
    if (self.shouldExitWorkThread) {
        return;
    }
    [self performSelector:@selector(scheduleSyncTimer) onThread:self.workThread withObject:nil waitUntilDone:NO];
}
- (void)stopSyncFavFromRMS
{
    self.shouldExitWorkThread = YES;
    self.isStarted = NO;
    
    [self.workTimer invalidate];
    self.workThread = nil;
}

-(void)scheduleSyncTimer
{
   // NSLog(@"NXFileMarker start sync ++++++++++");
    
    [self.workTimer invalidate];
    self.workTimer = [NSTimer scheduledTimerWithTimeInterval:SYNC_INTERVAL target:self selector:@selector(syncFavFilesFromRMS:) userInfo:nil repeats:NO];
    if (_isWorkTimerFirstStart) {
        [self.workTimer fire];
        _isWorkTimerFirstStart = NO;
    }
}

-(void) syncFavFilesFromRMS:(NSTimer *)timer
{
    NSTimeInterval syncTime = [[NSDate date] timeIntervalSince1970];
    WeakObj(self);
    [self.syncHelper uploadPreviousFailedRESTRequestWithCachedURL:[self favReqCacheDirectory] mustAllSuccess:YES Complection:^(id object, NSError *error) {
        StrongObj(self);
        if (error || syncTime < self.lastOperationTimeStamp || self.shouldExitWorkThread) {
            [self startTimer];
        }else{
            NXFavoriteGetAllFavoriteFilesInReposAPIRequest *allFavReq = [[NXFavoriteGetAllFavoriteFilesInReposAPIRequest alloc] init];
            [allFavReq requestWithObject:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
                if (self) {
                    if (error == nil) {
                        if (syncTime < self.lastOperationTimeStamp || self.shouldExitWorkThread) { // means the RMS data is out of date from local operation or shouldExitWorkThread(This will not start a new timer in startTimer)
                            [self startTimer];
                            return;
                        }
                        NXFavoriteGetAllFavoriteFilesInReposAPIResponse *allFavListResponse = (NXFavoriteGetAllFavoriteFilesInReposAPIResponse *)response;
                        if(allFavListResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS){
                            NSMutableArray *rmsFavFilesArray = [[NSMutableArray alloc] init];
                            for (NXFavoriteSpecificFileItemModel *specificFileItem in allFavListResponse.favoriteRepoModelArray) {
                                [rmsFavFilesArray addObject:specificFileItem.fileItem];
                            }
                            
                            NSMutableSet *rmsFavFilesSet = [[NSMutableSet alloc] initWithArray:rmsFavFilesArray];
                            NSSet *rmsFavFilesSet2 = [NSSet setWithSet:rmsFavFilesSet];
                            
                            NSMutableSet *localFavFilesSet = [[NSMutableSet alloc] initWithArray:[self allFavFileList]];
                            NSSet *localFavFilesSet2 = [NSSet setWithSet:localFavFilesSet];
                            // Get add fav file set
                            [rmsFavFilesSet minusSet:localFavFilesSet2];
                            // Get removed fav file set
                            [localFavFilesSet minusSet:rmsFavFilesSet2];
                            
                            BOOL anyChange = NO;
                            for (NXFile *file in rmsFavFilesSet) {
                                anyChange = YES;
                                [NXFavFileStorage insertNewFavFileItem:file];
                            }
                            
                            for (NXFile *file in localFavFilesSet) {
                                anyChange = YES;
                                [NXFavFileStorage deleteFavFileItem:file];
                            }
                            if (anyChange) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FAV_FILE_LIST_CHANGED object:nil];
                                });
                            }
                            [self startTimer];
                        }else{
                            [self startTimer];
                        }
                    }else{
                        [self startTimer];
                    }
                }
            }];
        }
    }];
}

- (void)getAllFavFileListFromNetWorkWithCompletion:(getAllFavFileCompleteBlock)completion
{
    NXFavoriteGetAllFavoriteFilesInReposAPIRequest *allFavReq = [[NXFavoriteGetAllFavoriteFilesInReposAPIRequest alloc] init];
    
    [allFavReq requestWithObject:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        
          completion([self allFavFileList],nil);
    }];
}


#pragma mark - MARK/UnMark
- (void)markFileAsFav:(NXFileBase *)file withCompleton:(markFileCompleteBlock)completion
{
    self.lastOperationTimeStamp = [[NSDate date] timeIntervalSince1970];
    // step1. cache fav req in local and try to send req to RMS
    WeakObj(self);
    NXFavoriteMarkFilesAsFavoriteAPIRequest *favReq = [[NXFavoriteMarkFilesAsFavoriteAPIRequest alloc] init];
    [favReq generateRequestObject:file];
    [self.syncHelper cacheRESTAPI:favReq directlyURL:[self favReqCacheURL:file]];
    WeakObj(favReq);
    [favReq requestWithObject:file Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        StrongObj(favReq);
        if (self) {
            if (!error) {
                NXFavoriteMarkFilesAsFavoriteAPIResponse *favResponse = (NXFavoriteMarkFilesAsFavoriteAPIResponse *)response;
                if (favResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) {
                    [self.syncHelper removeCachedRESTAPI:favReq directlyCacheURL:[self favReqCacheURL:file]];
                }
            }
        }
    }];
    
    // step2. update local data
    file.isFavorite = YES;
    [NXFavFileStorage insertNewFavFileItem:file];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FAV_FILE_LIST_CHANGED object:nil];
    });
    completion(file);
    
}
- (void)unmarkFileAsFav:(NXFileBase *)file withCompletion:(unmarkFileCompleteBlock)completion
{
    self.lastOperationTimeStamp = [[NSDate date] timeIntervalSince1970];
    
    // step1. cache fav req in local and try to send req to RMS
    WeakObj(self);
    NXFavoriteUnMarkFilesAsFavoriteAPIRequest *unFavReq = [[NXFavoriteUnMarkFilesAsFavoriteAPIRequest alloc] init];
    [unFavReq generateRequestObject:file];
    [self.syncHelper cacheRESTAPI:unFavReq directlyURL:[self favReqCacheURL:file]];
    WeakObj(unFavReq);
    [unFavReq requestWithObject:file Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        StrongObj(unFavReq);
        if (self) {
            if (!error) {
                NXFavoriteUnMarkFilesAsFavoriteAPIResponse *unFavResponse = (NXFavoriteUnMarkFilesAsFavoriteAPIResponse *)response;
                if (unFavResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) {
                    [self.syncHelper removeCachedRESTAPI:unFavReq directlyCacheURL:[self favReqCacheURL:file]];
                }
            }
        }
    }];
    
    // step2. update local data
    [NXFavFileStorage deleteFavFileItem:file];
    file.isFavorite = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FAV_FILE_LIST_CHANGED object:nil];
    });
    completion(file);
}

- (void)removeFileFromFavList:(NXFileBase *)file withCompletion:(removeFavFileCompleteBlock)completion
{
    self.lastOperationTimeStamp = [[NSDate date] timeIntervalSince1970];
    
    if(file.sorceType == NXFileBaseSorceTypeRepoFile){
        [[NXLoginUser sharedInstance].myRepoSystem deleteFileItem:file completion:^(NXFileBase *fileItem, NSError *error) {
            if (!error) {
                [NXFavFileStorage deleteFavFileItem:fileItem];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FAV_FILE_LIST_CHANGED object:nil];
                });
            }
            completion(file, error);
        }];
    }else if(file.sorceType == NXFileBaseSorceTypeMyVaultFile){
        if (((NXMyVaultFile *)file).duid == nil) {
            [[NXLoginUser sharedInstance].nxlOptManager getNXLFileRights:file withWatermark:NO withCompletion:^(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray *watermark, NSString *owner, BOOL isOwner, NSError *error) {
                if (error) {
                    completion(file, error);
                }else{
                    ((NXMyVaultFile *)file).duid = duid;
                    [[NXLoginUser sharedInstance].myVault deleteFile:(NXMyVaultFile *)file withCompletion:^(NXMyVaultFile *file, NSError *error) {
                        if (!error) {
                            [NXFavFileStorage deleteFavFileItem:file];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FAV_FILE_LIST_CHANGED object:nil];
                            });
                        }
                        completion(file, error);
                    }];
                }
            }];
        }else{
            [[NXLoginUser sharedInstance].myVault deleteFile:(NXMyVaultFile *)file withCompletion:^(NXMyVaultFile *file, NSError *error) {
                if (!error) {
                    [NXFavFileStorage deleteFavFileItem:file];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FAV_FILE_LIST_CHANGED object:nil];
                    });
                }
                completion(file, error);
            }];
        }
    }
}

- (NSArray *)allFavFileList
{
    return [NXFavFileStorage allFavFileItems];
}

- (NSArray *)allFavFileListInMydrive
{
     return [NXFavFileStorage allFavFileItemsInMyDrive];
}
- (NSArray *)allFavFileItemsInMyVault{
    return [NXFavFileStorage allFavFileItemsInMyVault];
}
#pragma mark - Private
- (NSURL *)favReqCacheURL:(NXFileBase *)file
{
    NSString *fileKey = [NXCommonUtils fileKeyForFile:file];
    NSString *fileName = [fileKey stringByAppendingString:NXREST_CACHE_EXTENSION];
    NSURL *storeURL = [self favReqCacheDirectory];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:storeURL.path]) {  // folder doesn't exist, create
        NSError* error = nil;
        BOOL rt = [[NSFileManager defaultManager] createDirectoryAtURL:storeURL withIntermediateDirectories:YES attributes:nil error:&error];
        if (!rt) {
            NSLog(@"create folder failed, %@, %@", storeURL, error);
            return nil;
        }
    }

    storeURL = [storeURL URLByAppendingPathComponent:fileName];
    return storeURL;
}
- (NSURL *)favReqCacheDirectory
{
    NSURL *storeURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    storeURL = [storeURL URLByAppendingPathComponent:[NXLoginUser sharedInstance].profile.userId];
    storeURL = [storeURL URLByAppendingPathComponent:@"FAV_REQ_CACHE"];
    return storeURL;
}
@end
