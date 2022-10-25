//
//  NXFileActivityLogAPI.m
//  nxrmc
//
//  Created by helpdesk on 20/2/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXFileActivityLogAPI.h"

@implementation NXFileActivityLogAPIRequest
-(NSURLRequest*)generateRequestObject:(id)object {
    if (self.reqRequest==nil) {
        NSURL *apiURL=nil;
        if ([object isKindOfClass:[NXFileActivityLogParModel class]]) {
            NXFileActivityLogParModel *parModel =(NXFileActivityLogParModel*)object;
            apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/log/v2/activity/%@?orderBy=%@&orderByReverse=%@",[NXCommonUtils currentRMSAddress],parModel.fileDUID,parModel.orderBy,parModel.orderByReverse]];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
            [request setHTTPMethod:@"GET"];
            self.reqRequest=request;
        }
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        NXFileActivityLogAPIResponse *apiResponse =[[NXFileActivityLogAPIResponse alloc]init];
        NSData *backData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (backData) {
            [apiResponse analysisResponseStatus:backData];
            NSDictionary *backDic=[NSJSONSerialization JSONObjectWithData:backData options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *resultsDic =backDic[@"results"];
            NSDictionary *dataDic =resultsDic[@"data"];
            NSString *fileName = dataDic[@"name"];
            NSString *duid = dataDic[@"duid"];
            NSArray *logArray=dataDic[@"logRecords"];
            NSMutableArray *logRecordArray=[NSMutableArray array];
            for (NSDictionary * recordDic in logArray) {
                NXFileActivityLogRecordsModel *item=[[NXFileActivityLogRecordsModel alloc]initWithNXFileActivityLogRecordsModelDic:recordDic];
                item.name = fileName;
                item.duid = duid;
                [logRecordArray addObject:item];
            }
            apiResponse.logRecords=logRecordArray;
        }
        return apiResponse;
    };
    return analysis;
}
@end

@implementation NXFileActivityLogAPIResponse
-(NSMutableArray*)logRecords {
    if (!_logRecords) {
        _logRecords=[NSMutableArray array];
    }
    return _logRecords;
}
@end
#pragma mark parameter model
@implementation NXFileActivityLogParModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        // default
        self.start=0;
        self.count=0;
        self.seachField=@"";
        self.serachText=@"";
        self.orderBy=@"accessTime";
        self.orderByReverse=@"true";
    }
    return self;
}
@end
#pragma mark parameter result model
@implementation NXFileActivityLogRecordsModel
-(instancetype)initWithNXFileActivityLogRecordsModelDic:(NSDictionary *)dic {
    self=[super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dic];
    }
    if (self.activityData) {
        if ([self.activityData isKindOfClass:[NSString class]]) {
            NSString *activityData = self.activityData;
            NSArray *array = [activityData componentsSeparatedByString:@":"];
            NSString *activityDetail = array.lastObject;
            self.activityData = [activityDetail stringByReplacingOccurrencesOfString:@"}" withString:@""];
        }
    }
    return self;
}
- (void)setValue:(id)value forKey:(NSString *)key {
   if ([key isEqualToString:@"accessTime"]) {
        NSNumber *time = (NSNumber *)value;
        NSInteger minSecondsToSecond = 1000;
        long long publishLong = [time longLongValue]/minSecondsToSecond;
        NSDateFormatter *formatter =[[NSDateFormatter alloc]init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        //        [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [formatter setDateFormat:@"dd MMM yyyy, HH:mm"];
        NSDate *publishDate = [NSDate dateWithTimeIntervalSince1970:publishLong];
        self.accessTimeStr =[formatter stringFromDate:publishDate];
        
        NSString *agoTime = [NXCommonUtils timeAgoShortFromDate:publishDate];
        NSTimeInterval timeBetween = [publishDate timeIntervalSinceNow];
        NSTimeInterval oneDayAgo = -60*60*24;
        if (timeBetween>oneDayAgo) {
            self.accessTimeShortStr = agoTime;
        }else {
            NSDateFormatter *formatter =[[NSDateFormatter alloc]init];
            [formatter setDateStyle:NSDateFormatterMediumStyle];
            [formatter setDateStyle:NSDateFormatterShortStyle];
            //            [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
            [formatter setDateFormat:@"dd MMM yyyy"];
            self.accessTimeShortStr =[formatter stringFromDate:publishDate];
        }
        self.accessTime = value;
    } else {
        [super setValue:value forKey:key];
    }
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}
@end


