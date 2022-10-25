//
//  NXGetCaptchaAPI.h
//  nxrmc
//
//  Created by nextlabs on 12/20/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

@interface NXGetCaptchaAPI : NXSuperRESTAPIRequest

@end

@interface NXGetCaptchaResponse : NXSuperRESTAPIResponse

@property(nonatomic, strong) NSString *captcha;
@property(nonatomic, strong) NSString *nonce;

@end
