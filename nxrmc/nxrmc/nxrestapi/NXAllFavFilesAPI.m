//
//  NXAllFavAndOfflineFilesAPI.m
//  nxrmc
//
//  Created by EShi on 11/30/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXAllFavFilesAPI.h"
#import "NXLProfile.h"

#pragma mark ----------------------------NXRepoFavInfo----------------------------
@interface NXRepoFavInfo()
@property(nonatomic, readwrite, strong)  NSString *repoID;
@property(nonatomic, readwrite, strong) NSMutableArray *markedFavFiles;
@property(nonatomic, readwrite, strong) NSMutableArray *unmarkedFavFiles;
@end
@implementation NXRepoFavInfo
- (instancetype) init
{
    self = [super init];
    if (self) {
        _markedFavFiles = [[NSMutableArray alloc] init];
        _unmarkedFavFiles = [[NSMutableArray alloc] init];
    }
    return self;
}
@end

#pragma mark ----------------------------NXAllFavFilesResponse----------------------------
@implementation NXAllFavFilesResponse
- (instancetype) init
{
    self = [super init];
    if (self) {
        _repoFavOfflineList  = [[NSMutableArray alloc] init];
    }
    return self;
}
- (void) analysisResponseData:(NSData *) responseData
{
    if (responseData) {
        [super analysisResponseStatus:responseData];
        if (self.rmsStatuCode == 200) {
            NSError *error = nil;
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
            
            self.serverTime = ((NSNumber *)jsonDict[@"serverTime"]).longLongValue;
            
            NSDictionary *resultDict = jsonDict[@"results"];
            NSArray *repos = resultDict[@"repos"];
            for(NSDictionary *reposItem in repos)
            {
                NXRepoFavInfo *info = [[NXRepoFavInfo alloc] init];
                info.repoID = reposItem[@"repoId"];
                
                NSArray * favArray = reposItem[@"markedFavoriteFiles"];
                for (NSDictionary *favNode in favArray) {
                    [info.markedFavFiles addObject:favNode[@"pathId"]];
                }
                
                NSArray * unmarkedFavArray = reposItem[@"unmarkedFavoriteFiles"];
                for (NSDictionary *unmarkedFavNode in unmarkedFavArray) {
                    [info.unmarkedFavFiles addObject:unmarkedFavNode[@"pathId"]];
                }
                [self.repoFavOfflineList addObject:info];
            }
        }
    }
}

@end

#pragma mark ----------------------------NXAllFavFilesRequest----------------------------

@implementation NXAllFavFilesRequest


#pragma mark - NXRESTAPIScheduleProtocol
-(NSMutableURLRequest *) generateRequestObject:(id) object
{
    if (self.reqRequest == nil && [object isKindOfClass:[NXLProfile class]]) {
        NXLProfile *profile = (NXLProfile *)object;
        NSString *strURL = [NSString stringWithFormat:@"%@/rs/favorite", profile.rmserver];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:strURL]];
        [request setHTTPMethod:@"GET"];
        self.reqRequest = request;
    }
   
    return self.reqRequest;
}
- (Analysis)analysisReturnData
{
    Analysis analysisBlock = (id)^(NSString *returnData, NSError *error)
    {
        NXAllFavFilesResponse *response = nil;
        if (!error) {
            response = [[NXAllFavFilesResponse alloc] init];
            [response analysisResponseData: [returnData dataUsingEncoding:NSUTF8StringEncoding]];
        }
  
        return response;
    };
    return analysisBlock;
}
@end



