//
//  NXAllProjectListAPI.h
//  nxrmc
//
//  Created by Sznag on 2020/3/12.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface NXAllProjectListAPIRequest : NXSuperRESTAPIRequest<NXRESTAPIScheduleProtocol>
-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;

@end
@interface NXAllProjectListAPIResponse : NXSuperRESTAPIResponse
@property (nonatomic, strong) NSMutableArray *itemsArray;
@end
NS_ASSUME_NONNULL_END
