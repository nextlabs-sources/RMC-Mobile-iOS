//
//  NXFileValidityDisplayView.m
//  Calender
//
//  Created by Stepanoval (Xinxin) Huang on 06/11/2017.
//  Copyright © 2017 NextLabs. All rights reserved.
//

#import "NXFileValidityDisplayView.h"
#import "UIBezierPath+draw_arrowhead.h"
#import "Masonry.h"
#import "NXLFileValidateDateModel.h"

@interface NXFileValidityDisplayDateView()
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) UIView *contentView;
@end

@implementation NXFileValidityDisplayDateView

- (instancetype)initWithDate:(NSDate *)date
{
    self = [super init];
    if (self) {
        [self configureWithDate:date];
    }
    return self;
}

- (void)update:(NSDate *)date
{
    [self.contentView removeFromSuperview];
    [self configureWithDate:date];
}

- (void)configureWithDate:(NSDate *)date
{
    NSString *dateStr = [self.createDateFormatter stringFromDate:date];
    NSArray *dateStrArray = [dateStr componentsSeparatedByString:@","];
    
    NSString *day = [dateStrArray firstObject];
    NSString *month = [dateStrArray objectAtIndex:1];
    NSString *week = [dateStrArray objectAtIndex:2];
    NSString *year = [dateStrArray lastObject];
    
    week = [week stringByAppendingString:[NSString stringWithFormat:@" %@",year]];
    
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor clearColor];
    self.contentView = contentView;
    [self addSubview:contentView];
    
    UILabel *dayLabel = [[UILabel alloc] init];
    dayLabel.font = [UIFont systemFontOfSize:19.0];
    dayLabel.textColor = [UIColor colorWithRed:236.0/255.0 green:135.0/255.0 blue:58.0/255.0 alpha:1.0];
    dayLabel.text = day;
    [contentView addSubview:dayLabel];
    
    UILabel *monthLabel = [[UILabel alloc] init];
    monthLabel.font = [UIFont systemFontOfSize:12.0];
    monthLabel.textColor = [UIColor colorWithRed:111.0/255.0 green:111.0/255.0 blue:111.0/255.0 alpha:1.0];
    monthLabel.text = month;
    [contentView addSubview:monthLabel];
    
    UILabel *weekLabel = [[UILabel alloc] init];
    weekLabel.font = [UIFont systemFontOfSize:10.0];
    weekLabel.textColor = [UIColor colorWithRed:189.0/255.0 green:189.0/255.0 blue:189.0/255.0 alpha:1.0];
    weekLabel.text = week;
    weekLabel.textAlignment = NSTextAlignmentLeft;
    [contentView addSubview:weekLabel];
    
    [dayLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(contentView);
        make.top.equalTo(contentView);
        make.width.equalTo(@(24));
        make.height.equalTo(@(25));
        
    }];
    
    [monthLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(dayLabel.mas_right).offset(4);
        make.top.equalTo(contentView);
        make.width.equalTo(@(65));
        make.height.equalTo(@(17));
    }];
    
    [weekLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(dayLabel.mas_right).offset(4);
        make.top.equalTo(monthLabel.mas_bottom);
        make.width.equalTo(@(65));
        make.height.equalTo(@(12));
    }];
    
#if 0
    dayLabel.backgroundColor = [UIColor redColor];
    monthLabel.backgroundColor = [UIColor purpleColor];
    weekLabel.backgroundColor = [UIColor cyanColor];
    self.backgroundColor = [UIColor yellowColor];
#endif
}

- (NSDateFormatter *)createDateFormatter
{
    if (!_formatter) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.timeZone = [NSTimeZone localTimeZone];
        dateFormatter.locale = [NSLocale currentLocale];
        dateFormatter.dateFormat = @"dd,MMMM,EEE,yyyy";
        self.formatter = dateFormatter;
    }
    return _formatter;
}

@end

@interface NXFileValidityDisplayView ()

@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) UIView *arrowView;
@property (nonatomic, strong) UIView *dateStartView;
@property (nonatomic, strong) UIView *dateEndView;
@property (nonatomic, strong) UIView *contentView;
@end

@implementation NXFileValidityDisplayView

