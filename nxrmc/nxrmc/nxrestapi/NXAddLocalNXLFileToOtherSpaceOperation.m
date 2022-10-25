//
//  NXAddLocalNXLFileToOtherSpaceOperation.m
//  nxrmc
//
//  Created by Sznag on 2022/2/23.
//  Copyright © 2022 nextlabs. All rights reserved.
//

#import "NXAddLocalNXLFileToOtherSpaceOperation.h"
#import "NXCopyNxlFileTransformModel.h"
#import "NXAddLocalNXLFileToOtherSpaceAPI.h"
@interface NXAddLocalNXLFileToOtherSpaceOperation ()
@property(nonatomic, strong)NXFileBase *fileItem;
@property(nonatomic, strong)NXFileBase *destPathFolder;
@property(nonatomic, strong)NSString *destType;
@property(nonatomic, strong)NXAddLocalNXLFileToOtherSpaceAPIRequest *request;
@property(nonatomic, strong)NSString *tempCopyPath;
@property(nonatomic, assign)BOOL overwrite;
@end
@implementation NXAddLocalNXLFileToOtherSpaceOperation
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
    transformModel.fileName = self.fileItem.name;
    transformModel.fileLocalPath = self.fileItem.localPath;
    transformModel.sourceSpaceType = @"LOCAL_DRIVE";
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
    
    NXAddLocalNXLFileToOtherSpaceAPIRequest *request = [[NXAddLocalNXLFileToOtherSpaceAPIRequest alloc]init];
    self.request = request;
    [request requestWithObject:transformModel Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (!error) {
            NXAddLocalNXLFileToOtherSpaceAPIResponse *copyResponse = (NXAddLocalNXLFileToOtherSpaceAPIResponse *)response;
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
    if (self.addLocalNXLFileFinishCompletion) {
        self.addLocalNXLFileFinishCompletion(self.fileItem, error);
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
