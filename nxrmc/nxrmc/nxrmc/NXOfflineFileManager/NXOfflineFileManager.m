//
//  NXOfflineFileManager.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2018/8/9.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import "NXOfflineFileManager.h"
#import "NXWebFileManager.h"
#import "NXOfflineFileTokenManager.h"
#import "NXOfflineFileRightsManager.h"
#import "NXMarkFileAsOfflineCombinedOperation.h"
#import "NXRMCDef.h"
#import "NXCommonUtils.h"
#import "NXNetworkHelper.h"
#import "NXOfflineFileStorage.h"
#import "NXOfflineFileOperation.h"
#import "NXLogAPI.h"
#import "NXLFileValidateDateModel.h"
#import "NXTimeServerManager.h"
#import "NXSyncHelper.h"
#import "NXCacheManager.h"
#import "JTDateHelper.h"
#import "NXNXLFileLogManager.h"
#import "NXLSDKDef.h"
#import "NXNXLOperationManager.h"
#import "NXLMetaData.h"
#import "NXLRights.h"
#import "NXTimeServerManager.h"
// set offline file local expire time as 7 day after mark as offline date
#define  OFFLINE_FILE_LOACL_EXPIRE_TIME  7

@interface NXOfflineFileManager()

@property(nonatomic, strong) NSOperationQueue *markAsOfflineQueue;
@property(nonatomic, strong) NSMutableDictionary *doingOfflineCallBackBlocks;
@property(nonatomic, strong) NSMutableDictionary *doingOfflineOperations;
@property(nonatomic, strong) NSMutableDictionary *downloadProgresses;
@property(nonatomic, strong) dispatch_queue_t barrierQueue;
@property(nonatomic, strong) NSMutableDictionary *markFileAsOfflineOperationIdMap;

@property(nonatomic, strong,readwrite) NXWebFileManager *webFileManager;
@property(nonatomic, strong,readwrite) NXOfflineFileTokenManager *offlineFileTokenManager;
@property(nonatomic, strong,readwrite) NXOfflineFileRightsManager *offlineFileRightsManager;
@property(nonatomic, strong,readwrite) NSOperation *queryCacheOperation;
@property(nonatomic, strong,readwrite) JTDateHelper *dateHelper;
@property(nonatomic, strong) NXNXLFileLogManager *fileLogManager;

@property(nonatomic, strong) NSMutableSet *isConvertingToOfflineFileKeySet;
@property(nonatomic, strong) NSMutableDictionary *refreshOfflineFileRightsOptKeyArray;
@property(nonatomic, strong) NSMutableDictionary *refreshOfflineFileTokenOptKeyArray;


@end

@implementation NXOfflineFileManager

