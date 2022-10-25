//
//  NXUserPreference.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 11/8/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXWatermarkWord.h"
@class NXLFileValidateDateModel;
@interface NXUserPreference : NSObject<NSCopying>
@property(nonatomic, strong) NXLFileValidateDateModel *preferenceFileValidateDate;
@property(nonatomic, strong) NSArray<NXWatermarkWord *> *preferenceWatermark;
@end