- (instancetype)initWithFileValidityModel:(NXLFileValidateDateModel *)model
{
    self = [super init];
    if (self) {
        [self commonInitWithDateModel:model];
    }
    return self;
}

- (void)update:(NXLFileValidateDateModel*)dateModel
{
    [self.contentView removeFromSuperview];
    [self commonInitWithDateModel:dateModel];
}

- (void)commonInitWithDateModel:(NXLFileValidateDateModel *)model
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
    [self addSubview:view];
    self.contentView = view;
  //  view.backgroundColor = [UIColor redColor];
    
    UILabel *fromDateLabel = [[UILabel alloc] init];
    fromDateLabel.text = @"From date";
    fromDateLabel.font = [UIFont fontWithName:@"Arial-ItalicMT" size:10.0];
    fromDateLabel.textColor = [UIColor colorWithRed:144.0/255.0 green:144.0/255.0 blue:144.0/255.0 alpha:1.0];
    
    UILabel *toDateLabel = [[UILabel alloc] init];
    toDateLabel.text = @"To date";
    toDateLabel.font = [UIFont fontWithName:@"Arial-ItalicMT" size:10.0];
    toDateLabel.textColor = [UIColor colorWithRed:144.0/255.0 green:144.0/255.0 blue:144.0/255.0 alpha:1.0];
    
    UIImageView *lineView = [[UIImageView alloc] init];
    lineView.backgroundColor = [UIColor colorWithRed:189.0/255.0 green:189.0/255.0 blue:189.0/255.0 alpha:1.0];
    
    UIView *dateStartview = [[NXFileValidityDisplayDateView alloc] initWithDate:model.startTime];
    self.dateStartView = dateStartview;
    [view addSubview:dateStartview];
    
    UIView *dateEndview = [[NXFileValidityDisplayDateView alloc] initWithDate:model.endTime];
    self.dateEndView = dateEndview;
    [view addSubview:dateEndview];
    
    [view addSubview:fromDateLabel];
    [view addSubview:toDateLabel];
    [view addSubview:lineView];
    
    UIView *arrowView = [self getArrowView];
    arrowView.backgroundColor = [UIColor clearColor];
    [view addSubview:arrowView];
    
    [view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.top.equalTo(self);
        make.height.equalTo(@(80));
    }];
    
    [fromDateLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(view);
        make.top.equalTo(view);
        make.width.equalTo(@(48));
        make.height.equalTo(@(12));
    }];
    
    [toDateLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(fromDateLabel.mas_right).offset(88);
        make.top.equalTo(view);
        make.width.equalTo(@(48));
        make.height.equalTo(@(12));
    }];
    
    [lineView mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(view);
        make.top.equalTo(fromDateLabel.mas_bottom).offset(2);
        make.width.equalTo(@(225));
        make.height.equalTo(@(0.5));
    }];
    
    [dateStartview mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(view);
        make.top.equalTo(lineView.mas_bottom).offset(2);
        make.width.equalTo(@(93));
        make.height.equalTo(@(25));
    }];
    
    [arrowView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(dateStartview.mas_right).offset(7);
        make.top.equalTo(lineView.mas_bottom).offset(12);
        make.width.equalTo(@(26));
        make.height.equalTo(@(8));
    }];
    
    [dateEndview mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(arrowView.mas_right).offset(8);
        make.top.equalTo(lineView.mas_bottom).offset(2);
        make.width.equalTo(@(93));
        make.height.equalTo(@(25));
    }];
}

- (UIView *)getArrowView
{
    if (!_arrowView) {
        UIView *arrowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 26, 8)];
        
        UIBezierPath *path=[UIBezierPath draw_bezierPathWithArrowFromPoint:CGPointMake(1, 4)
                                                                   toPoint:CGPointMake(24,4)
                                                                 tailWidth:1.50f
                                                                 headWidth:4.0f
                                                                headLength:4.0f];
        
        CAShapeLayer *shape = [CAShapeLayer layer];
        shape.path = path.CGPath;
        shape.fillColor = [UIColor colorWithRed:189.0/255.0 green:189.0/255.0 blue:189.0/255.0 alpha:1.0].CGColor;
        [arrowView.layer addSublayer:shape];
        _arrowView = arrowView;
    }
    return _arrowView;
}

@end
