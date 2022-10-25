//
//  NXFileValidityDateChooseViewController.m
//  Calender
//
//  Created by Stepanoval (Xinxin) Huang on 06/11/2017.
//  Copyright © 2017 NextLabs. All rights reserved.
//

#import "NXFileValidityDateChooseViewController.h"
#import "NXDefine.h"
#import "ZYCalendarView.h"
#import "UIView+NXExtension.h"
#import "UIImage+NXExtension.h"
#import "NSString+NXExtension.h"
#import "Masonry.h"
#import "NXFileValidityNavigationViewController.h"
#import "NXFileValidityPickViewController.h"
#import "NXFileValidityDisplayView.h"

#define textViewHeight 33.0
#define textViewWidth  120.0
#define textViewMargin 15.0

#define dateLabelHeight 33.0
#define dateLabelWidth  120.0
#define dateLabelMargin  15.0

#define textViewMarginDateLabel 10.0
#define textViewTopMarginSuperView 30.0
#define NUMBERS @"0123456789"

@interface NXFileValidityWindow ()
@end

@implementation NXFileValidityWindow

- (instancetype)initWithaFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.opaque = NO;
        self.windowLevel = 1999.0;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor colorWithWhite:0 alpha:0.66] set];
    CGContextFillRect(context, self.bounds);
}
- (void)dismiss
{
    self.alpha = 0;
    [self removeFromSuperview];
    [NXFirstWindow makeKeyAndVisible];
}
@end

@interface NXFileValidityDateChooseViewController()<UIGestureRecognizerDelegate,UITextViewDelegate>

@property (nonatomic, weak) UIView *footView;
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *descriptionLabel;
@property (nonatomic, weak) UILabel *fileValidityDateLabel;
@property (nonatomic, weak) UILabel *changeLabel;

@property (nonatomic, weak) ZYCalendarView *calenderView;
@property (nonatomic, weak) UIView *calenderTitleView;

@property (nonatomic, strong) NXFileValidityWindow *fileValidityWindow;
@property (nonatomic, assign) CGFloat viewHeight;
@property (nonatomic, assign) CGFloat contentViewHeight;
@property (nonatomic, strong) NXFileValidityNavigationViewController *navgationVc;

@property (nonatomic, strong) UITextView *yearsTextView;
@property (nonatomic, strong) UITextView *monthTextView;
@property (nonatomic, strong) UITextView *weekTextView;
@property (nonatomic, strong) UITextView *dayTextView;

@property (nonatomic, strong) UILabel *yearPlaceHolderLabel;
@property (nonatomic, strong) UILabel *monthPlaceHolderLabel;
@property (nonatomic, strong) UILabel *weekPlaceHolderLabel;
@property (nonatomic, strong) UILabel *dayPlaceHolderLabel;

@property (nonatomic, strong) NXLFileValidateDateModel *dateModel;
@property (nonatomic, strong) NXLFileValidateDateModel *originalFileValidityDateModel;

@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, strong) UILabel *tipsLabel;

@property (nonatomic, strong) NXFileValidityDisplayView *rangeDateDisplayView;
@property (nonatomic, strong) NXFileValidityDisplayDateView *absoluteDateDisplayView;
@property (nonatomic, strong) NXFileValidityDisplayView *relativeDisplayView;
@end

