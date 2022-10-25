//
//  NXUpdateProfileAPI.m
//  nxrmc
//
//  Created by nextlabs on 12/7/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXUpdateProfileAPI.h"
#import "NXCommonUtils.h"

@implementation NXUpdateProfileAPIRequestModel

- (instancetype)initWithDisplayName:(NSString *)name isChangeImage:(BOOL)isChangeImage avatorData:(NSString *)base64Str userid:(NSString *)userid ticket:(NSString *)ticket {
    if (self = [super init]) {
        self.userId = userid;
        self.ticket = ticket;
        self.displayname = name;
        self.avatorimage = base64Str;
        self.isChangeImage = isChangeImage;
    }
    return self;
}

- (NSData *)generateBodyData {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"userId": self.userId,
                                                                                      @"ticket": self.ticket
                                                                                      }];
    if (self.displayname) {
        [parameters setObject:self.displayname forKey:@"displayName"];
    }
    
    NSString *imagestr = [NSString stringWithFormat:@"data:image/jpeg;base64,%@",self.avatorimage];
    
    NSDictionary *preferencesBody = @{@"profile_picture" : imagestr};
    if (self.isChangeImage) {
        [parameters setObject:preferencesBody forKey:@"preferences"];
    }
    
    NSDictionary *bodyDic = @{@"parameters" : parameters};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyDic options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"generate Membership json request data failed");
    }
    return jsonData;
}
@end


@interface NXUpdateProfileAPI()

@property(nonatomic, strong) NXUpdateProfileAPIRequestModel *requestModel;

@end

@implementation NXUpdateProfileAPI

- (instancetype)initWIthModel:(NXUpdateProfileAPIRequestModel *)model {
    if (self = [super init]) {
        self.requestModel = model;
    }
    return self;
}

- (NSMutableURLRequest *)generateRequestObject:(id)object {
    NSData *bodyData = [self.requestModel generateBodyData];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [NXCommonUtils currentRMSAddress], @"rs/usr/profile"]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"consume"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:bodyData];
    [request addValue:self.reqFlag forHTTPHeaderField:RESTAPIFLAGHEAD];
    
    return request;
}
- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error) {
        //restCode
        NXSuperRESTAPIResponse *model = [[NXSuperRESTAPIResponse alloc]init];
        [model analysisResponseStatus:[returnData dataUsingEncoding:NSUTF8StringEncoding]];
        return  model;
    };
    return analysis;
}

@end