#pragma -mark -init

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static NXOfflineFileManager *instance = nil;
    dispatch_once(&once, ^{
        instance = [[NXOfflineFileManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _doingOfflineCallBackBlocks = [[NSMutableDictionary alloc] init];
         _doingOfflineOperations = [[NSMutableDictionary alloc] init];
        _downloadProgresses = [[NSMutableDictionary alloc] init];
        _markFileAsOfflineOperationIdMap = [[NSMutableDictionary alloc] init];
        _offlineFileRightsManager = [[NXOfflineFileRightsManager alloc] init];
        _offlineFileTokenManager = [[NXOfflineFileTokenManager alloc] init];
        _fileLogManager = [[NXNXLFileLogManager alloc] init];
        _queryCacheOperation = [[NSOperation alloc] init];
        _webFileManager = [NXWebFileManager sharedInstance];
        _dateHelper = [[JTDateHelper alloc] init];
        _isConvertingToOfflineFileKeySet = [NSMutableSet set];
        _barrierQueue = dispatch_queue_create("com.skydrm.rmcent.NXOfflineFileManagerBarrierQueue", DISPATCH_QUEUE_CONCURRENT);
        _markAsOfflineQueue = [[NSOperationQueue alloc] init];
        _markAsOfflineQueue.maxConcurrentOperationCount = 5;
        _refreshOfflineFileTokenOptKeyArray = [[NSMutableDictionary alloc] init];
        _refreshOfflineFileRightsOptKeyArray = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma -mark public method
- (NSString *)markFileAsOffline:(NXFileBase *)file
                 withCompletion:(markFileAsOfflineCompletedBlock)completion
{
    // step1. check network
    if (![[NXNetworkHelper sharedInstance] isNetworkAvailable]) {
        dispatch_main_async_safe(^{
            NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NETWORK_DOMAIN code:NXRMC_ERROR_NO_NETWORK userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_NETWORK_UNUSABLE", nil)}];
            if (completion) {
                completion(file,error);
            }
        });
        return nil;
    }
    
     // step2. check is supported offline file format
    NSString *fileExtension = [NXCommonUtils getFileExtensionByFileName:file];
    if ([NXCommonUtils isRemoteViewSupportFormat:fileExtension]) {
        // if current file view need server support, it means it can not be offline
        dispatch_main_async_safe(^{
            NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXOFFLINEFILE_DOMAIN code:NXRMC_ERROR_CODE_OFFLINE_FILE_FORMAT_NOT_SUPPORT_ERROR userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_OFFLINE_FILE_FORMAT_NOT_SUPPORT", nil)}];
            if (completion) {
                completion(file,error);
            }
        });
        return nil;
    }
    
    NSString *operatonIdentify = [[NSUUID UUID] UUIDString];
    // Generate cachekey for the file
    NSString *fileKey = [NXCommonUtils fileKeyForFile:file];
    // add to convert offline set
    if (fileKey.length > 0) {
        [self addToConvertOfflineFileSet:fileKey];
    }
    
    // post notification that myvault page need update
       dispatch_main_async_safe(^{
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MARK_AS_OFFLINE_VC_NEED_UPDATE object:nil];
       });

    // step3. Generate one markFileAsOfflineCombinedOperation stand for this task and key for the file item
    NXMarkFileAsOfflineCombinedOperation *combinedOperation = [[NXMarkFileAsOfflineCombinedOperation alloc] initWithFile:file];
    
 
    [self.doingOfflineOperations setObject:combinedOperation forKey:operatonIdentify];
    [self.doingOfflineCallBackBlocks setObject:completion forKey:operatonIdentify];
    
    // cache the fileKey - operationIdentify map
    [self.markFileAsOfflineOperationIdMap setObject:operatonIdentify forKey:fileKey];
    
    
      // step4. Mark file as offline
    WeakObj(self);
    combinedOperation.markFileAsOfflineCompletedBlock = ^(NXFileBase *fileItem, NSError *error) {
          StrongObj(self);
        markFileAsOfflineCompletedBlock completion = self.doingOfflineCallBackBlocks[operatonIdentify];
        if (completion) {

            // if cancel by yourself, do not show error message
            if (error.code == NXRMC_ERROR_CODE_NXOPERATION_CANCELLED) {
                // remove from  convert offline set
                [self removeFromConvertOfflineFileSet:fileKey];
                
                // post notification that myvault page need update
                  dispatch_main_async_safe(^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MARK_AS_OFFLINE_VC_NEED_UPDATE object:nil];
                      });
            }else{
                dispatch_main_async_safe(^{
                    // remove from  convert offline set
                    [self removeFromConvertOfflineFileSet:fileKey];
                    completion(fileItem,error);
                    
                    // post notification that myvault page need update
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MARK_AS_OFFLINE_VC_NEED_UPDATE object:nil];
                });
            }
        }
        
        [self.doingOfflineCallBackBlocks removeObjectForKey:operatonIdentify];
        
        
        
        [self.doingOfflineOperations removeObjectForKey:operatonIdentify];
        
        
        
        [self.markFileAsOfflineOperationIdMap removeObjectForKey:fileKey];
        
    };
     
    [self.markAsOfflineQueue addOperation:combinedOperation];
    return operatonIdentify;
}


- (NSString *)markFileAsOffline:(NXFileBase *)file
                  progressBlock:(markFileAsOfflineProgressBlock)progressBlock
                 withCompletion:(markFileAsOfflineCompletedBlock)completion
{
    /////////////////////////////////////////////////////////
    return @"";
}

- (void)unmarkFileAsOffline:(NXFileBase *)file withCompletion:(unmarkFileAsOfflineCompletedBlock)completion
{
    //setp1. Generate cachekey for the file
    NSString *fileKey = [NXCommonUtils fileKeyForFile:file];
    
    NSString *markAsOfflineOptIdentify;
    NSOperation *markAsOfflineOperation;
    
    
    markAsOfflineOptIdentify = [self.markFileAsOfflineOperationIdMap objectForKey:fileKey];
    markAsOfflineOperation = [self.doingOfflineOperations objectForKey:markAsOfflineOptIdentify];
    
    
    // step2. if current file has a mark as offline task and not completed,cancel it
    
    if (markAsOfflineOperation) {
        [markAsOfflineOperation cancel];
    }
    
    // remove from  convert offline set
    [self removeFromConvertOfflineFileSet:fileKey];
    
    // step3. clear `cached file` `cached rights` `cached token` `coredata offline file record`
    [self.webFileManager cleanDiskForOfflineFile:file withKey:fileKey];
    [self.offlineFileRightsManager clearCachedRightsForFile:file];
    [self.offlineFileTokenManager deleteTokenForFile:file];
    [NXOfflineFileStorage deleteOfflineFileItemWithKey:fileKey];
    
    // post notification that myvault page need update
     dispatch_main_async_safe(^{
           [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MARK_AS_OFFLINE_VC_NEED_UPDATE object:nil];
     });
    
    completion(file,nil);
}

- (NSArray *)allOfflineFileList
{
    return [NXOfflineFileStorage allOfflineFileItems];
}
- (NSArray *)allOfflineFileListFromMyVault {
    return [NXOfflineFileStorage allOfflineFileListFromMyVault];
}

