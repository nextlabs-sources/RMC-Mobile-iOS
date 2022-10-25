//
//  NXFileActivityLogAPI.h
//  nxrmc
//
//  Created by helpdesk on 20/2/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"
#pragma mark parameter model
@interface NXFileActivityLogParModel:NSObject
@property(nonatomic, assign)NSInteger start;
@property(nonatomic, assign)NSInteger count;
@property(nonatomic, strong)NSString *seachField;
@property(nonatomic, strong)NSString *serachText;
@property(nonatomic, strong)NSString *orderBy;
@property(nonatomic, strong)NSString *orderByReverse;
@property(nonatomic, strong)NSString *fileDUID;
@end
#pragma mark parameter result model
@interface NXFileActivityLogRecordsModel : NSObject
@property(nonatomic, strong)NSString *duid;
@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)NSNumber *accessTime;
@property(nonatomic, strong)NSString *email;
@property(nonatomic, strong)NSString *operation;
@property(nonatomic, strong)NSString *deviceType;
@property(nonatomic, strong)NSString *deviceId;
@property(nonatomic, strong)NSString *accessTimeStr;
@property(nonatomic, strong)NSString *accessResult;
@property(nonatomic, strong)NSString *activityData;
@property(nonatomic, strong)NSString *activityDetail;
@property(nonatomic, strong)NSString *accessTimeShortStr;
-(instancetype)initWithNXFileActivityLogRecordsModelDic:(NSDictionary*)dic;
@end
@interface NXFileActivityLogAPIRequest : NXSuperRESTAPIRequest<NXRESTAPIScheduleProtocol>
-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;
@end


@interface NXFileActivityLogAPIResponse : NXSuperRESTAPIResponse
@property(nonatomic, strong)NSMutableArray *logRecords;

@end
