//
//  NXSharedFileManager.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 31/7/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXSharedFileManager.h"
#import "NXSharedWithMeFileListOperation.h"
#import "NXSharedWithMeReshareFileOperation.h"
#import "NXGetFileListInMyVaultFolderOperation.h"
#import "NXSharedWithMeReshareProjectFileOperation.h"
#import "NXRMCDef.h"
#import "NXMyVaultFileStorage.h"
#import "NXSharedWithMeFileStorage.h"
#import "NXSharedWithMeFile.h"
#import "NXSharedWithProjectFile.h"
#import "NXNetworkHelper.h"
#define SHAREDWITHME_FILELIST    @"SHAREDWITHME_FILELIST"
#define SHAREDWITHME_RESHARE     @"SHAREDWITHME_RESHARE"
#define SHAREDBYME_FILELIST      @"SHAREDBYME_FILELIST"
@interface NXSharedFileManager ()
@property(nonatomic, strong) NSMutableDictionary *operationDict;
@property(nonatomic, strong) NSMutableDictionary *compDict;
@property(nonatomic, strong) NXLProfile *userProfile;
@property(nonatomic, strong) NSArray *sharedWithMefilesCacheArray;
@property(nonatomic, strong) NSMutableArray *sharedByMeFilesCacheArray;
@end

@implementation NXSharedFileManager
- (NSArray *)sharedWithMefilesCacheArray {
    if (!_sharedWithMefilesCacheArray) {
        _sharedWithMefilesCacheArray = [NSArray array];
    }
    return _sharedWithMefilesCacheArray;
}
- (NSMutableArray *)sharedByMeFilesCacheArray {
    if (!_sharedByMeFilesCacheArray) {
        _sharedByMeFilesCacheArray = [NSMutableArray array];
    }
    return _sharedByMeFilesCacheArray;
}
- (instancetype)initWithUserProfile:(NXLProfile *)userProfile
{
    self = [super init];
    if (self) {
        _userProfile = userProfile;
    }
    return self;
    
}
- (NSMutableDictionary *)operationDict
{
    @synchronized (self) {
        if (_operationDict == nil) {
            _operationDict = [[NSMutableDictionary alloc] init];
        }
        return _operationDict;
    }
}

- (NSMutableDictionary *)compDict
{
    @synchronized (self) {
        if (_compDict == nil) {
            _compDict = [[NSMutableDictionary alloc] init];
        }
        return _compDict;
    }
}

- (NSString *)getSharedWithMeFileListWithParameterModel:(NXSharedWithMeFileListParameterModel *)parameterModel shouldReadCache:(BOOL)isReadCache wtihCompletion:(getSharedWithMeFileListCompletion)sharedWithMeFileListCompletion {
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSString *operationId = [NSString stringWithFormat:@"%@%@", SHAREDWITHME_FILELIST, uuid];
    if (isReadCache) {
        
        NSArray *sharedWithMeFileArrayInStorage = [NXSharedWithMeFileStorage getAllSharedWithMeFiles];
        if (sharedWithMeFileListCompletion) {
            sharedWithMeFileListCompletion (parameterModel,sharedWithMeFileArrayInStorage,nil);
        }
        if (![[NXNetworkHelper sharedInstance] isNetworkAvailable]) {
            return operationId;
        }
        NXSharedWithMeFileListOperation *getFileListOpt = [[NXSharedWithMeFileListOperation alloc]initWithSharedWithMeFileListParameterModel:parameterModel];
        if (sharedWithMeFileListCompletion) {
            [self.compDict setObject:sharedWithMeFileListCompletion forKey:operationId];
        }
           
        [self.operationDict setObject:getFileListOpt forKey:operationId];
            WeakObj(self);
            getFileListOpt.sharedWithMeFileListCompletion = ^(NXSharedWithMeFileListParameterModel *parameterModel, NSArray *fileListArray, NSError *error) {
                StrongObj(self);
                if (!error) {
                    NSArray *sharedWithMeFileArrayInStorage = [NXSharedWithMeFileStorage getAllSharedWithMeFiles];
                    [self updateDataInLocal:fileListArray localData:sharedWithMeFileArrayInStorage];
                    [NXSharedWithMeFileStorage insertSharedWithMeFileItems:fileListArray];
                    NSArray *newDatasOfSharedWithMe = [NXSharedWithMeFileStorage getAllSharedWithMeFiles];
                    getSharedWithMeFileListCompletion completion = self.compDict[operationId];
                    if (completion) {
                        completion(parameterModel,newDatasOfSharedWithMe,error);
                    }
                    
                    [self.compDict removeObjectForKey:operationId];
                    [self.operationDict removeObjectForKey:operationId];
                }
            };
        [getFileListOpt start];
    } else {
            NXSharedWithMeFileListOperation *getFileListOpt = [[NXSharedWithMeFileListOperation alloc]initWithSharedWithMeFileListParameterModel:parameterModel];
            [self.compDict setObject:sharedWithMeFileListCompletion forKey:operationId];
            [self.operationDict setObject:getFileListOpt forKey:operationId];
            WeakObj(self);
            getFileListOpt.sharedWithMeFileListCompletion = ^(NXSharedWithMeFileListParameterModel *parameterModel, NSArray *fileListArray, NSError *error) {
                StrongObj(self);
                    NSArray *sharedWithMeFileArrayInStorage = [NXSharedWithMeFileStorage getAllSharedWithMeFiles];
                    [self updateDataInLocal:fileListArray localData:sharedWithMeFileArrayInStorage];
                    [NXSharedWithMeFileStorage insertSharedWithMeFileItems:fileListArray];
                    NSArray *newDatasOfSharedWithMe = [NXSharedWithMeFileStorage getAllSharedWithMeFiles];
                    
                    getSharedWithMeFileListCompletion completion = self.compDict[operationId];
                    if (completion) {
                        completion(parameterModel,newDatasOfSharedWithMe,error);
                    }
                    
                    [self.compDict removeObjectForKey:operationId];
                    [self.operationDict removeObjectForKey:operationId];
            };
            [getFileListOpt start];
    }
    return operationId;
}

