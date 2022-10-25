//
//  NXGetFavFilesInRepoAPI.m
//  nxrmc
//
//  Created by EShi on 11/30/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXGetFavFilesInRepoAPI.h"
#import "NXLProfile.h"


#pragma mark -----------------NXGetFavFilesInRepoResponse--------------------
@interface NXGetFavFilesInRepoResponse()
@property(nonatomic, readwrite, strong) NSMutableArray *markedFavFiles;
@property(nonatomic, readwrite, strong) NSMutableArray *unmarkedFavFiles;
@property(nonatomic, readwrite, assign) BOOL isFullCopy;
@end

@implementation NXGetFavFilesInRepoResponse
- (void) analysisReponseData:(NSData *) responseData error:(NSError *) error
{
    if (responseData && error == nil) {
        [super analysisResponseStatus:responseData];
        if (self.rmsStatuCode == 200) {
            self.markedFavFiles = [[NSMutableArray alloc] init];
            self.unmarkedFavFiles = [[NSMutableArray alloc] init];
            
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
            self.isFullCopy = jsonDict[@"results"][@"isFullCopy"];
            NSArray *markedFavFiles = jsonDict[@"results"][@"markedFavoriteFiles"];
            NSArray *unmarkedFavFiles = jsonDict[@"results"][@"unmarkedFavoriteFiles"];
            for (NSDictionary *favNode in markedFavFiles) {
                [self.markedFavFiles addObject:favNode[@"pathId"]];
            }
            
            for (NSDictionary *unmarkedFavNode in unmarkedFavFiles) {
                [self.unmarkedFavFiles addObject:unmarkedFavNode[@"pathId"]];
            }
        }
    }
}

@end

#pragma mark -----------------NXGetFavFilesInRepoRequest--------------------
@implementation NXGetFavFilesInRepoRequest
#pragma mark - NXRESTAPIScheduleProtocol
-(NSMutableURLRequest *) generateRequestObject:(id) object
{
    if (!self.reqRequest && [object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *modalDict = (NSDictionary *) object;
        NSNumber *lastModified = modalDict[NXGetFavFilesInRepoModel_ServiceTimeKey];
        NSString *repoId = modalDict[NXGetFavFilesInRepoModel_RepoIdKey];
        NXLProfile *profile = modalDict[NXGetFavFilesInRepoModel_UserProfileKey];
        
        NSString *strURL = [NSString stringWithFormat:@"%@/rs/repository/%@/files/favorite%@", profile.rmserver, repoId, lastModified? [NSString stringWithFormat:@"?last_modified=%lld", lastModified.longLongValue]: @""];
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
        NXGetFavFilesInRepoResponse *response = [[NXGetFavFilesInRepoResponse alloc] init];
        [response analysisReponseData:[returnStr dataUsingEncoding:NSUTF8StringEncoding] error:error];
        return response;
    };
    return analysis;
}
@end