- (NSArray *)allOfflineFileListFromSharedWithMe
{
     return [NXOfflineFileStorage allOfflineFileListFromSharedWithMe];
}

- (NSArray *)allOfflineFileListFromMyVaultAndSharedWithMe
{
      return [NXOfflineFileStorage allOfflineFileListFromMyVaultOrSharedWithMe];
}

- (NSArray *)allOfflineFileListFromWorkSpace {
    return [NXOfflineFileStorage allOfflineFileListFromWorkSpace];
}

-(NSArray *)allOfflineFileListFromProject:(NSNumber *)projectId {
    return [NXOfflineFileStorage queryAllOfflineFilesInProject:projectId];
}
- (BOOL)hasConvertingFailedFile
{
    return [NXOfflineFileStorage hasConvertFailedOfflineFile];
}

- (void)cancelAllMarkTask
{
    [self.markAsOfflineQueue cancelAllOperations];
    
    for (NXMarkFileAsOfflineCombinedOperation *opt in self.doingOfflineOperations.allValues) {
        [self.webFileManager cancelDownload:opt.downloadOptIdentify];
        [self.offlineFileRightsManager cancelOperation:opt.queryRightsOptIdentify];
    }
}

- (BOOL)hasMarkingAsOfflinedFile
{
    if (self.doingOfflineOperations.allKeys.count>=1) {
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)isEncryptedByCenterPolicy:(NXOfflineFile *)file
{
    return NO;
}

- (NXFileState)currentState:(NXFileBase *)file
{
    NSString *fileKey = @"";
    if ([file isKindOfClass:[NXOfflineFile class]] && (file.sorceType == NXFileBaseSorceTypeShareWithMe || file.sorceType == NXFileBaseSorceTypeSharedWithProject)) {
        NXOfflineFile *offlienFile = (NXOfflineFile *)file;
        if (offlienFile.fileKey.length > 0) {
            fileKey = offlienFile.fileKey;
        }
    }else{
        fileKey = [NXCommonUtils fileKeyForFile:file];
    }
    
    if ([self.isConvertingToOfflineFileKeySet containsObject:fileKey]) {
        return NXFileStateConvertingOffline;
    }
    
    return [NXOfflineFileStorage getOfflineFileState:file];
}

- (void)decryptOfflineFile:(NXOfflineFile *)file toPath:(NSString *)destPath withCompletion:(optOfflineFileDecryptCompletionBlock)completion{
    
    //step1. check offline file expire time
    BOOL isExpire = [self checkIsExpire:file];
    if (isExpire) {
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXOFFLINEFILE_DOMAIN code:NXRMC_ERROR_CODE_OFFLINE_FILE_EXPIRED_ERROR userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_OFFLINE_FILE_EXPIRED", nil)}];
        completion(nil,nil,nil, nil, nil, NO, error);
        return;
    }
    
    // step2. read cache
    WeakObj(self);
    NXWebFileDownloaderProgressBlock progressBlock = ^(int64_t receivedSize, int64_t totalCount, double fractionCompleted){
        DLog(@"open offline file->Downloading: %lf", fractionCompleted);
    };
    
    NXFile *originalSourceFile = nil;
    if (file.sorceType == NXFileBaseSorceTypeProject) {
        originalSourceFile = [[NXOfflineFileManager sharedInstance]  getProjectFilePartner:file];
    }else if (file.sorceType == NXFileBaseSorceTypeMyVaultFile) {
        originalSourceFile = [[NXOfflineFileManager sharedInstance] getMyVaultFilePartner:file];
    }else if (file.sorceType == NXFileBaseSorceTypeShareWithMe) {
        originalSourceFile = [[NXOfflineFileManager sharedInstance] getSharedWithMeFilePartner:file];
    }else if (file.sorceType == NXFileBaseSorceTypeWorkSpace) {
        originalSourceFile = [[NXOfflineFileManager sharedInstance] getWorkSpaceFilePartner:file];
    }else if (file.sorceType == NXFileBaseSorceTypeSharedWithProject) {
        originalSourceFile = [[NXOfflineFileManager sharedInstance] getShareWithProjectFilePartner:file];
    }
    
    NSAssert(originalSourceFile, @"Should have one source file!!");
    
    NSDate *nowDate = [NXTimeServerManager sharedInstance].currentServerTime;
    
    [[NXOfflineFileManager sharedInstance].webFileManager downloadFile:(NXFileBase<NXWebFileDownloadItemProtocol>*)originalSourceFile withProgress:progressBlock isOffline:YES forOffline:NO completed:^(NXFileBase *downloadedFile, NSData *fileData, NSError *error) {
        StrongObj(self);
         if (downloadedFile && downloadedFile.localPath.length >0) {
//             NXOfflineFile *curOfflineFile = [file copy];
//             curOfflineFile.localPath = downloadedFile.localPath;
             originalSourceFile.localPath = downloadedFile.localPath;
             
             NSString *operationId = [[NXOfflineFileManager sharedInstance].offlineFileRightsManager queryRightsForFile:originalSourceFile completed:^(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray<NXWatermarkWord *> *waterMarkWords, NSString *owner, BOOL isOwner, NSError *error) {
                 if (error) {
                     NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc]init];
                     model.duid = duid;
                     model.owner = owner;
                     model.operation = [NSNumber numberWithInteger:kViewOperation];
                     model.repositoryId = @"";
                     model.filePathId = file.fullServicePath;
                     model.filePath = file.fullServicePath;
                     model.fileName = file.fullServicePath;
                     model.activityData = @"TestData";
                     model.accessTime = [NSNumber numberWithLongLong:([nowDate timeIntervalSince1970] * 1000)];
                     model.accessResult = [NSNumber numberWithInteger:0];
                     
                     NXLogAPI *logAPI = [[NXLogAPI alloc]init];
                     [logAPI generateRequestObject:model];
                     [[NXSyncHelper sharedInstance] cacheRESTAPI:logAPI cacheURL:[NXCacheManager getLogCacheURL]];
                     [[NXSyncHelper sharedInstance] uploadPreviousFailedRESTRequestWithCachedURL:[NXCacheManager getLogCacheURL] mustAllSuccess:NO Complection:^(id object, NSError *error) {
                     }];
                     [self.fileLogManager insertNXLFileActivity:model];
                     
                     completion(nil,nil,nil,nil,nil,NO,error);
                     return;
                 }else{
                     if ((classifications.count ==0 && !isOwner) || classifications.count > 0 || (classifications.count ==0 && file.sorceType == NXFileBaseSorceTypeProject)) {
                         NXLFileValidateDateModel *fileValidateDate = [rights getVaildateDateModel];
                         if(fileValidateDate.type != NXLFileValidateDateModelTypeNeverExpire) {
                             NSDate *nowDate = [[NXTimeServerManager sharedInstance] currentServerTime];
                             if (nowDate == nil) {
                                 NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_DECRYPT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_NO_TIME_SERVER", nil)}];
                                 completion(nil,nil,nil, nil, nil, NO, error);
                                 return;
                             }
                             BOOL isValidateDate = [fileValidateDate checkInValidateDateRange:nowDate];
                             if (!isValidateDate) {
                                 NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_DECRYPT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_NO_ACCESS_RIGHT", nil)}];
                                 completion(nil,nil,nil, nil, nil, NO, error);
                                 // send log
                                 NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc]init];
                                 model.duid = duid;
                                 model.owner = owner;
                                 model.operation = [NSNumber numberWithInteger:kViewOperation];
                                 model.repositoryId = @"";
                                 model.filePathId = file.fullServicePath;
                                 model.filePath = file.fullServicePath;
                                 model.fileName = file.fullServicePath;
                                 model.activityData = @"TestData";
                                 model.accessTime = [NSNumber numberWithLongLong:([nowDate timeIntervalSince1970] * 1000)];
                                 model.accessResult = [NSNumber numberWithInteger:0];
                                 
                                 NXLogAPI *logAPI = [[NXLogAPI alloc]init];
                                 [logAPI generateRequestObject:model];
                                 [[NXSyncHelper sharedInstance] cacheRESTAPI:logAPI cacheURL:[NXCacheManager getLogCacheURL]];
                                 [[NXSyncHelper sharedInstance] uploadPreviousFailedRESTRequestWithCachedURL:[NXCacheManager getLogCacheURL] mustAllSuccess:NO Complection:^(id object, NSError *error) {
                                 }];
                                 [self.fileLogManager insertNXLFileActivity:model];
                                 return;
                             }
                         }
                         
                         if (![rights ViewRight]) {
                             NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_DECRYPT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_NO_ACCESS_RIGHT", nil)}];
                             completion(nil, nil, nil, nil, nil, NO, error);
                             // send log
                             NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc] init];
                             model.duid = duid;
                             model.owner = owner;
                             model.operation = [NSNumber numberWithInteger:kViewOperation];
                             model.repositoryId = @"";
                             model.filePathId = file.fullServicePath;
                             model.filePath = file.fullServicePath;
                             model.fileName = file.fullServicePath;
                             model.activityData = @"TestData";
                             model.accessTime = [NSNumber numberWithLongLong:([nowDate timeIntervalSince1970] * 1000)];
                             model.accessResult = [NSNumber numberWithInteger:0];
                             
                             NXLogAPI *logAPI = [[NXLogAPI alloc]init];
                             [logAPI generateRequestObject:model];
                             [[NXSyncHelper sharedInstance] cacheRESTAPI:logAPI cacheURL:[NXCacheManager getLogCacheURL]];
                             [[NXSyncHelper sharedInstance] uploadPreviousFailedRESTRequestWithCachedURL:[NXCacheManager getLogCacheURL] mustAllSuccess:NO Complection:^(id object, NSError *error) {
                             }];
                             [self.fileLogManager insertNXLFileActivity:model];
                             return;
                         };
                     }
                     
                     // step3. get file token
                     [self.offlineFileTokenManager getTokenForFile:originalSourceFile completedBlock:^(NSString *token, NXFileBase *file, NSError *error) {
                         
                         if (error || !token) {
                             completion(nil,nil,nil,nil,nil,NO,error);
                             // send log
                             NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc]init];
                             model.duid = duid;
                             model.owner = owner;
                             model.operation = [NSNumber numberWithInteger:kViewOperation];
                             model.repositoryId = @"";
                             model.filePathId = file.fullServicePath;
                             model.filePath = file.fullServicePath;
                             model.fileName = file.fullServicePath;
                             model.activityData = @"TestData";
                             model.accessTime = [NSNumber numberWithLongLong:([nowDate timeIntervalSince1970] * 1000)];
                             model.accessResult = [NSNumber numberWithInteger:0];
                             
                             NXLogAPI *logAPI = [[NXLogAPI alloc]init];
                             [logAPI generateRequestObject:model];
                             [[NXSyncHelper sharedInstance] cacheRESTAPI:logAPI cacheURL:[NXCacheManager getLogCacheURL]];
                             [[NXSyncHelper sharedInstance] uploadPreviousFailedRESTRequestWithCachedURL:[NXCacheManager getLogCacheURL] mustAllSuccess:NO Complection:^(id object, NSError *error) {
                             }];
                             [self.fileLogManager insertNXLFileActivity:model];
                             
                             return ;
                         }else{
                             
                             // step4. decrypte offline file
                             WeakObj(self);
                             [NXLMetaData decryptNXLOfflineFileWithPolicySection:originalSourceFile.localPath destPath:destPath tokenValue:token duid:duid complete:^(NSError *error, NSString *destPath) {
                                 StrongObj(self);
                                 if (self) {
                                     if (error) {
                                         if (error.code == NXLSDKErrorNOTPermission || error.code == 403) {
                                             error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_DECRYPT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_NO_ACCESS_RIGHT", nil)}];
                                             // send log
                                             NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc]init];
                                             model.duid = duid;
                                             model.owner = owner;
                                             model.operation = [NSNumber numberWithInteger:kViewOperation];
                                             model.repositoryId = @"";
                                             model.filePathId = file.fullServicePath;
                                             model.filePath = file.fullServicePath;
                                             model.fileName = file.fullServicePath;
                                             model.activityData = @"TestData";
                                             model.accessTime = [NSNumber numberWithLongLong:([nowDate timeIntervalSince1970] * 1000)];
                                             model.accessResult = [NSNumber numberWithInteger:0];
                                             
                                             NXLogAPI *logAPI = [[NXLogAPI alloc]init];
                                             [logAPI generateRequestObject:model];
                                             [[NXSyncHelper sharedInstance] cacheRESTAPI:logAPI cacheURL:[NXCacheManager getLogCacheURL]];
                                             [[NXSyncHelper sharedInstance] uploadPreviousFailedRESTRequestWithCachedURL:[NXCacheManager getLogCacheURL] mustAllSuccess:NO Complection:^(id object, NSError *error) {
                                             }];
                                             [self.fileLogManager insertNXLFileActivity:model];
                                         }
                                         completion(nil, nil, nil, nil, nil, NO, error);
                                     }else{
                                         // decrypte offline file success
                                         NSLog(@"NXOfflineFileManager:decrypt offline file->%@ success!!!!",file.name);
                                         completion(destPath,duid,rights,classifications,owner,isOwner,error);
                                         
                                         // send log
                                         NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc]init];
                                         model.duid = duid;
                                         model.owner = owner;
                                         model.operation = [NSNumber numberWithInteger:kViewOperation];
                                         model.repositoryId = @"";
                                         model.filePathId = file.fullServicePath;
                                         model.filePath = file.fullServicePath;
                                         model.fileName = file.fullServicePath;
                                         model.activityData = @"TestData";
                                         model.accessTime = [NSNumber numberWithLongLong:([nowDate timeIntervalSince1970] * 1000)];
                                         model.accessResult = [NSNumber numberWithInteger:1];
                                         
                                         NXLogAPI *logAPI = [[NXLogAPI alloc]init];
                                         [logAPI generateRequestObject:model];
                                         [[NXSyncHelper sharedInstance] cacheRESTAPI:logAPI cacheURL:[NXCacheManager getLogCacheURL]];
                                         [[NXSyncHelper sharedInstance] uploadPreviousFailedRESTRequestWithCachedURL:[NXCacheManager getLogCacheURL] mustAllSuccess:NO Complection:^(id object, NSError *error) {
                                         }];
                                         [self.fileLogManager insertNXLFileActivity:model];
                                     }
                                 }
                             }];
                         }
                     }];
                 }
             }];
             NSLog(@"queryOfflineFileRightsOperationId:%@------",operationId);
         }else{
             NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NOSUCHFILE userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_PARAMETER_INVALID", nil)}];
             completion(nil, nil, nil, nil, nil, NO, error);
             return;
         }

     }];
}

