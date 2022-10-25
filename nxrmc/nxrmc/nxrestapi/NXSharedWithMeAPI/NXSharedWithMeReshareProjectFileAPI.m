//
//  NXSharedWithMeReshareProjectFileAPI.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2020/1/9.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXSharedWithMeReshareProjectFileAPI.h"

@implementation NXSharedWithMeReshareProjectFileRequestModel
@end

@implementation NXSharedWithMeReshareProjectFileResponseModel

- (instancetype)initWithNSDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _freshSharedList = [[NSArray alloc] init];
        _alreadySharedList = [[NSArray alloc] init];
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"newTransactionId"]) {
        self.freshTransactionId = value;
    }
    if ([key isEqualToString:@"newSharedList"]) {
        self.freshSharedList = value;
    }
}

- (id)copyWithZone:(NSZone *)zone {
    NXSharedWithMeReshareProjectFileResponseModel *model = [[NXSharedWithMeReshareProjectFileResponseModel alloc]init];
    model.freshTransactionId = [self.freshTransactionId copy];
    model.sharedLink = [self.sharedLink copy];
    model.freshSharedList = [self.freshSharedList copy];
    model.alreadySharedList = [self.alreadySharedList copy];
    return model;
}
@end

@implementation NXSharedWithMeReshareProjectFileAPIRequest
- (NSURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        if ([object isMemberOfClass:[NXSharedWithMeReshareProjectFileRequestModel class]]) {
            NXSharedWithMeReshareProjectFileRequestModel *requestModel = (NXSharedWithMeReshareProjectFileRequestModel *)object;

            NSDictionary *parameterDic = @{@"parameters":@{@"transactionId":requestModel.transactionId,@"transactionCode":requestModel.transactionCode,@"spaceId":requestModel.spaceId,@"recipients":requestModel.recipients,@"comment":requestModel.reshareComment?:@""}}.copy;
            
            NSData *parameterData = [NSJSONSerialization dataWithJSONObject:parameterDic options:NSJSONWritingPrettyPrinted error:nil];
            
            NSURL *apiUrl = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/sharedWithMe/reshare",[NXCommonUtils currentRMSAddress]]];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:apiUrl];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:parameterData];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            self.reqRequest = request;
            
        }
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError* error) {
        NXSharedWithMeReshareProjectFileAPIResponse *response = [[NXSharedWithMeReshareProjectFileAPIResponse alloc]init];
        NSData *resultData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (returnData) {
            [response analysisResponseStatus:resultData];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *resultsDic = dict[@"results"];
            NXSharedWithMeReshareProjectFileResponseModel *model = [[NXSharedWithMeReshareProjectFileResponseModel alloc]initWithNSDictionary:resultsDic];
            response.responseModel = model;
        }
        return response;
    };
    return analysis;
}

@end


@implementation NXSharedWithMeReshareProjectFileAPIResponse
@end

