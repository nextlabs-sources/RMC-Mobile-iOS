//
//  NXHeartbeatAPI.h
//  nxrmc
//
//  Created by nextlabs on 7/15/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

@interface NXHeartbeatAPI : NXSuperRESTAPIRequest

@end


@interface NXWaterMarkContent : NSObject<NSCoding>
@property(nonatomic,  strong) NSString *serialNumber;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSNumber *transparentRatio;
@property (nonatomic, strong) NSString *fontName;
@property (nonatomic, strong) NSNumber *fontSize;
@property (nonatomic, strong) NSString *fontColor;
@property (nonatomic, assign) BOOL isClockwise;
@property (nonatomic, strong) NSString *density;
@property (nonatomic, assign) BOOL repeat;
@end



@interface NXHeartbeatAPIResponse : NXSuperRESTAPIResponse<NSCoding>
- (void)parseHeartbeatResponseData:(NSData *)responseData;
@property(nonatomic, strong) NXWaterMarkContent *waterMarkContent;
@property(nonatomic, readonly, strong) NSString *policyBundle;
@end
