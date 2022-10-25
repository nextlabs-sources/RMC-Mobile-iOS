//
//  NXFavoriteGetFavoriteFilesInRepoAPI.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 21/08/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXSuperRESTAPI.h"

@interface NXFavoriteGetFavoriteFilesInRepoAPIRequest : NXSuperRESTAPIRequest <NXRESTAPIScheduleProtocol>
-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;
@end

@interface NXFavoriteGetFavoriteFilesInRepoAPIResponse : NXSuperRESTAPIResponse
@property (nonatomic,strong) NSMutableArray *favoriteFilesList;
@end
