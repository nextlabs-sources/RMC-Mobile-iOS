//
//  NXProjectDeleteFolderOperation.m
//  nxrmc
//
//  Created by xx-huang on 23/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectDeleteFolderOperation.h"
#import "NXProjectDeleteFileAPI.h"
#import "NXRMCDef.h"
#import "NXProjectFolder.h"

@interface NXProjectDeleteFolderOperation ()

@property(nonatomic,strong) NXProjectFolder *deletedFolder;
@property(nonatomic, weak) NXProjectDeleteFileAPIRequest *delRequest;
@end

@implementation NXProjectDeleteFolderOperation

-(instancetype)initWithProjectModel:(NXProjectModel *)projectModel filePath:(NSString *)filePath;
{
    self = [super init];
    if (self) {
        _deletedFolder = [[NXProjectFolder alloc] init];
        
        _prjectModel = projectModel;
        _filePath = filePath;
    }
    return self;
}

- (void)executeTask:(NSError **)error
{
    NXProjectDeleteFileAPIRequest *request = [[NXProjectDeleteFileAPIRequest alloc]init];
    self.delRequest = request;
    WeakObj(self);
    NSDictionary *paraDic = @{@"projectId":_prjectModel.projectId,@"filePath":_filePath};
    [request requestWithObject:paraDic Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        if (!error){
            NXProjectDeleteFileAPIResponse *returnResponse = (NXProjectDeleteFileAPIResponse *) response;
            if (returnResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS)
            {
                _deletedFolder.fullServicePath = returnResponse.path;
                _deletedFolder.name = returnResponse.name;
                
                [self finish:nil];
            }
            else
            {
                NSError *restError = [[NSError alloc] initWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_CODE_RMS_REST_FAILED userInfo:nil];
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
    if (self.projectDeleteFolderCompletion)
    {
        self.projectDeleteFolderCompletion(_deletedFolder,error);
    }
}

- (void)cancelWork:(NSError *)cancelError
{
    [self.delRequest cancelRequest];
    if (self.projectDeleteFolderCompletion)
    {
        self.projectDeleteFolderCompletion(_deletedFolder,cancelError);
    }
}

@end
