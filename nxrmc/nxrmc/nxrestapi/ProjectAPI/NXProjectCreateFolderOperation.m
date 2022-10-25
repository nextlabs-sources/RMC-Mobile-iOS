//
//  NXProjectCreateFolderOperation.m
//  nxrmc
//
//  Created by xx-huang on 23/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectCreateFolderOperation.h"
#import "NXProjectCreateFolderAPI.h"
#import "NXRMCDef.h"

@interface NXProjectCreateFolderOperation ()

//@property (nonatomic, strong) NSString *folderName;
@property (nonatomic, strong) NSString *NewFolderName;
@property (nonatomic, strong) NSString *parentPathId;
@property (nonatomic, strong) NXProjectFolder *createFolder;
@property(nonatomic, weak) NXProjectCreateFolderAPIRequest *creaetFolderRequest;

@end

@implementation NXProjectCreateFolderOperation

-(instancetype)initWithProjectModel:(NXProjectModel *)projectModel parentPathId:(NSString *)filePath withNewFolderName:(NSString *)folderName autoRename:(NSString *)autoRename
{
    self = [super init];
    if (self) {
        _prjectModel = projectModel;
        _filePath = filePath;
        _NewFolderName = folderName;
        _parentPathId = filePath;
        _autoRename = autoRename;
    }
    return self;
}

- (void)executeTask:(NSError **)error
{
    NXProjectCreateFolderAPIRequest *request = [[NXProjectCreateFolderAPIRequest alloc]init];
    self.creaetFolderRequest = request;
    WeakObj(self);
    NSDictionary *paraDic = @{@"projectId":_prjectModel.projectId,@"parentPathId":_filePath,@"name":_NewFolderName,@"autorename":_autoRename};
    [request requestWithObject:paraDic Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        if (!error){
            NXProjectCreateFolderAPIResponse *returnResponse = (NXProjectCreateFolderAPIResponse *) response;
            if (returnResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS)
            {
//                _folderName = returnResponse.folderName;
                _createFolder = returnResponse.createFolder;
                [self finish:nil];
            }
            else
            {
                NSError *restError = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:@{NSLocalizedDescriptionKey:returnResponse.rmsStatuMessage}];
                [self finish:restError];
            }
        }
        else
        {
            [self finish:error];
        }
    }];
}

- (void)workFinished:(NSError *)error
{
    if (self.projectCreateFolderCompletion)
    {
        self.projectCreateFolderCompletion(_createFolder,error);
    }
}

- (void)cancelWork:(NSError *)cancelError
{
    [self.creaetFolderRequest cancelRequest];
    if (self.projectCreateFolderCompletion)
    {
        self.projectCreateFolderCompletion(_createFolder,cancelError);
    }
}
@end