@implementation NXFileValidityDateChooseViewController
- (instancetype)initWithDateModel:(NXLFileValidateDateModel *)dateModel
{
    self = [super init];
    if (self) {
        _viewHeight = 0;
        _contentViewHeight = 0;
        _dateModel = [dateModel copy];
        _originalFileValidityDateModel = [dateModel copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickBackground:)];
    tapGesture.delegate = self;
    [self.fileValidityWindow addGestureRecognizer:tapGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationWillChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navgationVc.viewHeight = _viewHeight;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

/**
 *  show actionsheet window
 */
- (void)show
{
    self.view.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
    NXFileValidityNavigationViewController *navVC = [[NXFileValidityNavigationViewController alloc] initWithRootViewController:self];
    [navVC.view addSubview:self.view];
    navVC.fileValidityWindow = self.fileValidityWindow;
    self.navgationVc = navVC;
    navVC.view.backgroundColor = [UIColor whiteColor];
    self.fileValidityWindow.rootViewController = navVC;
   
    [self.fileValidityWindow makeKeyAndVisible];
    [self commonInitWithDateModel:self.dateModel];
}

- (void)commonInitWithDateModel:(NXLFileValidateDateModel *)dateModel
{
    _viewHeight = 0.0;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Specify rights expiry date";
    titleLabel.textColor = [UIColor blackColor];
    //titleLabel.font = [UIFont systemFontOfSize:16.0];
    titleLabel.font = [UIFont fontWithName:@"Roboto" size:14.0];
    self.titleLabel = titleLabel;
    [self.view addSubview:titleLabel];
    
    UILabel *fileValidityDateLabel = [[UILabel alloc] init];
    fileValidityDateLabel.text = @"Date range";
    fileValidityDateLabel.textColor = [UIColor colorWithRed:79.0/255.0 green:79.0/255.0 blue:79.0/255.0 alpha:1.0];
    fileValidityDateLabel.font = [UIFont systemFontOfSize:12.0];
    self.fileValidityDateLabel = fileValidityDateLabel;
    [self.view addSubview:fileValidityDateLabel];
    
    UIView *descriptionContentView = [self getDescriptionContentViewWithDateModel:dateModel];
    [self.view addSubview:descriptionContentView];
    
    UILabel *changeLabel = [[UILabel alloc] init];
    changeLabel.textColor = [UIColor colorWithRed:74.0/255.0 green:143.0/255.0 blue:232.0/255.0 alpha:1.0];
    changeLabel.font = [UIFont italicSystemFontOfSize:12.0];
    UITapGestureRecognizer *changeLabelTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapChangeLabel:)];
    [changeLabel addGestureRecognizer:changeLabelTapGestureRecognizer];
    changeLabel.userInteractionEnabled = YES;
    
    NSDictionary *attribtDic = @{NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle]};
    NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:@"Change" attributes:attribtDic];
    changeLabel.attributedText = attribtStr;
    self.changeLabel = changeLabel;
    [self.view addSubview:changeLabel];
    
    //content view will change by dateModel type
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor whiteColor];
    
    UIView *wrapView = [self getWrapViewWithDateModel:dateModel];
    [contentView addSubview:wrapView];
    self.contentView = contentView;
    [self.view addSubview:contentView];
    
    /** foot view */
    UIView *footView = [[UIView alloc] init];
    footView.backgroundColor = [UIColor whiteColor];
    footView.layer.masksToBounds = YES;
    
    UIButton *cancelButton = [[UIButton alloc] init];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(onTapCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelButton setBackgroundColor:[UIColor colorWithRed:189.0/255.0 green:189.0/255.0 blue:189.0/255.0 alpha:1.0]];
    cancelButton.layer.cornerRadius = 5.0;
    
    UIButton *OKButton = [[UIButton alloc] init];
    self.okButton = OKButton;
    [OKButton setTitle:@"Save" forState:UIControlStateNormal];
    [OKButton addTarget:self action:@selector(onTapOKButton:) forControlEvents:UIControlEventTouchUpInside];
    [OKButton setBackgroundColor:[UIColor colorWithRed:73.0/255.0 green:160.0/255.0 blue:84.0/255.0 alpha:1.0]];
    [OKButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    OKButton.layer.cornerRadius = 5.0;
    
    [footView addSubview:cancelButton];
    [footView addSubview:OKButton];
    
    self.footView = footView;
    [self.view addSubview:footView];
    
    [footView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.height.equalTo(@(75));
        make.width.equalTo(self.view);
    }];
    
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(45);
        make.centerX.equalTo(footView).offset(-75);
        make.bottom.equalTo(footView.mas_bottom).offset(-15);
    }];
    
    [OKButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(45);
        make.centerX.equalTo(footView).offset(75);
        make.bottom.equalTo(footView.mas_bottom).offset(-15);
    }];
    _viewHeight += 75;
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(footView.mas_top);
        make.height.equalTo(@(_contentViewHeight));
        make.width.equalTo(self.view);
    }];
    _viewHeight += _contentViewHeight;
    
    [wrapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(contentView);
    }];
    
    CGFloat descriptionContentViewHeight = 0.0;
    if (dateModel.type == NXLFileValidateDateModelTypeRange || dateModel.type == NXLFileValidateDateModelTypeRelative) {
        descriptionContentViewHeight = 55.0;
    }else{
        descriptionContentViewHeight = 45.0;
    }
    
    [descriptionContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.bottom.equalTo(contentView.mas_top).offset(-5);
        make.height.equalTo(@(descriptionContentViewHeight));
    }];
    _viewHeight += descriptionContentViewHeight;
    
    [fileValidityDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.width.equalTo(@(100));
        make.bottom.equalTo(descriptionContentView.mas_top).offset(-8);
        make.height.equalTo(@(34));
    }];
    _viewHeight += 34;
    
    [changeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(fileValidityDateLabel).offset(100);
        make.width.equalTo(@(100));
        make.bottom.equalTo(descriptionContentView.mas_top).offset(-8);
        make.height.equalTo(@(34));
    }];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.bottom.equalTo(fileValidityDateLabel.mas_top);
        make.height.equalTo(@(30));
        make.width.equalTo(descriptionContentView);
    }];
    
    _viewHeight += 48;
    self.navgationVc.viewHeight = _viewHeight;
    
#if 0
    self.calenderTitleView.backgroundColor = [UIColor redColor];
    self.footView.backgroundColor = [UIColor yellowColor];
    self.fileValidityDateLabel.backgroundColor = [UIColor purpleColor];
    self.titleLabel.backgroundColor = [UIColor blueColor];
    self.changeLabel.backgroundColor = [UIColor cyanColor];
    descriptionContentView.backgroundColor = [UIColor yellowColor];
#endif
}

/**
 *  remove actionsheet window
 */
- (void)removeView {
    [self.fileValidityWindow dismiss];
    self.fileValidityWindow = nil;
    self.navgationVc = nil;
    [self.calenderView.manager.selectedDateArray removeAllObjects];
    
    [self.navgationVc.view hd_removeAllSubviews];
    [self.view hd_removeAllSubviews];
    [self.view removeFromSuperview];
    [NXFirstWindow makeKeyAndVisible];
}

