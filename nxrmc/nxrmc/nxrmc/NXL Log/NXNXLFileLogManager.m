
//  NXNXLFileLogManager.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 10/11/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXNXLFileLogManager.h"
#import "NXFileActivityLogAPI.h"
#import <objc/runtime.h>
#import "NXLProfile.h"
#import "NXTimeServerManager.h"
@interface NXNXLFileLogManager()
@property(nonatomic, strong) NSDictionary<NSNumber *, NSString *> *dictRights;
@end
@implementation NXNXLFileLogManager
- (instancetype)init {
    if (self = [super init]) {
        _dictRights = @{
                        [NSNumber numberWithLong:kProtectOperation]: @"Protect",
                        [NSNumber numberWithLong:kShareOperation]: @"Share",
                        [NSNumber numberWithLong:kRemoveUserOperation]: @"Remove User",
                        [NSNumber numberWithLong:kViewOperation]: @"View",
                        [NSNumber numberWithLong:kDownloadOperation]: @"Download",
                        [NSNumber numberWithLong:kPrintOpeartion]: @"Print",
                        [NSNumber numberWithLong:kRevokeOperation]: @"Revoke",
                        [NSNumber numberWithLong:kDecryptOperation]: @"Decrypt",
                        [NSNumber numberWithLong:kReshareOperation]: @"Reshare",
                        [NSNumber numberWithLong:kDeleteOperation]: @"Delete"};
    }
    return self;
}

- (void)activityLogForFile:(NSString *)duid
                    sortBy:(NXSortOption)sortType
             onlyLocalData:(BOOL)onlyLocalData
            withCompletion:(NXNXLFileLogManagerGetNXLLogsCompletion)completion {
    NSArray *activityLogs = [NXNXLFileLogStorage nxlFileLogs:duid sortBy:sortType];
    if (activityLogs.count || onlyLocalData) {
        completion(activityLogs, duid, nil);
    }
    if (onlyLocalData) {
        return;
    }
   
    NXFileActivityLogAPIRequest *req = [[NXFileActivityLogAPIRequest alloc] init];
    NXFileActivityLogParModel *parModel = [[NXFileActivityLogParModel alloc]init];
    parModel.fileDUID = duid;
    [req requestWithObject:parModel Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (error) {
            completion(nil, duid, error);
        } else {
            NXFileActivityLogAPIResponse *activityLogResponse = (NXFileActivityLogAPIResponse *)response;
            if (activityLogResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) {
                // step1. update local data
                NSMutableArray *fileLogs = [[NSMutableArray alloc] init];
                [activityLogResponse.logRecords enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NXNXLFileLogModel *logModel = [self convertRESTLogModel:obj];
                    [fileLogs addObject:logModel];
                }];
                [NXNXLFileLogStorage storeNXLFileLogs:fileLogs];
                // step2. return if not return yet
                if (activityLogs.count) { // means already return, just notify activity updated
                    if (self.delegate) {
                        dispatch_main_async_safe(^{
                            NSArray *retArray = [NXNXLFileLogStorage nxlFileLogs:duid sortBy:sortType];
                            [self.delegate nxNXLFileLogManager:self duid:duid didUpdateLog:retArray];
                        });
                    }
                } else {
                    dispatch_main_async_safe(^{
                        NSArray *retArray = [NXNXLFileLogStorage nxlFileLogs:duid sortBy:sortType];
                        completion(retArray, duid, nil);
                    });
                }
            } else {
                if (activityLogs.count == 0) { // means not call completion yet, just return error
                    NSError *retError = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"MSG_ACTIVITY_FAILED", nil)}];
                    completion(nil, duid, retError);
                }
            }
        }
    }];
    
}

- (void)insertNXLFileActivity:(NXLogAPIRequestModel *)logModel {
    NXNXLFileLogModel *storageLogModel = [[NXNXLFileLogModel alloc] init];
    storageLogModel.duid = logModel.duid;
    storageLogModel.name = logModel.fileName;
    storageLogModel.accessTime = logModel.accessTime;
    storageLogModel.email = [NXLoginUser sharedInstance].profile.email;
    storageLogModel.operation = self.dictRights[logModel.operation];
    storageLogModel.deviceId = [UIDevice currentDevice].name;
    storageLogModel.deviceType = [UIDevice currentDevice].model;
    storageLogModel.accessTime = logModel.accessTime;
    storageLogModel.accessResult = (logModel.accessResult.integerValue == 1?@"Allow":@"Deny");
    storageLogModel.activityData = logModel.activityData;
    [NXNXLFileLogStorage insertNXLFileLog:storageLogModel];
}

- (NSArray *)searchActivityLogForFile:(NSString *)duid sortBy:(NXSortOption)sortType searchString:(NSString *)searchString {
    
    NSArray *retArray = [[NSArray alloc] init];
    if (duid) {
        retArray = [NXNXLFileLogStorage searchFileLogs:duid sortBy:sortType searchString:searchString];
    }
    return retArray;
}

- (NXNXLFileLogModel *)convertRESTLogModel:(NXFileActivityLogRecordsModel *)recordModel {
    unsigned int ivarCount = 0;
    Ivar *vars = class_copyIvarList([recordModel class], &ivarCount);
    NSMutableArray *varKeys = [[NSMutableArray alloc] init];
    for (int i =0; i < ivarCount; ++i) {
        Ivar var = vars[i];
        NSString *varName = [NSString stringWithUTF8String:ivar_getName(var)];
        [varKeys addObject:varName];
    }
    free(vars);
    NSDictionary *recordModelVaulesAndKeysDict = [recordModel dictionaryWithValuesForKeys:varKeys];
    NXNXLFileLogModel *fileLogModel = [[NXNXLFileLogModel alloc] initWithNXFileActivityLogModelDic:recordModelVaulesAndKeysDict];
    return fileLogModel;
}
@end
