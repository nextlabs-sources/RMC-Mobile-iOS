//
//  NXNXLOperationManager.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 7/3/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXNXLOperationManager.h"
#import "NXRMCDef.h"
#import "NXLMetaData.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXSyncHelper.h"
#import "NXCacheManager.h"
#import "NXLSDKDef.h"
#import "NXSharingRepositoryAPI.h"
#import "NXUpdateSharingRecipientsAPI.h"
#import "NXMyVaultMetadataAPI.h"
#import "NXProjectFileMetaDataAPI.h"
#import "NXWebFileManager.h"
#import "NXSharedWithMeFile.h"
#import "NXSharedWithMeReshareFileOperation.h"
#import "NSString+NXExt.h"
#import "NXTimeServerManager.h"
#import "NXMBManager.h"
#import "NXPerformPolicyEvaluationAPI.h"
#import "NXLFileValidateDateModel.h"
#import "NXLClient.h"
#import "NXLRights.h"
#import "NXNXLFileLogManager.h"
#import "NXWorkSpaceUploadFileAPI.h"
#import "NXSharedFileUpateRecipientsOperation.h"
#import "NXProjectFileSharingOperation.h"
#import "NXRevokingSharedFileOperation.h"
#import "NXCopyNxlFileOperation.h"
#import "NXSaveAsToLocalOperation.h"
#import "NXSharedWorkspaceFile.h"
#import "NXAddLocalNXLFileToOtherSpaceOperation.h"
#import "NXPolicyTransFormForCopyOperation.h"

#define NXL_NO_VIEW_RIGHT @"NXL_NO_VIEW_RIGHT"
#define MAX_SERVER_POLICY_LIFE 300 // 5min
typedef void(^AddRightBlock)(NXLRights *rights);


@interface NXNXLOptCacheNode : NSObject
@property(nonatomic, strong) NSString *DUID;
@property(nonatomic, strong) NSArray <NXWatermarkWord *> *waterMarkContent;
@property(nonatomic, strong) NSArray<NXClassificationCategory *> *classification;
@property(nonatomic, strong) NXLRights *rights;
@property(nonatomic, strong) NSString *ownerId;
@property(nonatomic, strong) NSDate *cacheDate;
- (instancetype)initWithDUID:(NSString *)duid rights:(NXLRights *)rights ownerID:(NSString *)ownerId;
@end;

@implementation NXNXLOptCacheNode
- (instancetype)initWithDUID:(NSString *)duid rights:(NXLRights *)rights ownerID:(NSString *)ownerId
{
    if (self = [super init]) {
        _DUID = duid;
        _rights = rights;
        _ownerId = ownerId;
    }
    return self;
}

- (instancetype)initWithDUID:(NSString *)duid rights:(NXLRights *)rights classification:(NSArray<NXClassificationCategory *> *) classification cacheDate:(NSDate *)cacheDate ownerId:(NSString *)ownerId
{
    if (self = [super init]) {
        _DUID = duid;
        _classification = classification;
        _ownerId = ownerId;
        _cacheDate = cacheDate;
        _rights = rights;
    }
    return self;
}

@end

// stand for Enrypt file operation
@interface NXEncryptFileOperation : NSOperation
@property(nonatomic, strong) NSString *uploadMyVaultIdentify;
@end
@implementation NXEncryptFileOperation
- (void)cancel
{
    [[NXLoginUser sharedInstance].myVault cancelOperation:self.uploadMyVaultIdentify];
}
@end

@interface NXEncryptProjectFileOperation : NSOperation
@property(nonatomic, strong) NSString *uploadProjectIdentify;
@end

@implementation NXEncryptProjectFileOperation
- (void)cancel {
    [[NXLoginUser sharedInstance].myProject cancelOperation:self.uploadProjectIdentify];

}
@end
@interface NXEncryptworkspaceFileOperation : NSOperation
@property(nonatomic, strong) NSString *uploadProjectIdentify;
@end

@implementation NXEncryptworkspaceFileOperation
- (void)cancel {
    [[NXLoginUser sharedInstance].workSpaceManager cancelOperation:self.uploadProjectIdentify];

}
@end


// stand for sharing file operation
@interface NXShareFileOperation : NSOperation
@property(nonatomic, strong) NSString *shareFileIdentify;
@end

@implementation NXShareFileOperation
- (void)cancel{
    [[NXLClient currentNXLClient:nil] cancelOperation:self.shareFileIdentify];
}
@end


@interface NXNXLOperationManager()
@property(nonatomic, strong) NXLClient *nxlClient;
@property(nonatomic, strong) NSCache *nxlCache; // key: fileID vaule: NXNXLOptCacheNode // for adhoc
@property(nonatomic, strong) NSMutableDictionary*isCenterPolicyFileCachedRightsDic;
@property(nonatomic, strong) NSDictionary *parseRightsDict;
@property(nonatomic, strong) NSMutableDictionary *completeBlockDict;
@property(nonatomic, strong) NSMutableDictionary *operationDict;
@property(nonatomic, strong) NSDictionary *nxlRightToLogRightDict;
@property(nonatomic, strong) NXNXLFileLogManager *fileLogManager;
@end

@implementation NXNXLOperationManager
- (instancetype)initWithNXProfile:(NXLProfile *)profile
{
    if (self = [super init]) {
        _nxlClient = [[NXLClient alloc] initWithNXProfile:profile tenantID:profile.defaultTenantID tenantName:profile.defaultTenant];
        _nxlCache = [[NSCache alloc] init];
        _isCenterPolicyFileCachedRightsDic = [[NSMutableDictionary alloc] init];
        AddRightBlock addViewRight = ^(NXLRights *rights){
            [rights setRight:NXLRIGHTVIEW value:YES];
        };
        AddRightBlock addEditRight = ^(NXLRights *rights){
            [rights setRight:NXLRIGHTEDIT value:YES];
        };
        AddRightBlock addPrintRight = ^(NXLRights *rights){
            [rights setRight:NXLRIGHTPRINT value:YES];
        };
        AddRightBlock addClipBoardRight = ^(NXLRights *rights){
            [rights setRight:NXLRIGHTCLIPBOARD value:YES];
        };
        AddRightBlock addSaveAsRight = ^(NXLRights *rights){
            [rights setRight:NXLRIGHTSAVEAS value:YES];
        };
        AddRightBlock addDecryptRight = ^(NXLRights *rights){
            [rights setRight:NXLRIGHTDECRYPT value:YES];
        };
        AddRightBlock addScreenCapRight = ^(NXLRights *rights){
            [rights setRight:NXLRIGHTSCREENCAP value:YES];
        };
        AddRightBlock addSendRight = ^(NXLRights *rights){
            [rights setRight:NXLRIGHTSEND value:YES];
        };
        AddRightBlock addClassifyRight = ^(NXLRights *rights){
            [rights setRight:NXLRIGHTCLASSIFY value:YES];
        };
        AddRightBlock addSharingRight = ^(NXLRights *rights){
            [rights setRight:NXLRIGHTSHARING value:YES];
        };
        AddRightBlock addDownloadRight = ^(NXLRights *rights){
            [rights setRight:NXLRIGHTSDOWNLOAD value:YES];
        };
        
        AddRightBlock addWaterMarkRight = ^(NXLRights *rights){
            [rights setObligation:NXLOBLIGATIONWATERMARK value:YES];
        };
        
        _parseRightsDict = @{@"VIEW":addViewRight,
                             @"EDIT":addEditRight,
                             @"PRINT":addPrintRight,
                             @"CLIPBOARD":addClipBoardRight,
                             @"SAVEAS":addSaveAsRight,
                             @"DECRYPT":addDecryptRight,
                             @"SCREENCAP":addScreenCapRight,
                             @"SEND":addSendRight,
                             @"CLASSIFY":addClassifyRight,
                             @"SHARE":addSharingRight,
                             @"DOWNLOAD":addDownloadRight,
                             @"WATERMARK":addWaterMarkRight};
        
        _nxlRightToLogRightDict = @{[NSNumber numberWithLong:NXLRIGHTVIEW]:[NSNumber numberWithLong:kViewOperation],
                                    [NSNumber numberWithLong:NXLRIGHTEDIT]:[NSNumber numberWithLong:kEditSaveOperation],
                                    [NSNumber numberWithLong:NXLRIGHTPRINT]:[NSNumber numberWithLong:kPrintOpeartion],
                                    [NSNumber numberWithLong:NXLRIGHTCLIPBOARD]:[NSNumber numberWithLong:kCopyContentOpeartion],
                                    [NSNumber numberWithLong:NXLRIGHTDECRYPT]:[NSNumber numberWithLong:kDecryptOperation],
                                    [NSNumber numberWithLong:NXLRIGHTSCREENCAP]:[NSNumber numberWithLong:kCaptureScreenOpeartion],
                                    [NSNumber numberWithLong:NXLRIGHTCLASSIFY]:[NSNumber numberWithLong:kClassifyOperation],
                                    [NSNumber numberWithLong:NXLRIGHTSHARING]:[NSNumber numberWithLong:kReshareOperation], // NOTE, THERE IS RESHARE for deny log(Steward share will never deny, so only other people share file will deny, it is treated as reshare)
                                    [NSNumber numberWithLong:NXLRIGHTSDOWNLOAD]:[NSNumber numberWithLong:kDownloadOperation],};
        
        _completeBlockDict = [[NSMutableDictionary alloc] init];
        _operationDict = [[NSMutableDictionary alloc] init];
        _fileLogManager = [[NXNXLFileLogManager alloc] init];
    }
    return self;
}

#pragma mark -
+ (NXLClient *)currentNXLClient:(NSError **)error
{
    return [NXLClient currentNXLClient:error];
}

- (void)downloadAndEncryptMultipleFile:(NSArray *)filesArray  permissions:(NXLRights *)permissions membershipId:(NSString *)memberShipId  withComplection:(nxlOptEncryptMultipleFilesCompletion)completion{
    NSMutableArray *successArray = [NSMutableArray array];
    NSMutableArray *failArray = [NSMutableArray array];
    
    dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);

// 2.异步执行任务
    dispatch_async(serialQueue, ^{
        for (NXFileBase *fileItem in filesArray) {
            [[NXWebFileManager sharedInstance] downloadFile:(NXFileBase<NXWebFileDownloadItemProtocol>*)fileItem withProgress:nil completed:^(NXFileBase *file, NSData *fileData, NSError *error) {
                NSString *tmpPath = [NXCommonUtils createNewNxlTempFile:file.name];
                NSDate *currentServerDate = [[NXTimeServerManager sharedInstance] currentServerTime];
                if (!error) {
                    [self onlyEncryptToNXLFile:file toPath:tmpPath permissions:permissions membershipId:memberShipId createDate:currentServerDate withCompletion:^(NSString *filePath, NSError *error1) {
                        if (!error1) {
                            NXFileBase *file = [[NXFile alloc] init];
                            file.localPath = filePath;
                            file.name = [filePath lastPathComponent];
                            [successArray addObject:file];
                        }else{
                            fileItem.name = [NSString stringWithFormat:@"%@%@",fileItem.name,@".nxl"];
                            fileItem.localPath = error1.localizedDescription;
                            [failArray addObject:fileItem];
                        }
                        if (successArray.count + failArray.count == filesArray.count) {
                            if (completion) {
                                completion(successArray,failArray,nil);
                            }
                        }
                        
                    }];
                    
                }else {
                    fileItem.name = [NSString stringWithFormat:@"%@%@",fileItem.name,@".nxl"];
                    fileItem.localPath = error.localizedDescription;
                    [failArray addObject:fileItem];
                    if (successArray.count + failArray.count == filesArray.count) {
                        if (completion) {
                            completion(successArray,failArray,nil);
                        }
                    }
                    
                }
                        
            }];
        }
    });
   
}
- (void)downloadAndEncryptMultipleFile:(NSArray *)filesArray classifications:(NSArray<NXClassificationCategory *> *)classifications membershipId:(NSString *)memberShipId  withComplection:(nxlOptEncryptMultipleFilesCompletion)completion;{
    NSMutableArray *successArray = [NSMutableArray array];
    NSMutableArray *failArray = [NSMutableArray array];
    
    dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);

// 2.异步执行任务
    dispatch_async(serialQueue, ^{
        for (NXFileBase *fileItem in filesArray) {
            [[NXWebFileManager sharedInstance] downloadFile:(NXFileBase<NXWebFileDownloadItemProtocol>*)fileItem withProgress:nil completed:^(NXFileBase *file, NSData *fileData, NSError *error) {
                NSString *tmpPath = [NXCommonUtils createNewNxlTempFile:file.name];
                NSDate *currentServerDate = [[NXTimeServerManager sharedInstance] currentServerTime];
                if (!error) {
                    [self onlyEncryptToNXLFile:file toPath:tmpPath classifications:classifications membershipId:memberShipId createDate:currentServerDate withCompletion:^(NSString *filePath, NSError *error1) {
                        if (!error1) {
                            NXFileBase *file = [[NXFile alloc] init];
                            file.localPath = filePath;
                            file.name = [filePath lastPathComponent];
                            [successArray addObject:file];
                        }else{
                            fileItem.name = [NSString stringWithFormat:@"%@%@",fileItem.name,@".nxl"];
                            fileItem.localPath = error1.localizedDescription;
                            [failArray addObject:fileItem];
                        }
                        if (successArray.count + failArray.count == filesArray.count) {
                            if (completion) {
                                completion(successArray,failArray,nil);
                            }
                        }
                        
                    }];
                    
                }else {
                    fileItem.name = [NSString stringWithFormat:@"%@%@",fileItem.name,@".nxl"];
                    fileItem.localPath = error.localizedDescription;
                    [failArray addObject:fileItem];
                    if (successArray.count + failArray.count == filesArray.count) {
                        if (completion) {
                            completion(successArray,failArray,nil);
                        }
                    }
                    
                }
                        
            }];
        }
        
    });
   
    
}

