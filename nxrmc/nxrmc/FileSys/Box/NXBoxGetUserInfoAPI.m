//
//  NXBoxGetUserInfoAPI.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 1/12/18.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import "NXBoxGetUserInfoAPI.h"

@implementation NXBoxGetUserInfoRequest
-(NSMutableURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NSURL *apiURL = [[NSURL alloc] initWithString:@"https://api.box.com/2.0/users/me"];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        [request setHTTPMethod:@"GET"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        self.reqRequest = request;
    }
    
    return (NSMutableURLRequest *)self.reqRequest;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError *error){
        
        NXBoxGetUserInfoResponse *response = [[NXBoxGetUserInfoResponse alloc] init];
        if(error == nil && returnData) {
            NSError *convertError = nil;
            NSDictionary *userInfoDict = [returnData toJSONFormatDictionary:&convertError];
            if (convertError == nil) {
                response = [[NXBoxGetUserInfoResponse alloc] initWithDictionary:userInfoDict];
            }
        }else if(error && error.code == 401) {
            response.isAccessTokenExpireError = YES;
        }
        return response;
    };
    
    return analysis;
}
@end

@implementation NXBoxGetUserInfoResponse
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
