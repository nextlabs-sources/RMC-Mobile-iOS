//
//  NXPolicyTransFormForCopyOperation.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2022/5/20.
//  Copyright © 2022 nextlabs. All rights reserved.
//

#import "NXPolicyTransFormForCopyOperation.h"
#import "NXLRights.h"
#import "NXFileBase.h"
#import "NXPolicyTransformModel.h"
#import "NXPolicyGetPermissionsForCopyAPI.h"
#import "NXGetLocalNXLFilePermissionsForCopyAPI.h"
#import "NXCommonUtils.h"
@interface NXPolicyTransFormForCopyOperation ()
@property(nonatomic, strong)NXFileBase *currentFile;
@property(nonatomic, strong)NXFileBase *destPathFolder;
@property(nonatomic, strong)NSString *membershipId;
@property(nonatomic, strong)id request;
@property(nonatomic, strong)NXLRights *currentRights;
@end
@implementation NXPolicyTransFormForCopyOperation
- (instancetype)initWithSourceFile:(NXFileBase *)fileItem andDestSpaceFolder:(NXFileBase *)destSpaceFolder andDestSpaceMembershipId:(NSString *)membershipId {
    self = [super init];
    if (self) {
        _currentFile = fileItem;
        _destPathFolder = destSpaceFolder;
        _membershipId = membershipId;
    }
    return self;
}
- (void)executeTask:(NSError *__autoreleasing *)error {
    
    NXPolicyTransformModel *transformModel = [[NXPolicyTransformModel alloc] init];;
    transformModel.scrFilePathId = self.currentFile.fullServicePath;
    transformModel.destMembershipId = self.membershipId;
    transformModel.destFileName = self.currentFile.name;
    switch (self.destPathFolder.sorceType) {
        case NXFileBaseSorceTypeProject:
        {
            transformModel.destSpaceType = @"PROJECT";
        }
            break;
        case NXFileBaseSorceTypeRepoFile:
            transformModel.destSpaceType = [NXCommonUtils rmcToRMSRepoType:self.destPathFolder.serviceType];
            break;
        case NXFileBaseSorceTypeSharedWorkspaceFile:
            transformModel.destSpaceType = @"SHAREPOINT_ONLINE";
            break;
        case NXFileBaseSorceTypeMyVaultFile:
            transformModel.destSpaceType = @"MY_VAULT";
            break;
        case NXFileBaseSorceTypeWorkSpace:
            transformModel.destSpaceType = @"ENTERPRISE_WORKSPACE";
            break;
        case NXFileBaseSorceTypeShareWithMe:
            transformModel.destSpaceType = @"SHARED_WITH_ME";
            break;
        default:
            break;
    }
    switch (self.currentFile.sorceType) {
        case NXFileBaseSorceTypeProject:
        {
            NXProjectFile *projectFile = (NXProjectFile *)self.currentFile;
            transformModel.sourceSpaceId = [projectFile.projectId stringValue];
            transformModel.sourceSpaceType = @"PROJECT";
        }
            break;
        case NXFileBaseSorceTypeRepoFile:
        {
            transformModel.sourceSpaceId = self.currentFile.repoId;
            transformModel.sourceSpaceType = [NXCommonUtils rmcToRMSRepoType:self.currentFile.serviceType];
           
        }
            break;
        case NXFileBaseSorceTypeSharedWorkspaceFile:
        {
            transformModel.sourceSpaceId = self.currentFile.repoId;
            transformModel.sourceSpaceType = @"SHAREPOINT_ONLINE";
            transformModel.scrFilePathId = self.currentFile.fullPath;
        }
            break;
        case NXFileBaseSorceTypeMyVaultFile:
           
        {
          
            transformModel.sourceSpaceType = @"MY_VAULT";
        }
            break;
        case NXFileBaseSorceTypeWorkSpace:
        {
           
            transformModel.sourceSpaceType = @"ENTERPRISE_WORKSPACE";
        }
            break;
        case NXFileBaseSorceTypeShareWithMe:
        {
           
            transformModel.sourceSpaceType = @"SHARED_WITH_ME";
        }
            break;
        case NXFileBaseSorceTypeLocalFiles:
        {
            NSData *fileData = [NSData dataWithContentsOfFile:self.currentFile.localPath];
            NSData *headerData = [fileData subdataWithRange:NSMakeRange(0, NXL_FILE_HEAD_LENGTH)];
            transformModel.headerData = headerData;
            [self transformLocalFile:transformModel];
           
            return;
        }
            break;
        default:
            break;
    }
    
    NXPolicyGetPermissionsForCopyAPIRequest *request = [[NXPolicyGetPermissionsForCopyAPIRequest alloc]init];
    self.request = request;
    [request requestWithObject:transformModel Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (!error) {
            NXPolicyGetPermissionsForCopyAPIResponse *copyResponse = (NXPolicyGetPermissionsForCopyAPIResponse *)response;
            if (copyResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS ) {
                NSString *watermarkStr = copyResponse.watermarkStr;
                NSArray *rightsArray = copyResponse.rightsArray;
                NXLRights *rights = [[NXLRights alloc] init];
                [rights setStringRights:rightsArray];
                [rights setWatermarkString:watermarkStr];
                self.currentRights = rights;

            }else{
                error = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:copyResponse.rmsStatuMessage?@{NSLocalizedDescriptionKey : copyResponse.rmsStatuMessage}:nil];
            }
        }
        [self finish:error];
    }];
}
- (void)transformLocalFile:(id)model {
   
    NXGetLocalNXLFilePermissionsForCopyAPIRequest *request = [[NXGetLocalNXLFilePermissionsForCopyAPIRequest alloc]init];
    self.request = request;
    [request requestWithObject:model Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (!error) {
            NXGetLocalNXLFilePermissionsForCopyAPIResponse *copyResponse = (NXGetLocalNXLFilePermissionsForCopyAPIResponse *)response;
            if (copyResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS ) {
                NSString *watermarkStr = copyResponse.watermarkStr;
                NSArray *rightsArray = copyResponse.rightsArray;
                NXLRights *rights = [[NXLRights alloc] init];
                [rights setStringRights:rightsArray];
                [rights setWatermarkString:watermarkStr];
                self.currentRights = rights;

            }else{
                error = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:copyResponse.rmsStatuMessage?@{NSLocalizedDescriptionKey : copyResponse.rmsStatuMessage}:nil];
            }
        }
        [self finish:error];
    }];
    
}
- (void)workFinished:(NSError *)error{
    if (self.transFormPemissionsFinishCompletion) {
        self.transFormPemissionsFinishCompletion(self.currentRights, error);
    }
}
- (void)cancelWork:(NSError *)cancelError {
    [self.request cancelRequest];
}

@end