- (UIView *)getRelativeViewWithDateModel:(NXLFileValidateDateModel *)dateModel
{
    self.fileValidityDateLabel.text = @"Relative";
    
    UIView *relativeView = [[UIView alloc] init];
    relativeView.backgroundColor = [UIColor whiteColor];
    
    UITextView *yearsTextView =  [[UITextView alloc] init];
    yearsTextView.tag = 1;
    yearsTextView.textAlignment = NSTextAlignmentCenter;
    yearsTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    yearsTextView.delegate = self;
    yearsTextView.layer.borderColor = [UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0].CGColor;
    yearsTextView.layer.borderWidth = 1.0;
    yearsTextView.layer.cornerRadius = 5.0;
    self.yearsTextView = yearsTextView;
    [yearsTextView addSubview:self.yearPlaceHolderLabel];
    if (self.dateModel.year > 0) {
        _yearPlaceHolderLabel.text = @"";
        self.yearsTextView.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.dateModel.year];
    }else{
        _yearPlaceHolderLabel.text = @"0";
    }
    
    UILabel *yearsLabel = [[UILabel alloc] init];
    yearsLabel.textColor = [UIColor colorWithRed:90.0/255.0 green:90.0/255.0 blue:90.0/255.0 alpha:1.0];
    yearsLabel.font = [UIFont systemFontOfSize:12.0];
    yearsLabel.textAlignment = NSTextAlignmentLeft;
    yearsLabel.text = @"Year(s)";
    [relativeView addSubview:yearsTextView];
    [relativeView addSubview:yearsLabel];
    
    UITextView *monthTextView = [[UITextView alloc] init];
    monthTextView.tag = 2;
    monthTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    monthTextView.textAlignment = NSTextAlignmentCenter;
    monthTextView.delegate = self;
    monthTextView.layer.borderColor = [UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0].CGColor;
    monthTextView.layer.borderWidth = 1.0;
    monthTextView.layer.cornerRadius = 5.0;
    self.monthTextView = monthTextView;
    [monthTextView addSubview:self.monthPlaceHolderLabel];
    
    if (self.dateModel.month > 0) {
        _monthPlaceHolderLabel.text = @"";
        self.monthTextView.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.dateModel.month];
    }else{
        _monthPlaceHolderLabel.text = @"0";
    }
    
    UILabel *monthLabel = [[UILabel alloc] init];
    monthLabel.textColor = [UIColor colorWithRed:90.0/255.0 green:90.0/255.0 blue:90.0/255.0 alpha:1.0];
    monthLabel.textAlignment = NSTextAlignmentLeft;
    monthLabel.font = [UIFont systemFontOfSize:12.0];
    monthLabel.text = @"Month(s)";
    [relativeView addSubview:monthTextView];
    [relativeView addSubview:monthLabel];
    
    UITextView *weekTextView =  [[UITextView alloc] init];
     weekTextView.tag = 3;
    weekTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    weekTextView.textAlignment = NSTextAlignmentCenter;
    weekTextView.delegate = self;
    weekTextView.layer.borderColor = [UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0].CGColor;
    weekTextView.layer.borderWidth = 1.0;
    weekTextView.layer.cornerRadius = 5.0;
    self.weekTextView = weekTextView;
    weekTextView.delegate = self;
    [weekTextView addSubview:self.weekPlaceHolderLabel];
    
    if (self.dateModel.week > 0) {
        _weekPlaceHolderLabel.text = @"";
        self.weekTextView.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.dateModel.week];
    }else{
        _weekPlaceHolderLabel.text = @"0";
    }
    
    UILabel *weekLabel = [[UILabel alloc] init];
    weekLabel.textColor = [UIColor colorWithRed:90.0/255.0 green:90.0/255.0 blue:90.0/255.0 alpha:1.0];
    weekLabel.font = [UIFont systemFontOfSize:12.0];
    weekLabel.textAlignment = NSTextAlignmentLeft;
    weekLabel.text = @"Week(s)";
    [relativeView addSubview:weekTextView];
    [relativeView addSubview:weekLabel];
    
    UITextView *dayTextView = [[UITextView alloc] init];
    dayTextView.tag = 4;
    dayTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    dayTextView.textAlignment = NSTextAlignmentCenter;
    dayTextView.layer.borderColor = [UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0].CGColor;
    dayTextView.layer.borderWidth = 1.0;
    dayTextView.layer.cornerRadius = 5.0;
    self.dayTextView = dayTextView;
    dayTextView.delegate = self;
    [dayTextView addSubview:self.dayPlaceHolderLabel];
  
    UILabel *dayLabel = [[UILabel alloc] init];
    dayLabel.textColor = [UIColor colorWithRed:90.0/255.0 green:90.0/255.0 blue:90.0/255.0 alpha:1.0];
    dayLabel.font = [UIFont systemFontOfSize:12.0];
    dayLabel.textAlignment = NSTextAlignmentLeft;
    dayLabel.text = @"Day(s)";
    [relativeView addSubview:dayTextView];
    [relativeView addSubview:dayLabel];
    
    UILabel *tipsLabel = [[UILabel alloc] init];
    tipsLabel.textColor = [UIColor redColor];
    tipsLabel.font = [UIFont systemFontOfSize:14.0];
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.adjustsFontSizeToFitWidth = YES;
    tipsLabel.text = @"Please specify relative digital rights validity period";
    [relativeView addSubview:tipsLabel];
    
    self.tipsLabel = tipsLabel;
    [self.tipsLabel setHidden:YES];
    
    
    if (self.dateModel.day > 0) {
        _dayPlaceHolderLabel.text = @"";
        self.dayTextView.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.dateModel.day];
    }else{
        _dayPlaceHolderLabel.text = @"0";
    }
    
    if (self.originalFileValidityDateModel.type != dateModel.type) {
        
        _yearPlaceHolderLabel.text = @"0";
        self.yearsTextView.text = @"";
        
        _monthPlaceHolderLabel.text = @"";
        self.monthTextView.text = @"1";
        
        _weekPlaceHolderLabel.text = @"0";
        self.weekTextView.text = @"";
        
        _dayPlaceHolderLabel.text = @"0";
        self.dayTextView.text = @"";
        
        NXLFileValidateDateModel *tempModel = [[NXLFileValidateDateModel alloc] initRelativeValidateDateModelWithYear:0 month:1 week:0 day:0];
         [self.relativeDisplayView update:tempModel];
    }
    else
    {
         [self.relativeDisplayView update:dateModel];
    }
    
    [yearsTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(relativeView).offset(textViewTopMarginSuperView);
        make.top.equalTo(relativeView).offset(textViewTopMarginSuperView);
        make.height.equalTo(@(textViewHeight));
        make.width.equalTo(@(textViewWidth));
    }];
    
    [yearsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(yearsTextView.mas_right).offset(textViewMarginDateLabel);
        make.top.equalTo(relativeView).offset(textViewTopMarginSuperView);
        make.height.equalTo(@(dateLabelHeight));
        make.width.equalTo(@(dateLabelWidth));
    }];
    
    [monthTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(relativeView).offset(textViewTopMarginSuperView);
        make.top.equalTo(yearsTextView.mas_bottom).offset(textViewMargin);
        make.height.equalTo(@(textViewHeight));
        make.width.equalTo(@(textViewWidth));
    }];
    
    [monthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(monthTextView.mas_right).offset(textViewMarginDateLabel);
        make.top.equalTo(yearsLabel.mas_bottom).offset(dateLabelMargin);
        make.height.equalTo(@(dateLabelHeight));
        make.width.equalTo(@(dateLabelWidth));
    }];
    
    [weekTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(relativeView).offset(textViewTopMarginSuperView);
        make.top.equalTo(monthTextView.mas_bottom).offset(textViewMargin);
        make.height.equalTo(@(textViewHeight));
        make.width.equalTo(@(textViewWidth));
    }];
    
    [weekLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weekTextView.mas_right).offset(textViewMarginDateLabel);
        make.top.equalTo(monthLabel.mas_bottom).offset(dateLabelMargin);
        make.height.equalTo(@(dateLabelHeight));
        make.width.equalTo(@(dateLabelWidth));
    }];
    
    [dayTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(relativeView).offset(textViewTopMarginSuperView);
        make.top.equalTo(weekTextView.mas_bottom).offset(textViewMargin);
        make.height.equalTo(@(textViewHeight));
        make.width.equalTo(@(textViewWidth));
    }];
    
    [dayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(dayTextView.mas_right).offset(textViewMarginDateLabel);
        make.top.equalTo(weekLabel.mas_bottom).offset(dateLabelMargin);
        make.height.equalTo(@(dateLabelHeight));
        make.width.equalTo(@(dateLabelWidth));
    }];
    
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       make.top.equalTo(dayTextView.mas_bottom).offset(10);
        make.centerX.equalTo(relativeView);
        make.width.equalTo(@(320));
        make.height.equalTo(@15);
    }];
    
    _contentViewHeight = 237;
    return relativeView;
