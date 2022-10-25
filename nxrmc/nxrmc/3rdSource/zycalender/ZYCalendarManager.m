//
//  ZYCalendarManager.m
//  Example
//
//  Created by Daniel on 2016/10/30.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "ZYCalendarManager.h"
#import "ZYWeekView.h"

#define ZYHEXCOLOR(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:1.0]

@interface ZYCalendarManager ()
@property (nonatomic, copy)NSMutableArray *reusePool;
@property (nonatomic, copy)NSMutableDictionary *reusePoolDictionary;
@end

@implementation ZYCalendarManager

- (instancetype)init {
    if (self = [super init]) {
        _selectedBackgroundColor = [UIColor colorWithRed:111.0/255.0 green:207.0/255.0 blue:151.0/255.0 alpha:1.0];
        //_selectedBackgroundColor = [UIColor blackColor];
        _selectedTextColor = [UIColor whiteColor];
        _defaultTextColor = [UIColor colorWithRed:140.0/255.0 green:149.0/255.0 blue:173.0/255.0 alpha:1.0];
        _disableTextColor = [UIColor colorWithRed:225.0/255.0 green:228.0/255.0 blue:231.0/255.0 alpha:1.0];
        _imageRenderingMode = UIImageRenderingModeAlwaysTemplate;
    }
    return self;
}

- (void)registerWeekViewWithReuseIdentifier:(NSString *)identifier {
    !identifier ?: [self.reusePoolDictionary setObject:@[].mutableCopy forKey:identifier];
}

- (void)addToReusePoolWithView:(UIView *)view identifier:(NSString *)identifier {
    NSMutableArray *reusePool = self.reusePoolDictionary[identifier];
    if (!reusePool) {
        NSLog(@"没有注册此标记: %@", identifier);
        return;
    }
    [reusePool addObject:view];
}

- (ZYWeekView *)dequeueReusableWeekViewWithIdentifier:(NSString *)identifier {
    NSMutableArray *reusePool = self.reusePoolDictionary[identifier];
    if (!reusePool) {
        NSLog(@"没有注册此标记: %@", identifier);
        return nil;
    }
    ZYWeekView *view = reusePool.firstObject;
    if (view) {
        [reusePool removeObject:view];
        return view;
    }
    return nil;
}

- (NSMutableDictionary *)reusePoolDictionary {
    if (!_reusePoolDictionary) {
        _reusePoolDictionary = @{}.mutableCopy;
    }
    return _reusePoolDictionary;
}

- (NSMutableArray *)reusePool {
    if (!_reusePool) {
        _reusePool = @[].mutableCopy;
    }
    return _reusePool;
}

-(JTDateHelper *)helper {
    if (!_helper) {
        _helper = [JTDateHelper new];
    }
    return _helper;
}

- (NSMutableArray *)selectedDateArray {
    if (!_selectedDateArray) {
        _selectedDateArray = @[].mutableCopy;
    }
    return _selectedDateArray;
}

- (NSDateFormatter *)titleDateFormatter {
    if (!_titleDateFormatter) {
        _titleDateFormatter = [self.helper createDateFormatter];
        _titleDateFormatter.dateFormat = @"MMMM yyyy";
    }
    return _titleDateFormatter;
}

- (NSDateFormatter *)dayDateFormatter {
    if (!_dayDateFormatter) {
        _dayDateFormatter = [self.helper createDateFormatter];
        _dayDateFormatter.dateFormat = @"dd";
    }
    return _dayDateFormatter;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [self.helper createDateFormatter];
        _dateFormatter.dateFormat = @"yyyy-MM-dd";
    }
    return _dateFormatter;
}

// 单选或者范围选择,通过'selectedStartDay' 和 'selectedEndDay' 的setter方法把date保存到 'selectedDateArray'
// 单选: 'selectedDateArray' 中只保存一个 date
// 范围选择: 'selectedDateArray' 保存两个 date, 一个开始一个结束
// 多选: 由于多选的结果和 'selectedStartDay'及'selectedEndDay' 没有关系, 所以不再这里操作 'selectedDateArray'

@end
