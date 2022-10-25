//
//  NXWatermarkWord.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 11/2/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray(NXWatermarkWordExt)
- (NSString *)translateIntoPolicyString;
- (NSString *)translateIntoLocalizedString;
- (NSMutableAttributedString *)translateInfoTextUIString;
@end

@interface NSString(NXWatermarkWordExt)
- (NSArray *)parseWatermarkWords;
@end

@interface NXWatermarkWord : NSObject<NSCopying, NSCoding>
- (instancetype)initWithWatermarkPolicyString:(NSString *)policyString watermarkLocalizedString:(NSString *)localizedString;

- (NSString *)watermarkPolicyString;
- (NSString *)watermarkLocalizedString;
- (NSString *)watermarkTextViewUIString;
@end