#if 0
        yearsTextView.backgroundColor = [UIColor redColor];
        weekTextView.backgroundColor = [UIColor redColor];
        monthTextView.backgroundColor = [UIColor redColor];
        dayTextView.backgroundColor = [UIColor redColor];

        monthLabel.backgroundColor = [UIColor purpleColor];
        yearsLabel.backgroundColor = [UIColor purpleColor];
        weekLabel.backgroundColor = [UIColor purpleColor];
        dayLabel.backgroundColor = [UIColor purpleColor];
#endif
}

- (UIView *)getCalenderViewWithDateType:(NXLFileValidateDateModel *)dateModel
{
    UIView *wrapView = [[UIView alloc] init];
    wrapView.backgroundColor = [UIColor whiteColor];
    
    UIView *calenderTitlecontentView = [[UIView alloc] init];
    calenderTitlecontentView.backgroundColor = [UIColor whiteColor];
    
    UIView *calenderTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 40, 34)];
    calenderTitleView.backgroundColor = [UIColor whiteColor];
    self.calenderTitleView = calenderTitleView;
    
    [calenderTitlecontentView addSubview:calenderTitleView];
    [wrapView addSubview:calenderTitlecontentView];
    CGFloat weekW = (self.view.frame.size.width - 40.0)/7;
    NSArray *titles = @[@"S", @"M", @"T", @"W",
                        @"T", @"F", @"S"];
    for (int i = 0; i < 7; i++) {
        UILabel *week = [[UILabel alloc] initWithFrame:CGRectMake(i*weekW, 0, weekW, 34)];
        week.textAlignment = NSTextAlignmentCenter;
        week.font = [UIFont boldSystemFontOfSize:14.0];
        week.textColor = [UIColor colorWithRed:176.0/255.0 green:176.0/255.0 blue:176.0/255.0 alpha:1.0];
        [calenderTitleView addSubview:week];
        week.text = titles[i];
    }
    
    NXLFileValidateDateModel *currentDisplayModel = [dateModel copy];
    ZYCalendarView *calenderview = [[ZYCalendarView alloc] initWithFrame:CGRectMake(20, 0, self.view.frame.size.width - 40, 300)];
    calenderview.manager.canSelectPastDays = false;
    self.calenderView = calenderview;
   
    if (dateModel.type == NXLFileValidateDateModelTypeRange) {
        calenderview.manager.selectionType = ZYCalendarSelectionTypeRange;
        self.fileValidityDateLabel.text = @"Date range";
        
        if (dateModel.type != _originalFileValidityDateModel.type) {
            NSDate *startTime = [NSDate date];
            NSDate *endTime;
            
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *adcomps = [[NSDateComponents alloc] init];
            [adcomps setMonth:1];
            endTime = [calendar dateByAddingComponents:adcomps toDate:startTime options:0];
            
            NXLFileValidateDateModel *temp = [[NXLFileValidateDateModel alloc] initWithNXFileValidateDateModelType:NXLFileValidateDateModelTypeRange withStartTime:startTime endTIme:endTime];
            
            [calenderview.manager.selectedDateArray addObject:startTime];
            [calenderview.manager.selectedDateArray addObject:endTime];
            
            // set default time
            self.dateModel.startTime = startTime;
            self.dateModel.endTime = endTime;
            
            [self.rangeDateDisplayView update:temp];
        }
        else
        {
            BOOL isSameDay = [self isSameDay:currentDisplayModel.startTime date2:currentDisplayModel.endTime];
             NSComparisonResult result = [self.dateModel.startTime compare:self.dateModel.endTime];
            if (isSameDay && result == NSOrderedSame) {
                [calenderview.manager.selectedDateArray addObject:currentDisplayModel.startTime];
            }
            else
            {
                [calenderview.manager.selectedDateArray addObject:currentDisplayModel.startTime];
                [calenderview.manager.selectedDateArray addObject:currentDisplayModel.endTime];
            }
              // set default time
            self.dateModel.startTime = currentDisplayModel.startTime;
            self.dateModel.endTime = currentDisplayModel.endTime;
            
            [self.rangeDateDisplayView update:currentDisplayModel];
        }
    }
    else if (dateModel.type == NXLFileValidateDateModelTypeAbsolute){
        calenderview.manager.selectionType = ZYCalendarSelectionTypeSingle;
        self.fileValidityDateLabel.text = @"Absolute date";
        
        if (dateModel.type != _originalFileValidityDateModel.type) {
            NSDate *startTime = [NSDate date];
            NSDate *endTime;
            
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *adcomps = [[NSDateComponents alloc] init];
            [adcomps setMonth:1];
            endTime = [calendar dateByAddingComponents:adcomps toDate:startTime options:0];
            [calenderview.manager.selectedDateArray addObject:endTime];
            
            NXLFileValidateDateModel *temp = [[NXLFileValidateDateModel alloc] initWithNXFileValidateDateModelType:NXLFileValidateDateModelTypeAbsolute withStartTime:startTime endTIme:endTime];
               [self.absoluteDateDisplayView update:temp.endTime];
            
            // set default time
            self.dateModel.startTime = [NSDate date];
            self.dateModel.endTime = endTime;
        }
        else{
            [calenderview.manager.selectedDateArray addObject:dateModel.endTime];
             [self.absoluteDateDisplayView update:currentDisplayModel.endTime];
            
            // set default time
            self.dateModel.startTime = [NSDate date];
            self.dateModel.endTime = currentDisplayModel.endTime;
        }
    }
    calenderview.date = [NSDate date];
    calenderview.dayViewBlock = ^(ZYCalendarManager *manager, NSDate *dayDate) {
        
        for (NSDate *date in manager.selectedDateArray) {
            NSLog(@"%@", [manager.dateFormatter stringFromDate:date]);
        }
        printf("\n");
        if (dateModel.type == NXLFileValidateDateModelTypeRange) {
            self.dateModel.startTime = manager.selectedDateArray.firstObject;
            self.dateModel.endTime = manager.selectedDateArray.lastObject;
            if ([self isSameDay:self.dateModel.startTime date2:self.dateModel.endTime]) {
                 self.dateModel.endTime =  [self endOfDay:self.dateModel.startTime];
            }
          [self.rangeDateDisplayView update:self.dateModel];
        }
        else if (dateModel.type == NXLFileValidateDateModelTypeAbsolute){
            self.dateModel.startTime = [NSDate date];
            self.dateModel.endTime = manager.selectedDateArray.firstObject;
            if ([self isSameDay:self.dateModel.startTime date2:self.dateModel.endTime]) {
                self.dateModel.endTime =  [self endOfDay:self.dateModel.startTime];
            }
              [self.absoluteDateDisplayView update:self.dateModel.endTime];
        }
    };
    
    [wrapView addSubview:calenderview];
    
    [calenderTitlecontentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wrapView);
        make.right.equalTo(wrapView);
        make.top.equalTo(wrapView.mas_top);
        make.height.equalTo(@(34));
    }];
    
    [calenderTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(calenderTitlecontentView).offset(20);
        make.right.equalTo(calenderTitlecontentView).offset(-20);
        make.bottom.equalTo(calenderTitlecontentView);
        make.height.equalTo(@(34));
    }];
    
    //[calenderTitleView setBackgroundColor:[UIColor redColor]];
    
    [calenderview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wrapView).offset(20);
        make.right.equalTo(wrapView).offset(-20);
        make.top.equalTo(calenderTitlecontentView.mas_bottom);
        make.height.equalTo(@(300));
    }];
    _contentViewHeight = 300 + 34;
    
    return wrapView;
}

