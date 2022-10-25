//
//  NXGoogleDateTime.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 15/01/2018.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import "NXGoogleDateTime.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NXGoogleDateTime : NSObject <NSCopying>

/**
 *  Constructor from a string representation.
 */
+ (nullable instancetype)dateTimeWithRFC3339String:(nullable NSString *)str;

/**
 *  Constructor from a date and time representation.
 */
+ (instancetype)dateTimeWithDate:(NSDate *)date;

/**
 *  Constructor from a date and time representation, along with an offset
 *  minutes value used when creating a RFC3339 string representation.
 *
 *  The date value is independent of time zone; the offset affects how the
 *  date will be rendered as a string.
 *
 *  The offsetMinutes may be initialized from a NSTimeZone as
 *  (timeZone.secondsFromGMT / 60)
 */
+ (instancetype)dateTimeWithDate:(NSDate *)date
                   offsetMinutes:(NSInteger)offsetMinutes;

/**
 *  Constructor from a date for an all-day event.
 *
 *  Use this constructor to create a @c GTLRDateTime that is "date only".
 *
 *  @note @c hasTime will be set to NO.
 */
+ (instancetype)dateTimeForAllDayWithDate:(NSDate *)date;

/**
 *  Constructor from date components.
 */
+ (instancetype)dateTimeWithDateComponents:(NSDateComponents *)date;

/**
 *  The represented date and time.
 *
 *  If @c hasTime is NO, the time is set to noon GMT so the date is valid for all time zones.
 */
@property(nonatomic, readonly) NSDate *date;

/**
 *  The date and time as a RFC3339 string representation.
 */
@property(nonatomic, readonly) NSString *RFC3339String;

/**
 *  The date and time as a RFC3339 string representation.
 *
 *  This returns the same string as @c RFC3339String.
 */
@property(nonatomic, readonly) NSString *stringValue;

/**
 *  The represented date and time as date components.
 */
@property(nonatomic, readonly, copy) NSDateComponents *dateComponents;

/**
 *  The fraction of seconds represented, 0-999.
 */
@property(nonatomic, readonly) NSInteger milliseconds;

/**
 *  The time offset displayed in the string representation, if any.
 *
 *  If the offset is not nil, the date and time will be rendered as a string
 *  for the time zone indicated by the offset.
 *
 *  An app may create a NSTimeZone for this with
 *  [NSTimeZone timeZoneForSecondsFromGMT:(offsetMinutes.integerValue * 60)]
 */
@property(nonatomic, readonly, nullable) NSNumber *offsetMinutes;

/**
 *  Flag indicating if the object represents date only, or date with time.
 */
@property(nonatomic, readonly) BOOL hasTime;

/**
 *  The calendar used by this class, Gregorian and UTC.
 */
+ (NSCalendar *)calendar;


@end
NS_ASSUME_NONNULL_END

