//
//  NXSaveAsToLocalOperation.m
//  nxrmc
//
//  Created by Sznag on 2022/2/15.
//  Copyright © 2022 nextlabs. All rights reserved.
//

#import "NXSaveAsToLocalOperation.h"
#import "NXSaveAsToLocalAPI.h"
#import "NXCopyNxlFileTransformModel.h"

static NSString *localSpaceType = @"LOCAL_DRIVE";


@interface NXSaveAsToLocalOperation ()
@property(nonatomic, strong)NXFileBase *fileItem;
@property(nonatomic, strong)NSString *tempCopyPath;

@property(nonatomic, strong)NXSaveAsToLocalAPIRequest *request;

@end
@implementation NXSaveAsToLocalOperation
- (instancetype)initWithSourceFile:(NXFileBase *)fileItem {
    self = [super init];
    if (self) {
        _fileItem = fileItem;
    }
    return self;
}
- (void)executeTask:(NSError *__autoreleasing *)error {
    NXCopyNxlFileTransformModel *transformModel = [[NXCopyNxlFileTransformModel alloc] init];;
   
    transformModel.destSpaceType = localSpaceType;
   
    switch (self.fileItem.sorceType) {
        case NXFileBaseSorceTypeProject:
        {
            NXProjectFile *projectFile = (NXProjectFile *)self.fileItem;
            transformModel.fileSourceType = NXFileSourceTypeProject;
            transformModel.fileName = projectFile.name;
            transformModel.filePath = projectFile.fullPath;
            transformModel.filePathId = projectFile.fullServicePath;
            transformModel.scrSpaceId = [NSString stringWithFormat:@"%@",projectFile.projectId];
            transformModel.sourceSpaceType = @"PROJECT";
        }
            break;
        case NXFileBaseSorceTypeRepoFile:
        {
            transformModel.fileSourceType = NXFileSourceTypePersonalRepository;
            transformModel.fileName = self.fileItem.name;
            transformModel.filePath = self.fileItem.fullPath;
            transformModel.scrSpaceId = self.fileItem.repoId;
            transformModel.filePathId = self.fileItem.fullServicePath;
            transformModel.sourceSpaceType = [NXCommonUtils rmcToRMSRepoType:self.fileItem.serviceType];
           
        }
            break;
        case NXFileBaseSorceTypeSharedWorkspaceFile:
        {
            transformModel.fileSourceType = NXFileSourceTypeSharedWorkspace;
            transformModel.fileName = self.fileItem.name;
            transformModel.filePath = self.fileItem.fullPath;
            transformModel.filePathId = self.fileItem.fullPath;
            transformModel.scrSpaceId = self.fileItem.repoId;
            transformModel.sourceSpaceType = @"SHAREPOINT_ONLINE";
        }
            break;
        case NXFileBaseSorceTypeMyVaultFile:
           
        {
            transformModel.fileSourceType = NXFileSourceTypeMyvault;
            transformModel.fileName = self.fileItem.name;
            transformModel.filePathId = [NSString stringWithFormat:@"/nxl_myvault_nxl/%@",self.fileItem.name];
            transformModel.sourceSpaceType = @"MY_VAULT";
        }
            break;
        case NXFileBaseSorceTypeWorkSpace:
        {
            transformModel.fileSourceType = NXFileSourceTypeEnterWorkspace;
            transformModel.fileName = self.fileItem.name;
            transformModel.filePath = self.fileItem.fullPath;
            transformModel.filePathId = self.fileItem.fullServicePath;
            transformModel.sourceSpaceType = @"ENTERPRISE_WORKSPACE";
        }
            break;
        case NXFileBaseSorceTypeShareWithMe:
        {
            NXSharedWithMeFile *sharedWithMeFile = (NXSharedWithMeFile *)self.fileItem;
            transformModel.fileSourceType = NXFileSourceTypeSharedWithMe;
            transformModel.fileName = sharedWithMeFile.name;
            transformModel.transactionCode = sharedWithMeFile.transactionCode;
            transformModel.transactionId = sharedWithMeFile.transactionId;
            transformModel.sourceSpaceType = @"SHARED_WITH_ME";
        }
            break;
        default:
            break;
    }
    NXSaveAsToLocalAPIRequest *request = [[NXSaveAsToLocalAPIRequest alloc]init];
    self.request = request;
    [request requestWithObject:transformModel Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (!error) {
            NXSaveAsToLocalAPIResponse *copyResponse = (NXSaveAsToLocalAPIResponse *)response;
            if (copyResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS ) {
                NSString *fileName = copyResponse.fileName;
                NSData *fileData = copyResponse.fileData;
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSString *filePath = [self.tempCopyPath stringByAppendingPathComponent:fileName];
                if ([fileManager createFileAtPath:filePath contents:fileData attributes:nil]){
                    self.fileItem.localPath = filePath;
                }

            }else{
                error = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:copyResponse.rmsStatuMessage?@{NSLocalizedDescriptionKey : copyResponse.rmsStatuMessage}:nil];
            }
        }
        [self finish:error];
    }];
}
- (void)workFinished:(NSError *)error{
    if (self.saveAsFinishCompletion) {
        self.saveAsFinishCompletion(self.fileItem, error);
    }
}
- (void)cancelWork:(NSError *)cancelError {
    [self.request cancelRequest];
}
- (NSString *)tempCopyPath{
    NSString *docPath =  NSTemporaryDirectory();
    NSString *tmpPath = [docPath stringByAppendingPathComponent:@"CopyTemp"];
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:tmpPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:tmpPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    return tmpPath;
}
@end