- (UIView *)getNeverExpireView
{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"Access rights will Never expire"];
    [attrString addAttribute:NSForegroundColorAttributeName
                       value:[UIColor colorWithRed:48.0/255.0 green:173.0/255.0 blue:99.0/255.0 alpha:1.0]
                       range:NSMakeRange(19, 12)];
    [attrString addAttribute:NSFontAttributeName
                       value:[UIFont boldSystemFontOfSize:15.0f]
                       range:NSMakeRange(19, 12)];
    [attrString addAttribute:NSForegroundColorAttributeName
                       value:[UIColor colorWithRed:79.0/255.0 green:79.0/255.0 blue:79.0/255.0 alpha:1.0]
                       range:NSMakeRange(0, 18)];
    
    self.descriptionLabel.attributedText = attrString;
    self.fileValidityDateLabel.text = @"Never expire";
    
    UIView *wrapView = [[UIView alloc] init];
    wrapView.backgroundColor = [UIColor whiteColor];
    _contentViewHeight = 237;
    
    return wrapView;
}

- (UIView *)getWrapViewWithDateModel:(NXLFileValidateDateModel *)dateModel
{
    switch (dateModel.type) {
        case NXLFileValidateDateModelTypeNeverExpire:
            return [self getNeverExpireView];
            break;
        case NXLFileValidateDateModelTypeAbsolute:
        case NXLFileValidateDateModelTypeRange:
            return [self getCalenderViewWithDateType:dateModel];
            break;
        case NXLFileValidateDateModelTypeRelative:
            return [self getRelativeViewWithDateModel:dateModel];
            break;
        default:
            return [self getNeverExpireView];
            break;
    }
}

