//
//  NXBreakLineWord.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 11/2/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXBreakLineWatermarkWord.h"

@implementation NXBreakLineWatermarkWord
- (instancetype)initWithWatermarkPolicyString:(NSString *)policyString watermarkLocalizedString:(NSString *)localizedString {
    if (self = [super init]) {
       
    }
    return self;
}

- (NSString *)watermarkPolicyString {
    return @"$(Break)";
}

- (NSString *)watermarkLocalizedString {
    return @"\n";
}

- (NSString *)watermarkTextViewUIString {
   
    return @"Line break";
}
@end