- (void)canDoOperation:(NXLRIGHT)operationType forFile:(NXOfflineFile *)file withCompletion:(offlineFileOptCanDoOperationCompletion)completion
{
    NSDate *nowDate = [NXTimeServerManager sharedInstance].currentServerTime;
    WeakObj(self);
    [self.offlineFileRightsManager queryRightsForFile:file completed:^(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray<NXWatermarkWord *> *waterMarkWords, NSString *owner, BOOL isOwner, NSError *error) {
        StrongObj(self);
        if (error) {
            completion(nil, nil, nil, nil, NO, error);
            return;
        }else{
                // check expire date
                if (!isOwner && [rights getVaildateDateModel].type != NXLFileValidateDateModelTypeNeverExpire) {
                    NSDate *nowDate = [[NXTimeServerManager sharedInstance] currentServerTime];
                    if (nowDate == nil) {
                        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_DECRYPT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_NO_TIME_SERVER", nil)}];
                        completion(nil, nil, nil, nil, NO, error);
                        return;
                    }
                    
                    BOOL isValidateDate = [[rights getVaildateDateModel] checkInValidateDateRange:nowDate];
                    if (!isValidateDate) {
                        completion(NO, duid, [rights copy],nil, NO, nil);
                        if (operationType != NXLRIGHTSHARING) { // share will do log at RMS
                            NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc]init];
                            model.duid =duid;
                            model.owner = owner;
                            model.operation = [[NXLoginUser sharedInstance].nxlOptManager nxlRightToLogRight:operationType];
                            model.repositoryId = @"";
                            model.filePathId = file.fullServicePath;
                            model.filePath = file.fullServicePath;
                            model.fileName = file.fullServicePath;
                            model.activityData = @"TestData";
                            model.accessTime = [NSNumber numberWithLongLong:([nowDate timeIntervalSince1970] * 1000)];
                            model.accessResult = [NSNumber numberWithInteger:0];
                            NXLogAPI *logAPI = [[NXLogAPI alloc]init];
                            [logAPI generateRequestObject:model];
                            [[NXSyncHelper sharedInstance] cacheRESTAPI:logAPI cacheURL:[NXCacheManager getLogCacheURL]];
                            [[NXSyncHelper sharedInstance] uploadPreviousFailedRESTRequestWithCachedURL:[NXCacheManager getLogCacheURL] mustAllSuccess:NO Complection:^(id object, NSError *error) {
                                
                            }];
                            [self.fileLogManager insertNXLFileActivity:model];
                        }
                        return;
                    }
                }
                    
                    // if rights is in expire time range, just check rights
                    if ([rights getRight:operationType] || isOwner) {
                        completion(YES, duid, [rights copy], owner, isOwner, nil);
                        if (operationType != NXLRIGHTSHARING) { // share will do log at RMS
                            NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc]init];
                            model.duid = duid;
                            model.owner = owner;
                            model.operation = [[NXLoginUser sharedInstance].nxlOptManager nxlRightToLogRight:operationType];
                            model.repositoryId = @"";
                            model.filePathId = file.fullServicePath;
                            model.filePath = file.fullServicePath;
                            model.fileName = file.fullServicePath;
                            model.activityData = @"TestData";
                            model.accessTime = [NSNumber numberWithLongLong:([nowDate timeIntervalSince1970] * 1000)];
                            model.accessResult = [NSNumber numberWithInteger:1];
                            NXLogAPI *logAPI = [[NXLogAPI alloc]init];
                            [logAPI generateRequestObject:model];
                            [[NXSyncHelper sharedInstance] cacheRESTAPI:logAPI cacheURL:[NXCacheManager getLogCacheURL]];
                            [[NXSyncHelper sharedInstance] uploadPreviousFailedRESTRequestWithCachedURL:[NXCacheManager getLogCacheURL] mustAllSuccess:NO Complection:^(id object, NSError *error) {
                                
                            }];
                            [self.fileLogManager insertNXLFileActivity:model];
                        }
                        
                    }else{
                        completion(NO, duid, [rights copy], nil, NO, nil);
                        // send deny log
                        NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc]init];
                        model.duid = duid;
                        model.owner = owner;
                        model.operation = [[NXLoginUser sharedInstance].nxlOptManager nxlRightToLogRight:operationType];
                        model.repositoryId = @"";
                        model.filePathId = file.fullServicePath;
                        model.filePath = file.fullServicePath;
                        model.fileName = file.fullServicePath;
                        model.activityData = @"TestData";
                        model.accessTime = [NSNumber numberWithLongLong:([nowDate timeIntervalSince1970] * 1000)];
                        model.accessResult = [NSNumber numberWithInteger:0];
                        NXLogAPI *logAPI = [[NXLogAPI alloc]init];
                        [logAPI generateRequestObject:model];
                        [[NXSyncHelper sharedInstance] cacheRESTAPI:logAPI cacheURL:[NXCacheManager getLogCacheURL]];
                        [[NXSyncHelper sharedInstance] uploadPreviousFailedRESTRequestWithCachedURL:[NXCacheManager getLogCacheURL] mustAllSuccess:NO Complection:^(id object, NSError *error) {
                            
                        }];
                        [self.fileLogManager insertNXLFileActivity:model];
                    }
                }
    }];
}

