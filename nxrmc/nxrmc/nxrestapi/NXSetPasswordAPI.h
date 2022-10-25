//
//  NXSetPasswordAPI.h
//  nxrmc
//
//  Created by nextlabs on 12/16/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

@interface NXSetPasswordAPI : NXSuperRESTAPIRequest

- (instancetype)initWithNonce:(NSString *)nonce captcha:(NSString *)captcha;

@end
