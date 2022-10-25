//
//  NXGetAccessTokenAPI.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 06/12/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "NXSuperRESTAPI.h"
@interface NXGetAccessTokenAPIRequest : NXSuperRESTAPIRequest
@end

@interface NXGetAccessTokenAPIResponse : NXSuperRESTAPIResponse
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *authURL;
@end
