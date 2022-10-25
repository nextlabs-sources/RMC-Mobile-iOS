//
//  NSURL+HTTP.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 1/10/18.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (HTTPExt)
- (NSString *)getValueStringFromUrl:(NSString *)url;
+ (NSURL*)generateURL:(NSString*)baseURL params:(NSDictionary*)params;
- (NSDictionary *)parseURLParams;
@end