- (NSString *)onlyEncryptToNXLFile:(NXFileBase *)file toPath:(NSString *)destPath permissions:(NXLRights *)permissions membershipId:(NSString *)memberShipId createDate:(NSDate *)createDate withCompletion:(nxlOptEncryptCompletion)completion{
   
    if (file.localPath && destPath && completion) {
        NSString *operationId = [[NSUUID UUID] UUIDString];
        [self.completeBlockDict setObject:completion forKey:operationId];
        NXEncryptFileOperation *enryptFileOpt = [[NXEncryptFileOperation alloc] init];
        [self.operationDict setObject:enryptFileOpt forKey:operationId];
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [NXLMetaData encrypt:file.localPath destPath:destPath clientProfile:[NXLoginUser sharedInstance].profile rights:permissions membershipId:memberShipId environment:[[permissions getVaildateDateModel] getPolicyFormatJSONDictionary] encryptdDate:createDate complete:^(NSError *error, NSString *enryptedFilePath, id appendInfo) {
             nxlOptEncryptCompletion completionBlock = self.completeBlockDict[operationId];
            if (error) {
                error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_ENCRYPT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_PROCESSING_FILE_FAILED", nil)}];
            }
            dispatch_semaphore_signal(sema);
            if (completionBlock) {
                completionBlock(enryptedFilePath, error);
                [self.completeBlockDict removeObjectForKey:operationId];
                [self.operationDict removeObjectForKey:operationId];
            }
            //do log
            if (!error) {
                NSString *DUID = [((NSDictionary *)appendInfo) allKeys].firstObject;
                                                  // DO Rights Cache
                if ([appendInfo isKindOfClass:[NSDictionary class]]) {
                  
                    NXNXLOptCacheNode *cacheNode = [[NXNXLOptCacheNode alloc] initWithDUID:DUID rights:permissions ownerID:memberShipId?:[NXLoginUser sharedInstance].profile.individualMembership.ID];
                    [self.nxlCache setObject:cacheNode forKey:[NXCommonUtils fileKeyForFile:file]];
                }
          
                NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc] init];
                model.duid = DUID;
                model.owner = memberShipId?:[NXLoginUser sharedInstance].profile.individualMembership.ID;
                model.operation = [NSNumber numberWithInteger:kProtectOperation];
                model.repositoryId = @"";
                model.filePathId = file.fullServicePath;
                model.filePath = file.fullServicePath;
                model.fileName = file.name;
                model.activityData = @"TestData";
                model.accessTime = [NSNumber numberWithLongLong:([createDate timeIntervalSince1970] * 1000)];
                model.accessResult = [NSNumber numberWithInteger:1];
                NXLogAPI *logAPI = [[NXLogAPI alloc] init];
                [logAPI generateRequestObject:model];
                [[NXSyncHelper sharedInstance] cacheRESTAPI:logAPI cacheURL:[NXCacheManager getLogCacheURL]];
                [[NXSyncHelper sharedInstance] uploadPreviousFailedRESTRequestWithCachedURL:[NXCacheManager getLogCacheURL] mustAllSuccess:NO Complection:^(id object, NSError *error) {
                }];
                [self.fileLogManager insertNXLFileActivity:model];
                
            }
          
            
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        return operationId;
    }
    return nil;
}
- (void)encryptAndUploadMultipleFilesToRepo:(NSArray *)filesArray toPath:(NXFileBase *)folder permissions:(NXLRights *)permissions membershipId:(NSString *)memeberShipId withComplection:(nxlOptProtectMultipleCompletion)completion{
    NSMutableArray *successArray = [NSMutableArray array];
    NSMutableArray *failArray = [NSMutableArray array];
    // 1.创建一个串行队列，保证for循环依次执行
            dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);

    // 2.异步执行任务
    dispatch_async(serialQueue, ^{
        // 3.创建一个数目为1的信号量，用于“卡”for循环，等上次循环结束在执行下一次的for循环
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
       
        for (NXFileBase *file in filesArray) {
            [NXLMetaData encrypt:file.localPath destPath:[NXCommonUtils createNewNxlTempFile:file.name] clientProfile:[NXLoginUser sharedInstance].profile rights:permissions membershipId:[NXLoginUser sharedInstance].profile.tenantMembership.ID environment:[[permissions getVaildateDateModel] getPolicyFormatJSONDictionary] encryptdDate:[[NXTimeServerManager sharedInstance] currentServerTime] complete:^(NSError *error, NSString *enryptedFilePath, id appendInfo) {
                dispatch_semaphore_signal(sema);
                if (!error) {
                    NXFileBase *file = [[NXFile alloc] init];
                    file.localPath = enryptedFilePath;
                    file.name = [enryptedFilePath lastPathComponent];
                    [[NXLoginUser sharedInstance].myRepoSystem uploadFile:file.name toPath:folder fromPath:enryptedFilePath uploadType:NXRepositorySysManagerUploadTypeOverWrite overWriteFile:nil progress:nil completion:^(NXFileBase *fileItem, NXFileBase *parentFolder, NSError *error) {
                        if (!error) {
                           
                            [successArray addObject:fileItem];
                        }else{
                            file.name = [NSString stringWithFormat:@"%@%@",file.name,@".nxl"];
                            file.localPath = error.localizedDescription;
                            [failArray addObject:file];
                        }
                        if (successArray.count + failArray.count == filesArray.count) {
                            if (completion) {
                                completion(successArray,failArray,nil);
                            }
                        }
                                        
                    }];
                    
                }else{
                    file.name = [NSString stringWithFormat:@"%@%@",file.name,@".nxl"];
                    file.localPath = error.localizedDescription;
                    [failArray addObject:file];
                    if (successArray.count + failArray.count == filesArray.count) {
                        if (completion) {
                            completion(successArray,failArray,nil);
                        }
                    }
                }
                
            }];
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        }
        
    });
    
    
}
- (void)encryptAndUploadMultipleFilesToRepo:(NSArray *)filesArray toPath:(NXFileBase *)folder classifications:(NSArray<NXClassificationCategory *> *)classifications  membershipId:(NSString *)memeberShipId withComplection:(nxlOptProtectMultipleCompletion)completion{
    NSMutableArray *successArray = [NSMutableArray array];
    NSMutableArray *failArray = [NSMutableArray array];
//    1.创建一个串行队列，保证for循环依次执行
           dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);

   // 2.异步执行任务
   dispatch_async(serialQueue, ^{
       // 3.创建一个数目为1的信号量，用于“卡”for循环，等上次循环结束在执行下一次的for循环
       
      
       for (NXFileBase *file in filesArray) {
           
               NSMutableDictionary *classificaitonDict = [[NSMutableDictionary alloc] init];
               for (NXClassificationCategory *classificationCategory in classifications) {
                   if (classificationCategory.selectedLabs.count > 0) {
                       NSMutableArray *labs = [[NSMutableArray alloc] init];
                       for (NXClassificationLab *classificationLab in classificationCategory.selectedLabs) {
                           NSString *labName = classificationLab.name;
                           [labs addObject:labName];
                       }
                       [classificaitonDict setObject:labs forKey:classificationCategory.name];
                   }
               }
           dispatch_semaphore_t sema = dispatch_semaphore_create(0);
               [NXLMetaData encrypt:file.localPath destPath:[NXCommonUtils createNewNxlTempFile:file.name]  clientProfile:[NXLoginUser sharedInstance].profile membershipId:[NXLoginUser sharedInstance].profile.tenantMembership.ID classifications:classificaitonDict encryptdDate:[[NXTimeServerManager sharedInstance] currentServerTime] complete:^(NSError *error, NSString *enryptedFilePath, id appendInfo) {
                   dispatch_semaphore_signal(sema);
                   if (!error) {
                       NXFileBase *file = [[NXFile alloc] init];
                       file.localPath = enryptedFilePath;
                       file.name = [enryptedFilePath lastPathComponent];
                       [[NXLoginUser sharedInstance].myRepoSystem uploadFile:file.name toPath:folder fromPath:enryptedFilePath uploadType:NXRepositorySysManagerUploadTypeOverWrite overWriteFile:nil progress:nil completion:^(NXFileBase *fileItem, NXFileBase *parentFolder, NSError *error) {
                           if (!error) {
                              
                               [successArray addObject:fileItem];
                           }else{
                               file.name = [NSString stringWithFormat:@"%@%@",file.name,@".nxl"];
                               file.localPath = error.localizedDescription;
                               [failArray addObject:file];
                           }
                           if (successArray.count + failArray.count == filesArray.count) {
                               if (completion) {
                                   completion(successArray,failArray,nil);
                               }
                           }
                                           
                       }];
                       
                   }else{
                       file.name = [NSString stringWithFormat:@"%@%@",file.name,@".nxl"];
                       file.localPath = error.localizedDescription;
                       [failArray addObject:file];
                       if (successArray.count + failArray.count == filesArray.count) {
                           if (completion) {
                               completion(successArray,failArray,nil);
                           }
                       }
                   }
                 
               }];
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        }
       
   });
    
    
}
- (NSString *)onlyEncryptToNXLFile:(NXFileBase *)file toPath:(NSString *)destPath classifications:(NSArray<NXClassificationCategory *> *)classifications membershipId:(NSString *)memberShipId  createDate:(NSDate *)createDate withCompletion:(nxlOptEncryptCompletion)completion{
    if (file.localPath && destPath && completion) {
        NSMutableDictionary *classificaitonDict = [[NSMutableDictionary alloc] init];
        for (NXClassificationCategory *classificationCategory in classifications) {
            if (classificationCategory.selectedLabs.count > 0) {
                NSMutableArray *labs = [[NSMutableArray alloc] init];
                for (NXClassificationLab *classificationLab in classificationCategory.selectedLabs) {
                    NSString *labName = classificationLab.name;
                    [labs addObject:labName];
                }
                [classificaitonDict setObject:labs forKey:classificationCategory.name];
            }
        }
        NSString *operationId = [[NSUUID UUID] UUIDString];
        [self.completeBlockDict setObject:completion forKey:operationId];
        NXEncryptFileOperation *enryptFileOpt = [[NXEncryptFileOperation alloc] init];
        [self.operationDict setObject:enryptFileOpt forKey:operationId];
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [NXLMetaData encrypt:file.localPath destPath:destPath clientProfile:[NXLoginUser sharedInstance].profile membershipId:memberShipId classifications:classificaitonDict encryptdDate:createDate complete:^(NSError *error, NSString *enryptedFilePath, id appendInfo) {
            nxlOptEncryptCompletion completionBlock = self.completeBlockDict[operationId];
            if (error) {
                error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_ENCRYPT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_PROCESSING_FILE_FAILED", nil)}];
            }
            dispatch_semaphore_signal(sema);
            if (completionBlock) {
                completionBlock(enryptedFilePath, error);
                [self.completeBlockDict removeObjectForKey:operationId];
                [self.operationDict removeObjectForKey:operationId];
            }
            if (!error) {
                NSString *DUID = [((NSDictionary *)appendInfo) allKeys].firstObject;
                // do log
                NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc]init];
                model.duid = DUID;
                model.owner = memberShipId?:[NXLoginUser sharedInstance].profile.individualMembership.ID;
                model.operation = [NSNumber numberWithInteger:kProtectOperation];
                model.repositoryId = @"";
                model.filePathId = file.fullServicePath;
                model.filePath = file.fullServicePath;
                model.fileName = file.name;
                model.activityData = @"TestData";
                model.accessTime = [NSNumber numberWithLongLong:([createDate timeIntervalSince1970] * 1000)];
                model.accessResult = [NSNumber numberWithInteger:1];
                NXLogAPI *logAPI = [[NXLogAPI alloc]init];
                [logAPI generateRequestObject:model];
                [[NXSyncHelper sharedInstance] cacheRESTAPI:logAPI cacheURL:[NXCacheManager getLogCacheURL]];
                [[NXSyncHelper sharedInstance] uploadPreviousFailedRESTRequestWithCachedURL:[NXCacheManager getLogCacheURL] mustAllSuccess:NO Complection:^(id object, NSError *error) {
                }];
                [self.fileLogManager insertNXLFileActivity:model];
                
            }
           
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        return operationId;
    }
   
      
    return nil;
    
}
- (NSString *)protectAndUploadMultipleFilesToMyVault:(NSArray *)fileArray permissions:(NXLRights *)permissions membershipId:(NSString *)meberShipId  withCompletion:(nxlOptProtectMultipleCompletion)completion {
    NSMutableArray *successArray = [NSMutableArray array];
    NSMutableArray *failArray = [NSMutableArray array];
    dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);

// 2.异步执行任务
    dispatch_async(serialQueue, ^{
        for (NXFileBase *fileItem in fileArray) {
            [[NXWebFileManager sharedInstance] downloadFile:(NXFileBase<NXWebFileDownloadItemProtocol>*)fileItem withProgress:nil completed:^(NXFileBase *file, NSData *fileData, NSError *error) {
                if (!error) {
                    [self protectToNXLFile:file toPath:[NXCommonUtils createNewNxlTempFile:file.name] permissions:permissions membershipId:meberShipId createDate:[[NXTimeServerManager sharedInstance] currentServerTime] withCompletion:^(NSString *filePath, NSError *error1) {
                      
                        if (!error1) {
                            NXFileBase *file = [[NXFile alloc] init];
                            file.localPath = filePath;
                            file.name = [filePath lastPathComponent];
                            [successArray addObject:file];
                        }else{
                            fileItem.name = [NSString stringWithFormat:@"%@%@",fileItem.name,@".nxl"];
                            fileItem.localPath = error1.localizedDescription;
                            [failArray addObject:fileItem];
                        }
                        if (successArray.count + failArray.count == fileArray.count) {
                            if (completion) {
                                completion(successArray,failArray,nil);
                            }
                        }
                       
                    }];
                    
                }else{
                    fileItem.name = [NSString stringWithFormat:@"%@%@",fileItem.name,@".nxl"];
                    fileItem.localPath = error.localizedDescription;
                    [failArray addObject:fileItem];
                    if (successArray.count + failArray.count == fileArray.count) {
                        if (completion) {
                            completion(successArray,failArray,nil);
                        }
                    }
                }
                
                        
            }];
        }
    });
    return nil;
}

- (NSString *)protectToNXLFile:(NXFileBase *)file toPath:(NSString *)destPath permissions:(NXLRights *)permissions membershipId:(NSString *)memberShipId createDate:(NSDate *)createDate withCompletion:(nxlOptEncryptCompletion)completion{
    if (file.localPath && destPath && completion) {
           NSString *operationId = [[NSUUID UUID] UUIDString];
           [self.completeBlockDict setObject:completion forKey:operationId];
           NXEncryptFileOperation *enryptFileOpt = [[NXEncryptFileOperation alloc] init];
           [self.operationDict setObject:enryptFileOpt forKey:operationId];
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [NXLMetaData encrypt:file.localPath destPath:destPath clientProfile:[NXLoginUser sharedInstance].profile rights:permissions membershipId:memberShipId environment:[[permissions getVaildateDateModel] getPolicyFormatJSONDictionary] encryptdDate:createDate complete:^(NSError *error, NSString *enryptedFilePath, id appendInfo) {
               nxlOptEncryptCompletion completionBlock = self.completeBlockDict[operationId];
                dispatch_semaphore_signal(sema);
               if (error) {
                   error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_ENCRYPT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_PROCESSING_FILE_FAILED", nil)}];
                   if (completionBlock) {
                       completionBlock(nil, error);
                       [self.completeBlockDict removeObjectForKey:operationId];
                       [self.operationDict removeObjectForKey:operationId];
                   }
               }else{ // encrypt successfully, upload to my vault
                   if(completionBlock){
                       enryptFileOpt.uploadMyVaultIdentify = [[NXLoginUser sharedInstance].myVault uploadFile:enryptedFilePath.lastPathComponent fileData:[NSData dataWithContentsOfFile:enryptedFilePath] fileItem:file toMyVaultFolder:nil progress:nil withCompletion:^(NXMyVaultFile *myVaultFile, NXFileBase *parentFolder, NSError *error) {
                           nxlOptEncryptCompletion completionBlock2 = self.completeBlockDict[operationId];
                           if (error) {
                               error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_ENCRYPT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_PROCESSING_FILE_FAILED", nil)}];
                               if (completionBlock2) {
                                   completionBlock2(nil, error);
                                   [self.completeBlockDict removeObjectForKey:operationId];
                                   [self.operationDict removeObjectForKey:operationId];
                               }
                           }else{ // upload to myVault successfully, do log
                               if (completionBlock2) {
                                   completionBlock2(enryptedFilePath, nil);
                                   [self.completeBlockDict removeObjectForKey:operationId];
                                   [self.operationDict removeObjectForKey:operationId];
                                   NSString *DUID = [((NSDictionary *)appendInfo) allKeys].firstObject;
                                   // DO Rights Cache
                                   if ([appendInfo isKindOfClass:[NSDictionary class]]) {
                                       
                                       NXNXLOptCacheNode *cacheNode = [[NXNXLOptCacheNode alloc] initWithDUID:DUID rights:permissions ownerID:[NXLoginUser sharedInstance].profile.individualMembership.ID];
                                       [self.nxlCache setObject:cacheNode forKey:[NXCommonUtils fileKeyForFile:myVaultFile]];
                                   }
                                   
                                   NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc]init];
                                   model.duid = DUID;
                                   model.owner = [NXLoginUser sharedInstance].profile.individualMembership.ID;
                                   model.operation = [NSNumber numberWithInteger:kProtectOperation];
                                   model.repositoryId = @"";
                                   model.filePathId = file.fullServicePath;
                                   model.filePath = file.fullServicePath;
                                   model.fileName = file.name;
                                   model.activityData = @"TestData";
                                   model.accessTime = [NSNumber numberWithLongLong:([createDate timeIntervalSince1970] * 1000)];
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
               }
           
           }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
           return operationId;
       }else{
           NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NOSUCHFILE userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_PARAMETER_INVALID", nil)}];
           if (completion) {
               completion(nil, error);
           }
           return nil;
       }
}

- (NSString *)protectToNXLFile:(NXFileBase *)file toPath:(NSString *)destPath permissions:(NXLRights *)permissions membershipId:(NSString *)memberShipId inProject:(NSNumber *)projectId intoFolder:(NXProjectFolder *)projectFolder createDate:(NSDate *)createDate andIsOverwrite:(BOOL)isOverwrite withCompletion:(nxlOptProjectFileEncryptCompletion)completion {
    if (file.localPath && destPath && completion) {
        NSString *operationId = [[NSUUID UUID] UUIDString];
        [self.completeBlockDict setObject:completion forKey:operationId];
        NXEncryptProjectFileOperation *enryptFileOpt = [[NXEncryptProjectFileOperation alloc] init];
        [self.operationDict setObject:enryptFileOpt forKey:operationId];
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [NXLMetaData encrypt:file.localPath destPath:destPath clientProfile:[NXLoginUser sharedInstance].profile rights:permissions membershipId:memberShipId environment:[[permissions getVaildateDateModel] getPolicyFormatJSONDictionary] encryptdDate:createDate complete:^(NSError *error, NSString *enryptedFilePath, id appendInfo) {
            nxlOptProjectFileEncryptCompletion completionBlock = self.completeBlockDict[operationId];
            dispatch_semaphore_signal(sema);
            if (error) {
                error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_ENCRYPT userInfo:@{NSLocalizedDescriptionKey:error.localizedDescription}];
                if (completionBlock) {
                    completionBlock(nil,nil,error);
                    [self.completeBlockDict removeObjectForKey:operationId];
                    [self.operationDict removeObjectForKey:operationId];
                }
            }else{ // encrypt successfully, upload to project
                if(completionBlock){
                    // i will use this
                    NSURL *fileURL = [NSURL fileURLWithPath:enryptedFilePath];
                    NXProjectUploadFileParameterModel *parModel =[[NXProjectUploadFileParameterModel alloc]init];
                    parModel.fileName = enryptedFilePath.lastPathComponent;
                    parModel.projectId = projectId;
                    parModel.destFilePathId = projectFolder.fullServicePath;
                    parModel.destFilePathDisplay = projectFolder.fullPath;
                    parModel.fileData = [NSData dataWithContentsOfURL:fileURL];
                    parModel.type = [NSNumber numberWithInt:0];
                    parModel.isoverWrite = isOverwrite;
                    enryptFileOpt.uploadProjectIdentify = [[NXLoginUser sharedInstance].myProject addFile:parModel underParentFolder:projectFolder progress:nil withCompletion:^(NXProjectFolder *parentFolder, NXProjectFile *newProjectFile, NSError *error) {
                        if (error) {
                            error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_ENCRYPT userInfo:@{NSLocalizedDescriptionKey:error.localizedDescription}];
                            if (completion) {
                                completion(nil, nil, error);
                                [self.completeBlockDict removeObjectForKey:operationId];
                                [self.operationDict removeObjectForKey:operationId];
                            }
                            
                        }else { // upload to project success
                            // do cache
                            NSString *DUID = [((NSDictionary *)appendInfo) allKeys].firstObject;
                            // DO Rights Cache
                            if ([appendInfo isKindOfClass:[NSDictionary class]]) {
                                NXNXLOptCacheNode *cacheNode = [[NXNXLOptCacheNode alloc] initWithDUID:DUID rights:permissions ownerID:[NXLoginUser sharedInstance].profile.individualMembership.ID];
                                [self.nxlCache setObject:cacheNode forKey:[NXCommonUtils fileKeyForFile:newProjectFile]];
                            }
                            // do log
                            NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc]init];
                            model.duid = DUID;
                            model.owner = memberShipId?:[NXLoginUser sharedInstance].profile.individualMembership.ID;
                            model.operation = [NSNumber numberWithInteger:kProtectOperation];
                            model.repositoryId = @"";
                            model.filePathId = file.fullServicePath;
                            model.filePath = file.fullServicePath;
                            model.fileName = file.name;
                            model.activityData = @"TestData";
                            model.accessTime = [NSNumber numberWithLongLong:([createDate timeIntervalSince1970] * 1000)];
                            model.accessResult = [NSNumber numberWithInteger:1];
                            NXLogAPI *logAPI = [[NXLogAPI alloc]init];
                            [logAPI generateRequestObject:model];
                            [[NXSyncHelper sharedInstance] cacheRESTAPI:logAPI cacheURL:[NXCacheManager getLogCacheURL]];
                            [[NXSyncHelper sharedInstance] uploadPreviousFailedRESTRequestWithCachedURL:[NXCacheManager getLogCacheURL] mustAllSuccess:NO Complection:^(id object, NSError *error) {
                            }];
                            [self.fileLogManager insertNXLFileActivity:model];
                            if (completion) {
                                completion(parentFolder, newProjectFile, nil);
                                [self.completeBlockDict removeObjectForKey:operationId];
                                [self.operationDict removeObjectForKey:operationId];
                            }
                        }
                    }];
                }
            }
           
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        return operationId;
    }else{
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NOSUCHFILE userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_PARAMETER_INVALID", nil)}];
        completion(nil, nil, error);
        return nil;
    }
    
}
- (void)protectMultipleFilesToWorkspace:(NSArray *)fileArray membershipId:(NSString *)membershipId permissions:(NXLRights *)permissions classifications:(NSDictionary *)classificationDict intoFolder:(NXFolder *)folder withCompletion:(nxlOptProtectMultipleFilesToWorkSpaceCompletion)completion{
    NSMutableArray *successArray = [NSMutableArray array];
    NSMutableArray *failArray = [NSMutableArray array];
    
    dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);

// 2.异步执行任务
    dispatch_async(serialQueue, ^{
        for (NXFileBase *fileItem in fileArray) {
            [[NXWebFileManager sharedInstance] downloadFile:(NXFileBase<NXWebFileDownloadItemProtocol>*)fileItem withProgress:nil completed:^(NXFileBase *file, NSData *fileData, NSError *error) {
                if (!error) {
                    NSString *tmpPath = [NXCommonUtils createNewNxlTempFile:file.name];
                    NSDate *currentServerDate = [[NXTimeServerManager sharedInstance] currentServerTime];
                    [self protectFileToWorkSpace:file toPath:tmpPath membershipId:[NXLoginUser sharedInstance].profile.tenantMembership.ID permissions:permissions classifications:classificationDict intoFolder:folder createDate:currentServerDate andIsOverwrite:YES withCompletion:^(NXFolder *folder, NXFileBase *newFile, NSError *error1) {
                        if (!error1) {
                            [successArray addObject:newFile];
                        }else{
                            fileItem.name = [NSString stringWithFormat:@"%@%@",fileItem.name,@".nxl"];
                            fileItem.localPath = error1.localizedDescription;
                            [failArray addObject:fileItem];
                        }
                        if (successArray.count + failArray.count == fileArray.count) {
                            if (completion) {
                                completion(successArray,failArray,nil);
                            }
                        }
                    }];
                }else{
                    fileItem.name = [NSString stringWithFormat:@"%@%@",fileItem.name,@".nxl"];
                    fileItem.localPath = error.localizedDescription;
                    [failArray addObject:fileItem];
                    if (successArray.count + failArray.count == fileArray.count) {
                        if (completion) {
                            completion(successArray,failArray,nil);
                        }
                    }
                }
            }];
        }
    });
        
        
}
- (void)protectMultipleAlreadyDownloadFilesToWorkspace:(NSArray *)downloadFiles  membershipLid:(NSString *)memberShipId permissions:(NXLRights *)permissions classifications:(NSDictionary *)classificationDict inFolder:(NXFolder *)folder  withCompletion:(nxlOptProtectMultipleFilesToWorkSpaceCompletion)completion {
    NSMutableArray *successArray = [NSMutableArray array];
    NSMutableArray *failArray = [NSMutableArray array];
    
    dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);

// 2.异步执行任务
    dispatch_async(serialQueue, ^{
        for (NXFileBase *downloadFile in downloadFiles) {
            NSString *tmpPath = [NXCommonUtils createNewNxlTempFile:downloadFile.name];
            NSDate *currentServerDate = [[NXTimeServerManager sharedInstance] currentServerTime];
            [self protectFileToWorkSpace:downloadFile toPath:tmpPath membershipId:memberShipId permissions:permissions classifications:classificationDict intoFolder:folder createDate:currentServerDate andIsOverwrite:YES withCompletion:^(NXFolder *folder, NXFileBase *newFile, NSError *error) {
                if (!error) {
                    [successArray addObject:newFile];
                }else{
                    downloadFile.name = [NSString stringWithFormat:@"%@%@",downloadFile.name,@".nxl"];
                    downloadFile.localPath = error.localizedDescription;
                    [failArray addObject:downloadFile];
                }
                if (successArray.count + failArray.count == downloadFiles.count) {
                    if (completion) {
                        completion(successArray,failArray,nil);
                    }
                }
                        
            }];
        }
    });
   
    
}

