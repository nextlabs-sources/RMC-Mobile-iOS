//
//  NXUserPreferenceStorage.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 11/8/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXUserPreferenceStorage.h"
#import "NXLoginUserPreference+CoreDataClass.h"
#import "MagicalRecord.h"
#import "NSString+NXExt.h"
#import "NXLFileValidateDateModel.h"
@implementation NXUserPreferenceStorage
+ (NXUserPreference *)getUserPreference {
    NXLoginUserPreference *preference = [NXLoginUserPreference MR_findFirst];
    if (preference) {
        NXUserPreference *userPreference = [[NXUserPreference alloc] init];
        NSArray *watermarkArray = [preference.watermark parseWatermarkWords];
        userPreference.preferenceWatermark = watermarkArray;
        
        NXLFileValidateDateModel *fileValidateDate = nil;
        switch (preference.validateType.integerValue) {
            case 0: // never expire
            {
                fileValidateDate = [[NXLFileValidateDateModel alloc] initWithNXFileValidateDateModelType:NXLFileValidateDateModelTypeNeverExpire withStartTime:nil endTIme:nil];
            }
                break;
            case 1: // relative expire
            {
                fileValidateDate = [[NXLFileValidateDateModel alloc] initRelativeValidateDateModelWithYear:preference.relativeYear.integerValue month:preference.relativeMonth.integerValue week:preference.relativeWeek.integerValue day:preference.relativeDay.integerValue];
            }
                break;
            case 2: // absolute expire
            {
                fileValidateDate = [[NXLFileValidateDateModel alloc] initWithNXFileValidateDateModelType:NXLFileValidateDateModelTypeAbsolute withStartTime:preference.validateStartDate endTIme:preference.validateEndDate];
            }
                break;
            case 3: // range expire
            {
                fileValidateDate = [[NXLFileValidateDateModel alloc] initWithNXFileValidateDateModelType:NXLFileValidateDateModelTypeRange withStartTime:preference.validateStartDate endTIme:preference.validateEndDate];
            }
                break;
            default:
                break;
        }
        userPreference.preferenceFileValidateDate = fileValidateDate;
        return userPreference;
    }else {
        return nil;
    }
    
}

+ (void)updateUserPreference:(NXUserPreference *)userPreference {
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NXLoginUserPreference *loginUserPreference = [NXLoginUserPreference MR_findFirstInContext:localContext];
        if(!loginUserPreference) {
            loginUserPreference = [NXLoginUserPreference MR_createEntityInContext:localContext];
        }
        
        if (userPreference.preferenceWatermark) {
            loginUserPreference.watermark = [userPreference.preferenceWatermark translateIntoPolicyString];
        }
        
        if (userPreference.preferenceFileValidateDate) {
            loginUserPreference.validateType = [NSNumber numberWithInteger:userPreference.preferenceFileValidateDate.type];
            loginUserPreference.validateStartDate = userPreference.preferenceFileValidateDate.startTime;
            loginUserPreference.validateEndDate = userPreference.preferenceFileValidateDate.endTime;
            loginUserPreference.relativeYear = [NSNumber numberWithUnsignedInteger:userPreference.preferenceFileValidateDate.year];
            loginUserPreference.relativeMonth = [NSNumber numberWithUnsignedInteger:userPreference.preferenceFileValidateDate.month];
            loginUserPreference.relativeWeek = [NSNumber numberWithUnsignedInteger:userPreference.preferenceFileValidateDate.week];
            loginUserPreference.relativeDay = [NSNumber numberWithUnsignedInteger:userPreference.preferenceFileValidateDate.day];
        }
    }];
}

+ (void)updateUserWatermark:(NSArray<NXWatermarkWord *> *)userWatermark {
    NXUserPreference *userPreference = [[NXUserPreference alloc] init];
    userPreference.preferenceWatermark = userWatermark;
    [self.class updateUserPreference:userPreference];
}

+ (void)updateUserValidateFileDate:(NXLFileValidateDateModel *)validateModel {
    NXUserPreference *userPreference = [[NXUserPreference alloc] init];
    userPreference.preferenceFileValidateDate = validateModel;
    [self.class updateUserPreference:userPreference];
}
@end
