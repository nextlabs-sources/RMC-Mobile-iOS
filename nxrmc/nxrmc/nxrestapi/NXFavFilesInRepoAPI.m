//
//  NXMarkFavFailesInRepoAPI.m
//  nxrmc
//
//  Created by EShi on 11/30/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXFavFilesInRepoAPI.h"
#import "NXLProfile.h"
#import "NXRMCDef.h"
#import "NXLoginUser.h"

#pragma mark - -----------------------NXFavFilesInRepoResponse------------------------
@implementation NXFavFilesInRepoResponse
-(void) analysisResult:(NSString *)returnString error:(NSError **) error
{
    if (returnString) {
        NSData *returnData = [returnString dataUsingEncoding:NSUTF8StringEncoding];
        
        [super analysisResponseStatus:returnData];
    }
}
@end

#pragma mark ----------------------NXFavFilesInRepoRequest---------------------------
@interface NXFavFilesInRepoRequest()
@property(nonatomic, assign) NXFavFilesInRepoRequestType requestType;
@property(nonatomic, readwrite, strong) NSMutableArray *operationFileIds;
@end
@implementation NXFavFilesInRepoRequest
#pragma mark - NXRESTAPIScheduleProtocol
-(instancetype)init
{
    NSAssert(NO, @"Must use initWithType");
    return nil;
}
-(instancetype)initWithType:(NXFavFilesInRepoRequestType) type
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
        NSDictionary *modelDict = (NSDictionary *)object;
        NSString *repoId = modelDict[NXFavFilesInRepoModel_RepoIdKey];
        NSArray *fileItemList = modelDict[NXFavFilesInRepoModel_FilesKey];
        NXFileBase *parent = modelDict[NXFavFilesInRepoModel_ParentKey];
        
        NSString *urlString = [NSString stringWithFormat:@"%@/rs/favorite/%@", [NXLoginUser sharedInstance].profile.rmserver, repoId];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
        switch (self.requestType) {
            case NXFavFilesInRepoRequestTypeMark:
                [request setHTTPMethod:@"POST"];
                break;
            case NXFavFilesInRepoRequestTypeUnmark:
                [request setHTTPMethod:@"DELETE"];
                break;
            default:
                break;
        }
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        NSMutableArray *filesList = [[NSMutableArray alloc] init];
        for (NXFileBase *file in fileItemList) {
            NSDictionary *dic = nil;
            if (self.requestType == NXFavFilesInRepoRequestTypeMark) {
                NSTimeInterval lastModifiedTime = [file.lastModifiedDate timeIntervalSince1970];
                long long longModifiedTime = lastModifiedTime * 1000;
                NSNumber *numLastModifiedTime = [NSNumber numberWithLongLong:longModifiedTime];
                dic = @{@"pathId":file.fullServicePath, @"pathDisplay":file.fullPath, @"parentFileId":parent.isRoot?@"/":parent.fullServicePath, @"fileSize":[NSNumber numberWithLongLong:file.size], @"fileLastModified":numLastModifiedTime};
            }else{
                dic = @{@"pathId":file.fullServicePath, @"pathDisplay":file.fullPath};
            }
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
        NXFavFilesInRepoResponse *response = [[NXFavFilesInRepoResponse alloc] init];
        [response analysisResult:returnString error:&error];
        if (response.rmsStatuCode == NXRMS_ERROR_CODE_UNAUTHENTICATED) { // unauthenticated means repo may deleted, so we tread as success here
            response.rmsStatuCode = NXRMS_ERROR_CODE_SUCCESS;
        }
        return response;
    };
    return analysis;
}

@end