- (void)refreshOfflineFileList:(NSArray *)fileList
                withCompletion:(refreshOfflineFileListCompletdBlock)completion
{
    // need rms batch api support
}

- (NXOfflineFile *)getOfflineFilePartner:(NXFileBase *)file
{
    return [NXOfflineFileStorage getOfflineFileItem:file];
}

- (void)queryRightsForFile:(NXFileBase *)file
            withCompletion:(queryRightsCompletedBlock)completion
{
    [self.offlineFileRightsManager queryRightsForFile:file completed:^(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray<NXWatermarkWord *> *waterMarkWords, NSString *owner, BOOL isOwner, NSError *error) {
        if (error) {
            completion(duid,rights,classifications,waterMarkWords,owner,isOwner,error);
        }else{
             completion(duid,rights,classifications,waterMarkWords,owner,isOwner,nil);
        }
    }];
}

- (void)refreshOfflineFileExpireDate:(NXOfflineFile *)file withCompletion:(refreshOfflineFileExpireDateCompletedBlock)completion
{
    WeakObj(self);
    NSString *refreshRightsOptId =  [self.offlineFileRightsManager refreshRightsForFile:file completed:^(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray<NXWatermarkWord *> *waterMarkWords, NSString *owner, BOOL isOwner, NSError *error) {
        [self.refreshOfflineFileRightsOptKeyArray removeObjectForKey:file.fileKey];
        StrongObj(self);
        if (error) {
            completion(error);
        }else{
           NSString *refreshTokenOptId =  [self.offlineFileTokenManager refreshTokenForFile:file completedBlock:^(NXFileBase *file, NSError *error) {
                [self.refreshOfflineFileTokenOptKeyArray removeObjectForKey:[NXCommonUtils fileKeyForFile:file]];
                if (error) {
                    completion(error);
                }else{
                    NXOfflineFile *newOfflineFile = [file copy];
                    newOfflineFile.markAsOfflineDate = [NSDate date];
                    [NXOfflineFileStorage insertNewOfflineFileItem:newOfflineFile];
                    completion(nil);
                }
            }];
            [self.refreshOfflineFileTokenOptKeyArray setObject:refreshTokenOptId forKey:file.fileKey];
        }
    }];
    [self.refreshOfflineFileRightsOptKeyArray setObject:refreshRightsOptId forKey:file.fileKey];
}

