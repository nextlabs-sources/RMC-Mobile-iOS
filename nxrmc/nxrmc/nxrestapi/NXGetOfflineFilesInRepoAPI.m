//
//  NXGetOfflineFilesInRepoAPI.m
//  nxrmc
//
//  Created by EShi on 11/30/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXGetOfflineFilesInRepoAPI.h"
#import "NXLProfile.h"


#pragma mark -----------------NXGetOfflineFilesInRepoResponse--------------------
@interface NXGetOfflineFilesInRepoResponse()
@property(nonatomic, readwrite, strong) NSMutableArray *markedOfflineFiles;
@property(nonatomic, readwrite, strong) NSMutableArray *unmarkedOfflineFiles;
@property(nonatomic, readwrite, assign) BOOL isFullCopy;
@end

@implementation NXGetOfflineFilesInRepoResponse
- (void) analysisReponseData:(NSData *) responseData error:(NSError *) error
{
    if (responseData && error == nil) {
        [super analysisResponseStatus:responseData];
        if (self.rmsStatuCode == 200) {
            self.markedOfflineFiles = [[NSMutableArray alloc] init];
            self.unmarkedOfflineFiles = [[NSMutableArray alloc] init];
            
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
            self.isFullCopy = jsonDict[@"results"][@"isFullCopy"];
            NSArray *markedOfflineFiles = jsonDict[@"results"][@"markedOfflineFiles"];
            NSArray *unmarkedOfflineFiles = jsonDict[@"results"][@"unmarkedOfflineFiles"];
            for (NSDictionary *OfflineNode in markedOfflineFiles) {
                [self.markedOfflineFiles addObject:OfflineNode[@"pathId"]];
            }
            
            for (NSDictionary *unmarkedOfflineNode in unmarkedOfflineFiles) {
                [self.unmarkedOfflineFiles addObject:unmarkedOfflineNode[@"pathId"]];
            }
        }
    }
}

@end

#pragma mark -----------------NXGetOfflineFilesInRepoRequest--------------------
@implementation NXGetOfflineFilesInRepoRequest
#pragma mark - NXRESTAPIScheduleProtocol
-(NSMutableURLRequest *) generateRequestObject:(id) object
{
    if (!self.reqRequest && [object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *modalDict = (NSDictionary *) object;
        NSNumber *lastModified = modalDict[NXGetOfflineFilesInRepoModel_ServiceTimeKey];
        NSString *repoId = modalDict[NXGetOfflineFilesInRepoModel_RepoIdKey];
        NXLProfile *profile = modalDict[NXGetOfflineFilesInRepoModel_UserProfileKey];
        
        NSString *strURL = [NSString stringWithFormat:@"%@/rs/repository/%@/files/offline%@", profile.rmserver, repoId, lastModified? [NSString stringWithFormat:@"?last_modified=%lld", lastModified.longLongValue]: @""];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:strURL]];
        [request setHTTPMethod:@"GET"];
        [request setValue:profile.userId forHTTPHeaderField:@"userId"];
        [request setValue:profile.ticket forHTTPHeaderField:@"ticket"];
        self.reqRequest = request;
    }
    
    return self.reqRequest;
}
- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnStr, NSError *error)
    {
        NXGetOfflineFilesInRepoResponse *response = [[NXGetOfflineFilesInRepoResponse alloc] init];
        [response analysisReponseData:[returnStr dataUsingEncoding:NSUTF8StringEncoding] error:error];
        return response;
    };
    return analysis;
}
@end




