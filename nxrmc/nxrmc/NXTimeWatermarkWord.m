//
//  NXTimeWord.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 11/2/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXTimeWatermarkWord.h"

@implementation NXTimeWatermarkWord
- (instancetype)initWithWatermarkPolicyString:(NSString *)policyString watermarkLocalizedString:(NSString *)localizedString {
    if (self = [super init]) {
        
    }
    return self;
}

- (NSString *)watermarkPolicyString {
    return @"$(Time)";
}

- (NSString *)watermarkLocalizedString {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    return [dateFormatter stringFromDate:date];
}

- (NSString *)watermarkTextViewUIString {
    return @"Time";
}
@end