- (UIView *)getDescriptionContentViewWithDateModel:(NXLFileValidateDateModel *)model
{
    UIView *wrapView = [[UIView alloc] init];
    if (model.type == NXLFileValidateDateModelTypeNeverExpire) {
        UILabel *descriptionLabel = [[UILabel alloc] init];
        descriptionLabel.textColor = [UIColor colorWithRed:48.0/255.0 green:173.0/255.0 blue:99.0/255.0 alpha:1.0];
        descriptionLabel.font = [UIFont systemFontOfSize:14.0];
        descriptionLabel.text = @"Friday,November 3,2017 - Friday,December 29,2017"; //standard format for date range
        descriptionLabel.adjustsFontSizeToFitWidth = YES;
        
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"Access rights will Never expire"];
        [attrString addAttribute:NSForegroundColorAttributeName
                           value:[UIColor colorWithRed:48.0/255.0 green:173.0/255.0 blue:99.0/255.0 alpha:1.0]
                           range:NSMakeRange(19, 12)];
        [attrString addAttribute:NSFontAttributeName
                           value:[UIFont boldSystemFontOfSize:15.0f]
                           range:NSMakeRange(19, 12)];
        [attrString addAttribute:NSForegroundColorAttributeName
                           value:[UIColor colorWithRed:79.0/255.0 green:79.0/255.0 blue:79.0/255.0 alpha:1.0]
                           range:NSMakeRange(0, 18)];
        
        descriptionLabel.attributedText = attrString;
        self.fileValidityDateLabel.text = @"Never expire";
        [wrapView addSubview:descriptionLabel];
        
        [descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wrapView);
            make.top.equalTo(wrapView);
            make.width.equalTo(wrapView);
            make.height.equalTo(@(44));
        }];
    }
    
    if (model.type == NXLFileValidateDateModelTypeRange) {
        NXFileValidityDisplayView *dateRangeView = [[NXFileValidityDisplayView alloc] initWithFileValidityModel:model];
        self.rangeDateDisplayView = dateRangeView;
        [wrapView addSubview:dateRangeView];
        
        [dateRangeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wrapView);
            make.top.equalTo(wrapView);
            make.bottom.equalTo(wrapView);
            make.right.equalTo(wrapView);
        }];
    }
    
    if (model.type == NXLFileValidateDateModelTypeRelative) {
        NXFileValidityDisplayView *realtiveDisplayView = [[NXFileValidityDisplayView alloc] initWithFileValidityModel:model];
        self.relativeDisplayView = realtiveDisplayView;
        [wrapView addSubview:realtiveDisplayView];
        
        [realtiveDisplayView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wrapView);
            make.top.equalTo(wrapView);
            make.bottom.equalTo(wrapView);
            make.right.equalTo(wrapView);
        }];
    }
    
    if (model.type == NXLFileValidateDateModelTypeAbsolute) {
        UILabel *descriptionLabel = [[UILabel alloc] init];
        descriptionLabel.textColor = [UIColor colorWithRed:48.0/255.0 green:173.0/255.0 blue:99.0/255.0 alpha:1.0];
        descriptionLabel.font = [UIFont systemFontOfSize:15.0];
        descriptionLabel.text = @"Friday,November 3,2017 - Friday,December 29,2017"; //standard format for date range
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"Rights will Expire on"];
        [attrString addAttribute:NSForegroundColorAttributeName
                           value:[UIColor colorWithRed:48.0/255.0 green:173.0/255.0 blue:99.0/255.0 alpha:1.0]
                           range:NSMakeRange(12, 9)];
        [attrString addAttribute:NSFontAttributeName
                           value:[UIFont boldSystemFontOfSize:15.0f]
                           range:NSMakeRange(12, 9)];
        [attrString addAttribute:NSForegroundColorAttributeName
                           value:[UIColor colorWithRed:79.0/255.0 green:79.0/255.0 blue:79.0/255.0 alpha:1.0]
                           range:NSMakeRange(0, 11)];
        descriptionLabel.attributedText = attrString;
        self.fileValidityDateLabel.text = @"Absolute date";
        [wrapView addSubview:descriptionLabel];
        
        NXFileValidityDisplayDateView *absoluteDateView = [[NXFileValidityDisplayDateView alloc] initWithDate:model.endTime];
        self.absoluteDateDisplayView = absoluteDateView;
        
        [wrapView addSubview:absoluteDateView];
        [descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wrapView);
            make.top.equalTo(wrapView);
            make.width.equalTo(@(145));
            make.height.equalTo(@(44));
        }];
        
        [absoluteDateView mas_makeConstraints:^(MASConstraintMaker *make) {
             make.left.equalTo(descriptionLabel.mas_right).offset(2);
             make.top.equalTo(wrapView).offset(12);
             make.width.equalTo(@(79));
             make.height.equalTo(@(25));
        }];
    }
    
    return wrapView;
}

