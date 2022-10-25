//
//  NXCopyNxlFileOperation.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2021/4/9.
//  Copyright © 2021 nextlabs. All rights reserved.
//

#import "NXCopyNxlFileOperation.h"
#import "NXCopyNxlFileAPI.h"
#import "NXCopyNxlFileTransformModel.h"
#import "NXMyVaultFile.h"
#import "NXProjectFile.h"
#import "NXWorkSpaceItem.h"
#import "NXSharedWithMeFile.h"
#import "NXRepoFileSync.h"
@interface NXCopyNxlFileOperation ()
@property(nonatomic, strong)NXFileBase *fileItem;
@property(nonatomic, strong)NXFileBase *destPathFolder;
@property(nonatomic, strong)NSString *destType;
@property(nonatomic, strong)NXCopyNxlFileAPIRequest *request;
@property(nonatomic, strong)NSString *tempCopyPath;
@property(nonatomic, assign)BOOL overwrite;
@end

@implementation NXCopyNxlFileOperation
- (instancetype)initWithSourceFile:(NXFileBase *)fileItem andDestSpaceType:(NSString *)destSapceType{
    if (self = [super init]) {
        _fileItem = fileItem;
        _destType = destSapceType;
    }
    return self;
}
-(instancetype)initWithSourceFile:(NXFileBase *)fileItem shouldOverwrite:(BOOL)overwrite andDestSpaceType:(NSString *)destSapceType andDestSpacePathFolder:(NXFileBase *)destSpacePathFolder{
    if (self = [super init]) {
        _fileItem = fileItem;
        _destType = destSapceType;
        _destPathFolder = destSpacePathFolder;
        _overwrite = overwrite;
    }
    return self;
    
}
- (void)executeTask:(NSError *__autoreleasing *)error {
    NXCopyNxlFileTransformModel *transformModel = [[NXCopyNxlFileTransformModel alloc] init];;
    transformModel.overwrite = self.overwrite;
    transformModel.destSpaceType = self.destType?:@"";
    transformModel.destSpacePath = self.destPathFolder.fullServicePath?:@"/";
    switch (self.destPathFolder.sorceType) {
        case NXFileBaseSorceTypeProject:
        {
            NXProjectFile *projectFile = (NXProjectFile *)self.destPathFolder;
            transformModel.destSpaceId = projectFile.projectId?[NSString stringWithFormat:@"%@",projectFile.projectId]:@"";
            transformModel.fileDestSpaceType = NXFileDestSpaceTypeProject;
        }
            break;
        case NXFileBaseSorceTypeRepoFile:
            transformModel.fileDestSpaceType = NXFileDestSpaceTypePersonalRepository;
            transformModel.destSpaceId = self.destPathFolder.repoId?:@"";
            if (self.destPathFolder.isRoot && [self.destPathFolder.fullServicePath isEqualToString:@""]) {
                transformModel.destSpacePath = @"/";
            }
            break;
        case NXFileBaseSorceTypeSharedWorkspaceFile:
            transformModel.fileDestSpaceType = NXFileDestSpaceTypeSharedWorkspace;
            transformModel.destSpaceId = self.destPathFolder.repoId?:@"";
            transformModel.destSpacePath = self.destPathFolder.fullPath?:@"/";
            break;
        case NXFileBaseSorceTypeMyVaultFile:
            transformModel.fileDestSpaceType = NXFileDestSpaceTypeMyvault;
            break;
        case NXFileBaseSorceTypeWorkSpace:
            transformModel.fileDestSpaceType = NXFileDestSpaceTypeEnterWorkspace;
            break;
        default:
            break;
    }
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
//            transformModel.filePathId = [NSString stringWithFormat:@"/nxl_myvault_nxl/%@",self.fileItem.name];
            transformModel.filePathId = self.fileItem.fullServicePath;
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
    
    NXCopyNxlFileAPIRequest *request = [[NXCopyNxlFileAPIRequest alloc]init];
    self.request = request;
    [request requestWithObject:transformModel Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (!error) {
            NXCopyNxlFileAPIResponse *copyResponse = (NXCopyNxlFileAPIResponse *)response;
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
    if (self.copyNxlFileCompletion) {
        self.copyNxlFileCompletion(self.fileItem, error);
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
