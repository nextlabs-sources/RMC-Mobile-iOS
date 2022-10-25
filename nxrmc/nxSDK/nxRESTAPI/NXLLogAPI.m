//
//  NXLogAPI.m
//  nxrmc
//
//  Created by nextlabs on 7/14/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXLLogAPI.h"
#import "NSData+zip.h"
#include "NXLSDKDef.h"
#import "NXLCommonUtils.h"

@implementation NXLLogAPIRequestModel
-(instancetype) init
{
    self = [super init];
    if (self) {
        _duid = @"";
        _owner = @"";
        _repositoryId = @"";
        _filePathId = @"";
        _fileName = @"";
        _filePath = @"";
        _activityData = @"";
    }
    
    return self;
    
}
@end

@implementation NXLLogAPI

- (NSMutableURLRequest *)generateRequestObject:(id)object {
    
    if (object && [object isKindOfClass:[NXLLogAPIRequestModel class]]) {
        NXLLogAPIRequestModel *requestModel = (NXLLogAPIRequestModel *)object;
        NSString *separator = @",";
        NSArray *array = @[requestModel.duid,
                           requestModel.owner,
                           requestModel.userID,
                           requestModel.operation,
                           [NXLCommonUtils deviceID],
                           [NXLCommonUtils getPlatformId],   //deviceType
                           requestModel.repositoryId,
                           requestModel.filePathId,
                           requestModel.fileName,
                           requestModel.filePath,
                           APPLICATION_NAME,
                           APPLICATION_PATH,
                           APPLICATION_PUBLISHER,
                           requestModel.accessResult,  //accessresult.
                           requestModel.accessTime,
                           requestModel.activityData];
        
        NSString *str = [array componentsJoinedByString:separator];
        str = [str stringByAppendingString:@"\n"];
        NSData *bodyData = [str dataUsingEncoding:NSUTF8StringEncoding];//TBD
        NSData *gzCompressedData = [bodyData gzip];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@/%@", [NXLTenant currentTenant].rmsServerAddress, @"rs/log/activity", requestModel.userID, requestModel.ticket]]];
        [request setHTTPMethod:@"PUT"];
        [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Consume"];
        [request setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
        [request setValue:@"text/csv" forHTTPHeaderField:@"Consume"];

        [request setHTTPBody:gzCompressedData];
        
        [request addValue:self.reqFlag forHTTPHeaderField:RESTAPIFLAGHEAD];
        
        self.reqRequest = request;
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error) {
        //restCode
        NXLLogAPIResponse *model = [[NXLLogAPIResponse alloc]init];
        [model analysisResponseStatus:[returnData dataUsingEncoding:NSUTF8StringEncoding]];
        return  model;
    };
    return analysis;
}

@end


@implementation NXLLogAPIResponse

- (void)analysisResponseStatus:(NSData *)responseData {
    [self parseLogResponseJsonData: responseData];
}

- (void)parseLogResponseJsonData:(NSData *)data {
    NSError *error;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        NSLog(@"parse data failed:%@", error.localizedDescription);
        return;
    }
    if ([result objectForKey:@"statusCode"]) {
        self.rmsStatuCode = [[result objectForKey:@"statusCode"] integerValue];
    }
    
    if ([result objectForKey:@"message"]) {
        self.rmsStatuMessage = [result objectForKey:@"message"];
    }
}

@end