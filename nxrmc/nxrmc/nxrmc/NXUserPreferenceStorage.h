//
//  NXUserPreferenceStorage.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 11/8/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXUserPreference.h"

@interface NXUserPreferenceStorage : NSObject
+ (NXUserPreference *)getUserPreference;
+ (void)updateUserPreference:(NXUserPreference *)userPreference;
+ (void)updateUserWatermark:(NSArray<NXWatermarkWord *> *)userWatermark;
+ (void)updateUserValidateFileDate:(NXLFileValidateDateModel *)validateModel;
@end
