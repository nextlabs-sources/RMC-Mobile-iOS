//
//  NXUserPreferenceManager.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 11/8/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXUserPreference.h"

@interface NXUserPreferenceManager : NSObject
- (void)startSyncUserPreference;
- (void)stopSyncUserPreference;

- (NXUserPreference *)userPreference;
- (void)updateUserPreference:(NXUserPreference *)userPreference completion:(void(^)(NSError *error))completion;
- (void)updateUserWatermark:(NSArray<NXWatermarkWord *> *)watermark completion:(void(^)(NSError *error))completion;
- (void)updateFileValidateDate:(NXLFileValidateDateModel *)validateDate completion:(void(^)(NSError *error))completion;
@end