- (void)cancelRefreshOfflineFileExpireDateOpt:(NXFileBase *)file
{
    NSString *fileKey;
    if ([file isKindOfClass:[NXOfflineFile class]]) {
        NXOfflineFile *off = (NXOfflineFile *)file;
        fileKey = off.fileKey;
    }else{
        fileKey =  [NXCommonUtils fileKeyForFile:file];
    }
    NSString *refreshOptId = [self.refreshOfflineFileRightsOptKeyArray objectForKey:fileKey];
    NSLog(@"cancelRefresh->Rights:%@======filekey%@:========%@",file.name,fileKey,refreshOptId);
    if (refreshOptId) {
        NSLog(@"cancelRefreshSuccess!!!!->Rights:%@==============%@",file.name,refreshOptId);
        [self.offlineFileRightsManager cancelOperation:refreshOptId];
    }
    NSString *refreshTokenOptId = [self.refreshOfflineFileTokenOptKeyArray objectForKey:fileKey];
    NSLog(@"cancelRefresh->Token%@==============%@",file.name,refreshTokenOptId);
    if (refreshTokenOptId) {
        [self.offlineFileTokenManager cancel:refreshTokenOptId];
          NSLog(@"cancelRefreshsuccess!!!!->Token%@==============%@",file.name,refreshTokenOptId);
    }
}

