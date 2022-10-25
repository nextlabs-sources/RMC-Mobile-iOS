//
//  SDClient.m
//  nxrmc
//
//  Created by nextlabs on 10/24/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "SDClient.h"

#import "NXLoginUser.h"

#import "SDMetadata.h"
#import "SDOperation.h"
#import "NXMyDriveFileListAPI.h"
#import "NXMyDriveFileDownloadAPI.h"
#import "NXMyDriveFileUploadAPI.h"
#import "NXMyDriveItemDeleteAPI.h"
#import "NXMyDriveCreateFolderAPI.h"
#import "NXMyDriveGetUsageAPI.h"
#import "NXLProfile.h"
@interface SDClient ()

@property(nonatomic, strong) NSMutableArray<SDOperation *> *requestArray;
@property(nonatomic, strong) NSProgress *downloadProgress;
@property(nonatomic, strong) NSProgress *uploadProgress;

@end

@implementation SDClient

- (instancetype)initWithUser:(NXLoginUser *)user {
    if (self = [super init]) {
        self.requestArray = [NSMutableArray array];
        _downloadProgress = [[NSProgress alloc] init];
        [_downloadProgress addObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted)) options:NSKeyValueObservingOptionNew context:NULL];
        _uploadProgress = [[NSProgress alloc] init];
        [_uploadProgress addObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted)) options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

#pragma mark -
- (void)dealloc
{
    [_downloadProgress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
    [_uploadProgress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(fractionCompleted))] && [object isEqual:self.downloadProgress]) {
            if (DELEGATE_HAS_METHOD(self.delegate, @selector(client:loadProgress:forFile:))) {
                // for only one SDClient for every operation, so we can get request from requestArray first object(The array only have one item for ever)
                // !!!!!!!!!!!!!!!!!!!!!! IF REAUEST ARRAY NOT ONLY HAVE ONE ITEM, WILL HAVE ERROR
                SDOperation *opt = self.requestArray.firstObject;
                [self.delegate client:self loadProgress:self.downloadProgress.fractionCompleted forFile:opt.path];
            }
        }
        
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(fractionCompleted))] && [object isEqual:self.uploadProgress]) {
            if (DELEGATE_HAS_METHOD(self.delegate, @selector(client:uploadProgress:forFile:fromPath:))) {
                // for only one SDClient for every operation, so we can get request from requestArray first object(The array only have one item for ever)
               // !!!!!!!!!!!!!!!!!!!!!! IF REAUEST ARRAY NOT ONLY HAVE ONE ITEM, WILL HAVE ERROR
                SDOperation *opt = self.requestArray.firstObject;
                [self.delegate client:self uploadProgress:self.uploadProgress.fractionCompleted forFile:opt.path.lastPathComponent fromPath:opt.path];

            }
        }
    });
    
}

- (NSInteger)requestCount {
    //TBD
    return self.requestArray.count;
}

- (void)cancelAllRequests {
    [self.requestArray enumerateObjectsUsingBlock:^(SDOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //TBD cancel operation
        [self.requestArray removeObject:obj];
    }];
}

- (void)loadMemadata:(NSString *)path recursive:(BOOL)recursive  {
   
    
    SDOperation *operation = [[SDOperation alloc] init];
     NXMyDriveFileListAPI *API =[[NXMyDriveFileListAPI alloc]init];
    operation.path = path;
    operation.method = SDMethodTypeList;
    operation.restAPI = API;
    [self.requestArray addObject:operation];
    NSMutableArray *dataArray=[NSMutableArray array];
    NSDictionary *objectDic =[NSDictionary dictionary];
    SDMetadata *data = [[SDMetadata  alloc] init];
    if (path==nil) {
        path=@"/";
    }
    if (![path isEqualToString:@"/"]) {
//        path=[path substringToIndex:path.length-1];
    }
    if (recursive==NO) {
        objectDic=@{@"pathId":path};
    } else {
    objectDic=@{@"pathId":path};
    }
    [API requestWithObject:objectDic Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        NSError *backError=error;
        if (error==nil) {
            NXGetMyDriveFileListAPIResponse *APIResponse =(NXGetMyDriveFileListAPIResponse*)response;
            if (!(APIResponse.errorR==nil)) {
                backError=APIResponse.errorR;
            } else{
            for (NXMyDriveFileItem *item in APIResponse.myDriveFileLists) {
                SDMetadata *SDItem =[[SDMetadata alloc]initWithItem:item];
                [dataArray addObject:SDItem];
            }
            data.contents=dataArray;
            }
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(client:loadedMetaData:error:)]) {
             dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate client:self loadedMetaData:data error:backError];
             });
        }
        
        [self.requestArray removeObject:operation];
    }];
}

