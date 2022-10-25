//
//  NXGetUserPreferenceAPI.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 11/7/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXSuperRESTAPI.h"
#import "NXWatermarkWord.h"
@class NXLFileValidateDateModel;
@interface NXGetUserPreferenceRequest : NXSuperRESTAPIRequest

@end

@interface NXGetUserPreferenceResponse : NXSuperRESTAPIResponse
@property(nonatomic, strong) NXLFileValidateDateModel *validateDatePreference;
@property(nonatomic, strong) NSArray<NXWatermarkWord *> *watermarkPreference;
@end

