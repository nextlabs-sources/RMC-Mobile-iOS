//
//  NXDateWord.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 11/2/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXDateWatermarkWord.h"

@implementation NXDateWatermarkWord
- (instancetype)initWithWatermarkPolicyString:(NSString *)policyString watermarkLocalizedString:(NSString *)localizedString {
    if (self = [super init]) {
        
    }
    return self;
}

- (NSString *)watermarkPolicyString {
    return @"$(Date)";
}
- (NSString *)watermarkLocalizedString {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return [dateFormatter stringFromDate:date];
}

- (NSString *)watermarkTextViewUIString {
    return @"Date";
}
@end