- (BOOL)cancelLoadMetadata:(NSString *)path {
    __block BOOL ret = NO;
    [self.requestArray enumerateObjectsUsingBlock:^(SDOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.path isEqualToString:path] && obj.method == SDMethodTypeList) {
            //cancel TBD
           [obj.restAPI cancelRequest];
            [self.requestArray removeObject:obj];
            ret = YES;
        }
    }];
    
    return ret;
}
- (void)downloadFile:(NSString *)path length:(NSUInteger)length intoPath:(NSString *)destPath {
    NSMutableDictionary * object = [[NSMutableDictionary alloc]initWithDictionary:@{@"pathId":path}];
    if (length > 0) {
        [object setObject:@(0) forKey:@"start"];
        [object setObject:@(length) forKey:@"length"];
    }
    
    NXMyDriveFileDownloadAPI *api =[[NXMyDriveFileDownloadAPI alloc]init];
    SDOperation *operation = [[SDOperation alloc]initWithPath:path method:SDMethodTypeDownload api:api];
    [self.requestArray addObject:operation];
    
    [api requestWithObject:object withUploadProgress:self.uploadProgress downloadProgress:self.downloadProgress Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        //TBD
        NXMyDriveFileDownloadAPIResponse *resultResponse =(NXMyDriveFileDownloadAPIResponse*)response;
        if (error && error.code == NXRMS_ERROR_CODE_EMPTY_CONTENT) {
            error = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_EMPTY_CONTENT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_EMPTY_CONTENT", nil)}];
        }
        SDMetadata *data = nil;
        if (!error) {
            data = [[SDMetadata alloc] init];
            data.path=path;
            if (data && destPath) {
                [resultResponse.resultData writeToFile:destPath atomically:YES];
                if (DELEGATE_HAS_METHOD(self.delegate, @selector(client:downloadedFile:metadata:error:))) {
                    dispatch_main_async_safe(^{
                        [self.delegate client:self downloadedFile:data.path metadata:data error:error];
                    });
                }
            }
        }
        
        if (DELEGATE_HAS_METHOD(self.delegate, @selector(client:downloadedContent:metadata:error:))) {
            dispatch_main_async_safe(^{
                [self.delegate client:self downloadedContent:resultResponse.resultData metadata:data error:error];
            });
        }
        
        [self.requestArray removeObject:operation];
    }];
}

- (void)downloadFile:(NSString *)path intoPath:(NSString *)destPath {
    return [self downloadFile:path length:0 intoPath:destPath];
}

- (void)downloadFile:(NSString *)path {
    return [self downloadFile:path length:0 intoPath:nil];
}

- (BOOL)cancelFileLoad:(NSString *)path {
    __block BOOL ret = NO;
    [self.requestArray enumerateObjectsUsingBlock:^(SDOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.path isEqualToString:path] && obj.method == SDMethodTypeDownload) {
            //cancel TBD
            [self.requestArray removeObject:obj];
            ret = YES;
        }
    }];
    
    return ret;
}

- (void)uploadfile:(NSString *)filename fromPath:(NSString *)srcPath toPath:(NSString *)parentFolder overWriteFile:(NSString *)filePath {
    NSData *fileData =[NSData dataWithContentsOfFile:srcPath];
    if (parentFolder==nil) {
        parentFolder=@"/";
    }
    NSDictionary *object =@{@"parentPathId":parentFolder, @"name":filename, @"userConfirmedFileOverwrite":@"true"};
    NSDictionary *superObject =@{@"fileData":fileData,@"object":object};
    
    NXMyDriveFileUploadAPI *api =[[NXMyDriveFileUploadAPI alloc]init];
    NSString *operationPath = [NSString stringWithFormat:@"%@/%@", parentFolder, filename];
    SDOperation *operation = [[SDOperation alloc]initWithPath:operationPath method:SDMethodTypeUpload api:api];
    
    [self.requestArray addObject:operation];
    
    [api requestWithObject:superObject withUploadProgress:self.uploadProgress downloadProgress:self.downloadProgress Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        //TBD
        SDMetadata *fileData=nil;
        if (error==nil) {
            NXMyDriveFileUploadAPIResponse *apiResponse=(NXMyDriveFileUploadAPIResponse*)response;
            fileData=[[SDMetadata alloc]initWithUploadItem:apiResponse.item];
        }
        
        
        if (((NXMyDriveFileUploadAPIResponse*)response).rmsStatuCode == NXRMS_MYVAULT_UPLOAD_FILL_EXISTED) {
            error = [[NSError alloc] initWithDomain:NX_ERROR_MY_VAULT_DOMAIN code:NXRMC_ERROR_CODE_MY_VAULT_UPLOAD_FILE_EXISTED userInfo:nil];
        } else if (((NXMyDriveFileUploadAPIResponse*)response).rmsStatuCode == NXRMS_MYDRIVE_UPLOAD_DRIVE_EXCEEDED) {
             error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_STORAGE_DOMAIN code:NXRMC_ERROR_CODE_REPO_STORAGE_MANAGER_EXCEEDED_ERROR userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_DRIVE_STORAGE_EXCEEDED", nil)}];
        } else if(((NXMyDriveFileUploadAPIResponse*)response).rmsStatuCode != NXRMS_ERROR_CODE_SUCCESS) {
            error = [[NSError alloc] initWithDomain:NX_ERROR_MY_VAULT_DOMAIN code:NXRMC_ERROR_CODE_REST_UPLOAD_FAILED userInfo:nil];
        
        }
//        SDMetadata *data = nil;
//        if (error == nil) {
//            data = [[SDMetadata alloc]init];
//        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(client:uploadFile:fromPath:metadata:error:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
              [self.delegate client:self uploadFile:[parentFolder stringByAppendingPathComponent:filename] fromPath:srcPath metadata:fileData error:error];
           });
        
        }
        [self.requestArray removeObject:operation];
    }];
}