- (NSString *)protectFileToWorkSpace:(NXFileBase *)file toPath:(NSString *)destPath membershipId:(NSString *)memberShipId permissions:(NXLRights *)permissions classifications:(NSDictionary *)classificaitonDict intoFolder:(NXFolder *)folder createDate:(NSDate *)createDate andIsOverwrite:(BOOL)isOverwrite  withCompletion:(nxlOptWorkSpaceFileEncryptCompletion)completion{
     if (file.localPath && destPath && completion) {
        NSString *operationId = [[NSUUID UUID] UUIDString];
        [self.completeBlockDict setObject:completion forKey:operationId];
         NXEncryptworkspaceFileOperation *enryptFileOpt = [[NXEncryptworkspaceFileOperation alloc] init];
        [self.operationDict setObject:enryptFileOpt forKey:operationId];
        if (classificaitonDict) {
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            [NXLMetaData encrypt:file.localPath destPath:destPath clientProfile:[NXLoginUser sharedInstance].profile membershipId:memberShipId classifications:classificaitonDict encryptdDate:createDate complete:^(NSError *error, NSString *enryptedFilePath, id appendInfo) {
                dispatch_semaphore_signal(sema);
                if (error) {
                    error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_ENCRYPT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_PROCESSING_FILE_FAILED", nil)}];
                    [self.completeBlockDict removeObjectForKey:operationId];
                    [self.operationDict removeObjectForKey:operationId];
                    completion(nil, nil, error);
                }else{
                    NXFileBase *nxlFile = [file copy];
                    nxlFile.name = enryptedFilePath.lastPathComponent;
                    nxlFile.localPath = enryptedFilePath;
                    NXWorkSpaceUploadFileModel *model = [[NXWorkSpaceUploadFileModel alloc] init];
                    model.tags = classificaitonDict;
                    model.parentFolder = folder;
                    model.file = nxlFile;
                    model.isOverWrite = isOverwrite;
                    enryptFileOpt.uploadProjectIdentify = [[NXLoginUser sharedInstance].workSpaceManager uploadWorkSpaceFile:model WithCompletion:^(NXWorkSpaceFile *workSpaceFile, NXWorkSpaceUploadFileModel *uploadModel, NSError *error) {
                        if (error) {
                            if (!error.localizedDescription) {
                                error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_ENCRYPT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_PROCESSING_FILE_FAILED", nil)}];
                            }
                            if (completion) {
                                completion(nil, nil, error);
                                [self.completeBlockDict removeObjectForKey:operationId];
                                [self.operationDict removeObjectForKey:operationId];
                            }
                            
                        }else { // upload to workspace success
                            NSString *DUID = [((NSDictionary *)appendInfo) allKeys].firstObject;
                            // do log
                            NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc]init];
                            model.duid = DUID;
                            model.owner = memberShipId?:[NXLoginUser sharedInstance].profile.individualMembership.ID;
                            model.operation = [NSNumber numberWithInteger:kProtectOperation];
                            model.repositoryId = @"";
                            model.filePathId = file.fullServicePath;
                            model.filePath = file.fullServicePath;
                            model.fileName = file.name;
                            model.activityData = @"TestData";
                            model.accessTime = [NSNumber numberWithLongLong:([createDate timeIntervalSince1970] * 1000)];
                            model.accessResult = [NSNumber numberWithInteger:1];
                            NXLogAPI *logAPI = [[NXLogAPI alloc]init];
                            [logAPI generateRequestObject:model];
                            [[NXSyncHelper sharedInstance] cacheRESTAPI:logAPI cacheURL:[NXCacheManager getLogCacheURL]];
                            [[NXSyncHelper sharedInstance] uploadPreviousFailedRESTRequestWithCachedURL:[NXCacheManager getLogCacheURL] mustAllSuccess:NO Complection:^(id object, NSError *error) {
                            }];
                            [self.fileLogManager insertNXLFileActivity:model];
                            if (completion) {
                                completion(nil, workSpaceFile, nil);
                                [self.completeBlockDict removeObjectForKey:operationId];
                                [self.operationDict removeObjectForKey:operationId];
                            }
                        }
                      
                    }];
                }
            }];
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        }else if(permissions){
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            [NXLMetaData encrypt:file.localPath destPath:destPath clientProfile:[NXLoginUser sharedInstance].profile rights:permissions membershipId:memberShipId environment:[[permissions getVaildateDateModel] getPolicyFormatJSONDictionary] encryptdDate:createDate complete:^(NSError *error, NSString *enryptedFilePath, id appendInfo) {
                dispatch_semaphore_signal(sema);
                if (error) {
                    error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_ENCRYPT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_PROCESSING_FILE_FAILED", nil)}];
                    [self.completeBlockDict removeObjectForKey:operationId];
                    [self.operationDict removeObjectForKey:operationId];
                    completion(nil, nil, error);
                }else{
                    NXFileBase *nxlFile = [file copy];
                    nxlFile.name = enryptedFilePath.lastPathComponent;
                    nxlFile.localPath = enryptedFilePath;
                    NXWorkSpaceUploadFileModel *model = [[NXWorkSpaceUploadFileModel alloc] init];
                    model.tags = classificaitonDict;
                    model.parentFolder = folder;
                    model.file = nxlFile;
                    model.isOverWrite = isOverwrite;
                    enryptFileOpt.uploadProjectIdentify = [[NXLoginUser sharedInstance].workSpaceManager uploadWorkSpaceFile:model WithCompletion:^(NXWorkSpaceFile *workSpaceFile, NXWorkSpaceUploadFileModel *uploadModel, NSError *error) {
                        if (error) {
                            if (!error.localizedDescription) {
                                error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_ENCRYPT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_PROCESSING_FILE_FAILED", nil)}];
                            }
                            if (completion) {
                                completion(nil, nil, error);
                                [self.completeBlockDict removeObjectForKey:operationId];
                                [self.operationDict removeObjectForKey:operationId];
                            }
                            
                        }else { // upload to workspace success
                            NSString *DUID = [((NSDictionary *)appendInfo) allKeys].firstObject;
                            // do log
                            NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc]init];
                            model.duid = DUID;
                            model.owner = memberShipId?:[NXLoginUser sharedInstance].profile.individualMembership.ID;
                            model.operation = [NSNumber numberWithInteger:kProtectOperation];
                            model.repositoryId = @"";
                            model.filePathId = file.fullServicePath;
                            model.filePath = file.fullServicePath;
                            model.fileName = file.name;
                            model.activityData = @"TestData";
                            model.accessTime = [NSNumber numberWithLongLong:([createDate timeIntervalSince1970] * 1000)];
                            model.accessResult = [NSNumber numberWithInteger:1];
                            NXLogAPI *logAPI = [[NXLogAPI alloc]init];
                            [logAPI generateRequestObject:model];
                            [[NXSyncHelper sharedInstance] cacheRESTAPI:logAPI cacheURL:[NXCacheManager getLogCacheURL]];
                            [[NXSyncHelper sharedInstance] uploadPreviousFailedRESTRequestWithCachedURL:[NXCacheManager getLogCacheURL] mustAllSuccess:NO Complection:^(id object, NSError *error) {
                            }];
                            [self.fileLogManager insertNXLFileActivity:model];
                            if (completion) {
                                completion(nil, workSpaceFile, nil);
                                [self.completeBlockDict removeObjectForKey:operationId];
                                [self.operationDict removeObjectForKey:operationId];
                            }
                        }
                        
                    }];
                }
            }];
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        }
         return operationId;
     }else {
         NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NOSUCHFILE userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_PARAMETER_INVALID", nil)}];
         if (completion) {
             completion(nil, nil, error);
         }
         return nil;
     }
    
    
}
- (void)protectMultipleFilesToProject:(NSArray *)fileArray classifications:(NSArray<NXClassificationCategory *> *)classifications membershipId:(NSString *)memberShipId inProject:(NSNumber *)projectId intoFolder:(NXProjectFolder *)projectFolder  andIsOverwrite:(BOOL)isOverwrite  withCompletion:(nxlOptProtectMultipleCompletion)completion{
    NSMutableArray *successArray = [NSMutableArray array];
    NSMutableArray *failArray = [NSMutableArray array];
    
    dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);

// 2.异步执行任务
    dispatch_async(serialQueue, ^{
        for (NXFileBase *fileItem in fileArray) {
            [[NXWebFileManager sharedInstance] downloadFile:(NXFileBase<NXWebFileDownloadItemProtocol>*)fileItem withProgress:nil completed:^(NXFileBase *file, NSData *fileData, NSError *error) {
                if (!error) {
                    NSString *tmpPath = [NXCommonUtils createNewNxlTempFile:file.name];
                    NSDate *currentServerDate = [[NXTimeServerManager sharedInstance] currentServerTime];
                   
                    [self protectToNXLFile:file toPath:tmpPath classifications:classifications membershipId:memberShipId inProject:projectId intoFolder:projectFolder createDate:currentServerDate andIsOverwrite:isOverwrite withCompletion:^(NXProjectFolder *projectFolder, NXProjectFile *newProjectFile, NSError *error1) {
                            if (!error1) {
                                [successArray addObject:newProjectFile];
                            }else{
                                fileItem.name = [NSString stringWithFormat:@"%@%@",fileItem.name,@".nxl"];
                                fileItem.localPath = error1.localizedDescription;
                                [failArray addObject:fileItem];
                            }
                            if (successArray.count + failArray.count == fileArray.count) {
                                if (completion) {
                                    completion(successArray,failArray,nil);
                                }
                            }
                    }];

                }else{
                    fileItem.name = [NSString stringWithFormat:@"%@%@",fileItem.name,@".nxl"];
                    fileItem.localPath = error.localizedDescription;
                    [failArray addObject:fileItem];
                    if (successArray.count + failArray.count == fileArray.count) {
                        if (completion) {
                            completion(successArray,failArray,nil);
                        }
                    }
                }
            }];
        }
    });
    
}
- (void)protectMultipleFilesToProject:(NSArray *)fileArray permissions:(NXLRights *)permissions membershipId:(NSString *)memberShipId inProject:(NSNumber *)projectId intoFolder:(NXProjectFolder *)projectFolder  andIsOverwrite:(BOOL)isOverwrite  withCompletion:(nxlOptProtectMultipleCompletion)completion {
    NSMutableArray *successArray = [NSMutableArray array];
    NSMutableArray *failArray = [NSMutableArray array];
    
    dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);

