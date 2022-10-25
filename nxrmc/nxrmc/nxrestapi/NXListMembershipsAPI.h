//
//  NXListMembershipsAPI.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 20/03/2018.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXSuperRESTAPI.h"

@interface NXListMembershipsResultModel :NSObject

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, copy) NSString *tenantId;
@property (nonatomic, copy) NSNumber *projectId;
@end

@interface NXListMembershipsAPIRequest : NXSuperRESTAPIRequest
@end

@interface NXListMembershipsAPIResponse : NXSuperRESTAPIResponse
@property (nonatomic, strong) NSArray<NXListMembershipsResultModel *> *resultArray;
@end
