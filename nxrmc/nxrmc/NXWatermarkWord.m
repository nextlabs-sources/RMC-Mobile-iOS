//
//  NXWatermarkWord.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 11/2/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXWatermarkWord.h"
#import "YYText.h"
#import "NXNormalWatermarkWord.h"
#define  LINEBREAKSTR @"LineBreak"
#define  BORDERCOLOR [UIColor colorWithRed:203/255.0 green:234/255.0 blue:208/255.0 alpha:1]
#define  LINEBREAKCOLOR  [UIColor colorWithRed:244/255.0 green:140/255.0 blue:66/255.0 alpha:1]
@implementation NSArray(NXWatermarkWordExt)
- (NSString *)translateIntoPolicyString {
    NSMutableString *retString = [NSMutableString string];
    for (NXWatermarkWord *watermarkWord in self) {
        [retString appendString:[watermarkWord watermarkPolicyString]];
    }
    return retString;
}

- (NSString *)translateIntoLocalizedString {
    NSMutableString *retString = [NSMutableString string];
    for (NXWatermarkWord *watermarkWord in self) {
        [retString appendString:[watermarkWord watermarkLocalizedString]];
    }
    return retString;
}

- (NSMutableAttributedString *)translateInfoTextUIString {
    NSMutableAttributedString *reString = [[NSMutableAttributedString alloc]init];
    for (NXWatermarkWord *watermarkWord in self) {
            NSString *UIStr = [watermarkWord watermarkTextViewUIString];
            if (UIStr && ![UIStr isEqualToString:@""]) {
                if ([watermarkWord isKindOfClass:[NXNormalWatermarkWord class]]) {
                    [reString appendAttributedString:[[NSAttributedString alloc]initWithString:UIStr]];
                } else {
                    NSMutableAttributedString *borderStr = [self getBackBorderAndColorAuttributedStringWithBaseString:UIStr];
                    [reString appendAttributedString:borderStr];
                }
            }
    }
    reString.yy_lineSpacing = 10;
    return reString;
}
- (NSMutableAttributedString *)getBackBorderAndColorAuttributedStringWithBaseString:(NSString *)string {
    UIColor *tagFillColor = BORDERCOLOR;
    if ([string isEqualToString:LINEBREAKSTR]) {
        tagFillColor = LINEBREAKCOLOR;
    }
    NSMutableAttributedString *valueStr = [[NSMutableAttributedString alloc]initWithString:@" "];
    
    NSMutableAttributedString *baseStr = [[NSMutableAttributedString alloc]init];
    NSMutableAttributedString *borderStr = [[NSMutableAttributedString alloc]initWithString:string];
    borderStr.yy_font = [UIFont boldSystemFontOfSize:12];
    borderStr.yy_color = [UIColor blackColor];
    YYTextBorder *border = [[YYTextBorder alloc]init];
    border.fillColor = tagFillColor;
    border.cornerRadius = 8;
    border.lineJoin = kCGLineJoinBevel;
    border.insets = UIEdgeInsetsMake(-2, -2,-2, -2);
    [borderStr yy_setTextBackgroundBorder:border range:[borderStr.string rangeOfString:string]];
    
    [baseStr appendAttributedString:borderStr];
    [baseStr appendAttributedString:[[NSAttributedString alloc]initWithString:@" "]];
    
    [baseStr yy_setTextBinding:[YYTextBinding bindingWithDeleteConfirm:NO] range:baseStr.yy_rangeOfAll];
    baseStr.yy_lineSpacing = 10;
    baseStr.yy_lineBreakMode = NSLineBreakByWordWrapping;
    [valueStr appendAttributedString:baseStr];
    
    return valueStr;
}
@end

@implementation NXWatermarkWord
- (instancetype)initWithWatermarkPolicyString:(NSString *)policyString watermarkLocalizedString:(NSString *)localizedString {
    NSAssert(NO, @"Overwrite");
    return nil;
}

- (NSString *)watermarkPolicyString {
    NSAssert(NO, @"Overwrite");
    return nil;
}
- (NSString *)watermarkLocalizedString {
    NSAssert(NO, @"Overwrite");
    return nil;
}

- (NSString *)watermarkTextViewUIString {
    NSAssert(NO, @"Overwrite");
    return nil;
}

- (NSString *)description {
    return [self watermarkPolicyString];
}

// copy
- (id)copyWithZone:(NSZone *)zone {
    NXWatermarkWord *copyModel = [[NXWatermarkWord alloc] initWithWatermarkPolicyString:[self watermarkPolicyString] watermarkLocalizedString:[self watermarkLocalizedString]];
    return copyModel;
}

// equal
- (NSUInteger)hash {
    return [[self watermarkPolicyString] hash];
}

- (BOOL)isEqual:(NSObject *)object {
    if (![object isKindOfClass:[NXWatermarkWord class]]) {
        return NO;
    }
    NXWatermarkWord *otherObj = (NXWatermarkWord *)object;
    NSString *otherPolicyString = [otherObj watermarkPolicyString];
    if ([otherPolicyString isEqualToString:[self watermarkPolicyString]]) {
        return YES;
    }else {
        return NO;
    }
}

// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        
    }
    return self;
}
@end