- (NXMyVaultFile *)getMyVaultFilePartner:(NXOfflineFile *)offlineFile
{
    return [NXOfflineFileStorage getMyVaultFilePartner:offlineFile];
}

- (NXProjectFile *)getProjectFilePartner:(NXOfflineFile *)offlineFile
{
    return [NXOfflineFileStorage getProjectFilePartner:offlineFile];
}

- (NXSharedWithMeFile *)getSharedWithMeFilePartner:(NXOfflineFile *)offlineFile
{
    return [NXOfflineFileStorage getSharedWithMeFilePartner:offlineFile];
}

- (NXWorkSpaceFile *)getWorkSpaceFilePartner:(NXOfflineFile *)offlineFile {
    return [NXOfflineFileStorage getWorkSpaceFilePartner:offlineFile];
}

- (NXSharedWithProjectFile *)getShareWithProjectFilePartner:(NXOfflineFile *)offlineFile{
    return [NXOfflineFileStorage getShareWithProjectFilePartner:offlineFile];
}

- (void)addToConvertOfflineFileSet:(NSString *)fileKey
{
    [self.isConvertingToOfflineFileKeySet addObject:fileKey];
}

- (void)removeFromConvertOfflineFileSet:(NSString *)fileKey
{
    [self.isConvertingToOfflineFileKeySet removeObject:fileKey];
}

