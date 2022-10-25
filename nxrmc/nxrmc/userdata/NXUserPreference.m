//
//  NXUserPreference.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 11/8/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXUserPreference.h"
#import "NSString+NXExt.h"
#import "NXLFileValidateDateModel.h"
@implementation NXUserPreference

- (id)copyWithZone:(NSZone *)zone {
    NXUserPreference *copyModel = [[NXUserPreference alloc] init];
    copyModel.preferenceFileValidateDate = [self.preferenceFileValidateDate copy];
    copyModel.preferenceWatermark = [self.preferenceWatermark copy];
    return copyModel;
}
@end