- (void)updateCurrentUIWithDateModel:(NXLFileValidateDateModel *)dateModel
{
    if (dateModel.type != NXLFileValidateDateModelTypeRelative) {
        self.okButton.enabled = YES;
        self.okButton.alpha = 1.0;//透明度
    }
    
    [self.view hd_removeAllSubviews];
    [self commonInitWithDateModel:dateModel];
}

- (UILabel *)yearPlaceHolderLabel
{
    if (!_yearPlaceHolderLabel) {
        _yearPlaceHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 33)];
        _yearPlaceHolderLabel.font = [UIFont fontWithName:@"Arial" size:14.0f];
        _yearPlaceHolderLabel.backgroundColor = [UIColor clearColor];
        _yearPlaceHolderLabel.enabled = NO;
        _yearPlaceHolderLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _yearPlaceHolderLabel;
}

- (UILabel *)monthPlaceHolderLabel
{
    if (!_monthPlaceHolderLabel) {
        _monthPlaceHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 33)];
        _monthPlaceHolderLabel.text = @"0";
        _monthPlaceHolderLabel.font = [UIFont fontWithName:@"Arial" size:14.0f];
        _monthPlaceHolderLabel.backgroundColor = [UIColor clearColor];
        _monthPlaceHolderLabel.enabled = NO;
        _monthPlaceHolderLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _monthPlaceHolderLabel;
}

- (UILabel *)weekPlaceHolderLabel
{
    if (!_weekPlaceHolderLabel) {
        _weekPlaceHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 33)];
        _weekPlaceHolderLabel.text = @"0";
        _weekPlaceHolderLabel.font = [UIFont fontWithName:@"Arial" size:14.0f];
        _weekPlaceHolderLabel.backgroundColor = [UIColor clearColor];
        _weekPlaceHolderLabel.enabled = NO;
        _weekPlaceHolderLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _weekPlaceHolderLabel;
}

- (UILabel *)dayPlaceHolderLabel
{
    if (!_dayPlaceHolderLabel) {
        _dayPlaceHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 33)];
        _dayPlaceHolderLabel.text = @"0";
        _dayPlaceHolderLabel.font = [UIFont fontWithName:@"Arial" size:14.0f];
        _dayPlaceHolderLabel.backgroundColor = [UIColor clearColor];
        _dayPlaceHolderLabel.enabled = NO;
        _dayPlaceHolderLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _dayPlaceHolderLabel;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - PropertyMethod
- (NXFileValidityWindow *)fileValidityWindow {
    if (!_fileValidityWindow) {
        _fileValidityWindow = [[NXFileValidityWindow alloc] initWithaFrame:NXMainScreenBounds];
        _fileValidityWindow.alpha = 1.0;
    }
    return _fileValidityWindow;
}

- (BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    return [comp1 day] == [comp2 day] && [comp1 month] == [comp2 month] && [comp1 year]  == [comp2 year];
}

-(NSDate *)endOfDay:(NSDate *)date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date];
    
    [components setHour:23];
    [components setMinute:59];
    [components setSecond:59];
    
    return [cal dateFromComponents:components];
}

-(NSDate *)beginOfDay:(NSDate *)date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date];
    
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    return [cal dateFromComponents:components];
}

#pragma mark - OnClick Event
- (void)onClickBackground:(id)sender
{
    [self removeView];
}

- (void)onTapCancelButton:(id)sender
{
    [self removeView];
}

- (void)onTapOKButton:(id)sender
{
    NSLog(@"year: %@",self.yearsTextView.text);
    NSLog(@"month: %@",self.monthTextView.text);
    NSLog(@"week: %@",self.weekTextView.text);
    NSLog(@"day: %@",self.dayTextView.text);
    
    
    [self removeView];
    if (self.dateModel.type == NXLFileValidateDateModelTypeRelative){
        NSUInteger yearNum = self.yearsTextView.text.integerValue;
        NSUInteger monthNum = self.monthTextView.text.integerValue;
        NSUInteger weekNum = self.weekTextView.text.integerValue;
        NSUInteger dayNum = self.dayTextView.text.integerValue;
        
        NXLFileValidateDateModel *relativeDateModel = [[NXLFileValidateDateModel alloc] initRelativeValidateDateModelWithYear:yearNum month:monthNum week:weekNum day:dayNum];
        self.dateModel = relativeDateModel;
    }else {
        self.dateModel.startTime = [self beginOfDay:self.dateModel.startTime];
    }
    
    if (self.chooseCompBlock) {
        _chooseCompBlock(self.dateModel);
    }
}

