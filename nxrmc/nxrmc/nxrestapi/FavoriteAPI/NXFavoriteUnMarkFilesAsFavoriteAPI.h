//
//  NXFavoriteUnMarkFilesAsFavoriteAPI.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 21/08/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXSuperRESTAPI.h"

@interface NXFavoriteUnMarkFilesAsFavoriteAPIRequest : NXSuperRESTAPIRequest <NXRESTAPIScheduleProtocol>
-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;
@end

@interface NXFavoriteUnMarkFilesAsFavoriteAPIResponse : NXSuperRESTAPIResponse
@end