- (void)updateOfflineFileMarkAsOfflineDate:(NXOfflineFile *)file
{
    [NXOfflineFileStorage updateOfflineFileItem:file];
}

- (BOOL)checkIsExpire:(NXOfflineFile *)offlineFile{
    
    NSDate *expireDate = [self.dateHelper addToDate:offlineFile.markAsOfflineDate days:OFFLINE_FILE_LOACL_EXPIRE_TIME];
    NSDate *currentDate = [NSDate date];
    return [self.dateHelper date:currentDate isAfter:expireDate];
}

- (void)refreshTokenForFile:(NXFileBase *)file
             withCompletion:(refreshOfflineFileTokenCompletedBlock)completion{
   NSString *refreshTokenOptId = [self.offlineFileTokenManager refreshTokenForFile:file completedBlock:^(NXFileBase *file, NSError *error) {
         NSLog(@"refreshTokenOptID removed from dic!!!!!!");
        [self.refreshOfflineFileTokenOptKeyArray removeObjectForKey:[NXCommonUtils fileKeyForFile:file]];
        if (error) {
            completion(file,error);
        }else{
            completion(file,nil);
        }
    }];
    
    NSLog(@"----->>>>>>>>RefreshOfflineExpireTime:%@----fileKey:%@---->refreshTokenOptId->>>>z%@",file.name,[NXCommonUtils fileKeyForFile:file],refreshTokenOptId);
    [self.refreshOfflineFileTokenOptKeyArray setObject:refreshTokenOptId forKey:[NXCommonUtils fileKeyForFile:file]];
}

- (void)refreshRightsForFile:(NXFileBase *)file
           withCompletion:(refreshOfflineFileRightsCompletedBlock)completion{
   NSString *refreshRightsOptId = [self.offlineFileRightsManager refreshRightsForFile:file completed:^(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray<NXWatermarkWord *> *waterMarkWords, NSString *owner, BOOL isOwner, NSError *error) {
         NSLog(@"refreshOfflineFileRightsOptID removed from dic!!!!!!");
       [self.refreshOfflineFileRightsOptKeyArray removeObjectForKey:[NXCommonUtils fileKeyForFile:file]];
        if (error) {
            completion(file,error);
        }else{
            completion(file,nil);
        }
    }];
    NSLog(@"RefreshOfflineExpireTime:%@---filekey:%@----->refreshRightsOptId-->>>%@",file.name,[NXCommonUtils fileKeyForFile:file],refreshRightsOptId);
    [self.refreshOfflineFileRightsOptKeyArray setObject:refreshRightsOptId forKey:[NXCommonUtils fileKeyForFile:file]];
}

- (void)updateLastModifyDate:(NXFileBase *)file {
    if (![[NXNetworkHelper sharedInstance] isNetworkAvailable]) {
        return;
    }
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    [file queryLastModifiedDate:^(NSDate *lastModifiedDate, NSError *error) {
        if (!error && lastModifiedDate) {
            // update file lastModifiedDate
            file.lastModifiedDate = lastModifiedDate;
        }
        dispatch_semaphore_signal(semaphore);
    }];
    // wait no more than 5 seconds.
    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC);
    dispatch_semaphore_wait(semaphore, timeout);
}

#pragma -mark -private method
- (void)clearUpTokenForFile:(NXOfflineFile *)file{
    [self.offlineFileTokenManager deleteTokenForFile:file];
}

-(void)clearUpRightsForFile:(NXOfflineFile *)file{
    [self.offlineFileRightsManager clearCachedRightsForFile:file];
}

#pragma -mark -tool method
- (NSString *)getTempFilePathWithForFile:(NXOfflineFile *)file error:(NSError **)Error
{
    NSString *tmpPath = [NXCommonUtils getConvertFileTempPath];
    
    if (file.name && file.name.length > 0) {
        tmpPath = [tmpPath stringByAppendingPathComponent:[file.name lastPathComponent]];
    }
    else
    {
        if (file.localPath.lastPathComponent.length > 0) {
            file.name = file.localPath.lastPathComponent;
        }
        tmpPath = [tmpPath stringByAppendingPathComponent:[file.name lastPathComponent]];
    }
    
    // there get file token from RMS, may failed for no right or network error
    NSString *fileExtension = [self getFileExtensionByFileName:file];
    tmpPath = [tmpPath stringByAppendingPathExtension:fileExtension];
    return tmpPath;
}

- (NSString *)getFileExtensionByFileName:(NXFileBase *)file
{
    NSString *fileExtension = file.name.pathExtension;
    if ([fileExtension compare:NXL options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        fileExtension = [file.name stringByDeletingPathExtension].pathExtension;
    }
    return fileExtension;
}


@end