- (void)onTapChangeLabel:(id)sender {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    NXFileValidityPickViewController *pickView = [[NXFileValidityPickViewController alloc] initWithDateModel:self.dateModel];
    pickView.navc = self.navgationVc;
    
    pickView.selectItemCompBlock = ^(NXLFileValidateDateModel *dateModel) {
        self.dateModel = dateModel;
        [self updateCurrentUIWithDateModel:dateModel];
    };
    
    [self.navigationController pushViewController:pickView animated:YES];
}


#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    if ([touch.view isKindOfClass:[UIWindow class]]){
        return YES;
    }else{
        return NO;
    }
}

#pragma mark -UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length == 0){
        switch (textView.tag) {
            case 1:
            {
                self.yearPlaceHolderLabel.text = @"0";
                break;
            case 2:
                self.monthPlaceHolderLabel.text = @"0";
                 break;
            case 3:
                self.weekPlaceHolderLabel.text = @"0";
                 break;
            case 4:
                self.dayPlaceHolderLabel.text = @"0";
                 break;
            default:
                break;
            }
        }
    } else {
        switch (textView.tag) {
            case 1:
            {
                self.yearPlaceHolderLabel.text = @"";
                break;
            case 2:
                self.monthPlaceHolderLabel.text = @"";
                 break;
            case 3:
                self.weekPlaceHolderLabel.text = @"";
                 break;
            case 4:
                self.dayPlaceHolderLabel.text = @"";
                 break;
            default:
                break;
            }
        }
    }
    
    NSUInteger yearNum = self.yearsTextView.text.integerValue;
    NSUInteger monthNum = self.monthTextView.text.integerValue;
    NSUInteger weekNum = self.weekTextView.text.integerValue;
    NSUInteger dayNum = self.dayTextView.text.integerValue;
    
    if (yearNum == 0 && monthNum == 0 && weekNum == 0 && dayNum == 0) {
        self.okButton.enabled = NO;
        self.okButton.alpha=0.4;//透明度
        [self.tipsLabel setHidden:NO];
    }
    else
    {
       self.okButton.enabled = YES;
       self.okButton.alpha = 1.0;//透明度
       [self.tipsLabel setHidden:YES];
        
       NXLFileValidateDateModel *relativeDateModel = [[NXLFileValidateDateModel alloc] initRelativeValidateDateModelWithYear:yearNum month:monthNum week:weekNum day:dayNum];
        [self.relativeDisplayView update:relativeDateModel];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSCharacterSet*cs;
    cs = [[NSCharacterSet characterSetWithCharactersInString:NUMBERS] invertedSet];
    NSString *filtered = [[text componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    BOOL basicTest = [text isEqualToString:filtered];
    
    if (text.length == 0) {
        return YES;
    }
    
    if(!basicTest || textView.text.length == 3) {
        return NO;
    }
    
    NSString *str = [textView.text stringByAppendingString:text];
    if(str.intValue > 100) {
        return NO;
    }
    
    return YES;
}

#pragma -mark keyboard event

- (void)keyboardWillShow: (NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    
    [self.navgationVc.view mas_updateConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.leading.equalTo(self.fileValidityWindow.mas_safeAreaLayoutGuideLeading);
            make.trailing.equalTo(self.fileValidityWindow.mas_safeAreaLayoutGuideTrailing);
            make.bottom.equalTo(self.fileValidityWindow.mas_safeAreaLayoutGuideBottom).offset(-(height) + 30);
            make.width.equalTo(self.fileValidityWindow.mas_safeAreaLayoutGuideWidth);
            make.height.equalTo(@(_viewHeight));
        }
        else
        {
            make.leading.equalTo(self.fileValidityWindow);
            make.trailing.equalTo(self.fileValidityWindow);
            make.bottom.equalTo(self.fileValidityWindow.mas_bottom).offset(-(height) + 30);
            make.width.equalTo(self.fileValidityWindow);
            make.height.equalTo(@(_viewHeight));
        }
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self.navgationVc.view mas_updateConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.leading.equalTo(self.fileValidityWindow.mas_safeAreaLayoutGuideLeading);
            make.trailing.equalTo(self.fileValidityWindow.mas_safeAreaLayoutGuideTrailing);
            make.bottom.equalTo(self.fileValidityWindow.mas_safeAreaLayoutGuideBottom);
            make.width.equalTo(self.fileValidityWindow.mas_safeAreaLayoutGuideWidth);
            make.height.equalTo(@(_viewHeight));
        }
        else
        {
            make.leading.equalTo(self.fileValidityWindow);
            make.trailing.equalTo(self.fileValidityWindow);
            make.bottom.equalTo(self.fileValidityWindow.mas_bottom);
            make.width.equalTo(self.fileValidityWindow);
            make.height.equalTo(@(_viewHeight));
        }
    }];
}

#pragma -mark device oriention event

- (void)deviceOrientationWillChange:(NSNotification *)notification
{
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        
    }
    else
    {
        
    }
}

@end
