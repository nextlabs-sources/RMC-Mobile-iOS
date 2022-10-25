//
//  NXMarkOfflineFilesInRepoAPI.m
//  nxrmc
//
//  Created by EShi on 11/30/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXOfflineFilesInRepoAPI.h"
#import "NXLProfile.h"
#import "NXRMCDef.h"

#pragma mark - -----------------------NXOfflineFilesInRepoResponse------------------------
@implementation NXOfflineFilesInRepoResponse
-(void) analysisResult:(NSString *)returnString error:(NSError **) error
{
    if (returnString) {
        NSData *returnData = [returnString dataUsingEncoding:NSUTF8StringEncoding];
        
        [super analysisResponseStatus:returnData];
    }
}
@end

#pragma mark ----------------------NXOfflineFilesInRepoRequest---------------------------
@interface NXOfflineFilesInRepoRequest()
@property(nonatomic, assign) NXOfflineFilesInRepoRequestType requestType;
@property(nonatomic, readwrite, strong) NSMutableArray *operationFileIds;
@end
@implementation NXOfflineFilesInRepoRequest
#pragma mark - NXRESTAPIScheduleProtocol
-(instancetype)init
{
    NSAssert(NO, @"Must use initWithType");
    return nil;
}

- (instancetype) initWithType:(NXOfflineFilesInRepoRequestType) type
{
    self = [super init];
    if (self) {
        _requestType = type;
        _operationFileIds = [[NSMutableArray alloc] init];
    }
    return self;
}

-(NSMutableURLRequest *) generateRequestObject:(id) object
{
    if (self.reqRequest == nil  && [object isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *modalDict = (NSDictionary *)object;
        NXLProfile *profile = modalDict[NXOfflineFilesInRepoModel_UserProfileKey];
        NSString *repoID = modalDict[NXOfflineFilesInRepoModel_RepoIdKey];
        NSArray *fileIdList = modalDict[NXOfflineFilesInRepoModel_FilesKey];
        
        NSString *urlString = [NSString stringWithFormat:@"%@/rs/repository/%@/files/offline", profile.rmserver, repoID];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
        switch (self.requestType) {
            case NXOfflineFilesInRepoRequestTypeeMark:
                [request setHTTPMethod:@"POST"];
                break;
            case NXOfflineFilesInRepoRequestTypeUnmark:
                [request setHTTPMethod:@"DELETE"];
                break;
            default:
                break;
        }
        
        [request setValue:profile.userId forHTTPHeaderField:@"userId"];
        [request setValue:profile.ticket forHTTPHeaderField:@"ticket"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        NSMutableArray *filesList = [[NSMutableArray alloc] init];
        for (NSString *fileId in fileIdList) {
            NSDictionary *dic = @{@"pathId":fileId, @"pathDisplay":@"Unset"};
            [self.operationFileIds addObject:fileId];
            [filesList addObject:dic];
        };
        
        NSDictionary *filesDict = @{@"files":filesList};
        NSDictionary *bodyDict = @{@"parameters":filesDict};
        NSError *error = nil;
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:bodyDict options:NSJSONWritingPrettyPrinted error:&error];
        [request setHTTPBody:bodyData];
        
        self.reqRequest = request;
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnString, NSError *error)
    {
        NXOfflineFilesInRepoResponse *response = [[NXOfflineFilesInRepoResponse alloc] init];
        [response analysisResult:returnString error:&error];
        if (response.rmsStatuCode == NXRMS_ERROR_CODE_UNAUTHENTICATED) {
            response.rmsStatuCode = NXRMS_ERROR_CODE_SUCCESS;
        }
        return response;
    };
    return analysis;
}

@end
