//
//  NXSharedWithMeReshareFileAPI.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 27/7/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

@interface NXSharedWithMeReshareFileAPIRequest : NXSuperRESTAPIRequest <NXRESTAPIScheduleProtocol>
-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;
@end
@class NXShareWithMeReshareResponseModel;
@interface NXSharedWithMeReshareFileAPIResponse : NXSuperRESTAPIResponse
@property (nonatomic ,strong)NXShareWithMeReshareResponseModel *responseModel;
@end
