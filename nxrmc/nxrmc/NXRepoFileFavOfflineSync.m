//
//  NXRepoFileFavOfflineSync.m
//  nxrmc
//
//  Created by EShi on 1/6/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXRepoFileFavOfflineSync.h"
#import "NXCacheManager.h"
#import "NXAllFavFilesAPI.h"
#import "NXFavFilesInRepoAPI.h"
#import "NXOfflineFilesInRepoAPI.h"
#import "NXFileBase.h"

#define MARK_FAV_REQUSET_CACHE_EXT          @"MKFAV"
#define UNMARK_FAV_REQUSET_CACHE_EXT        @"UNMKFAV"

@interface NXRepoFileFavOfflineSync()
@property(atomic, strong)NSMutableDictionary *repoFavOfflineDict;
@property(nonatomic, strong)NSThread *workThread;
@property(nonatomic, assign)BOOL shouldExitWorkThread;
@property(nonatomic, assign)BOOL isStarted;
@property(nonatomic, strong) NSTimer *workTimer;
@property(nonatomic, strong) dispatch_queue_t favOfflineRESTCacheSerialOperationQueue;
@property(nonatomic, strong) NXLProfile *userProfile;
@property(nonatomic, assign) BOOL isWorkTimerFirstStart;
@end


@implementation NXRepoFileFavOfflineSync
- (instancetype) initWithCurrentLocalFavOfflineFileItems:(NSDictionary *)favOfflineFilesDict userProfile:(NXLProfile *)userProfile
{
    self = [super init];
    if (self) {
        _repoFavOfflineDict = [[NSMutableDictionary alloc] initWithDictionary:favOfflineFilesDict];
        _favOfflineRESTCacheSerialOperationQueue = dispatch_queue_create("com.skydrm.rmcent.NXRepoFileFavOfflineSync.favOfflineRESTCacheSerialOperationQueue", DISPATCH_QUEUE_SERIAL);
        _userProfile = userProfile;
        _isWorkTimerFirstStart = NO;
    }
    return self;
}

- (void)dealloc
{
    DLog(@"NXRepoFileFavOfflineSync dealloc");
}

#pragma mark - Timer thread
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
    NSLog(@"Exit the sync offline/fav runloop");
}

#pragma mark - Sync
-(void)startSyncFavOfflineFromRMS
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
- (void)stopSyncFavOfflineFromRMS
{
    self.shouldExitWorkThread = YES;
    self.isStarted = NO;
    
    [self.workTimer invalidate];
    self.workThread = nil;
}

-(void)scheduleSyncTimer
{
     //NSLog(@"NXRepoFileFavOfflineSync start sync ++++++++++");
    [self.workTimer invalidate];
    self.workTimer = [NSTimer scheduledTimerWithTimeInterval:FAVORITE_FILES_SYNC_INTERVAL target:self selector:@selector(syncFavOfflineFilesFromRMS:) userInfo:nil repeats:NO];
    if (_isWorkTimerFirstStart) {
        [self.workTimer fire];
        _isWorkTimerFirstStart = NO;
    }
}

-(void) syncFavOfflineFilesFromRMS:(NSTimer *)timer
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.favOfflineRESTCacheSerialOperationQueue, ^{
        // step1. upload all cached local operation
        [weakSelf uploadPreviousFailedRESTRequestWithCachedURL:[NXCacheManager getFavOfflineRESTCacheURL] mustAllSuccess:YES Complection:^(id object, NSError *error){
            if(!error) // step2. only all cached local operation upload successfully, then get RMS file offline/fav files
            {
                NSTimeInterval syncTime = [[NSDate date] timeIntervalSince1970];
                weakSelf.localFavOfflineLastOptTime = syncTime;
                NXAllFavFilesRequest *allFavRequest = [[NXAllFavFilesRequest alloc] init];
                [allFavRequest requestWithObject:weakSelf.userProfile Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
                    if (!error) {
                        if (syncTime < weakSelf.localFavOfflineLastOptTime) { // this means sync api callback lag behind local operation, ignore this call back
                            [weakSelf startTimer];
                            return;
                        }
                        NXAllFavFilesResponse *allFavOffResponse = (NXAllFavFilesResponse *)response;
                        
                        if (allFavOffResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) {
                            NSMutableArray *markFavItemsArray = [[NSMutableArray alloc] init];
                            NSMutableArray *unmarkFavItemsArray = [[NSMutableArray alloc] init];

                            NSMutableDictionary *newFavOfflineDict = [[NSMutableDictionary alloc] init];
                            for (NXRepoFavInfo *info in allFavOffResponse.repoFavOfflineList) {
                                NSSet *currentFavSet = [weakSelf favoriteFileSetForRepoId:info.repoID];
                                NSMutableSet *unmakrFavSet = [[NSMutableSet alloc] initWithSet:currentFavSet];
                                
                                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                                NSMutableSet *favSet = [[NSMutableSet alloc] init];
                                [dict setObject:favSet forKey:FAV_FILES_KEY];
                                for (NSString *fileId in info.markedFavFiles) {
                                    [favSet addObject:fileId];
                                    NXFileBase *fileBaseInfo = [[NXFileBase alloc] init];
                                    fileBaseInfo.repoId = info.repoID;
                                    fileBaseInfo.fullServicePath = fileId;
                                    if (![weakSelf isFileFav:fileBaseInfo]) {
                                        [markFavItemsArray addObject:fileBaseInfo];
                                    }
                                    [unmakrFavSet removeObject:fileId];
                                }
                                [newFavOfflineDict setObject:dict forKey:info.repoID];
                                [unmarkFavItemsArray addObjectsFromArray:[unmakrFavSet allObjects]];
                            }
                            // update the repoFavOfflineDict
                            weakSelf.repoFavOfflineDict = newFavOfflineDict;
                            //if (unmarkFavItemsArray.count || markFavItemsArray.count || unmrkOfflineItmesArray.count || markOfflineItemsArray.count) {
                                if (DELEGATE_HAS_METHOD(weakSelf.delegate, @selector(offlineFavSync:favOfflineFileItemsDict:))) {
                                    // There can't find change, for the repo may sync from
                                    NSDictionary *retDict = [NSDictionary dictionaryWithDictionary:newFavOfflineDict];
                                    [weakSelf.delegate offlineFavSync:weakSelf favOfflineFileItemsDict:retDict];
                                }
                           // }
                            
                        }
                    }
                    [weakSelf startTimer];
                }];
            }else
            {
                [weakSelf startTimer];
            }
        }];
    });
}

