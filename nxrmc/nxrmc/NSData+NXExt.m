//
//  NSData+NXExt.m
//  nxrmc
//
//  Created by EShi on 12/14/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NSData+NXExt.h"

@implementation NSData (NXExt)
- (NSDictionary *)toJSONDict:(NSError **)error
{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:self options:NSJSONReadingMutableLeaves error:error];
    return dict;
}
@end
