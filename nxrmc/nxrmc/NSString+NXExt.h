//
//  NSString+NXExt.h
//  nxrmc
//
//  Created by EShi on 12/14/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NXExt)
- (NSDictionary *)toJSONFormatDictionary:(NSError **)error;
- (NSArray *)parseWatermarkWords;
@end
