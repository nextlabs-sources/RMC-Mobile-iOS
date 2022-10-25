//
//  NXAllFavAndOfflineFilesAPI.h
//  nxrmc
//
//  Created by EShi on 11/30/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

@interface NXRepoFavInfo : NSObject
@property(nonatomic, readonly, strong) NSString *repoID;
@property(nonatomic, readonly, strong) NSMutableArray *markedFavFiles;
@property(nonatomic, readonly, strong) NSMutableArray *unmarkedFavFiles;
@property(nonatomic, assign) long long serverTime;
@end

@interface NXAllFavFilesResponse : NXSuperRESTAPIResponse
- (void) analysisResponseData:(NSData *) responseData;
@property(nonatomic, strong) NSMutableArray *repoFavOfflineList;
@end

@interface NXAllFavFilesRequest : NXSuperRESTAPIRequest

@end




