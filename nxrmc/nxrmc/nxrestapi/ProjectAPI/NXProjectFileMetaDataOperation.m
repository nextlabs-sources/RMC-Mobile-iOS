//
//  NXProjectFileMetaDataOperation.m
//  nxrmc
//
//  Created by xx-huang on 23/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectFileMetaDataOperation.h"
#import "NXRMCDef.h"
#import "NXProjectFile.h"
@interface NXProjectFileMetaDataOperation ()

@property (nonatomic,strong) NXProjectFile *fileInfo;
@property (nonatomic, weak) NXProjectFileMetaDataAPIRequest *fileMetaDataRequest;

@end

@implementation NXProjectFileMetaDataOperation

-(instancetype)initWithProjectModel:(NXProjectModel *)projectModel filePath:(NSString *)filePath
{
    self = [super init];
    if (self) {
        
        _fileInfo = [[NXProjectFile alloc] init];
        
        _prjectModel = projectModel;
        _filePath = filePath;
    }
    return self;
}

- (void)executeTask:(NSError **)error
{
    NXProjectFileMetaDataAPIRequest *request = [[NXProjectFileMetaDataAPIRequest alloc]init];
    self.fileMetaDataRequest = request;
    WeakObj(self);
    NSDictionary *paraDic = @{@"projectId":_prjectModel.projectId,@"filePath":_filePath};
    [request requestWithObject:paraDic Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        if (!error){
          NXProjectFileMetaDataAPIResponse *returnResponse = (NXProjectFileMetaDataAPIResponse *) response;
            if (returnResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS)
            {
                _fileInfo = returnResponse.fileInfo;
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
    if (self.getProjectFileMetadataCompletion)
    {
        self.getProjectFileMetadataCompletion(_fileInfo,_filePath,error);
    }
}

- (void)cancelWork:(NSError *)cancelError
{
    [self.fileMetaDataRequest cancelRequest];
    if (self.getProjectFileMetadataCompletion)
    {
        self.getProjectFileMetadataCompletion(_fileInfo,_filePath,cancelError);
    }
}
@end
