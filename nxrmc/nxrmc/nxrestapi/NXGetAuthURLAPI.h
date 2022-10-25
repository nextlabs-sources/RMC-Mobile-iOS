//
//  NXGetAuthURLAPI.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 11/15/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXSuperRESTAPI.h"
@interface NXGetAuthURLRequest : NXSuperRESTAPIRequest
@property(nonatomic, strong) NSString *repoName;
@property(nonatomic, assign) ServiceType repoType;
@property(nonatomic, copy) NSString *sharepointOnlineSiteUrl;
@end

@interface NXGetAuthURLResponse : NXSuperRESTAPIResponse
@property(nonatomic, strong) NSString *authURL;
@end