#pragma mark - public interface
-(void)unmarkFavFile:(NXFileBase *)fileBase
{
    NSMutableSet *favSet = (NSMutableSet *)[self favoriteFileSetForRepoId:fileBase.repoId];
    if (favSet) {
        [favSet removeObject:fileBase.fullServicePath];
    }
    
    NSURL *unmarkFavURL = [self unmarkFavFileCacheURL:fileBase];
    NSURL *markFavURL = [self markFavFileCacheURL:fileBase];
    
    dispatch_async(self.favOfflineRESTCacheSerialOperationQueue, ^{
        // step2.Delete cached mark request
        [NXCacheManager deleteCachedRESTByURL:markFavURL];
        
        // step3. Cache unmark request
        NXFavFilesInRepoRequest* request = [[NXFavFilesInRepoRequest alloc] initWithType:NXFavFilesInRepoRequestTypeUnmark];
        NSArray *unmarkFavFileArray = @[fileBase];
        NSDictionary *modelDict = @{NXFavFilesInRepoModel_FilesKey:unmarkFavFileArray,
                                    NXFavFilesInRepoModel_RepoIdKey:fileBase.repoId};
        [request generateRequestObject:modelDict];
        [NXCacheManager cacheRESTReq:request directlyCacheURL:unmarkFavURL];
    });
}

- (void)markFavFile:(NXFileBase *)fileBase withParent:(NXFileBase *)parent;
{
    NSDictionary *dict = self.repoFavOfflineDict[fileBase.repoId];
    if (dict == nil) {
        dict = @{FAV_FILES_KEY:[[NSMutableSet alloc] init]};
    }
    [self.repoFavOfflineDict setObject:dict forKey:fileBase.repoId];
    
    
    NSMutableSet *favSet = (NSMutableSet *)[self favoriteFileSetForRepoId:fileBase.repoId];
    if (![favSet containsObject:fileBase.fullServicePath]) {
        [favSet addObject:fileBase.fullServicePath];
    }
    
    NSURL *unmarkFavURL = [self unmarkFavFileCacheURL:fileBase];
    NSURL *markFavURL = [self markFavFileCacheURL:fileBase];
    
    dispatch_async(self.favOfflineRESTCacheSerialOperationQueue, ^{
        // step2. Delete cached unmark request
        [NXCacheManager deleteCachedRESTByURL:unmarkFavURL];
        
        // step3. Cache mark request
        NXFavFilesInRepoRequest* request = [[NXFavFilesInRepoRequest alloc] initWithType:NXFavFilesInRepoRequestTypeMark];
        NSArray *markFavFileArray = @[fileBase];
        NSDictionary *modelDict = @{NXFavFilesInRepoModel_FilesKey:markFavFileArray,
                                    NXFavFilesInRepoModel_RepoIdKey:fileBase.repoId,
                                    NXFavFilesInRepoModel_ParentKey:parent};
        [request generateRequestObject:modelDict];
        [NXCacheManager cacheRESTReq:request directlyCacheURL:markFavURL];
        
    });
}

#pragma mark - private method
-(NSURL *)markFavFileCacheURL:(NXFileBase *)file
{
    NSString *cachedFileName = [NSString stringWithFormat:@"%@.%@%@", file.fullServicePath, MARK_FAV_REQUSET_CACHE_EXT,NXREST_CACHE_EXTENSION];
    NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@":/\\?%*|\"<>"];
    cachedFileName = [[cachedFileName componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""];
    NSURL *destURL = [[NXCacheManager getFavOfflineRESTCacheURL] URLByAppendingPathComponent:cachedFileName];
    return destURL;
}

-(NSURL *)unmarkFavFileCacheURL:(NXFileBase *)file
{
    NSString *cachedFileName = [NSString stringWithFormat:@"%@.%@%@", file.fullServicePath, UNMARK_FAV_REQUSET_CACHE_EXT,NXREST_CACHE_EXTENSION];
    NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@":/\\?%*|\"<>"];
    cachedFileName = [[cachedFileName componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""];
    NSURL *destURL = [[NXCacheManager getFavOfflineRESTCacheURL] URLByAppendingPathComponent:cachedFileName];
    return destURL;
}



-(NSSet *)favoriteFileSetForRepoId:(NSString *)repoId
{
    if (self.repoFavOfflineDict[repoId]) {
        return self.repoFavOfflineDict[repoId][FAV_FILES_KEY];
    }
    
    return nil;
    
}


-(BOOL)isFileFav:(NXFileBase *)file
{
    NSSet * favSet = [self favoriteFileSetForRepoId:file.repoId];
    if ([favSet containsObject:file.fullServicePath]) {
        return YES;
    }else
    {
        return NO;
    }
}


@end
