//
//  NSString+Utility.m
//  xmlparser
//
//  Created by helpdesk on 3/7/15.
//  Copyright (c) 2015 test123. All rights reserved.
//

#import "NSString+Utility.h"

@implementation NSString (Utility)
- (NSString*)lowercaseFirstChar
{
    NSString *firstChar = [[self substringToIndex:1] lowercaseString];
    NSString *keypath = [NSString stringWithFormat:@"%@%@",firstChar,[self substringFromIndex:1]];
    return keypath;
}

+ (NSString *) toBOOLString:(BOOL) boolValue
{
    return (boolValue ? @"true":@"false");
}


- (NSString *)toHTTPURLString {
    NSString *charactersToEscape = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    return [self stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
}

- (NSString *)toUnicodeString {
    NSUInteger length = [self length];
    NSMutableString *str = [NSMutableString stringWithCapacity:0];
    for (int i = 0;i < length; i++){
        NSMutableString *s = [NSMutableString stringWithCapacity:0];
        unichar _char = [self characterAtIndex:i];
        // 判断是否为英文和数字
        if (_char <= '9' && _char >='0'){
            [s appendFormat:@"%@",[self substringWithRange:NSMakeRange(i,1)]];
        }else if(_char >='a' && _char <= 'z'){
            [s appendFormat:@"%@",[self substringWithRange:NSMakeRange(i,1)]];
        }else if(_char >='A' && _char <= 'Z')
        {
            [s appendFormat:@"%@",[self substringWithRange:NSMakeRange(i,1)]];
        }else{
            // 中文和字符
            [s appendFormat:@"\\u%x",[self characterAtIndex:i]];
            // 不足位数补0 否则解码不成功
            if(s.length == 4) {
                [s insertString:@"00" atIndex:2];
            } else if (s.length == 5) {
                [s insertString:@"0" atIndex:2];
            }
        }
        [str appendFormat:@"%@", s];
    }
    return str;
}
@end