// 2.异步执行任务
    dispatch_async(serialQueue, ^{
        for (NXFileBase *fileItem in fileArray) {
            [[NXWebFileManager sharedInstance] downloadFile:(NXFileBase<NXWebFileDownloadItemProtocol>*)fileItem withProgress:nil completed:^(NXFileBase *file, NSData *fileData, NSError *error) {
                if (!error) {
                    NSString *tmpPath = [NXCommonUtils createNewNxlTempFile:file.name];
                    NSDate *currentServerDate = [[NXTimeServerManager sharedInstance] currentServerTime];
                    [self protectToNXLFile:file toPath:tmpPath permissions:permissions membershipId:memberShipId inProject:projectId intoFolder:projectFolder createDate:currentServerDate andIsOverwrite:isOverwrite withCompletion:^(NXProjectFolder *projectFolder, NXProjectFile *newProjectFile, NSError *error1) {
                            if (!error1) {
                                [successArray addObject:newProjectFile];
                            }else{
                                fileItem.name = [NSString stringWithFormat:@"%@%@",fileItem.name,@".nxl"];
                                fileItem.localPath = error1.localizedDescription;
                                [failArray addObject:fileItem];
                            }
                            if (successArray.count + failArray.count == fileArray.count) {
                                if (completion) {
                                    completion(successArray,failArray,nil);
                                }
                            }
                    }];

                }else{
                    fileItem.name = [NSString stringWithFormat:@"%@%@",fileItem.name,@".nxl"];
                    fileItem.localPath = error.localizedDescription;
                    [failArray addObject:fileItem];
                    if (successArray.count + failArray.count == fileArray.count) {
                        if (completion) {
                            completion(successArray,failArray,nil);
                        }
                    }
                }
            }];
        }
    });
    
    
}
- (NSString *)protectToNXLFile:(NXFileBase *)file toPath:(NSString *)destPath classifications:(NSArray<NXClassificationCategory *> *)classifications membershipId:(NSString *)memberShipId inProject:(NSNumber *)projectId intoFolder:(NXProjectFolder *)projectFolder createDate:(NSDate *)createDate andIsOverwrite:(BOOL)isOverwrite  withCompletion:(nxlOptProjectFileEncryptCompletion)completion {
    if (file.localPath && destPath && completion) {
        // change classification array into dictionary
        NSMutableDictionary *classificaitonDict = [[NSMutableDictionary alloc] init];
        for (NXClassificationCategory *classificationCategory in classifications) {
            if (classificationCategory.selectedLabs.count > 0) {
                NSMutableArray *labs = [[NSMutableArray alloc] init];
                for (NXClassificationLab *classificationLab in classificationCategory.selectedLabs) {
                    NSString *labName = classificationLab.name;
                    [labs addObject:labName];
                }
                [classificaitonDict setObject:labs forKey:classificationCategory.name];
            }
        }
        
        NSString *operationId = [[NSUUID UUID] UUIDString];
        [self.completeBlockDict setObject:completion forKey:operationId];
        NXEncryptProjectFileOperation *enryptFileOpt = [[NXEncryptProjectFileOperation alloc] init];
        [self.operationDict setObject:enryptFileOpt forKey:operationId];
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [NXLMetaData encrypt:file.localPath destPath:destPath clientProfile:[NXLoginUser sharedInstance].profile membershipId:memberShipId classifications:classificaitonDict encryptdDate:createDate complete:^(NSError *error, NSString *enryptedFilePath, id appendInfo) {
            dispatch_semaphore_signal(sema);
            if (error) {
                error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_ENCRYPT userInfo:@{NSLocalizedDescriptionKey:error.localizedDescription?: NSLocalizedString(@"MSG_COM_PROCESSING_FILE_FAILED", nil)}];
                [self.completeBlockDict removeObjectForKey:operationId];
                [self.operationDict removeObjectForKey:operationId];
                completion(nil, nil, error);
            }else {
                if (self.operationDict[operationId]) {
                    // upload to project
                    NSURL *fileURL = [NSURL fileURLWithPath:enryptedFilePath];
                    NXProjectUploadFileParameterModel *parModel =[[NXProjectUploadFileParameterModel alloc]init];
                    parModel.fileName = enryptedFilePath.lastPathComponent;
                    parModel.projectId = projectId;
                    parModel.destFilePathId = projectFolder.fullServicePath;
                    parModel.destFilePathDisplay = projectFolder.fullPath;
                    parModel.type = [NSNumber numberWithInt:0];
                    parModel.isoverWrite = isOverwrite;
                    parModel.fileData = [NSData dataWithContentsOfURL:fileURL];
                     enryptFileOpt.uploadProjectIdentify = [[NXLoginUser sharedInstance].myProject addFile:parModel underParentFolder:(NXProjectFolder*)projectFolder progress:nil withCompletion:^(NXProjectFolder *parentFolder, NXProjectFile *newProjectFile, NSError *error) {
                        if (error) {
                            error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_ENCRYPT userInfo:@{NSLocalizedDescriptionKey:error.localizedDescription?: NSLocalizedString(@"MSG_COM_PROCESSING_FILE_FAILED", nil)}];
                            if (completion) {
                                completion(nil, nil, error);
                                [self.completeBlockDict removeObjectForKey:operationId];
                                [self.operationDict removeObjectForKey:operationId];
                            }
                            
                        }else { // upload to project success
                            NSString *DUID = [((NSDictionary *)appendInfo) allKeys].firstObject;
                            // do log
                            NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc]init];
                            model.duid = DUID;
                            model.owner = memberShipId?:[NXLoginUser sharedInstance].profile.individualMembership.ID;
                            model.operation = [NSNumber numberWithInteger:kProtectOperation];
                            model.repositoryId = @"";
                            model.filePathId = file.fullServicePath;
                            model.filePath = file.fullServicePath;
                            model.fileName = file.name;
                            model.activityData = @"TestData";
                            model.accessTime = [NSNumber numberWithLongLong:([createDate timeIntervalSince1970] * 1000)];
                            model.accessResult = [NSNumber numberWithInteger:1];
                            NXLogAPI *logAPI = [[NXLogAPI alloc]init];
                            [logAPI generateRequestObject:model];
                            [[NXSyncHelper sharedInstance] cacheRESTAPI:logAPI cacheURL:[NXCacheManager getLogCacheURL]];
                            [[NXSyncHelper sharedInstance] uploadPreviousFailedRESTRequestWithCachedURL:[NXCacheManager getLogCacheURL] mustAllSuccess:NO Complection:^(id object, NSError *error) {
                            }];
                            [self.fileLogManager insertNXLFileActivity:model];
                            if (completion) {
                                completion(parentFolder, newProjectFile, nil);
                                [self.completeBlockDict removeObjectForKey:operationId];
                                [self.operationDict removeObjectForKey:operationId];
                            }
                        }
                    }];
                }
            }
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        return operationId;
    }else {
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NOSUCHFILE userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_PARAMETER_INVALID", nil)}];
        if (completion) {
            completion(nil, nil, error);
        }
        return nil;
    }
}
- (void)decryptNXLFile:(NXFileBase *)file toPath:(NSString *)destPath shouldSendLog:(BOOL)shouldSendLog withCompletion:(nxlOptDecryptCompletion)completion {
    __block BOOL shouldsendLOG = shouldSendLog;
      NSDate *nowDate = [[NXTimeServerManager sharedInstance] currentServerTime];
    if(!file || !file.localPath || !destPath){
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NOSUCHFILE userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_PARAMETER_INVALID", nil)}];
        completion(nil, nil, nil, nil, nil, NO, error);
        return;
    }else{
        NXNXLOptCacheNode *cahceNode = [self.nxlCache objectForKey:[NXCommonUtils fileKeyForFile:file]];
        if (cahceNode) {
            shouldsendLOG = YES;
            BOOL isOwner = [NXCommonUtils isStewardUser:cahceNode.ownerId forFile:file];
            if (!isOwner || file.sorceType == NXFileBaseSorceTypeProject) {
                NXLFileValidateDateModel *fileValidateDate = [cahceNode.rights getVaildateDateModel];
                if(fileValidateDate.type != NXLFileValidateDateModelTypeNeverExpire) {
                    if (nowDate == nil) {
                        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_DECRYPT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_NO_TIME_SERVER", nil)}];
                        completion(nil, nil, nil, nil, nil, NO, error);
                        return;
                    }
                    BOOL isValidateDate = [fileValidateDate checkInValidateDateRange:nowDate];
                    if (!isValidateDate) {
                        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_DECRYPT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_NO_ACCESS_RIGHT", nil)}];
                        completion(nil, nil, nil, nil, nil, NO, error);
                        if (shouldsendLOG) {
                            // send log
                            NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc]init];
                            model.duid = cahceNode.DUID;
                            model.owner = cahceNode.ownerId;
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
                        return;
                    }
                    
                }
                
                if (![cahceNode.rights ViewRight]) {
                    NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_DECRYPT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_NO_ACCESS_RIGHT", nil)}];
                    completion(nil, nil, nil, nil, nil, NO, error);
                    if (shouldsendLOG) {
                        // send log
                        NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc] init];
                        model.duid = cahceNode.DUID;
                        model.owner = cahceNode.ownerId;
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
                    return;
                };
            }
        }
        
        WeakObj(self);
        NSDictionary *sharedInfoDict = nil;
        if ([file isKindOfClass:[NXSharedWithProjectFile class]]) {
            sharedInfoDict = @{
                @"sharedSpaceType": @1,
                @"sharedSpaceId": ((NXSharedWithProjectFile *)file).sharedProject.projectId,
                @"sharedSpaceUserMembership": ((NXSharedWithProjectFile *)file).sharedProject.membershipId
            };
        }
        
        [NXLMetaData decryptNXLFileWithPolicySection:file.localPath destPath:destPath clientProfile:[NXLoginUser sharedInstance].profile sharedInfo:sharedInfoDict complete:^(NSError *error, NSString *destPath, NSString *duid, NSString *ownner, NSDictionary *policySection, NSDictionary *classificationSection) {
            StrongObj(self);
            if (self) {
                if (error) {
                    if (error.code == NXLSDKErrorNOTPermission || error.code == 403) {
                        error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_DECRYPT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_NO_ACCESS_RIGHT", nil)}];
                        if (shouldsendLOG) {
                            // send log
                            NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc]init];
                            model.duid = duid;
                            model.owner = ownner;
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
                    }
                    completion(nil, nil, nil, nil, nil, NO, error);
                }else{
                    if (policySection || policySection.count > 0) {
                        BOOL isOwner = [NXCommonUtils isStewardUser:ownner forFile:file];
                        //step1. cache result
                        // extract rights and watermark from policy section
                        NSArray* namedRights = [policySection objectForKey:@"rights"];
                        NSArray* namedObs = [policySection objectForKey:@"obligations"];
                        NXLRights *rights = [[NXLRights alloc]initWithRightsObs:namedRights obligations:namedObs];
                        // extract validatetime from policy section
                        NXLFileValidateDateModel *validateDateModel = [self extractFileValidateDateFromPolicySection:policySection];
                        [rights setFileValidateDate:validateDateModel];
                        NXNXLOptCacheNode *newCacheNode = [[NXNXLOptCacheNode alloc] initWithDUID:duid rights:rights ownerID:ownner];
                        newCacheNode.waterMarkContent = [rights.getWatermarkString parseWatermarkWords];
                        
                        [self.nxlCache setObject:newCacheNode forKey:[NXCommonUtils fileKeyForFile:file]];
                        // check expire time
                        if (!isOwner || file.sorceType == NXFileBaseSorceTypeProject) {
                            NXLFileValidateDateModel *fileValidateDate = [newCacheNode.rights getVaildateDateModel];
                            if(fileValidateDate.type != NXLFileValidateDateModelTypeNeverExpire) {
                                NSDate *nowDate = [[NXTimeServerManager sharedInstance] currentServerTime];
                                if (nowDate == nil) {
                                    NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_DECRYPT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_NO_TIME_SERVER", nil)}];
                                    completion(nil, nil, nil, nil, nil, NO, error);
                                    return;
                                }
                                BOOL isValidateDate = [fileValidateDate checkInValidateDateRange:nowDate];
                                if (!isValidateDate) {
                                    NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_DECRYPT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_NO_ACCESS_RIGHT", nil)}];
                                    completion(nil, nil, nil, nil, nil, NO, error);
                                    if (shouldSendLog) {
                                        // send log
                                        NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc]init];
                                        model.duid = newCacheNode.DUID;
                                        model.owner = newCacheNode.ownerId;
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
                                    return;
                                }
                            }
                        }
                        
                        // step2. return block
                        completion(destPath, duid, rights, nil, ownner, isOwner, nil);
                        if (shouldsendLOG) {
                            // send log
                            NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc]init];
                            model.duid = newCacheNode.DUID;
                            model.owner = newCacheNode.ownerId;
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
                        
                    }else if(classificationSection) { // center policy encrypted
                        NSMutableArray *classifications = [NSMutableArray array];
                        [classificationSection enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSArray * obj, BOOL * _Nonnull stop) {
                            NXClassificationCategory *classificaitonCategory = [[NXClassificationCategory alloc] init];
                            classificaitonCategory.name = key;
                            for (NSString *lab in obj) {
                                NXClassificationLab *classificaitonLab = [[NXClassificationLab alloc] init];
                                classificaitonLab.name = lab;
                                [classificaitonCategory.selectedLabs addObject:classificaitonLab];
                            }
                            [classifications addObject:classificaitonCategory];
                        }];
                        
                       
                        NSString *ownerId = ownner;
                        if ((file.sorceType == NXFileBaseSorceType3rdOpenIn || file.sorceType == NXFileBaseSorceTypeRepoFile || file.sorceType == NXFileBaseSorceTypeSharedWorkspaceFile || file.sorceType == NXFileBaseSorceTypeLocalFiles) && ownner) {
        //Files sharedworkspace and repo maybe have the poject token group encrypt file,if the file is uploading by external,we need use the project token membershhipID decrypt.
                            NSArray *ownnerArray = [ownner componentsSeparatedByString:@"@"];
                            if (ownnerArray.count) {
                                NSString *currentFileTenantGroupName = ownnerArray.lastObject;
                                
                                if ([[NXLoginUser sharedInstance].profile.tenantMembership.tokenGroupName isEqualToString:currentFileTenantGroupName]) {
                                    ownerId = [NXLoginUser sharedInstance].profile.tenantMembership.ID;
                                }else{
                                    for (NXLMembership *membership in [NXLoginUser sharedInstance].profile.memberships) {
                                        if ([membership.tokenGroupName isEqualToString:currentFileTenantGroupName]) {
                                            ownerId = membership.ID;
                                            break;
                                        }else{
                                            ownerId = [NXLoginUser sharedInstance].profile.tenantMembership.ID;
                                        }
                                    }
                                }
                            }else{
                                ownerId = [NXLoginUser sharedInstance].profile.tenantMembership.ID;
                            }
                         
                        }else if (file.sorceType == NXFileBaseSorceTypeSharedWithProject){
                            // for shareWithProjectFile use shared project membershipID,not source project membershipID
                            NXSharedWithProjectFile *shareFromProjectFile = (NXSharedWithProjectFile *)file;
                            if(shareFromProjectFile.sharedProject.membershipId){
                                ownerId = shareFromProjectFile.sharedProject.membershipId;
                            }
                        }else if(file.sorceType == NXFileBaseSorceTypeProject){
                            NXProjectFile *projectFile = (NXProjectFile *)file;
                            NXProjectModel *projectModel = [[NXLoginUser sharedInstance].myProject getProjectModelForProjectId:projectFile.projectId];
                            if (projectModel.membershipId) {
                                ownerId = projectModel.membershipId;
                            }
                        }else{
                            ownerId = [NXLoginUser sharedInstance].profile.tenantMembership.ID;
                        }
                    
                        NSDictionary *dictModel = @{MEMBER_SHIP_ID:ownerId,
                                                    RESOURCE_NAME:file.name,
                                                    EVAL_NAME:@"VIEWER",
                                                    DUIDKEY:duid,
                                                    RIGHTS:@(NXLRIGHTVIEW|NXLRIGHTPRINT|NXLRIGHTSDOWNLOAD|NXLRIGHTEDIT|NXLRIGHTDECRYPT|NXLRIGHTSHARING|NXLRIGHTSCREENCAP),
                                                    USERID:[NXLoginUser sharedInstance].profile.userId,
                                                    EVALTYPE:@0,
                                                    CATEGORIES_ARRAY:classifications
                                                    };
                        NXPerformPolicyEvaluationAPIRequest *requeset = [[NXPerformPolicyEvaluationAPIRequest alloc] init];
                        [requeset requestWithObject:dictModel Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
                            if (error) {
                                error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_DECRYPT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_EVALUATION_FAILED", nil)}];
                                completion(nil, nil, nil, nil, nil, NO, error);
                            }else {
                                if (response.rmsStatuCode != NXRMS_ERROR_CODE_SUCCESS) {
                                    NSString *errorDescription = NSLocalizedString(@"MSG_COM_EVALUATION_FAILED", nil);
                                    if (response.rmsStatuCode == NXRMS_PROJECT_CLASSIFICATION_NOT_MATCH_RIGHTS) {
                                        errorDescription = NSLocalizedString(@"MSG_COM_NO_POLICY_TO_EVALUATE", nil);
                                    }
                                    error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_DECRYPT userInfo:@{NSLocalizedDescriptionKey:errorDescription}];
                                    completion(nil, nil, nil, classifications, nil, NO, error);
                                }else {
                                    
                                    NSNumber *shouldSendLogMA = [self.isCenterPolicyFileCachedRightsDic objectForKey:[NXCommonUtils fileKeyForFile:file]];
                                    if (shouldSendLogMA.boolValue) {
                                        shouldsendLOG = YES;
                                    }
                                    
                                    NXPerformPolicyEvaluationAPIResponse *evaResponse = (NXPerformPolicyEvaluationAPIResponse *)response;
                                    NXLRights *right = evaResponse.evaluationRight;
                                    if ([right getWatermarkString]) {
                                        NSString *newWatermarkStr = [self conversionPolicyWatermarkStringWithClassifications:classifications andCurrentWatermarkString:[right getWatermarkString]];
                                        [right setWatermarkString:newWatermarkStr];
                                    }
                                    // do cache
                                    NXNXLOptCacheNode *optCache = [[NXNXLOptCacheNode alloc] initWithDUID:duid rights:right classification:[classifications copy] cacheDate:[NXTimeServerManager sharedInstance].currentServerTime ownerId:nil];
                                    optCache.waterMarkContent = [[right getWatermarkString] parseWatermarkWords];
                                    NSString *filekey = [NXCommonUtils fileKeyForFile:file];
                                    [self.isCenterPolicyFileCachedRightsDic setObject:[NSNumber numberWithBool:YES] forKey:filekey];
                                    
                                    // step2. return block
                                    if(![right ViewRight]) {
                                        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_DECRYPT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_NO_ACCESS_RIGHT", nil)}];
                                        completion(nil, nil, nil, nil, nil, NO, error);
                                        if (shouldsendLOG) {
                                            // send log
                                            NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc] init];
                                            model.duid = optCache.DUID;
                                            model.owner = optCache.ownerId;
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
                                            
//                                            NSDictionary * dic = [[NSDictionary alloc] init];
//                                            //NSMutableDictionary *muc = [[NSMutableDictionary alloc] init];
//                                            
//                                            [dic setValue:@"ss" forKey:@"ssdd"];
                                            [self.fileLogManager insertNXLFileActivity:model];
                                        }
                                       
                                    }else {
                                        completion(destPath, duid, right, classifications, ownerId, NO, nil);
                                        if (shouldsendLOG) {
                                            // send log
                                            NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc]init];
                                            model.duid = duid;
                                            model.owner = ownner;
                                            model.operation = [NSNumber numberWithInteger:kViewOperation];
                                            model.repositoryId = @"";
                                            model.filePathId = file.fullServicePath;
                                            model.filePath = file.fullServicePath;
                                            model.fileName = file.fullServicePath;
                                            model.activityData = @"TestData";
                                            model.accessTime = [NSNumber numberWithLongLong:([nowDate timeIntervalSince1970] * 1000)];
                                            model.accessResult = right.ViewRight?@1:@0;
                                            
                                            NXLogAPI *logAPI = [[NXLogAPI alloc]init];
                                            [logAPI generateRequestObject:model];
                                            [[NXSyncHelper sharedInstance] cacheRESTAPI:logAPI cacheURL:[NXCacheManager getLogCacheURL]];
                                            [[NXSyncHelper sharedInstance] uploadPreviousFailedRESTRequestWithCachedURL:[NXCacheManager getLogCacheURL] mustAllSuccess:NO Complection:^(id object, NSError *error) {
                                            }];
                                            [self.fileLogManager insertNXLFileActivity:model];
                                        }
                                        
                                    }
                                }
                            }
                        }];
                        
                    }else {
                        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_INVALID userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_INVALID_NXL_FILE", nil)}];
                        completion(nil, nil, nil, nil, nil, NO, error);
                    }
                }
            }
        }];
    }
}

- (void)addNXLFile:(NXFileBase *)file intoDestFolder:(NXFolder *)destFolder shouldRename:(BOOL)shouldRename newName:(NSString*)newName completion:(nxlOptAddNXLFileCompletion)completion
{
     // first convert nxlfile to another nxlfile
        NSString *memberShipID = nil;
        NXAddNXLFileUploadType type = 0;
        if ([destFolder isKindOfClass:[NXProjectFolder class]]) {
            NXProjectFolder *projectFolder = (NXProjectFolder *)destFolder;
            NXProjectModel *projectModel = [[NXLoginUser sharedInstance].myProject getProjectModelForProjectId:projectFolder.projectId];
            memberShipID = projectModel.membershipId;
            type = NXAddNXLFileUploadTypeToProject;
        }else if([destFolder isKindOfClass:[NXWorkSpaceFolder class]]){
            memberShipID = [NXLoginUser sharedInstance].profile.tenantMembership.ID;
            type = NXAddNXLFileUploadTypeToWorkspace;
        }else if([destFolder isKindOfClass:[NXSharedWorkspaceFile class]] || destFolder.sorceType == NXFileBaseSorceTypeRepoFile){
            memberShipID = [NXLoginUser sharedInstance].profile.tenantMembership.ID;
            type = NXAddNXLFileUploadTypeToSharedWorkspace;
        }
        else{
            //can't find membershipID
            NSAssert(NO, @"membership can not be nil");
        }
    
    if([destFolder isKindOfClass:[NXProjectFolder class]] && memberShipID==nil){
        NSLog(@"memberShip is nil for project");
        NXProjectFolder *projectFolder = (NXProjectFolder *)destFolder;
           NXProjectModel *projectModel = [[NXLoginUser sharedInstance].myProject getProjectModelForProjectId:projectFolder.projectId];
        [[NXLoginUser sharedInstance].myProject getMemberShipID:projectModel withCompletion:^(NXProjectModel *returnProjectModel, NSError *error) {
            WeakObj(self);
            [self convertNXLFile:file withNewMembershipId:returnProjectModel.membershipId shouldRename:shouldRename newName:newName completion:^(NXFileBase *newNXLFile, NSString *originalFileownerID, NSString *originalFileDuid, NSString *newFileOwnerId, NSString *newFileDuid, NSError *error) {
                StrongObj(self);
                      if (error) {
                          completion(nil,error);
                      }else{
                          // convert success
                          [self uploadNXLFile:newNXLFile intoDestFolder:destFolder ownnerID:newFileOwnerId duid:newFileDuid uploadType:type shouldRename:shouldRename completion:^(NXFileBase *returnfile, NSError *error) {
                              if (error) {
                                  completion(nil,error);
                              }else{
                                  // upload success
                                  // do decrypted log
                                  completion(returnfile,nil);
                              }
                          }];
                      }
            }];
        }];
        return;
    }
    
    WeakObj(self);
    [self convertNXLFile:file withNewMembershipId:memberShipID shouldRename:shouldRename newName:newName completion:^(NXFileBase *newNXLFile, NSString *originalFileownerID, NSString *originalFileDuid, NSString *newFileOwnerId, NSString *newFileDuid, NSError *error) {
        StrongObj(self);
              if (error) {
                  completion(nil,error);
              }else{
                  // convert success
                  [self uploadNXLFile:newNXLFile intoDestFolder:destFolder ownnerID:newFileOwnerId duid:newFileDuid uploadType:type shouldRename:shouldRename  completion:^(NXFileBase *returnfile, NSError *error) {
                      if (error) {
                          completion(nil,error);
                      }else{
                          // upload success
                          // do decrypted log
                          completion(returnfile,nil);
                          
                          // send original protect log
                          NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc]init];
                          model.duid = originalFileDuid;
                          model.owner = originalFileownerID;
                          model.operation = [NSNumber numberWithLong:kProtectOperation];
                          model.repositoryId = @"";
                          model.filePathId = file.fullServicePath;
                          model.filePath = file.fullServicePath;
                          model.fileName = file.fullServicePath;
                          model.activityData = @"TestData";
                          model.accessTime = [NSNumber numberWithLongLong:([[NXTimeServerManager sharedInstance].currentServerTime timeIntervalSince1970] * 1000)];
                          model.accessResult = error?[NSNumber numberWithInteger:0]:[NSNumber numberWithInteger:1];
                          NXLogAPI *logAPI = [[NXLogAPI alloc]init];
                          [logAPI generateRequestObject:model];
                          [[NXSyncHelper sharedInstance] cacheRESTAPI:logAPI cacheURL:[NXCacheManager getLogCacheURL]];
                          [[NXSyncHelper sharedInstance] uploadPreviousFailedRESTRequestWithCachedURL:[NXCacheManager getLogCacheURL] mustAllSuccess:NO Complection:^(id object, NSError *error) {
                             
                          }];
                          [self.fileLogManager insertNXLFileActivity:model];
                      }
                  }];
              }
    }];
}

- (void)decryptNXLFile:(NXFileBase *)file toPath:(NSString *)destPath withCompletion:(nxlOptDecryptCompletion)completion
{
    BOOL shouldSendLog = YES;
    if ([file isKindOfClass:[NXSharedWithMeFile class]] || [file isKindOfClass:[NXSharedWithProjectFile class]]) {
        shouldSendLog = NO;
    }
    [self decryptNXLFile:file toPath:destPath shouldSendLog:shouldSendLog withCompletion:completion];
}

- (NSString *)addFile:(NXFileBase *)file toWorkSpaceWithClassificationwithClassification:(NSArray<NXClassificationCategory *>*)clafficications originalFile:(NXFile *)originalFile originalFileOwnnerID:(NSString *)ownerId originalFileDuid:(NSString *)duid completion:(nxlOptShareFileToWorkSpaceCompletion)completion {
    if (file.localPath) {
        
    }
    NSAssert(NO, @"Should not be here");
    return nil;
}

