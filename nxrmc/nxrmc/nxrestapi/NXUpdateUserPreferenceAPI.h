//
//  NXUpdateUserPreferenceAPI.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 11/7/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXSuperRESTAPI.h"

#define kUserPreferenceExpireKey @"kUserPreferenceExpireKey"
#define kUserPreferenceWatermark @"kUserPreferenceWatermark"

@interface NXUpdateUserPreferenceRequest : NXSuperRESTAPIRequest

@end

@interface NXUpdateUserPreferenceResponse : NXSuperRESTAPIResponse

@end