- (NSString *)reshareSharedWithMeFile:(NXSharedWithMeFile *)sharedWithMeFile withReceivers:(NSArray *)receiversArray withCompletion:(reShareSharedWithMeFileCompletion)reshareFileCompletion {
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSString *operationId = [NSString stringWithFormat:@"%@%@", SHAREDWITHME_RESHARE, uuid];
    NXSharedWithMeReshareFileOperation *reshareFileOpt = [[NXSharedWithMeReshareFileOperation alloc]initWithSharedWithMeFile:sharedWithMeFile withReceivers:receiversArray];
    [self.compDict setObject:reshareFileCompletion forKey:operationId];
    [self.operationDict setObject:reshareFileOpt forKey:operationId];
    WeakObj(self);
    reshareFileOpt.finishReshareFileCompletion = ^(NXSharedWithMeFile *originalFile, NXSharedWithMeFile *freshFile, NXShareWithMeReshareResponseModel *responseModel, NSError *error) {
        StrongObj(self);
        reShareSharedWithMeFileCompletion completion = self.compDict[operationId];
        if (completion) {
            completion(originalFile,freshFile,responseModel,error);
        }
        [self.compDict removeObjectForKey:operationId];
        [self.operationDict removeObjectForKey:operationId];
    };
    [reshareFileOpt start];
    return operationId;
}