- (NSString *)shareFile:(NXFileBase *)file toWorkSpaceWithDestFolder:(NXWorkSpaceFolder *)destFolder classification:(NSArray<NXClassificationCategory *>*)classifications originalFile:(NXFile *)originalFile originalFileOwnnerID:(NSString *)ownerId originalFileDuid:(NSString *)duid completion:(nxlOptShareFileToWorkSpaceCompletion)completion {
    if (file.localPath) {
        // change classification array into dictionary
        NSMutableDictionary *classificaitonDict = [[NSMutableDictionary alloc] init];
        for (NXClassificationCategory *classificationCategory in classifications) {
            if (classificationCategory.selectedLabs.count > 0) {
                NSMutableArray *labs = [[NSMutableArray alloc] init];
                for (NXClassificationLab *classificationLab in classificationCategory.selectedLabs) {
                    NSString *labName = classificationLab.name;
                    [labs addObject:labName];
                }
                [classificaitonDict setObject:labs forKey:classificationCategory.name];
            }
        }
        NXWorkSpaceUploadFileModel *model = [[NXWorkSpaceUploadFileModel alloc] init];
        model.file = file;
        model.parentFolder = destFolder;
        model.tags = classificaitonDict;
        WeakObj(self);
        NSString *operationId = [[NSUUID UUID] UUIDString];
        NXShareFileOperation *shareOpt = [[NXShareFileOperation alloc] init];
        [self.completeBlockDict setObject:completion forKey:operationId];
        [self.operationDict setObject:shareOpt forKey:operationId];
        shareOpt.shareFileIdentify = [[NXLoginUser sharedInstance].workSpaceManager uploadWorkSpaceFile:model WithCompletion:^(NXWorkSpaceFile *workSpaceFile, NXWorkSpaceUploadFileModel *uploadModel, NSError *error) {
            StrongObj(self);
            if (error) {
                completion(nil, error);
            }else {
                completion(workSpaceFile, nil);
            }
            
            [self.completeBlockDict removeObjectForKey:operationId];
            [self.operationDict removeObjectForKey:operationId];
            
            // send original decrypt log
            NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc]init];
            model.duid = duid;
            model.owner = ownerId;
            model.operation = [NSNumber numberWithLong:kDecryptOperation];
            model.repositoryId = @"";
            model.filePathId = originalFile.fullServicePath;
            model.filePath = originalFile.fullServicePath;
            model.fileName = originalFile.fullServicePath;
            model.activityData = @"TestData";
            model.accessTime = [NSNumber numberWithLongLong:([[NXTimeServerManager sharedInstance].currentServerTime timeIntervalSince1970] * 1000)];
            model.accessResult = error?[NSNumber numberWithInteger:0]:[NSNumber numberWithInteger:1];
            NXLogAPI *logAPI = [[NXLogAPI alloc]init];
            [logAPI generateRequestObject:model];
            [[NXSyncHelper sharedInstance] cacheRESTAPI:logAPI cacheURL:[NXCacheManager getLogCacheURL]];
            [[NXSyncHelper sharedInstance] uploadPreviousFailedRESTRequestWithCachedURL:[NXCacheManager getLogCacheURL] mustAllSuccess:NO Complection:^(id object, NSError *error) {
               
            }];
            [self.fileLogManager insertNXLFileActivity:model];
        }];
        return operationId;
    }
    NSAssert(NO, @"Should not be here, the file must have localpath");
    return nil;
}

- (NSString *)shareFile:(NXFileBase *)file toWorkSpaceWithDestFolder:(NXWorkSpaceFolder *)destFolder rights:(NXLRights *)digitalrights originalFile:(NXFile *)originalFile originalFileOwnnerID:(NSString *)ownerId originalFileDuid:(NSString *)duid completion:(nxlOptShareFileToWorkSpaceCompletion)completion
{
    if (file.localPath) {
           NXWorkSpaceUploadFileModel *model = [[NXWorkSpaceUploadFileModel alloc] init];
           model.file = file;
           model.parentFolder = destFolder;
           model.digitalRight = digitalrights;
           WeakObj(self); 
           NSString *operationId = [[NSUUID UUID] UUIDString];
           NXShareFileOperation *shareOpt = [[NXShareFileOperation alloc] init];
           [self.completeBlockDict setObject:completion forKey:operationId];
           [self.operationDict setObject:shareOpt forKey:operationId];
           shareOpt.shareFileIdentify = [[NXLoginUser sharedInstance].workSpaceManager uploadWorkSpaceFile:model WithCompletion:^(NXWorkSpaceFile *workSpaceFile, NXWorkSpaceUploadFileModel *uploadModel, NSError *error) {
               StrongObj(self);
               if (error) {
                   completion(nil, error);
               }else {
                   completion(workSpaceFile, nil);
               }
               
               [self.completeBlockDict removeObjectForKey:operationId];
               [self.operationDict removeObjectForKey:operationId];
               
               // send original decrypt log
               NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc]init];
               model.duid = duid;
               model.owner = ownerId;
               model.operation = [NSNumber numberWithLong:kDecryptOperation];
               model.repositoryId = @"";
               model.filePathId = originalFile.fullServicePath;
               model.filePath = originalFile.fullServicePath;
               model.fileName = originalFile.fullServicePath;
               model.activityData = @"TestData";
               model.accessTime = [NSNumber numberWithLongLong:([[NXTimeServerManager sharedInstance].currentServerTime timeIntervalSince1970] * 1000)];
               model.accessResult = error?[NSNumber numberWithInteger:0]:[NSNumber numberWithInteger:1];
               NXLogAPI *logAPI = [[NXLogAPI alloc]init];
               [logAPI generateRequestObject:model];
               [[NXSyncHelper sharedInstance] cacheRESTAPI:logAPI cacheURL:[NXCacheManager getLogCacheURL]];
               [[NXSyncHelper sharedInstance] uploadPreviousFailedRESTRequestWithCachedURL:[NXCacheManager getLogCacheURL] mustAllSuccess:NO Complection:^(id object, NSError *error) {
                  
               }];
               [self.fileLogManager insertNXLFileActivity:model];
           }];
           return operationId;
       }
       NSAssert(NO, @"Should not be here, the file must have localpath");
       return nil;
}

- (NSString *)shareFile:(NXFileBase *)file toProject:(NXProjectModel *)project destFolder:(NXProjectFolder *)destFolder withClassification:(NSArray<NXClassificationCategory *>*)classification originalFile:(NXFile *)originalFile originalFileOwnnerID:(NSString *)ownerId originalFileDuid:(NSString *)duid completion:(nxlOptShareFileToProjectCompletion)completion {
    if (file.localPath) {
        // Should only have normal file to share
        return [self protectToNXLFile:file toPath:[NXCommonUtils createNewNxlTempFile:file.name] classifications:classification membershipId:project.membershipId inProject:project.projectId intoFolder:destFolder createDate:[NXTimeServerManager sharedInstance].currentServerTime andIsOverwrite:NO withCompletion:^(NXProjectFolder *projectFolder, NXProjectFile *newProjectFile, NSError *error) {
                completion(project, newProjectFile, error);
//                // send original decrypt log
//                NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc]init];
//                model.duid = duid;
//                model.owner = ownerId;
//                model.operation = [NSNumber numberWithLong:kDecryptOperation];
//                model.repositoryId = @"";
//                model.filePathId = originalFile.fullServicePath;
//                model.filePath = originalFile.fullServicePath;
//                model.fileName = originalFile.fullServicePath;
//                model.activityData = @"TestData";
//                model.accessTime = [NSNumber numberWithLongLong:([[NXTimeServerManager sharedInstance].currentServerTime timeIntervalSince1970] * 1000)];
//                model.accessResult = error?[NSNumber numberWithInteger:0]:[NSNumber numberWithInteger:1];
//                NXLogAPI *logAPI = [[NXLogAPI alloc]init];
//                [logAPI generateRequestObject:model];
//                [[NXSyncHelper sharedInstance] cacheRESTAPI:logAPI cacheURL:[NXCacheManager getLogCacheURL]];
//                [[NXSyncHelper sharedInstance] uploadPreviousFailedRESTRequestWithCachedURL:[NXCacheManager getLogCacheURL] mustAllSuccess:NO Complection:^(id object, NSError *error) {
//
//                }];
//                [self.fileLogManager insertNXLFileActivity:model];
                }];
    }
    return nil;
}

- (NSString *)shareFile:(NXFileBase *)file toProect:(NXProjectModel *)project destFolder:(NXProjectFolder *)destFolder permissions:(NXLRights *)permissions originalFile:(NXFile *)originalFile originalFileOwnnerID:(NSString *)ownerId originalFileDuid:(NSString *)duid completion:(nxlOptShareFileToProjectCompletion)completion {
    if (file.localPath) {
        // Should only have normal file to share
        return [self protectToNXLFile:file toPath:[NXCommonUtils createNewNxlTempFile:file.name] permissions:permissions membershipId:project.membershipId inProject:project.projectId intoFolder:destFolder createDate:[NXTimeServerManager sharedInstance].currentServerTime andIsOverwrite:NO withCompletion:^(NXProjectFolder *projectFolder, NXProjectFile *newProjectFile, NSError *error) {
            completion(project, newProjectFile, error);
            
            // send original file share log
            NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc]init];
            model.duid = duid;
            model.owner = ownerId;
            model.operation = [NSNumber numberWithLong:kShareOperation];
            model.repositoryId = @"";
            model.filePathId = originalFile.fullServicePath;
            model.filePath = originalFile.fullServicePath;
            model.fileName = originalFile.fullServicePath;
            model.activityData = @"TestData";
            model.accessTime = [NSNumber numberWithLongLong:([[NXTimeServerManager sharedInstance].currentServerTime timeIntervalSince1970] * 1000)];
            model.accessResult = error?[NSNumber numberWithInteger:0]:[NSNumber numberWithInteger:1];
            NXLogAPI *logAPI = [[NXLogAPI alloc]init];
            [logAPI generateRequestObject:model];
            [[NXSyncHelper sharedInstance] cacheRESTAPI:logAPI cacheURL:[NXCacheManager getLogCacheURL]];
            [[NXSyncHelper sharedInstance] uploadPreviousFailedRESTRequestWithCachedURL:[NXCacheManager getLogCacheURL] mustAllSuccess:NO Complection:^(id object, NSError *error) {
                
            }];
            [self.fileLogManager insertNXLFileActivity:model];
        }];
    }
    return nil;
}

- (NSString *)shareProjectFile:(NXFileBase *)file recipients:(NSArray *)recipients permissions:(NXLRights *)permissions comment:(NSString *)comment originalFile:(NXFile *)originalFile originalFileOwnnerID:(NSString *)ownerId originalFileDuid:(NSString *)originalFileDuid withCompletion:(nxlOptShareFileCompletion)completion {
    if(!file || !recipients || !permissions ||  ![permissions getVaildateDateModel]){
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NOSUCHFILE userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_PARAMETER_INVALID", nil)}];
        completion(nil, nil, nil, nil,error);
        return nil;
    }
    return [self shareLocalFile:file recipients:recipients permissions:permissions comment:comment withCompletion:^(NSURL *originalFilePath,NSString *sharedFileName,NSArray *alreadySharedArray,NSArray *newSharedArray,NSError *error) {
        completion(sharedFileName,nil, nil, recipients, error);
        // send original file share log
        NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc]init];
        model.duid = originalFileDuid;
        model.owner = ownerId;
        model.operation = [NSNumber numberWithLong:kShareOperation];
        model.repositoryId = @"";
        model.filePathId = originalFile.fullServicePath;
        model.filePath = originalFile.fullServicePath;
        model.fileName = originalFile.fullServicePath;
        model.activityData = @"TestData";
        model.accessTime = [NSNumber numberWithLongLong:([[NXTimeServerManager sharedInstance].currentServerTime timeIntervalSince1970] * 1000)];
        model.accessResult = error?[NSNumber numberWithInteger:0]:[NSNumber numberWithInteger:1];
        NXLogAPI *logAPI = [[NXLogAPI alloc]init];
        [logAPI generateRequestObject:model];
        [[NXSyncHelper sharedInstance] cacheRESTAPI:logAPI cacheURL:[NXCacheManager getLogCacheURL]];
        [[NXSyncHelper sharedInstance] uploadPreviousFailedRESTRequestWithCachedURL:[NXCacheManager getLogCacheURL] mustAllSuccess:NO Complection:^(id object, NSError *error) {
            
        }];
        [self.fileLogManager insertNXLFileActivity:model];
    }];
}

- (NSString *)shareFile:(NXFileBase *)file recipients:(NSArray *)recipients permissions:(NXLRights *)permissions comment:(NSString *)comment withCompletion:(nxlOptShareFileCompletion)completion {
    if(!file || !recipients || !permissions ||  ![permissions getVaildateDateModel]){
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NOSUCHFILE userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_PARAMETER_INVALID", nil)}];
        completion(nil, nil, nil,nil, error);
        return nil;
    }
    if(file.sorceType == NXFileBaseSorceTypeShareWithMe){
        NXSharedWithMeFile *shareWithMeFile = (NXSharedWithMeFile*)file;
        shareWithMeFile.reshareComment = comment;
        return [self reshareSharedWithMeFile:shareWithMeFile recipients:recipients withCompletion:^(NSString *sharedFileName,NSString *duid, NSArray *alreadySharedArray, NSArray *newSharedArray, NSError *error) {
            completion(nil,duid, alreadySharedArray, newSharedArray, error);
        }];
    }else if(file.sorceType == NXFileBaseSorceTypeLocal || file.sorceType == NXFileBaseSorceType3rdOpenIn || file.sorceType == NXFileBaseSorceTypeLocalFiles){
        return [self shareLocalFile:file recipients:recipients permissions:permissions comment:comment withCompletion:^(NSURL *originalFilePath,NSString *sharedFileName,NSArray *alreadySharedArray,NSArray *newSharedArray,NSError*error) {
            completion(nil, nil,alreadySharedArray, newSharedArray, error);
        }];
    }else {
        [self shareRepoFile:file recipients:recipients permissions:permissions comment:comment withCompletion:^(NSString *sharedFileName,NSString *duid, NSArray *alreadySharedArray, NSArray *newSharedArray, NSError *error) {
            completion(nil,duid, alreadySharedArray, newSharedArray, error);
            if ([file isKindOfClass:[NXMyVaultFile class]] && error == nil) {
                NXMyVaultFile *fileItem = (NXMyVaultFile *)file;
                [[NXLoginUser sharedInstance].myVault updateMyVaultFileSharedStatus:fileItem];
            };
        }];
        return nil;
    }
}
// project file share to projects
- (NSString *)shareProjectFile:(NXFileBase *)file fromPorject:(NXProjectModel *)project toRecipinets:(NSArray *)recipients comment:(NSString *)commnet withCompletion:(nxlOptShareFileCompletion)completion {
    NSString *operationId = [[NSUUID UUID] UUIDString];
    NXSharingProjectFileModel *model = [[NXSharingProjectFileModel alloc] init];
    model.projectModel = project;
    model.file = file;
    model.recipients = recipients;
    model.comment = commnet;
    WeakObj(self);
    NXProjectFileSharingOperation *shareOpt = [[NXProjectFileSharingOperation alloc] initWithModel:model];
    [self.completeBlockDict setObject:completion forKey:operationId];
    [self.operationDict setObject:shareOpt forKey:operationId];
    shareOpt.projectFileSharingCompletion = ^(NSArray *aNewSharelist, NSArray *alreadySharedList, NSError *error) {
        StrongObj(self);
        nxlOptShareFileCompletion comp = self.completeBlockDict[operationId];
        comp(file.name,((NXProjectFile *)file).duid,alreadySharedList,aNewSharelist,error);
        [self.completeBlockDict removeObjectForKey:operationId];
        [self.operationDict removeObjectForKey:operationId];
    };
    [shareOpt start];
    return operationId;
}
// update share project recipients
- (NSString *)updateSharedFile:(NXFileBase *)file fromProject:(NXProjectModel *)projectModel addRecipients:(NSArray *)addRecipients removeRecipients:(NSArray *)removeRecipients comment:(NSString *)commnet withCompletion:(nxlOptUpateProjectRecipentsFromSharedFileCompletion)completion {
    NSString *operationId = [[NSUUID UUID] UUIDString];
    NXUpdateSharingRecipientsModel *model = [[NXUpdateSharingRecipientsModel alloc] init];
    model.file = file;
    model.addedRecipients = addRecipients;
    model.removedRecipients = removeRecipients;
    model.comment = commnet;
    NXSharedFileUpateRecipientsOperation *updateOpt = [[NXSharedFileUpateRecipientsOperation alloc] initWithModel:model];
    [self.completeBlockDict setObject:completion forKey:operationId];
    [self.operationDict setObject:updateOpt forKey:operationId];
    updateOpt.projectFileUpdateRecipientsCompletion = ^(NSArray *aNewSharelist, NSArray *alreadySharedList, NSArray *removeSharedList, NSError *error) {
        nxlOptUpateProjectRecipentsFromSharedFileCompletion comp = self.completeBlockDict[operationId];
        comp(aNewSharelist,removeSharedList,alreadySharedList,error);
        [self.completeBlockDict removeObjectForKey:operationId];
        [self.operationDict removeObjectForKey:operationId];
    };
      
       [updateOpt start];
       return operationId;
    
};

- (NSString *)downloadNXLFileAndDecrypted:(NXFileBase *)file completion:(downloadNXLFileAndDecryptedCompletion)completion
{
    WeakObj(self);
    NXFileBase *copyFileItem = [file copy];
    NXWebFileDownloaderProgressBlock progressBlock = ^(int64_t receivedSize, int64_t totalCount, double fractionCompleted){
        DLog(@"Project File Sharing :Downloading %lf", fractionCompleted);
    };
    return [[NXWebFileManager sharedInstance] downloadFile:(NXFileBase<NXWebFileDownloadItemProtocol>*)copyFileItem withProgress:progressBlock completed:^(NXFileBase *file, NSData *fileData, NSError *error) {
        StrongObj(self);
        if (self && [copyFileItem isEqual:file]) {
            if (error) {
                completion(nil,nil,nil,nil,error);
            }else{
                copyFileItem.localPath = file.localPath;
                copyFileItem.name = [NXCommonUtils getNXLFileOriginalName:file.name];
                NSError *error = nil;
                NSString *destTempPath = [self getTempFilePathWithForFile:copyFileItem error:&error];
                WeakObj(self);
                [[NXLoginUser sharedInstance].nxlOptManager decryptNXLFile:copyFileItem toPath:destTempPath shouldSendLog:NO withCompletion:^(NSString *filePath, NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSString *stewardID, BOOL isSteward, NSError *error) {
                    StrongObj(self);
                    if (self && [copyFileItem isEqual:file]) {
                        if (error) {
                            completion(nil,nil,nil,nil,error);
                        }else{
                            NXFile *newFileItem = [[NXFile alloc] init];
                            newFileItem.sorceType = NXFileBaseSorceTypeLocal;
                            newFileItem.localPath = filePath;
                            newFileItem.name = filePath.lastPathComponent;
                            completion(newFileItem,rights,duid,stewardID,nil);
                        }
                    }
                }];
            }
        }
    }];
}

- (void)shareRepoFile:(NXFileBase *)file recipients:(NSArray *)recipients permissions:(NXLRights *)permissions comment:(NSString *)comment withCompletion:(nxlOptShareFileCompletion)completion {
    // the file should only from myDrive or myVault.  Then there will be a optimize to sharing file(Do not need download)
    if (file.sorceType == NXFileBaseSorceTypeMyVaultFile) {
        file = [file copy];
        NXRepositoryModel *repo = [[NXLoginUser sharedInstance].myRepoSystem getNextLabsRepository];
        file.repoId = repo.service_id;
    }
    NXSharingRepositoryReqModel *reqModel = [[NXSharingRepositoryReqModel alloc] init];
    reqModel.file = file;
    NSMutableArray *recipientArray = [[NSMutableArray alloc] init];
    NSDictionary * recipient = nil;
    if (recipients.count) {
        for (NSInteger index = 0; index < recipients.count; ++index) {
            recipient = @{@"email":recipients[index]};
            [recipientArray addObject:recipient];
        }
    }
    reqModel.recipients = recipientArray;
    reqModel.rights = permissions;
    reqModel.validateDateModel = [permissions getVaildateDateModel];
    if([permissions getObligation:NXLOBLIGATIONWATERMARK]) {
         reqModel.watermarkArray = [permissions.getWatermarkString parseWatermarkWords];
    }
    reqModel.comment = comment;
    WeakObj(self);
    NXSharingRepositoryRequest *shareRepoFile = [[NXSharingRepositoryRequest alloc] init];
    [shareRepoFile requestWithObject:reqModel Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        if (error) {
            NSError *retError = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_SHARE userInfo:file.sorceType == NXFileBaseSorceTypeMyVaultFile?@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_UPDATE_RECIPIENTS_FAILED", nil)}:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_SHARE_FILE_FAILED", nil)}];
            completion(nil,nil, nil, nil, retError);
        }else{
            NXSharingRepositoryResponse *shareRepoResponse = (NXSharingRepositoryResponse *)response;
            if (shareRepoResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) {
                completion(nil,shareRepoResponse.duid, shareRepoResponse.alreadySharedList, shareRepoResponse.anewSharedList,nil);
                // DO cache
                NXNXLOptCacheNode *cacheNode = [[NXNXLOptCacheNode alloc] initWithDUID:shareRepoResponse.duid rights:permissions ownerID:[NXLoginUser sharedInstance].profile.individualMembership.ID];
                cacheNode.waterMarkContent = [permissions.getWatermarkString parseWatermarkWords];
                [self.nxlCache setObject:cacheNode forKey:[NXCommonUtils fileKeyForFile:file]];
            }else{
                NSError *retError = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_SHARE userInfo:file.sorceType == NXFileBaseSorceTypeMyVaultFile?@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_UPDATE_RECIPIENTS_FAILED", nil)}:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_SHARE_FILE_FAILED", nil)}];
                completion(nil,nil, nil, nil, retError);
            }
        }
    }];
}

