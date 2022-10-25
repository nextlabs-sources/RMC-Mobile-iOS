//
//  NXNormalWord.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 11/2/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXNormalWatermarkWord.h"
@interface NXNormalWatermarkWord()
@property(nonatomic, copy) NSString *policyString;
@property(nonatomic, copy) NSString *localizedString;
@end
@implementation NXNormalWatermarkWord
- (instancetype)initWithWatermarkPolicyString:(NSString *)policyString watermarkLocalizedString:(NSString *)localizedString {
    if (self = [super init]) {
        _policyString = policyString;
        _localizedString = localizedString;
    }
    return self;
}

- (NSString *)watermarkPolicyString {
    return _policyString;
}

- (NSString *)watermarkLocalizedString {
    // fix bug 47384, show '\n' in file overlay not breakline
    return [_localizedString stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
}

- (NSString *)watermarkTextViewUIString {
    return _localizedString;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_policyString forKey:@"policyString"];
    [aCoder encodeObject:_localizedString forKey:@"localizedString"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _policyString = [aDecoder decodeObjectForKey:@"policyString"];
        _localizedString = [aDecoder decodeObjectForKey:@"localizedString"];
    }
    return self;
}
@end
