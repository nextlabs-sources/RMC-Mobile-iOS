//
//  NXEmailID.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 11/2/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXEmailIDWatermarkWord.h"
#import "NXLoginUser.h"
#import "NXLProfile.h"
@implementation NXEmailIDWatermarkWord
- (instancetype)initWithWatermarkPolicyString:(NSString *)policyString watermarkLocalizedString:(NSString *)localizedString {
    if (self = [super init]) {
        
    }
    return self;
}

- (NSString *)watermarkPolicyString {
    return @"$(User)";
}
- (NSString *)watermarkLocalizedString {
    return [NXLoginUser sharedInstance].profile.email;
}

- (NSString *)watermarkTextViewUIString {
    return @"UserID";
}

@end