- (NSString *)shareLocalFile:(NXFileBase *)file recipients:(NSArray *)recipients permissions:(NXLRights *)permissions comment:(NSString *)comment withCompletion:(nxlOptShareLocalFileCompletion)completion {
    
    NSString *optIdentify = [[NSString alloc] init];
    NXShareFileOperation *shareFileopt = [[NXShareFileOperation alloc] init];
    WeakObj(self);
    shareFileopt.shareFileIdentify = [self.nxlClient sharelocalFile:[NSURL fileURLWithPath:file.localPath] recipients:recipients permissions:permissions tags:@"" validateFileDict:[[permissions getVaildateDateModel] getRMSRESTAPIShareFormatDictionary] watermarkString:[permissions getWatermarkString] shareAsAttachment:NO comment:comment withCompletion:^(NSURL *originalFilePath,NSString *sharedFileName,NSArray *alreadySharedArray,NSArray *newSharedArray,NSError *error) {
        StrongObj(self);
        if (self) {
            if (error) {
                error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_SHARE userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_SHARE_FILE_FAILED", nil)}];
            }
            nxlOptShareLocalFileCompletion completeBlock = self.completeBlockDict[optIdentify];
            if (completeBlock) {
                completeBlock(originalFilePath,sharedFileName,alreadySharedArray,newSharedArray,error);
                [self.completeBlockDict removeObjectForKey:optIdentify];
                [self.operationDict removeObjectForKey:optIdentify];
            }
        }
    }];
    [self.operationDict setObject:shareFileopt forKey:optIdentify];
    [self.completeBlockDict setObject:completion forKey:optIdentify];
    [shareFileopt start];
    return optIdentify;
}

- (NSString *)reshareSharedWithMeFile:(NXSharedWithMeFile *)sharedWithMeFile recipients:(NSArray *)recipients withCompletion:(nxlOptShareFileCompletion)completion
{
    NSString *operationId = [[NSUUID UUID] UUIDString];
    NXSharedWithMeReshareFileOperation *reshareFileOpt = [[NXSharedWithMeReshareFileOperation alloc]initWithSharedWithMeFile:sharedWithMeFile withReceivers:recipients];
    [self.completeBlockDict setObject:completion forKey:operationId];
    [self.operationDict setObject:reshareFileOpt forKey:operationId];
    WeakObj(self);
    reshareFileOpt.finishReshareFileCompletion = ^(NXSharedWithMeFile *originalFile, NXSharedWithMeFile *freshFile, NXShareWithMeReshareResponseModel *responseModel, NSError *error) {
        StrongObj(self);
        nxlOptShareFileCompletion completion = self.completeBlockDict[operationId];
        if (completion) {
            if (error) {
                 completion(nil, nil, nil,nil, error);
            }else{
                completion(nil,originalFile.duid, responseModel.alreadySharedList, responseModel.freshSharedList,nil);
            }
        }
        [self.completeBlockDict removeObjectForKey:operationId];
        [self.operationDict removeObjectForKey:operationId];
    };
    [reshareFileOpt start];
    return operationId;
}

- (void)updateSharedFileRecipients:(NXFileBase *)file newRecipients:(NSArray *)newRecipients removedRecipients:(NSArray *)removedRecipients comment:(NSString *)comment withCompletion:(nxlOptUpateSharedFileCompletion)completion
{
    NSAssert([file isKindOfClass:[NXMyVaultFile class]], @"update share should only called in myVault as designed");
    NXMyVaultFile *myVaultFile = (NXMyVaultFile *)file;
    
    NXUpdateSharingRecipientsReqModel *reqModel = [[NXUpdateSharingRecipientsReqModel alloc] initWithFile:myVaultFile addedRecipients:newRecipients removedRecipients:removedRecipients comment:comment];
    NXUpdateSharingRecipientsRequest *request = [[NXUpdateSharingRecipientsRequest alloc] init];
    [request requestWithObject:reqModel Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if(error){
            error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_UPDATE_RECIPIENTS userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_UPDATE_RECIPIENTS_FAILED", nil)}];
            completion(nil, nil, error);
        }else{
            NXUpdateSharingRecipientsResponse *updateSharingResponse = (NXUpdateSharingRecipientsResponse *)response;
            if (updateSharingResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) {
                completion(updateSharingResponse.addedRecipients, updateSharingResponse.removedRecipients, nil);
            }else{
                error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_UPDATE_RECIPIENTS userInfo:@{NSLocalizedDescriptionKey:updateSharingResponse.rmsStatuMessage?updateSharingResponse.rmsStatuMessage: NSLocalizedString(@"MSG_UPDATE_RECIPIENTS_FAILED", nil)}];
                completion(nil, nil, error);
            }
        }
    }];
}
- (NSString *)revokeSharedFileByFileDuid:(NSString *)duid wtihCompletion:(nxlOptRevokeDocumentCompletion)completion {
     NSString *operationId = [[NSUUID UUID] UUIDString];
    NXRevokingSharedFileOperation *revokeOpt = [[NXRevokingSharedFileOperation alloc] initWithFileDuid:duid];
    [self.completeBlockDict setObject:completion forKey:operationId];
    [self.operationDict setObject:revokeOpt forKey:operationId];
       WeakObj(self);
    revokeOpt.revokeSharedFileCompletion = ^(NSError *error) {
        StrongObj(self);
        nxlOptRevokeDocumentCompletion comp = self.completeBlockDict[operationId];
        comp(error);
        [self.completeBlockDict removeObjectForKey:operationId];
        [self.operationDict removeObjectForKey:operationId];
    };
    [revokeOpt start];
    return operationId;
    
}
- (void)revokeDocument:(NXFileBase *)file withCompletion:(nxlOptRevokeDocumentCompletion)completion
{
    NSAssert([file isKindOfClass:[NXMyVaultFile class]], @"revoke document should only called in myVault as designed");
    [self.nxlClient revokingDocumentByDocumentId:((NXMyVaultFile *)file).duid withCompletion:^(NSError *error) {
        if (error) {
            error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_REVOKE userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_UPDATE_RECIPIENTS_FAILED", nil)}];
        }
        else
        {
            [[NXLoginUser sharedInstance].myVault updateMyVaultFileRevokedStatus:(NXMyVaultFile *)file];
        }
        
        completion(error);
    }];
}

- (void)getNXLFileRights:(NXFileBase *)file withWatermark:(BOOL)needWatermark withCompletion:(nxlOptGetNXLRightsCompletion)completion
{
    if ([file isKindOfClass:[NXOfflineFile class]] || file.isOffline == YES) {
        [[NXOfflineFileManager sharedInstance] queryRightsForFile:file withCompletion:^(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray<NXWatermarkWord *> *waterMarkWords, NSString *owner, BOOL isOwner, NSError *error) {
            if (error) {
                error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_GETPOLICY userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_GET_RIGHTS_FAILED", nil)}];
                completion(duid, rights, classifications, waterMarkWords, owner, isOwner, error);
            }else{
                completion(duid,rights,classifications,waterMarkWords,owner,isOwner,nil);
            }
        }];
        return;
    }
    
    // first hit cache.
    NXNXLOptCacheNode *cacheNode = [self.nxlCache objectForKey:[NXCommonUtils fileKeyForFile:file]];
    if (cacheNode) {
        if (cacheNode.waterMarkContent || needWatermark == NO || ![cacheNode.rights getObligation:NXLOBLIGATIONWATERMARK]) {
            BOOL isOwner = [NXCommonUtils isStewardUser:cacheNode.ownerId forFile:file];
            completion(cacheNode.DUID, cacheNode.rights, nil, cacheNode.waterMarkContent, cacheNode.ownerId, isOwner, nil);
            return;
        }
    }
    if (cacheNode && cacheNode.rights) { // company-defined rights, no ownner
        NSDate *nowDate = [NXTimeServerManager sharedInstance].currentServerTime;
        if (nowDate) {
            NSTimeInterval timeSlide = nowDate.timeIntervalSince1970 - cacheNode.cacheDate.timeIntervalSince1970;
            if (timeSlide < MAX_SERVER_POLICY_LIFE) {
                completion(cacheNode.DUID, cacheNode.rights, cacheNode.classification, cacheNode.waterMarkContent, cacheNode.ownerId, NO, nil);
                return;
            }
        }
    }
    
    // miss cache or need watermark info
    if([file isKindOfClass:[NXMyVaultFile class]] && ((NXMyVaultFile *)file).duid && needWatermark == YES){
        WeakObj(self);
        NXMyVaultMetadataRequest *metadataRequest = [[NXMyVaultMetadataRequest alloc] init];
        [metadataRequest requestWithObject:file Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
            StrongObj(self);
            if (self) {
                if (error) {
                    error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_GETPOLICY userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_GET_RIGHTS_FAILED", nil)}];
                    completion(nil, nil, nil, nil, nil, NO, error);
                }else{
                    NXMyVaultMetadataResponse *metadataResponse = (NXMyVaultMetadataResponse *)response;
                    if (metadataResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) {
                        NXLRights *rights = [[NXLRights alloc] init];
                        for (NSString *right in metadataResponse.rights) {
                            AddRightBlock addRight = self.parseRightsDict[right];
                            addRight(rights);
                        }
                        
                        [rights setFileValidateDate:metadataResponse.validateDateModel];
                        
                        // do cache
                        NXNXLOptCacheNode *cacheNode = [[NXNXLOptCacheNode alloc] initWithDUID:((NXMyVaultFile *)file).duid rights:rights ownerID:[NXLoginUser sharedInstance].profile.individualMembership.ID];
                        [self.nxlCache setObject:cacheNode forKey:[NXCommonUtils fileKeyForFile:file]];

                        // call back
                        completion(cacheNode.DUID, rights, nil, nil, [NXLoginUser sharedInstance].profile.individualMembership.ID, YES, nil);
                    }else{
                        error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_GETPOLICY userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_GET_RIGHTS_FAILED", nil)}];
                        completion(nil, nil, nil, nil, nil, NO, error);
                    }
                }
            }
        }];
     }else{ // all file from other repository, need download nxl header
        WeakObj(self);
         [((NXFile *)file) getNXLHeader:^(NXFileBase *file, NSData *fileData, NSError *error) {
             StrongObj(self);
             if (self) {
                 if (error) {
                     error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_GETPOLICY userInfo:@{NSLocalizedDescriptionKey:error.localizedDescription?: NSLocalizedString(@"MSG_COM_GET_RIGHTS_FAILED", nil)}];
                     completion(nil, nil, nil, nil, nil, NO, error);
                 }else{
                     NSDictionary *sharedInfoDict = nil;
                     if ([file isKindOfClass:[NXSharedWithProjectFile class]]) {
                         sharedInfoDict = @{
                             @"sharedSpaceType": @1,
                             @"sharedSpaceId": ((NXSharedWithProjectFile *)file).sharedProject.projectId,
                             @"sharedSpaceUserMembership": ((NXSharedWithProjectFile *)file).sharedProject.membershipId
                         };
                     }
                     [NXLMetaData getPolicySection:file.localPath clientProfile:[NXLoginUser sharedInstance].profile sharedInfo:sharedInfoDict complete:^(NSDictionary *policySection, NSDictionary *classificationSection, NSError *error){
                        if(error){
                            if (error.code == 403) {
                                error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_ACCESS_DENY userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_NO_ACCESS_RIGHT", nil)}];
                            }else{
                                error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_GETPOLICY userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_GET_RIGHTS_FAILED", nil)}];
                            }
                            if (error.code == NXRMC_ERROR_CODE_NXFILE_ACCESS_DENY) {
                                NXLRights *rights = [[NXLRights alloc] init];
                                NSString *duid = [NXLMetaData getNXLFileDUID:file.localPath];
                                NSString *ownerId = [NXLMetaData getNXLFileOwnerId:file.localPath];
                                // Do right cache
                                if (policySection) {
                                    NSArray* policies = [policySection objectForKey:@"policies"];
                                    NSDictionary *policy = policies[0];
                                    NSArray* namedRights = [policy objectForKey:@"rights"];
                                    NSArray* namedObs = [policy objectForKey:@"obligations"];
                                    rights = [[NXLRights alloc]initWithRightsObs:namedRights obligations:namedObs];
                                    NSArray *watermark = nil;
                                    
                                    // call back
                                    BOOL isOwner = [NXCommonUtils isStewardUser:ownerId forFile:file];
                                    // parse watermark
                                    if ([rights getObligation:NXLOBLIGATIONWATERMARK]) {
                                        watermark = [[rights getWatermarkString] parseWatermarkWords];
                                        
                                    }
                                    
                                    // parse expire time
                                    NXLFileValidateDateModel *validateDateModel = [self extractFileValidateDateFromPolicySection:policy];
                                    [rights setFileValidateDate:validateDateModel];
                                    
//                                    NXNXLOptCacheNode *cacheNode = [[NXNXLOptCacheNode alloc] initWithDUID:duid rights:rights ownerID:ownerId];
//                                    [self.nxlCache setObject:cacheNode forKey:[NXCommonUtils fileKeyForFile:file]];
                                    completion(duid, rights, nil, watermark, ownerId, isOwner, error);
                                    
                                }else if (classificationSection) {
                                    NSMutableArray *classifications = [NSMutableArray array];
                                    [classificationSection enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSArray * obj, BOOL * _Nonnull stop) {
                                        NXClassificationCategory *classificaitonCategory = [[NXClassificationCategory alloc] init];
                                        classificaitonCategory.name = key;
                                        for (NSString *lab in obj) {
                                            NXClassificationLab *classificaitonLab = [[NXClassificationLab alloc] init];
                                            classificaitonLab.name = lab;
                                            [classificaitonCategory.selectedLabs addObject:classificaitonLab];
                                        }
                                        [classifications addObject:classificaitonCategory];
                                    }];
                                    completion(duid, rights, classifications, nil, ownerId, NO, error);
                                }else {
                                    completion(duid, rights, nil, nil, ownerId, NO, error);
                                }
                            }else{
                                completion(nil, nil, nil, nil, nil, NO, error);
                            }
                        }else{
                             NSString *duid = [NXLMetaData getNXLFileDUID:file.localPath];
                            
                            // step1. check adhoc encrypt or classificaiton encrypt
                            if (policySection) {
                                NSArray* policies = [policySection objectForKey:@"policies"];
                                NSDictionary *policy = policies[0];
                                NSArray* namedRights = [policy objectForKey:@"rights"];
                                NSArray* namedObs = [policy objectForKey:@"obligations"];
                                NXLRights *rights = [[NXLRights alloc]initWithRightsObs:namedRights obligations:namedObs];
                               
                                NSString *ownerId = [NXLMetaData getNXLFileOwnerId:file.localPath];
                                
                                NSArray *watermark = nil;
                                
                                // Do right cache
                                NXNXLOptCacheNode *cacheNode = [[NXNXLOptCacheNode alloc] initWithDUID:duid rights:rights ownerID:ownerId];
                                [self.nxlCache setObject:cacheNode forKey:[NXCommonUtils fileKeyForFile:file]];
                                
                                // call back
                                BOOL isOwner = [NXCommonUtils isStewardUser:cacheNode.ownerId forFile:file];
                                // parse watermark
                                if ([rights getObligation:NXLOBLIGATIONWATERMARK]) {
                                    watermark = [[rights getWatermarkString] parseWatermarkWords];
                                }
                                
                                // parse expire time
                                NXLFileValidateDateModel *validateDateModel = [self extractFileValidateDateFromPolicySection:policy];
                                [rights setFileValidateDate:validateDateModel];
                                
                                completion(duid, rights, nil, watermark, ownerId, isOwner, nil);
                            }else if(classificationSection) {
                                NSMutableArray *classifications = [NSMutableArray array];
                                [classificationSection enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSArray * obj, BOOL * _Nonnull stop) {
                                    NXClassificationCategory *classificaitonCategory = [[NXClassificationCategory alloc] init];
                                    classificaitonCategory.name = key;
                                    for (NSString *lab in obj) {
                                        NXClassificationLab *classificaitonLab = [[NXClassificationLab alloc] init];
                                        classificaitonLab.name = lab;
                                        [classificaitonCategory.selectedLabs addObject:classificaitonLab];
                                    }
                                    [classifications addObject:classificaitonCategory];
                                }];
                                
                                // get policy rights
                                  // before return, get rights
                                NSString *ownerId = [NXLMetaData getNXLFileOwnerId:file.localPath];
                                
                                // for shareWithProjectFile use shared project membershipID,not source project membershipID
                                  NSString *owner = ownerId;
                                if ((file.sorceType == NXFileBaseSorceType3rdOpenIn || file.sorceType == NXFileBaseSorceTypeRepoFile || file.sorceType == NXFileBaseSorceTypeSharedWorkspaceFile || file.sorceType == NXFileBaseSorceTypeLocalFiles) && ownerId) {
                                   
                                        NSArray *ownnerArray = [ownerId componentsSeparatedByString:@"@"];
                                        if (ownnerArray.count) {
                                            NSString *currentFileTenantGroupName = ownnerArray.lastObject;
                                            
                                            if ([[NXLoginUser sharedInstance].profile.tenantMembership.tokenGroupName isEqualToString:currentFileTenantGroupName]) {
                                                owner = [NXLoginUser sharedInstance].profile.tenantMembership.ID;
                                            }else{
                                                for (NXLMembership *membership in [NXLoginUser sharedInstance].profile.memberships) {
                                                    if ([membership.tokenGroupName isEqualToString:currentFileTenantGroupName]) {
                                                        owner = membership.ID;
                                                        break;
                                                    }else{
                                                        owner = [NXLoginUser sharedInstance].profile.tenantMembership.ID;
                                                    }
                                                }
                                            }
                                        }else{
                                            owner = [NXLoginUser sharedInstance].profile.tenantMembership.ID;
                                        }
                                   
                                } else if (file.sorceType == NXFileBaseSorceTypeSharedWithProject){
                                      NXSharedWithProjectFile *shareFromProjectFile = (NXSharedWithProjectFile *)file;
                                      if(shareFromProjectFile.sharedProject.membershipId){
                                          owner = shareFromProjectFile.sharedProject.membershipId;
                                      }
                                  }else if(file.sorceType == NXFileBaseSorceTypeProject){
                                      NXProjectFile *projectFile = (NXProjectFile *)file;
                                      NXProjectModel *projectModel = [[NXLoginUser sharedInstance].myProject getProjectModelForProjectId:projectFile.projectId];
                                      if (projectModel.membershipId) {
                                          owner = projectModel.membershipId;
                                      }
                                  }else{
                                      owner = [NXLoginUser sharedInstance].profile.tenantMembership.ID;
                                  }
                                
                                NSDictionary *dictModel = @{MEMBER_SHIP_ID:owner,
                                                            RESOURCE_NAME:file.name,
                                                            EVAL_NAME:@"RMS",
                                                            DUIDKEY:duid,
                                                            RIGHTS:@(NXLRIGHTVIEW|NXLRIGHTPRINT|NXLRIGHTSDOWNLOAD|NXLRIGHTEDIT|NXLRIGHTDECRYPT|NXLRIGHTSHARING|NXLRIGHTSCREENCAP),
                                                            USERID:[NXLoginUser sharedInstance].profile.userId,
                                                            EVALTYPE:@0,
                                                            CATEGORIES_ARRAY:classifications
                                                            };
                                NXPerformPolicyEvaluationAPIRequest *requeset = [[NXPerformPolicyEvaluationAPIRequest alloc] init];
                                [requeset requestWithObject:dictModel Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
                                    if (error) {
                                        error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_DECRYPT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_EVALUATION_FAILED", nil)}];
                                        completion(nil, nil, nil, nil, nil, NO, error);
                                    }else {
                                        if (response.rmsStatuCode != NXRMS_ERROR_CODE_SUCCESS) {
                                            NSString *errorDescription = NSLocalizedString(@"MSG_COM_EVALUATION_FAILED", nil);
                                            if (response.rmsStatuCode == NXRMS_PROJECT_CLASSIFICATION_NOT_MATCH_RIGHTS) {
                                                errorDescription = NSLocalizedString(@"MSG_COM_NO_POLICY_TO_EVALUATE", nil);
                                            }
                                             error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_DECRYPT userInfo:@{NSLocalizedDescriptionKey:errorDescription}];
                                            completion(nil, nil,classifications, nil, nil, NO, error);
                                        } else {
                                            NXPerformPolicyEvaluationAPIResponse *evaResponse = (NXPerformPolicyEvaluationAPIResponse *)response;
                                            NXLRights *right = evaResponse.evaluationRight;
                                            if ([right getWatermarkString]) {
                                                NSString *newWatermarkStr = [self conversionPolicyWatermarkStringWithClassifications:classifications andCurrentWatermarkString:[right getWatermarkString]];
                                                [right setWatermarkString:newWatermarkStr];
                                            }
                                            NSArray *watermark  = [[right getWatermarkString] parseWatermarkWords];
                                            // step2. return block
                                            completion(duid, right, classifications, watermark, ownerId, NO, nil);
                                        }
                                    }
                                }]; // end NXPerformPolicyEvaluationAPIRequest
                                
                            }else {
                                NSAssert(NO, @"Encrypt type should be adhoc or classification");
                                completion(nil, nil, nil, nil, nil, NO, nil);
                            }
                        }
                    }];
                 }
             }
         }];
    }
}
- (NSString *)checkCenterPolicyFileRightsForNXLFile:(NXFileBase *)fileBase copyToDestPathFolder:(NXFileBase *)pathFolder withDestMemberShip:(NSString *)membershipId  withCompletion:(nxlCheckCenterPolicyFileRightCompletion)completion{

    NSString *operationId = [[NSUUID UUID] UUIDString];
    NXPolicyTransFormForCopyOperation *transformOperation = [[NXPolicyTransFormForCopyOperation alloc] initWithSourceFile:fileBase andDestSpaceFolder:pathFolder andDestSpaceMembershipId:membershipId];
    [self.completeBlockDict setObject:completion forKey:operationId];
    [self.operationDict setObject:transformOperation forKey:operationId];
    WeakObj(self);
    transformOperation.transFormPemissionsFinishCompletion = ^(NXLRights * _Nonnull rights, NSError * _Nonnull error) {
        StrongObj(self);
        nxlCheckCenterPolicyFileRightCompletion completion = self.completeBlockDict[operationId];
        if (completion) {
            completion(rights,error);
        }
        [self.completeBlockDict removeObjectForKey:operationId];
        [self.operationDict removeObjectForKey:operationId];
    };
    [transformOperation start];
    return operationId;
    
}
- (void)checkCenterPolicyFileRightsWithMemberShip:(NSString *)membershipId classifications:(NSArray<NXClassificationCategory *> *) classifications fileName:(NSString *)fileName withCompletion:(nxlCheckCenterPolicyFileRightCompletion)completion {
    NSDictionary *dictModel = @{MEMBER_SHIP_ID:membershipId,
                                RESOURCE_NAME:fileName,
                                EVAL_NAME:@"RMS",
                                RIGHTS:@(NXLRIGHTVIEW|NXLRIGHTPRINT|NXLRIGHTSDOWNLOAD|NXLRIGHTEDIT|NXLRIGHTDECRYPT|NXLRIGHTSHARING|NXLRIGHTSCREENCAP),
                                USERID:[NXLoginUser sharedInstance].profile.userId,
                                EVALTYPE:@0,
                                CATEGORIES_ARRAY:classifications
                                };
    NXPerformPolicyEvaluationAPIRequest *requeset = [[NXPerformPolicyEvaluationAPIRequest alloc] init];
    [requeset requestWithObject:dictModel Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (error) {
            error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_DECRYPT userInfo:@{NSLocalizedDescriptionKey:error.localizedDescription?: NSLocalizedString(@"MSG_COM_EVALUATION_FAILED", nil)}];
            completion(nil, error);
        }else {
            if (response.rmsStatuCode != NXRMS_ERROR_CODE_SUCCESS) {
                NSString *errorDescription = NSLocalizedString(@"MSG_COM_EVALUATION_FAILED", nil);
                if (response.rmsStatuCode == NXRMS_PROJECT_CLASSIFICATION_NOT_MATCH_RIGHTS) {
                    errorDescription = NSLocalizedString(@"MSG_COM_NO_POLICY_TO_EVALUATE", nil);
                }
                error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_DECRYPT userInfo:@{NSLocalizedDescriptionKey:errorDescription}];
                completion(nil, error);
            }else {
                NXPerformPolicyEvaluationAPIResponse *evaResponse = (NXPerformPolicyEvaluationAPIResponse *)response;
                NXLRights *right = evaResponse.evaluationRight;
//                if ([right getWatermarkString]) {
//                    NSString *newWatermarkStr = [self conversionPolicyWatermarkStringWithClassifications:classifications andCurrentWatermarkString:[right getWatermarkString]];
//                    [right setWatermarkString:newWatermarkStr];
//                }
                completion(right, nil);
            }
        }
        
    }];
}
- (NSString *)conversionPolicyWatermarkStringWithClassifications:(NSArray<NXClassificationCategory *> *) classifications andCurrentWatermarkString:(NSString *)watermarkString{
    if (watermarkString) {
        if ([watermarkString containsString:@"$(Classification)"] || [watermarkString containsString:@"$(classification)"] || [watermarkString containsString:@"$(CLASSIFICATION)"]) {
            NSString *tagsString = @" ";
            for (NXClassificationCategory *classificationCategory in classifications) {
                if (classificationCategory.selectedLabs.count > 0) {
                    NSString *labs = @"";
                    for (NXClassificationLab *classificationLab in classificationCategory.selectedLabs) {
                        labs = [labs stringByAppendingFormat:@"%@%@%@%@",classificationCategory.name,@"=",classificationLab.name,@";"];
//                        labs = [labs stringByAppendingString:classificationCategory.name];
//                        labs = [labs stringByAppendingString:@"="]
//                        labs = [labs stringByAppendingString:classificationLab.name];
                    }
                tagsString = [tagsString stringByAppendingString:labs];
                }
                
            }
           

            NSArray *classificationArray = @[@"$(Classification)",@"$(classification)",@"$(CLASSIFICATION)"];
            for (NSString *classificationStr in classificationArray) {
                NSRange  range = [watermarkString rangeOfString:classificationStr];
                if (range.location != NSNotFound) {
                    NSString *newWaterSring = [watermarkString stringByReplacingCharactersInRange:range withString:tagsString];
                    return newWaterSring;
                    break;
                }
            }
            
           
        }

        NSMutableDictionary *cateforyDic = [NSMutableDictionary dictionary];
        for (NXClassificationCategory *classificationCategory in classifications) {
            NSString *predefinedStrng = [NSString stringWithFormat:@"$(%@)",classificationCategory.name];
            NSString *labs = @"";
            for (NXClassificationLab *classificationLab in classificationCategory.selectedLabs) {
                labs = [labs stringByAppendingFormat:@"%@%@%@%@",classificationCategory.name,@"=",classificationLab.name,@";"];
            }
            [cateforyDic setValue:labs forKey:predefinedStrng];
        }
        for (NSString *predefinedString in cateforyDic.allKeys) {
            if ([watermarkString containsString:predefinedString]) {
                [watermarkString stringByReplacingOccurrencesOfString:predefinedString withString:cateforyDic[predefinedString]];
            }
            return watermarkString;
        }
       
        
    }
    
    return nil;
}


