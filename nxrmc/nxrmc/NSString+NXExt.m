//
//  NSString+NXExt.m
//  nxrmc
//
//  Created by EShi on 12/14/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NSString+NXExt.h"
#import "NXDateWatermarkWord.h"
#import "NXEmailIDWatermarkWord.h"
#import "NXTimeWatermarkWord.h"
#import "NXBreakLineWatermarkWord.h"
#import "NXNormalWatermarkWord.h"
#import "NXHostWatermarkWord.h"
#import "NXIpWatermarkWord.h"

@implementation NSString (NXExt)
- (NSDictionary *)toJSONFormatDictionary:(NSError **)error
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:error];
    return jsonDict;
}

- (NSArray *)parseWatermarkWords {
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    NSArray *watermarkKeyword = @[@"$(Date)", @"$(User)", @"$(Time)", @"$(Break)",@"$(Host)",@"$(Ip)",@"$(date)", @"$(user)", @"$(time)",@"$(break)", @"$(host)",@"$(ip)",@"$(DATE)", @"$(USER)", @"$(TIME)",@"$(BREAK)",@"$(HOST)",@"$(IP)"];
    NSMutableString *tempString = [[NSMutableString alloc] init];
    
    for (NSUInteger index = 0; index < self.length; ++index) {
        [tempString appendString:[self substringWithRange:NSMakeRange(index, 1)]];
        // check if have special keyword
        for (NSString *keyword in watermarkKeyword) {
            if ([tempString containsString:keyword]) {
                NSArray *trancatedArray = [tempString componentsSeparatedByString:keyword];
                NSAssert(trancatedArray.count <= 2 && trancatedArray.count > 0, @"Can not be");
                NXWatermarkWord *watermarkWord = nil;
                if ([keyword isEqualToString:@"$(Date)"] || [keyword isEqualToString:@"$(date)"] || [keyword isEqualToString:@"$(DATE)"]) {
                    watermarkWord = [[NXDateWatermarkWord alloc] init];
                }else if ([keyword isEqualToString:@"$(User)"] || [keyword isEqualToString:@"$(user)"] || [keyword isEqualToString:@"$(USER)"]) {
                    watermarkWord = [[NXEmailIDWatermarkWord alloc] init];
                }else if ([keyword isEqualToString:@"$(Time)"] || [keyword isEqualToString:@"$(time)"] || [keyword isEqualToString:@"$(TIME)"]) {
                    watermarkWord = [[NXTimeWatermarkWord alloc] init];
                }else if ([keyword isEqualToString:@"$(Break)"] || [keyword isEqualToString:@"$(break)"] || [keyword isEqualToString:@"$(BREAK)"]) {
                    watermarkWord = [[NXBreakLineWatermarkWord alloc] init];
                }else if([keyword isEqualToString:@"$(Host)"] || [keyword isEqualToString:@"$(host)"] || [keyword isEqualToString:@"$(HOST)"]){
                    watermarkWord = [[NXHostWatermarkWord alloc] init];
                }else if([keyword isEqualToString:@"$(Ip)"] || [keyword isEqualToString:@"$(ip)"] || [keyword isEqualToString:@"$(IP)"]){
                    watermarkWord = [[NXIpWatermarkWord alloc] init];
                }
                
                if (trancatedArray.count > 1) { // only one keyword
                    NSString *normalWord = trancatedArray[0];
                    if (normalWord.length != 0) {
                        NXNormalWatermarkWord *normalWatermarkWord = [[NXNormalWatermarkWord alloc] initWithWatermarkPolicyString:normalWord watermarkLocalizedString:normalWord];
                        [retArray addObject:normalWatermarkWord];
                    }
                }
                if (watermarkWord != nil) {
                    [retArray addObject:watermarkWord];
                }
                
                
                // reset tempString
                tempString = [[NSMutableString alloc] init];
            }
        }
    }
    
    if (tempString.length > 0) {
        NXNormalWatermarkWord *normalWatermarkWord = [[NXNormalWatermarkWord alloc] initWithWatermarkPolicyString:tempString watermarkLocalizedString:tempString];
        [retArray addObject:normalWatermarkWord];
    }
    
    return retArray;
}
@end