- (NSString *)reshareProjectFile:(NXSharedWithProjectFile *)sharedWithProjectFile withReceivers:(NSArray *)receiversArray withCompletion:(reShareProjetFileCompletion)reshareProjectFileCompletion{
    NSString *uuid = [[NSUUID UUID] UUIDString];
        NXSharedWithMeReshareProjectFileRequestModel *model = [[NXSharedWithMeReshareProjectFileRequestModel alloc] init];
        model.transactionId = sharedWithProjectFile.transactionId;
        model.transactionCode = sharedWithProjectFile.transactionCode;
        model.reshareComment = sharedWithProjectFile.comment;
        model.recipients = receiversArray;
        model.spaceId = sharedWithProjectFile.spaceId;
       NSString *operationId = [NSString stringWithFormat:@"%@%@", SHAREDWITHME_RESHARE, uuid];
       NXSharedWithMeReshareProjectFileOperation *reshareFileOpt = [[NXSharedWithMeReshareProjectFileOperation alloc]initWithSharedWithProjectFile:sharedWithProjectFile withReceivers:model];
       [self.compDict setObject:reshareProjectFileCompletion forKey:operationId];
       [self.operationDict setObject:reshareFileOpt forKey:operationId];
       WeakObj(self);
       reshareFileOpt.finishReshareProjectFileCompletion = ^(NXSharedWithProjectFile *originalFile, NXSharedWithProjectFile *freshFile, NXSharedWithMeReshareProjectFileResponseModel *responseModel, NSError *error) {
           StrongObj(self);
           reShareProjetFileCompletion completion = self.compDict[operationId];
           if (completion) {
               completion(originalFile,freshFile,responseModel,error);
           }
           [self.compDict removeObjectForKey:operationId];
           [self.operationDict removeObjectForKey:operationId];
       };
       [reshareFileOpt start];
       return operationId;
}
// sharedByMe
- (NSString *)getSharedByMeFileListWithParameterModel:(id)parameterModel shouldReadCache:(BOOL)isReadCache withCompletion:(getSharedByMeFileListCompletion)sharedByMeFileListCompletion {
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSString *operationId = [NSString stringWithFormat:@"%@%@",SHAREDBYME_FILELIST,uuid];
    
    NXMyVaultListParModel *model = (NXMyVaultListParModel *)parameterModel;

    NXMyVaultListParModel *temParModel = [[NXMyVaultListParModel alloc] init];
    temParModel.page = model.page;
    temParModel.size = model.size;
    temParModel.filterType = NXMyvaultListFilterTypeAllFiles;
    temParModel.sortOptions = model.sortOptions;
    temParModel.searchString = model.searchString;
    
    NSMutableArray *localMyVaultFileItems = [NXMyVaultFileStorage getMyVaultFilesForShareByMe].mutableCopy;
    
    if (isReadCache && localMyVaultFileItems.count >= 1) {
        
        if (sharedByMeFileListCompletion) {
            sharedByMeFileListCompletion (parameterModel,localMyVaultFileItems,nil);
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NXGetFileListInMyVaultFolderOperation *shareByMeOpt = [[NXGetFileListInMyVaultFolderOperation alloc]initWithParentFolder:nil filterModel:temParModel];
            [self.operationDict setObject:shareByMeOpt forKey:operationId];
            [self.compDict setObject:sharedByMeFileListCompletion forKey:operationId];
            
            shareByMeOpt.completion = ^(NSArray *fileList, NXFileBase *parentFolder, NXMyVaultListParModel *filterModel, NSError *error) {
                [NXMyVaultFileStorage updateMyVaultFileItemsInStorage:fileList];
            };
            [shareByMeOpt start];
        });
    } else {
        NXGetFileListInMyVaultFolderOperation *shareByMeOpt = [[NXGetFileListInMyVaultFolderOperation alloc]initWithParentFolder:nil filterModel:temParModel];
        [self.operationDict setObject:shareByMeOpt forKey:operationId];
        [self.compDict setObject:sharedByMeFileListCompletion forKey:operationId];
        WeakObj(self);
        shareByMeOpt.completion = ^(NSArray *fileList, NXFileBase *parentFolder, NXMyVaultListParModel *filterModel, NSError *error) {
            StrongObj(self);
            
                // step 1  update myvaultFile item in coredata
                [NXMyVaultFileStorage updateMyVaultFileItemsInStorage:fileList];
                
                // step 2 read myvaultFileItems form coredata
                NSMutableArray *localMyVaultFileItems = [NXMyVaultFileStorage getMyVaultFilesForShareByMe].mutableCopy;
                
                getSharedByMeFileListCompletion sharedByMeFileCompletion = self.compDict[operationId];
                if (sharedByMeFileCompletion) {
                    sharedByMeFileCompletion(parameterModel,localMyVaultFileItems,error);
                }
                [self.operationDict removeObjectForKey:operationId];
                [self.compDict removeObjectForKey:operationId];
        };
        [shareByMeOpt start];
        
    }
    return operationId;
}

- (void)updateCacheListArrayWhenDeleteItem:(NXMyVaultFile *)item {
    if ([self.sharedByMeFilesCacheArray containsObject:item]) {
        [self.sharedByMeFilesCacheArray removeObject:item];
    }
}
- (void)cancelOperation:(NSString *)operationIdentify {
    if (operationIdentify == nil) {
        return;
    }
    NSOperation *opt = self.operationDict[operationIdentify];
    if (opt) {
        [opt cancel];
    };
    [self.operationDict removeObjectForKey:operationIdentify];
    [self.compDict removeObjectForKey:operationIdentify];

}

- (void)updateDataInLocal:(NSArray *)newfileList localData:(NSArray *)coreDataFileList
{
    if (newfileList.count > 0 && coreDataFileList.count >0) {
        NSMutableSet *duidSetInServer = [NSMutableSet new];
        NSMutableSet *duidSetInCoreData = [NSMutableSet new];
        
        for (NXSharedWithMeFile *file in newfileList) {
            if (file.duid) {
                   [duidSetInServer addObject:file.duid];
            }
        }
        
        for (NXSharedWithMeFile *file in coreDataFileList) {
            if (file.duid) {
                  [duidSetInCoreData addObject:file.duid];
            }
        }
        [duidSetInCoreData minusSet:duidSetInServer];
        if (duidSetInCoreData) {
          [NXSharedWithMeFileStorage deleteSharedWithMeFileItemsByDuidInStorage:duidSetInCoreData];
        }
    }
    
    if (newfileList.count == 0) {
        NSMutableSet *duidSetInCoreData = [NSMutableSet new];
        for (NXSharedWithMeFile *file in coreDataFileList) {
            if (file.duid) {
                [duidSetInCoreData addObject:file.duid];
            }
        }
        
        [NXSharedWithMeFileStorage deleteSharedWithMeFileItemsByDuidInStorage:duidSetInCoreData];
        
    }
}
- (NSArray *)getSharedWithMeFileListFromStorage{
    NSArray *sharedWithMeFileArrayInStorage = [NXSharedWithMeFileStorage getAllSharedWithMeFiles];
    return sharedWithMeFileArrayInStorage;
}
@end
