//
//  NSDictionary+NXExt.m
//  nxrmc
//
//  Created by EShi on 12/14/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NSDictionary+NXExt.h"

@implementation NSDictionary (NXExt)
- (NSData *)toJSONFormatData:(NSError **)error
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:error];
    return data;
}

- (NSString *)toJSONFormatString:(NSError **)error
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:0 error:error];
    if (!jsonData) {
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}
@end