- (BOOL)cancelFileUpload:(NSString *)srcpath {
    __block BOOL ret = NO;
    [self.requestArray enumerateObjectsUsingBlock:^(SDOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.path isEqualToString:srcpath] && obj.method == SDMethodTypeUpload) {
            //cancel TBD
            [obj.restAPI cancelRequest];
            [self.requestArray removeObject:obj];
            ret = YES;
        }
    }];
    
    return ret;
}

- (void)createFolder:(NSString *)name underParent:(NXFileBase *)parentFolder; {
    //TBD
    NXMyDriveCreateFolderAPI *api =[[NXMyDriveCreateFolderAPI alloc]init];
    
    NSDictionary *object=@{@"parentPathId":parentFolder.fullServicePath,@"name":name};
    [api requestWithObject:object Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        NXMyDriveCreateFolderAPIResponse *resultResponse =(NXMyDriveCreateFolderAPIResponse*)response;
        if (error==nil&&resultResponse.errorR==nil) {
            SDMetadata *data =[[SDMetadata alloc]init];
            data.filename=resultResponse.name;
            data.path=resultResponse.pathDisplay;
            data.fileID = resultResponse.pathId;
            data.lastmodifiedDate = [NSDate dateWithTimeIntervalSince1970:resultResponse.lastModified];
            data.isDirectory = YES;
            if ([self.delegate respondsToSelector:@selector(client:createdFolder:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate client:self createdFolder:data];
                });
            }
        }else{
            NSError *backError=error;
            if (error==nil) {
                backError=resultResponse.errorR;
            }
    if ([self.delegate respondsToSelector:@selector(client:createFolderFailedWithError:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
    [self.delegate client:self createFolderFailedWithError:backError];
                });
            }
        }
    }];
}

- (void)deletePath:(NSString *)path {
    NXMyDriveItemDeleteAPI *api =[[NXMyDriveItemDeleteAPI alloc]init];
    NSDictionary *object =@{@"pathId":path};
    [api requestWithObject:object Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        NXMyDriveItemDeleteAPIResponse *deleResponse=(NXMyDriveItemDeleteAPIResponse*)response;
        if (error==nil&&deleResponse.errorR==nil) {
            if ([self.delegate respondsToSelector:@selector(client:deletedPath:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.delegate client:self deletedPath:path];

                });
                            }
        }else {
            NSError *backError=error;
            if (error==nil) {
                backError=deleResponse.errorR;
            }
            if ([self.delegate respondsToSelector:@selector(client:deletePathFailedWithError:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate client:self deletePathFailedWithError:backError];
                });
                           }
        }
    }];
}

- (void)searchPath:(NSString *)path keywords:(NSString *)keyword {
    //TBD
}

- (void)getRepositoryInfo
{
    NXMyDriveGetUsageRequeset *requeset = [[NXMyDriveGetUsageRequeset alloc] init];
    NSString *email = [NXLoginUser sharedInstance].profile.email;
    NSString *userName = [NXLoginUser sharedInstance].profile.userName;
    [requeset requestWithObject:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        NXMyDriveGetUsageResponse *getInofResponse = (NXMyDriveGetUsageResponse *)response;
        if (!error) {
            if (getInofResponse.rmsStatuCode != NXRMS_ERROR_CODE_SUCCESS) {
                error = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_GET_MYDRIVE_USAGE_INFO_ERROR userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_FAILED_GET_MYDRIVE_QUOTA", nil)}];
                if (DELEGATE_HAS_METHOD(self.delegate, @selector(client:getRepositoryInfo:userEmail:totalQuota:usedQuota:error:))) {
                    dispatch_main_async_safe(^{
                        [self.delegate client:self getRepositoryInfo:userName userEmail:email totalQuota:nil usedQuota:nil error:error];
                    });
                }
            }else{
                if (DELEGATE_HAS_METHOD(self.delegate, @selector(client:getRepositoryInfo:userEmail:totalQuota:usedQuota:error:))) {
                    
                    NSNumber *usage = getInofResponse.usage;
                    NSNumber *quota = getInofResponse.quota;
                    dispatch_main_async_safe(^{
                        [self.delegate client:self getRepositoryInfo:userName userEmail:email totalQuota:quota usedQuota:usage error:nil];
                    });
                }
            }
        }else{
            if (DELEGATE_HAS_METHOD(self.delegate, @selector(client:getRepositoryInfo:userEmail:totalQuota:usedQuota:error:))) {
                dispatch_main_async_safe(^{
                    [self.delegate client:self getRepositoryInfo:userName userEmail:email totalQuota:nil usedQuota:nil error:error];
                });
            }
        }
    }];
}

#pragma mark - private method

@end
