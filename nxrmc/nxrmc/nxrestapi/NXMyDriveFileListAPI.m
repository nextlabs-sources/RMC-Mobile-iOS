//
//  NXMyDriveFileListAPI.m
//  nxrmc
//
//  Created by helpdesk on 30/11/16.
//  Copyright © 2016年 nextlabs. All rights reserved.
//

#import "NXMyDriveFileListAPI.h"
#import "NXCommonUtils.h"

@implementation NXMyDriveFileListAPI
- (NSURLRequest*) generateRequestObject:(id)object {
    if (self.reqRequest==nil) {
        NSDictionary *jsonDict = @{@"parameters" : object};
        NSError *error;
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
        NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/myDrive/list",[NXCommonUtils currentRMSAddress]]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        [request setHTTPBody:bodyData];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        self.reqRequest=request;
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error)
    {
        NXGetMyDriveFileListAPIResponse *apiResponse=[[NXGetMyDriveFileListAPIResponse alloc]init];
        
        NSData *resultData=[returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (resultData) {
            [apiResponse analysisResponseStatus:resultData];
            NSDictionary *returnDic=[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
            NSString *statusCode=[returnDic[@"statusCode"] stringValue];
            if (![statusCode isEqualToString:@"200"]) {
               NSString *message=returnDic[@"message"];
                if (message==nil) {
                    message=@"error";
                    statusCode=@"000";
                }
                apiResponse.errorR=[NSError errorWithDomain:message code:[statusCode integerValue] userInfo:nil];
    
            } else {
                apiResponse.errorR=nil;
            NSDictionary *resultsDic=returnDic[@"results"];
            NSArray *entries=resultsDic[@"entries"];
            NSMutableArray *files=[NSMutableArray array];
            for (NSMutableDictionary *modelDic in entries) {
                NXMyDriveFileItem *fileItem=[[NXMyDriveFileItem alloc]initWithDictionary:modelDic];
              
                [files addObject:fileItem];
            }
            apiResponse.myDriveFileLists=files;
        }
        }
        return apiResponse;
        
    };
    return analysis;
}
@end
@implementation NXGetMyDriveFileListAPIResponse

- (NSMutableArray*)myDriveFileLists {
    if (!_myDriveFileLists) {
        _myDriveFileLists =[NSMutableArray array];
    }
    return _myDriveFileLists;
}

@end
@implementation NXMyDriveFileItem
-(instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self=[super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}
@end