- (BOOL)isNXLFile:(NXFileBase *)file
{
    if ([file isKindOfClass:[NXMyVaultFile class]] || [file isKindOfClass:[NXProjectFile class]]) {
        return YES;
    }
    if (!file.localPath) {
        NSString *extension = file.name.pathExtension;
        if ([extension compare:NXL options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            return YES;
        }else{
            return NO;
        }
    }
    return [NXLMetaData isNxlFile:file.localPath];
}

- (void)cancelNXLOpt:(NSString *)optIdentify
{
    if (optIdentify) {
        NSOperation *opt = self.operationDict[optIdentify];
        [opt cancel];
        [self.operationDict removeObjectForKey:optIdentify];
        [self.completeBlockDict removeObjectForKey:optIdentify];
        [[NXLoginUser sharedInstance].sharedFileManager cancelOperation:optIdentify];
    }
}

- (void)canDoOperation:(NXLRIGHT)operationType forFile:(NXFileBase *)file withCompletion:(nxlOptCanDoOperationCompletion)completion
{
    NSDate *currentDate = [NXTimeServerManager sharedInstance].currentServerTime;
    if ([file isKindOfClass:[NXOfflineFile class]] || file.isOffline == YES) {
        NXOfflineFile *offlineFile = (NXOfflineFile *)file;
        [[NXOfflineFileManager sharedInstance] canDoOperation:operationType forFile:offlineFile withCompletion:^(BOOL isAllowed, NSString *duid, NXLRights *rights, NSString *owner, BOOL isOwner, NSError *error) {
            completion(isAllowed,duid,rights,owner,isOwner,error);
        }];
        return;
    }
    
    // step1. first read caceh
    BOOL isOwner = NO;
    NXNXLOptCacheNode *cacheNode = [self.nxlCache objectForKey:[NXCommonUtils fileKeyForFile:file]];
    if (cacheNode) { // only AD-ho encrypt file have ownner
        isOwner = [NXCommonUtils isStewardUser:cacheNode.ownerId forFile:file];
    }
    if (cacheNode) {
        NXLRights *right = cacheNode.rights;
         // check expire date
        if (!isOwner && [right getVaildateDateModel].type != NXLFileValidateDateModelTypeNeverExpire) {
            NSDate *nowDate = [[NXTimeServerManager sharedInstance] currentServerTime];
            if (nowDate == nil) {
                NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_DECRYPT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_NO_TIME_SERVER", nil)}];
                completion(NO, nil, nil, nil, NO, error);
                return;
            }
            BOOL isValidateDate = [[right getVaildateDateModel] checkInValidateDateRange:nowDate];
            if (!isValidateDate) {
                completion(NO, cacheNode.DUID, [right copy],nil, NO, nil);
                
                if (operationType != NXLRIGHTSHARING) { // share will do log at RMS
                    NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc]init];
                    model.duid = cacheNode.DUID;
                    model.owner = cacheNode.ownerId;
                    model.operation = [self nxlRightToLogRight:operationType];
                    model.repositoryId = @"";
                    model.filePathId = file.fullServicePath;
                    model.filePath = file.fullServicePath;
                    model.fileName = file.fullServicePath;
                    model.activityData = @"TestData";
                    model.accessTime = [NSNumber numberWithLongLong:([currentDate timeIntervalSince1970] * 1000)];
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
        if ([right getRight:operationType] || isOwner) {
            completion(YES, cacheNode.DUID, [right copy], cacheNode.ownerId, isOwner, nil);
            if (operationType != NXLRIGHTSHARING) { // share will do log at RMS
                NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc]init];
                model.duid = cacheNode.DUID;
                model.owner = cacheNode.ownerId;
                model.operation = [self nxlRightToLogRight:operationType];
                model.repositoryId = @"";
                model.filePathId = file.fullServicePath;
                model.filePath = file.fullServicePath;
                model.fileName = file.fullServicePath;
                model.activityData = @"TestData";
                model.accessTime = [NSNumber numberWithLongLong:([currentDate timeIntervalSince1970] * 1000)];
                model.accessResult = [NSNumber numberWithInteger:1];
                NXLogAPI *logAPI = [[NXLogAPI alloc]init];
                [logAPI generateRequestObject:model];
                [[NXSyncHelper sharedInstance] cacheRESTAPI:logAPI cacheURL:[NXCacheManager getLogCacheURL]];
                [[NXSyncHelper sharedInstance] uploadPreviousFailedRESTRequestWithCachedURL:[NXCacheManager getLogCacheURL] mustAllSuccess:NO Complection:^(id object, NSError *error) {
                    
                }];
                [self.fileLogManager insertNXLFileActivity:model];
            }
        }else{
            completion(NO, cacheNode.DUID, [right copy], nil, NO, nil);
            // send deny log
            NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc]init];
            model.duid = cacheNode.DUID;
            model.owner = cacheNode.ownerId;
            model.operation = [self nxlRightToLogRight:operationType];
            model.repositoryId = @"";
            model.filePathId = file.fullServicePath;
            model.filePath = file.fullServicePath;
            model.fileName = file.fullServicePath;
            model.activityData = @"TestData";
            model.accessTime = [NSNumber numberWithLongLong:([currentDate timeIntervalSince1970] * 1000)];
            model.accessResult = [NSNumber numberWithInteger:0];
            NXLogAPI *logAPI = [[NXLogAPI alloc]init];
            [logAPI generateRequestObject:model];
            [[NXSyncHelper sharedInstance] cacheRESTAPI:logAPI cacheURL:[NXCacheManager getLogCacheURL]];
            [[NXSyncHelper sharedInstance] uploadPreviousFailedRESTRequestWithCachedURL:[NXCacheManager getLogCacheURL] mustAllSuccess:NO Complection:^(id object, NSError *error) {
                
            }];
            [self.fileLogManager insertNXLFileActivity:model];
        }
    }else{ // NO Cache, get right first
        [self getNXLFileRights:file withWatermark:NO withCompletion:^(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray *watermark, NSString *owner, BOOL isOwner, NSError *error) {
            if (error && error.code != NXRMC_ERROR_CODE_NXFILE_ACCESS_DENY) {
                completion(NO, nil, nil, nil, NO, error);
            }else{
                if (classifications == nil) { // means AD-ho encrypt
                     // if get rights success, we will have cache, so read cache
                   NXNXLOptCacheNode *cacheNode = [self.nxlCache objectForKey:[NXCommonUtils fileKeyForFile:file]];
                   NSAssert(cacheNode, @"MUST HAVE CACHE");
                   
                   [self canDoOperation:operationType forFile:file withCompletion:^(BOOL isAllowed, NSString *duid, NXLRights *rights, NSString *owner, BOOL isOwner, NSError *error) {
                       completion(isAllowed, duid, rights, owner, isOwner, error);
                   }];
                }else {
                    BOOL isAllowed = NO;
                    if ([rights getRight:operationType] || isOwner) {
                        completion(YES, duid, [rights copy], owner, isOwner, nil);
                        isAllowed = YES;
                    }else{
                        completion(NO, duid, [rights copy], nil, NO, nil);
                    }
                    // send log
                    NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc]init];
                    model.duid = duid;
                    model.owner = owner;
                    model.operation = [self nxlRightToLogRight:operationType];
                    model.repositoryId = @"";
                    model.filePathId = file.fullServicePath;
                    model.filePath = file.fullServicePath;
                    model.fileName = file.fullServicePath;
                    model.activityData = @"TestData";
                    model.accessTime = [NSNumber numberWithLongLong:([currentDate timeIntervalSince1970] * 1000)];
                    model.accessResult = isAllowed? [NSNumber numberWithInteger:1]:[NSNumber numberWithInteger:0];
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
}

- (void)cacheRights:(NXLRights *)rights duid:(NSString *)duid ownerId:(NSString *)ownerId forFile:(NXFileBase *)file
{
    NXNXLOptCacheNode *cacheNode = [[NXNXLOptCacheNode alloc] initWithDUID:duid rights:rights ownerID:ownerId];
    [self.nxlCache setObject:cacheNode forKey:[NXCommonUtils fileKeyForFile:file]];
}

- (void)checkClassificationFileRights:(NXFileBase *)file duid:(NSString *)duid membershipId:(NSString *)memberShipId withCompletion:(nxlOptClassificationRightsCompletion)completion {
    
}

#pragma mark - special for nxlClient
- (void)signOut:(NSError **)error
{
    [self.nxlClient signOut:nil];
    [self.nxlCache removeAllObjects];
    [self.completeBlockDict removeAllObjects];
}
- (void)updateProfile:(NXLProfile *)profile
{
    [self.nxlClient updateClientProfile:profile];
}

- (NSNumber *)nxlRightToLogRight:(NXLRIGHT)nxlRight{
    long nxlRightsValue = nxlRight;
    return self.nxlRightToLogRightDict[[NSNumber numberWithLong:nxlRightsValue]];
}

- (void)cleanCachedRight:(NXFileBase *)file {
    [self.nxlCache removeObjectForKey:[NXCommonUtils fileKeyForFile:file]];
}

#pragma mark - private method
- (NSString *)getTempFilePathWithForFile:(NXFileBase *)file error:(NSError **)Error
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

- (NSString *)getOrignalTempFilePathWithForFile:(NXFileBase *)file error:(NSError **)Error
{
    NSString *tmpPath = [NXCommonUtils getConvertFileTempPath];
    file.name = [NXCommonUtils getNXLFileOriginalName:file.name];
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

- (void)cacheNXLInfo:(NXLRights *)rights forFile:(NXFileBase *)file
{
    // do cache rights
    NSString *fileKey = [NXCommonUtils fileKeyForFile:file];
    NSString *DUID = [NXLMetaData getNXLFileDUID:file.localPath];
    NSString *ownId = [NXLMetaData getNXLFileOwnerId:file.localPath];
    
    NXNXLOptCacheNode *cacheNode = [[NXNXLOptCacheNode alloc] initWithDUID:DUID rights:rights ownerID:ownId];
    [self.nxlCache setObject:cacheNode forKey:fileKey];
}

- (NXLFileValidateDateModel *)extractFileValidateDateFromPolicySection:(NSDictionary *)policySection {
    NXLFileValidateDateModel *validateDateModel = nil;
    NSDictionary *conditions = [policySection objectForKey:@"conditions"];
    NSDictionary *environment = conditions[@"environment"];
    if (environment == nil) {
        validateDateModel = [[NXLFileValidateDateModel alloc] initWithNXFileValidateDateModelType:NXLFileValidateDateModelTypeNeverExpire withStartTime:nil endTIme:nil];
    }else {
        // environment type 0: means two operator type1 : means one operator
        if (((NSNumber *)environment[@"type"]).integerValue == 0) {
            NSArray *expressions = environment[@"expressions"];
          
            NSDictionary *firstDict = expressions[0];
            NSDictionary *secondDict = expressions[1];
            NSDictionary *startDateDict = nil;
            NSDictionary *endDateDict = nil;
            
            if ([firstDict[@"operator"] isEqualToString:@">="]) {
                startDateDict = firstDict;
                endDateDict = secondDict;
            }else {
                startDateDict = secondDict;
                endDateDict = firstDict;
            }
            long long startSeconds = (((NSNumber *)startDateDict[@"value"]).longLongValue)/1000;
            long long endSeconds = (((NSNumber *)endDateDict[@"value"]).longLongValue)/1000;
            
            validateDateModel = [[NXLFileValidateDateModel alloc] initWithNXFileValidateDateModelType:NXLFileValidateDateModelTypeRange withStartTime:[NSDate dateWithTimeIntervalSince1970:startSeconds] endTIme:[NSDate dateWithTimeIntervalSince1970:endSeconds]];
        }else if(((NSNumber *)environment[@"type"]).integerValue == 1) {
            long long endSeconds = ((NSNumber *)environment[@"value"]).longLongValue/1000;
            validateDateModel = [[NXLFileValidateDateModel alloc] initWithNXFileValidateDateModelType:NXLFileValidateDateModelTypeAbsolute withStartTime:[NSDate date] endTIme:[NSDate dateWithTimeIntervalSince1970:endSeconds]];
            
        }
    }
    return validateDateModel;
}

- (NSString *)convertNXLFile:(NXFileBase *)file withNewMembershipId:(NSString *)newMembershipId shouldRename:(BOOL )shouldRename newName:(NSString *)newName completion:(convertNXLFileCompletion)completion
{
    // judge current file is NXLFile
     BOOL isNXL = [[NXLoginUser sharedInstance].nxlOptManager isNXLFile:file];
       if (!isNXL) {
          NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_ISNOTNXL userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_PROCESSING_FILE_FAILED", nil)}];
           completion(nil, nil,nil,nil,nil,error);
           return nil;
       }
     
    NSError *err = nil;
    NSString *tempPath = [self getOrignalTempFilePathWithForFile:file error:&err];
     if (err) {
         completion(nil,nil,nil,nil,nil,err);
         return nil;
     }
     
     NSString *operationId = [[NSUUID UUID] UUIDString];
     [self.completeBlockDict setObject:completion forKey:operationId];
     NXEncryptFileOperation *enryptFileOpt = [[NXEncryptFileOperation alloc] init];
     [self.operationDict setObject:enryptFileOpt forKey:operationId];
     
     // do decrypt operation
    [self decryptNXLFile:file toPath:tempPath shouldSendLog:NO withCompletion:^(NSString *filePath, NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSString *owner, BOOL isOwner, NSError *error) {
            if (!error) {
                NXFile *decryptFile = [[NXFile alloc]init];
                decryptFile.name = tempPath.lastPathComponent;
                decryptFile.size = file.size;
                decryptFile.localPath = tempPath;
                decryptFile.sorceType = NXFileBaseSorceTypeLocal;
                if (classifications) {
                    // means protected by centerPolicy
                    // First step @@------>>>>change classification array into dictionary
                   NSMutableDictionary *classificaitonDict = [[NSMutableDictionary alloc] init];
                   for (NXClassificationCategory *classificationCategory in classifications) {
                       if (classificationCategory.selectedLabs.count > 0) {
                           NSMutableArray *labs = [[NSMutableArray alloc] init];
                           for (NXClassificationLab *classificationLab in classificationCategory.selectedLabs) {
                               NSString *labName = classificationLab.name;
                               [labs addObject:labName];
                           }
                           [classificaitonDict setObject:labs forKey:classificationCategory.name];
                       }
                   }
                    // judge should rename
                    NSString *fileName = decryptFile.name;
                    if (shouldRename && newName.length > 0) {
                        fileName = newName;
                    }
                    // Second step @@------>>>>  do encrypt operation
                    [NXLMetaData encrypt:decryptFile.localPath destPath:[NXCommonUtils createNewNxlTempFile:fileName] clientProfile:[NXLoginUser sharedInstance].profile membershipId:newMembershipId classifications:classificaitonDict encryptdDate:[NXTimeServerManager sharedInstance].currentServerTime complete:^(NSError *error, NSString *enryptedFilePath, id appendInfo) {
                         nxlOptEncryptCompletion completionBlock = self.completeBlockDict[operationId];
                        if (error) {
                            if (completionBlock) {
                            error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_ENCRYPT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_PROCESSING_FILE_FAILED", nil)}];
                              completion(nil,nil,nil,nil,nil,error);
                           }
                        }else {
                            if (completionBlock) {
                               NXFile *newFile = [[NXFile alloc] init];
                                newFile.name = enryptedFilePath.lastPathComponent;
                                newFile.localPath = enryptedFilePath;
                             
                                NSString *newFileOwnerID = newMembershipId?:[NXLoginUser sharedInstance].profile.individualMembership.ID;
                                NSString *newFileDuid = [((NSDictionary *)appendInfo) allKeys].firstObject;
                                completion(newFile,owner,duid,newFileOwnerID,newFileDuid,nil);
                            }
                        }
                        [self.completeBlockDict removeObjectForKey:operationId];
                        [self.operationDict removeObjectForKey:operationId];
                    }];
                }else{
                    // means protected by adhoc
                    // do encrypt operation
                    
                    // judge should rename
                     NSString *fileName = decryptFile.name;
                     if (shouldRename && newName.length > 0) {
                         fileName = newName;
                     }
    
                    [NXLMetaData encrypt:decryptFile.localPath destPath:[NXCommonUtils createNewNxlTempFile:fileName] clientProfile:[NXLoginUser sharedInstance].profile rights:rights membershipId:newMembershipId environment:[[rights getVaildateDateModel] getPolicyFormatJSONDictionary] encryptdDate:[NXTimeServerManager sharedInstance].currentServerTime complete:^(NSError *error, NSString *enryptedFilePath, id appendInfo) {
                         nxlOptEncryptCompletion completionBlock = self.completeBlockDict[operationId];
                        if (error) {
                             if (completionBlock) {
                                error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_ENCRYPT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_PROCESSING_FILE_FAILED", nil)}];
                                completion(nil,nil,nil,nil,nil,error);
                               }
                        }else{
                            if (completionBlock){
                                 NXFile *newFile = [[NXFile alloc] init];
                                 newFile.name = enryptedFilePath.lastPathComponent;
                                 newFile.localPath = enryptedFilePath;
                                 NSString *newFileOwnerID = newMembershipId?:[NXLoginUser sharedInstance].profile.individualMembership.ID;
                                 NSString *newFileDuid = [((NSDictionary *)appendInfo) allKeys].firstObject;
                                 completion(newFile,owner,duid,newFileOwnerID,newFileDuid,nil);
                            }
                        }
                        [self.completeBlockDict removeObjectForKey:operationId];
                        [self.operationDict removeObjectForKey:operationId];
                    }];
                }
            }else{
                if (completion) {
                     completion(nil,nil,nil,nil,nil,error);
                }
                [self.completeBlockDict removeObjectForKey:operationId];
                [self.operationDict removeObjectForKey:operationId];
            }
    }];
     return operationId;
}

- (NSString *)uploadNXLFile:(NXFileBase *)file intoDestFolder:(NXFolder *)destFolder ownnerID:(NSString *)ownerId duid:(NSString *)duid uploadType:(NXAddNXLFileUploadType)uploadType shouldRename:(BOOL)rename completion:(uploadNXLFileCompletion)completion
{
    if (!file.localPath) {
           NSAssert(NO, @"file local path can not be nil!!!");
    }
    
    switch (uploadType) {
        case NXAddNXLFileUploadTypeToProject:
        {
            // upload to project
            NXProjectFolder * projectFolder = (NXProjectFolder *)destFolder;
            
            NSURL *fileURL = [NSURL fileURLWithPath:file.localPath];
            NXProjectUploadFileParameterModel *parModel =[[NXProjectUploadFileParameterModel alloc]init];
            parModel.fileName = file.name;
            parModel.projectId = projectFolder.projectId;
            parModel.destFilePathId = destFolder.fullServicePath;
            parModel.destFilePathDisplay = destFolder.fullPath;
            parModel.type = [NSNumber numberWithInt:0];
            parModel.isoverWrite = !rename;
            
           
            parModel.fileData = [NSData dataWithContentsOfURL:fileURL];
            
            NSString *operationId = [[NSUUID UUID] UUIDString];
            [self.completeBlockDict setObject:completion forKey:operationId];
            NXEncryptProjectFileOperation *enryptFileOpt = [[NXEncryptProjectFileOperation alloc] init];
            [self.operationDict setObject:enryptFileOpt forKey:operationId];
            
            enryptFileOpt.uploadProjectIdentify = [[NXLoginUser sharedInstance].myProject addFile:parModel underParentFolder:(NXProjectFolder*)destFolder progress:nil withCompletion:^(NXProjectFolder *parentFolder, NXProjectFile *newProjectFile, NSError *error) {
                  if (error) {
                       // upload to project failed
                      error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_ENCRYPT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_PROCESSING_FILE_FAILED", nil)}];
                      if (completion) {
                          completion(nil,error);
                      }
                  }else {
                      // upload to project success
                      // do encrypted log
                    NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc]init];
                    model.duid = duid;
                    model.owner = ownerId;
                    model.operation = [NSNumber numberWithInteger:kProtectOperation];
                    model.repositoryId = @"";
                    model.filePathId = file.fullServicePath;
                    model.filePath = file.fullServicePath;
                    model.fileName = file.name;
                    model.activityData = @"TestData";
                    model.accessTime = [NSNumber numberWithLongLong:([[NXTimeServerManager sharedInstance].currentServerTime timeIntervalSince1970] * 1000)];
                    model.accessResult = [NSNumber numberWithInteger:1];
                    NXLogAPI *logAPI = [[NXLogAPI alloc]init];
                    [logAPI generateRequestObject:model];
                    [[NXSyncHelper sharedInstance] cacheRESTAPI:logAPI cacheURL:[NXCacheManager getLogCacheURL]];
                    [[NXSyncHelper sharedInstance] uploadPreviousFailedRESTRequestWithCachedURL:[NXCacheManager getLogCacheURL] mustAllSuccess:NO Complection:^(id object, NSError *error) {
                    }];
                    [self.fileLogManager insertNXLFileActivity:model];
                      
                      if (completion) {
                        completion(newProjectFile,error);
                     }
                  }
                    [self.completeBlockDict removeObjectForKey:operationId];
                    [self.operationDict removeObjectForKey:operationId];
              }];
            return  enryptFileOpt.uploadProjectIdentify;
        }
            break;
        case NXAddNXLFileUploadTypeToWorkspace:
        {
                  NXWorkSpaceUploadFileModel *model = [[NXWorkSpaceUploadFileModel alloc] init];
                  model.file = file;
            model.parentFolder = destFolder;
            model.isOverWrite = !rename;
                  NSString *operationId = [[NSUUID UUID] UUIDString];
                  NXShareFileOperation *shareOpt = [[NXShareFileOperation alloc] init];
                  [self.completeBlockDict setObject:completion forKey:operationId];
                  [self.operationDict setObject:shareOpt forKey:operationId];
                  shareOpt.shareFileIdentify = [[NXLoginUser sharedInstance].workSpaceManager uploadWorkSpaceFile:model WithCompletion:^(NXWorkSpaceFile *workSpaceFile, NXWorkSpaceUploadFileModel *uploadModel, NSError *error) {
                      if (error) {
                            // upload to workspace success
                          if (completion) {
                               completion(nil, error);
                          }
                      }else {
                          // upload to workspace success
                          // send encrypted log
                           NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc]init];
                           model.duid = duid;
                           model.owner = ownerId;
                           model.operation = [NSNumber numberWithLong:kProtectOperation];
                           model.repositoryId = @"";
                           model.filePathId = file.fullServicePath;
                           model.filePath = file.fullServicePath;
                           model.fileName = file.fullServicePath;
                           model.activityData = @"TestData";
                           model.accessTime = [NSNumber numberWithLongLong:([[NXTimeServerManager sharedInstance].currentServerTime timeIntervalSince1970] * 1000)];
                           model.accessResult = error?[NSNumber numberWithInteger:0]:[NSNumber numberWithInteger:1];
                           NXLogAPI *logAPI = [[NXLogAPI alloc]init];
                           [logAPI generateRequestObject:model];
                           [[NXSyncHelper sharedInstance] cacheRESTAPI:logAPI cacheURL:[NXCacheManager getLogCacheURL]];
                           [[NXSyncHelper sharedInstance] uploadPreviousFailedRESTRequestWithCachedURL:[NXCacheManager getLogCacheURL] mustAllSuccess:NO Complection:^(id object, NSError *error) {
                              
                           }];
                           [self.fileLogManager insertNXLFileActivity:model];
                          
                          if (completion) {
                              completion(workSpaceFile, nil);
                          }
                      }
                      
                      [self.completeBlockDict removeObjectForKey:operationId];
                      [self.operationDict removeObjectForKey:operationId];
                  }];
                  return operationId;
        }
            break;
        case NXAddNXLFileUploadTypeToSharedWorkspace:
        {
           
            NSString *operationId = [[NSUUID UUID] UUIDString];
            [self.completeBlockDict setObject:completion forKey:operationId];
            [self.completeBlockDict setObject:completion forKey:operationId];
            NXRepositorySysManagerUploadType uploadType = NXRepositorySysManagerUploadTypeNormal;
            if (!rename) {
                uploadType = NXRepositorySysManagerUploadTypeOverWrite;
            }
            operationId = [[NXLoginUser sharedInstance].myRepoSystem uploadFile:file.name toPath:destFolder fromPath:file.localPath uploadType:uploadType overWriteFile:nil progress:nil completion:^(NXFileBase *fileItem, NXFileBase *parentFolder, NSError *error) {
                if (error) {
                      // upload to workspace success
                    if (completion) {
                         completion(nil, error);
                    }
                }else {
                    // upload to workspace success
                    // send encrypted log
                     NXLogAPIRequestModel *model = [[NXLogAPIRequestModel alloc]init];
                     model.duid = duid;
                     model.owner = ownerId;
                     model.operation = [NSNumber numberWithLong:kProtectOperation];
                     model.repositoryId = file.repoId;
                     model.filePathId = file.fullServicePath;
                     model.filePath = file.fullServicePath;
                     model.fileName = file.fullServicePath;
                     model.activityData = @"TestData";
                     model.accessTime = [NSNumber numberWithLongLong:([[NXTimeServerManager sharedInstance].currentServerTime timeIntervalSince1970] * 1000)];
                     model.accessResult = error?[NSNumber numberWithInteger:0]:[NSNumber numberWithInteger:1];
                     NXLogAPI *logAPI = [[NXLogAPI alloc]init];
                     [logAPI generateRequestObject:model];
                     [[NXSyncHelper sharedInstance] cacheRESTAPI:logAPI cacheURL:[NXCacheManager getLogCacheURL]];
                     [[NXSyncHelper sharedInstance] uploadPreviousFailedRESTRequestWithCachedURL:[NXCacheManager getLogCacheURL] mustAllSuccess:NO Complection:^(id object, NSError *error) {
                        
                     }];
                     [self.fileLogManager insertNXLFileActivity:model];
                    
                    if (completion) {
                        completion(fileItem, nil);
                    }
                }
                
                [self.completeBlockDict removeObjectForKey:operationId];
                      
            }];
            return operationId;
        }
            break;
        default:
            NSAssert(NO, @"upload type can not be nil!!!");
            break;
    }
    return nil;
}
- (NSString *)saveAsNXlFileToLocal:(NXFileBase *)file withCompletion:(nxlCopyNXLFileCompletion)completion {
    NSString *operationId = [[NSUUID UUID] UUIDString];
    [self.completeBlockDict setObject:completion forKey:operationId];
    NXSaveAsToLocalOperation *copyOperation = [[NXSaveAsToLocalOperation alloc] initWithSourceFile:file];
    [self.operationDict setObject:copyOperation forKey:operationId];
    WeakObj(self);
    copyOperation.saveAsFinishCompletion = ^(NXFileBase * _Nonnull spaceFile, NSError * _Nonnull error) {

        StrongObj(self);
        nxlCopyNXLFileCompletion comp = self.completeBlockDict[operationId];
        comp(file,error);
        [self.completeBlockDict removeObjectForKey:operationId];
        [self.operationDict removeObjectForKey:operationId];
    };
    [copyOperation start];
    return operationId;
}
- (NSString *)uploadNXLFromLocal:(NXFileBase *)file shouldOverwrite:(BOOL)overwrite toSpaceType:(NSString *)destType andDestPathFolder:(NXFileBase *)destpathFolder withCompletion:(nxlCopyNXLFileCompletion)completion {
    NSString *operationId = [[NSUUID UUID] UUIDString];
    [self.completeBlockDict setObject:completion forKey:operationId];
    NXAddLocalNXLFileToOtherSpaceOperation *copyOperation = [[NXAddLocalNXLFileToOtherSpaceOperation alloc] initWithSourceFile:file shouldOverwrite:(BOOL)overwrite andDestSpaceType:destType andDestSpacePathFolder:destpathFolder];
    [self.operationDict setObject:copyOperation forKey:operationId];
    WeakObj(self);
    copyOperation.addLocalNXLFileFinishCompletion = ^(NXFileBase * _Nonnull spaceFile, NSError * _Nonnull error) {

        StrongObj(self);
        nxlCopyNXLFileCompletion comp = self.completeBlockDict[operationId];
        comp(file,error);
        [self.completeBlockDict removeObjectForKey:operationId];
        [self.operationDict removeObjectForKey:operationId];
    };
    [copyOperation start];
    return operationId;
}
- (NSString *)copyNXLFile:(NXFileBase *)file toSpace:(NSString *)destPath withCompletion:(nxlCopyNXLFileCompletion)completion{
    NSString *operationId = [[NSUUID UUID] UUIDString];
    [self.completeBlockDict setObject:completion forKey:operationId];
    NXCopyNxlFileOperation *copyOperation = [[NXCopyNxlFileOperation alloc] initWithSourceFile:file andDestSpaceType:destPath];
    [self.operationDict setObject:copyOperation forKey:operationId];
    WeakObj(self);
    copyOperation.copyNxlFileCompletion = ^(NXFileBase * _Nonnull spaceFile, NSError * _Nonnull error) {

        StrongObj(self);
        nxlCopyNXLFileCompletion comp = self.completeBlockDict[operationId];
        comp(file,error);
        [self.completeBlockDict removeObjectForKey:operationId];
        [self.operationDict removeObjectForKey:operationId];
    };
    [copyOperation start];
    return operationId;
}
- (NSString *)copyNXLFile:(NXFileBase *)file shouldOverwrite:(BOOL)overwrite toSpaceType:(NSString *)destType andDestPathFolder:(NXFileBase *)destpathFolder withCompletion:(nxlCopyNXLFileCompletion)completion{
    NSString *operationId = [[NSUUID UUID] UUIDString];
    [self.completeBlockDict setObject:completion forKey:operationId];
    NXCopyNxlFileOperation *copyOperation = [[NXCopyNxlFileOperation alloc] initWithSourceFile:file shouldOverwrite:(BOOL)overwrite andDestSpaceType:destType andDestSpacePathFolder:destpathFolder];
    [self.operationDict setObject:copyOperation forKey:operationId];
    WeakObj(self);
    copyOperation.copyNxlFileCompletion = ^(NXFileBase * _Nonnull spaceFile, NSError * _Nonnull error) {

        StrongObj(self);
        nxlCopyNXLFileCompletion comp = self.completeBlockDict[operationId];
        comp(file,error);
        [self.completeBlockDict removeObjectForKey:operationId];
        [self.operationDict removeObjectForKey:operationId];
    };
    [copyOperation start];
    return operationId;
    
}
@end
