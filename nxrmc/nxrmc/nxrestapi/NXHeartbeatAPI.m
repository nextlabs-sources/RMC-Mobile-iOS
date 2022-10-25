//
//  NXHeartbeatAPI.m
//  nxrmc
//
//  Created by nextlabs on 7/15/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXHeartbeatAPI.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXLProfile.h"
//////////// for NXWaterMarkContent
#define TEXT_KEY                @"kText"
#define TRANSPARENT_RATION_KEY  @"kTransparentRatio"
#define FONT_NAME_KEY           @"kFontName"
#define FONT_SIZE_KEY           @"kFontSize"
#define FONT_COLOR_KEY          @"kFontColor"
#define ROTATION_KEY            @"kRotation"
#define REPEAT_KEY              @"kRepeat"
#define SERIAL_NUM_KEY          @"kSerialNumber"

////////// for NXHeartbeatAPIResponse
#define WATER_MARK_CONTENT_KEY @"kWaterMarkContentKey"
#define POLICY_BUNDLE_KEY        @"kPolicyBundleKey"



@implementation NXHeartbeatAPI

- (NSMutableURLRequest *)generateRequestObject:(id)object {
    
    if(!self.reqRequest && [object isKindOfClass:[NXLProfile class]])
    {
        NXLProfile *profile = (NXLProfile *)object;
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/v2/heartbeat", profile.rmserver]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
        
        NSDictionary *parmeters = @{@"platformId" : [NXCommonUtils getPlatformId]};
        NSDictionary *bodyDic = @{@"parameters" : parmeters};
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyDic options:NSJSONWritingPrettyPrinted error:&error];
        [request setHTTPBody:jsonData];
        self.reqRequest = request;
    }
    return  self.reqRequest;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error) {
        //restCode
        NXHeartbeatAPIResponse *model = [[NXHeartbeatAPIResponse alloc]init];
        [model parseHeartbeatResponseData:[returnData dataUsingEncoding:NSUTF8StringEncoding]];
        return  model;
    };
    return analysis;
}

@end


#pragma mark ---------------------------------- NXHeartbeatAPIResponse ----------------------------------
@implementation NXWaterMarkContent
#pragma mark - NSCoding
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _text = [aDecoder decodeObjectForKey:TEXT_KEY];
        _transparentRatio = [aDecoder decodeObjectForKey:TRANSPARENT_RATION_KEY];
        _fontName = [aDecoder decodeObjectForKey:FONT_NAME_KEY];
        _fontSize = [aDecoder decodeObjectForKey:FONT_SIZE_KEY];
        _fontColor = [aDecoder decodeObjectForKey:FONT_COLOR_KEY];
        NSNumber *clockwiseNum = [aDecoder decodeObjectForKey:ROTATION_KEY];
        _isClockwise = clockwiseNum.boolValue;
        NSNumber *repeatNum = [aDecoder decodeObjectForKey:REPEAT_KEY];
        _repeat = repeatNum.boolValue;
        _serialNumber = [aDecoder decodeObjectForKey:SERIAL_NUM_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_text forKey:TEXT_KEY];
    [aCoder encodeObject:_transparentRatio forKey:TRANSPARENT_RATION_KEY];
    [aCoder encodeObject:_fontName forKey:FONT_NAME_KEY];
    [aCoder encodeObject:_fontSize forKey:FONT_SIZE_KEY];
    [aCoder encodeObject:_fontColor forKey:FONT_COLOR_KEY];
    NSNumber *clockwiseNum = [NSNumber numberWithBool:_isClockwise];
    [aCoder encodeObject:clockwiseNum forKey:ROTATION_KEY];
    NSNumber *repeatNum = [NSNumber numberWithBool:_repeat];
    [aCoder encodeObject:repeatNum forKey:REPEAT_KEY];
    [aCoder encodeObject:_serialNumber forKey:SERIAL_NUM_KEY];
}
@end

@implementation NXHeartbeatAPIResponse

- (void)analysisResponseStatus:(NSData *)responseData {
    [self parseHeartbeatResponseData:responseData];
}

- (void)parseHeartbeatResponseData:(NSData *)responseData {
    NSError *error;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
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
    
    if ([result objectForKey:@"results"]) {
        NSDictionary *results = [result objectForKey:@"results"];
        if ([results objectForKey:@"watermarkConfig"]) {
            NSDictionary *watermarkConfig = [results objectForKey:@"watermarkConfig"];
            if ([watermarkConfig objectForKey:@"content"]) {
                NSString *contentstr = [watermarkConfig objectForKey:@"content"];
                NSData *contentData = [contentstr dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *obligations = [NSJSONSerialization JSONObjectWithData:contentData options:NSJSONReadingMutableLeaves error:&error];
                
                self.waterMarkContent = [[NXWaterMarkContent alloc] init];
                
                if ([obligations objectForKey:@"text"]) {
                    self.waterMarkContent.text = [obligations objectForKey:@"text"];
                }
                if ([obligations objectForKey:@"transparentRatio"]) {
                    self.waterMarkContent.transparentRatio = [obligations objectForKey:@"transparentRatio"];
                }
                if ([obligations objectForKey:@"fontName"]) {
                    self.waterMarkContent.fontName = [obligations objectForKey:@"fontName"];
                }
                if ([obligations objectForKey:@"fontSize"]) {
                    self.waterMarkContent.fontSize = [obligations objectForKey:@"fontSize"];
                }
                if ([obligations objectForKey:@"fontColor"]) {
                    self.waterMarkContent.fontColor = [obligations objectForKey:@"fontColor"];
                }
                if ([obligations objectForKey:@"rotation"]) {
                    NSString *rotationStr = [obligations objectForKey:@"rotation"];
                    if ([rotationStr isEqualToString:@"Anticlockwise"]) {
                        self.waterMarkContent.isClockwise = NO;
                    }else
                    {
                        self.waterMarkContent.isClockwise = YES;
                    }
                    
                }
                if ([obligations objectForKey:@"repeat"]) {
                    BOOL isRepeat = ((NSNumber *)[obligations objectForKey:@"repeat"]).boolValue;
                    self.waterMarkContent.repeat = isRepeat;
                }
                if ([obligations objectForKey:@"density"]) {
                    self.waterMarkContent.density = [obligations objectForKey:@"density"];
                }
            }
        }
    }
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _policyBundle = [aDecoder decodeObjectForKey:POLICY_BUNDLE_KEY];
        _waterMarkContent = [aDecoder decodeObjectForKey:WATER_MARK_CONTENT_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_policyBundle forKey:POLICY_BUNDLE_KEY];
    [aCoder encodeObject:_waterMarkContent forKey:WATER_MARK_CONTENT_KEY];
}

@end
