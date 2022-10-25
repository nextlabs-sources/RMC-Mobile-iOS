//
//  NXGetClassificationProfileAPI.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 15/03/2018.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXSuperRESTAPI.h"
#import "NXClassificationCategory.h"
#import "NXClassificationLab.h"

@interface NXGetClassificationProfileAPIRequest : NXSuperRESTAPIRequest<NXRESTAPIScheduleProtocol>
-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;
@end

@interface NXGetClassificationProfileAPIResponse : NXSuperRESTAPIResponse

@property (nonatomic, strong) NSMutableArray *returndCategoriesArray;
@end

