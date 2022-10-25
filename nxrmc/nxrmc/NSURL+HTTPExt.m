//
//  NSURL+HTTP.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 1/10/18.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import "NSURL+HTTPExt.h"

@implementation NSURL (HTTP)
- (NSDictionary *)parseURLParams{
    NSString *query = [self absoluteString];
    NSString *queryParams = [[query componentsSeparatedByString:@"?"] lastObject];
    NSArray *pairs = [queryParams componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        if (kv.count == 2) {
            NSString *val =[[kv objectAtIndex:1] stringByRemovingPercentEncoding];
            [params setObject:val forKey:[kv objectAtIndex:0]];
        }
    }
    return params;
}

/*
 * 使用传入的baseURL地址和参数集合构造含参数的请求URL的工具方法。
 */
+ (NSURL*)generateURL:(NSString*)baseURL params:(NSDictionary*)params {
    if (params) {
        NSMutableArray* pairs = [NSMutableArray array];
        for (NSString* key in params.keyEnumerator) {
            NSString* value = [params objectForKey:key];
            NSString *charactersToEscape = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
            NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
            NSString* escaped_value = [value stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];

        }
        
        NSString* query = [pairs componentsJoinedByString:@"&"];
        NSString* url = [NSString stringWithFormat:@"%@?%@", baseURL, query];
        return [NSURL URLWithString:url];
    } else {
        return [NSURL URLWithString:baseURL];
    }
}

/*
 * 根据指定的参数名，从URL中找出并返回对应的参数值。
 */
- (NSString *)getValueStringFromParamKey:(NSString *)key {
    NSString *query = [self absoluteString];
    NSString *queryParams = [[query componentsSeparatedByString:@"?"] lastObject];
    NSArray *pairs = [queryParams componentsSeparatedByString:@"&"];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        if (kv.count == 2) {
            if ([kv.firstObject isEqualToString:key]) {
                return kv.lastObject;
            }
        }
    }
    return nil;
}
@end
