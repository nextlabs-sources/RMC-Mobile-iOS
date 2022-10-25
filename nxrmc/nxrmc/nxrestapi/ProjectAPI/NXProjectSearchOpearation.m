//
//  NXProjectSearchOpearation.m
//  nxrmc
//
//  Created by xx-huang on 23/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectSearchOpearation.h"
#import "NXProjectSearchAPI.h"
#import "NXRMCDef.h"

@interface NXProjectSearchOpearation ()

@property (nonatomic, strong) NSMutableArray *matchesFileList;
@property(nonatomic, weak) NXProjectSearchAPIRequest *searchRequet;

@end

@implementation NXProjectSearchOpearation

-(instancetype)initWithProjectModel:(NXProjectModel *)projectModel queryKeyword:(NSString *)keyword
{
    self = [super init];
    if (self) {
        _matchesFileList = [[NSMutableArray alloc] init];
        
        _prjectModel = projectModel;
        _queryKeyword = keyword;
    }
    return self;
}

- (void)executeTask:(NSError **)error
{
   NXProjectSearchAPIRequest *request = [[NXProjectSearchAPIRequest alloc]init];
    self.searchRequet = request;
    WeakObj(self);
    NSDictionary *paraDic = @{@"projectId":_prjectModel.projectId,@"query":_queryKeyword};
    [request requestWithObject:paraDic Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        if (!error){
           NXProjectSearchAPIResponse *returnResponse = (NXProjectSearchAPIResponse *) response;
            if (returnResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS)
            {
                _matchesFileList = returnResponse.matchedFileList;
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
    if (self.projectSearchCompletion)
    {
        self.projectSearchCompletion(_matchesFileList,error);
    }
}

- (void)cancelWork:(NSError *)cancelError
{
    [self.searchRequet cancelRequest];
    if (self.projectSearchCompletion)
    {
        self.projectSearchCompletion(nil,cancelError);
    }
}
@end
