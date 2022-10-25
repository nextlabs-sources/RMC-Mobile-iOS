//
//  NXSelectSeverURLView.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2018/6/26.
//  Copyright © 2018年 nextlabs. All rights reserved.
//

#import "NXSelectSeverURLView.h"
#import "Masonry.h"
#import "NXCommonUtils.h"
@interface NXSelectSeverURLView ()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) UIPickerView *pickView;
@property (nonatomic, assign) BOOL needScroll;
@end
@implementation NXSelectSeverURLView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:50/256.0 green:50/256.0 blue:50/256.0 alpha:0.8];
        [self commonInit];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [tap addTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}
- (void)setAllURLs:(NSArray *)allURLs {
    _allURLs = allURLs;
    [_allURLs enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:self.selectURL]) {
            self.currentIndex = idx;
            *stop = YES;
            self.needScroll = YES;
        }
    }];
    if (self.needScroll) {
        [self.pickView selectRow:self.currentIndex inComponent:0 animated:NO];
    } else {
        [self.pickView selectRow:0 inComponent:0 animated:NO];
        if (self.selectURL == nil) {
            self.selectURL = _allURLs[0];
        }
    }
}
- (void)commonInit {
    UIView *contentView = [[UIView alloc]init];
    contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:contentView];
    UIPickerView *pickerView = [[UIPickerView alloc]init];
    [contentView addSubview:pickerView];
    self.pickView = pickerView;
    pickerView.delegate = self;
    pickerView.dataSource = self;
    UIButton *cancelBtn = [[UIButton alloc]init];
    [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    cancelBtn.backgroundColor = [UIColor lightGrayColor];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:cancelBtn];
    UIButton *doneBtn = [[UIButton alloc]init];
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    doneBtn.backgroundColor = RMC_MAIN_COLOR;
    [doneBtn setTitle:@"Done" forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(doneBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:doneBtn];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.equalTo(self).multipliedBy(0.7);
    }];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(contentView).offset(-kMargin * 5);
        make.centerX.equalTo(contentView).offset(-70);
        make.width.equalTo(@100);
        make.height.equalTo(@40);
    }];
    [doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.width.height.equalTo(cancelBtn);
        make.centerX.equalTo(contentView).offset(70);
    }];
    [pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView).offset(kMargin * 4);
        make.left.right.equalTo(contentView);
        make.bottom.equalTo(cancelBtn.mas_top).offset(-kMargin * 6);
    }];
}
#pragma mark --- UIPickerViewDelegate
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.allURLs.count;
}

- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 1;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
     NSString * str = [self.allURLs objectAtIndex:row];
    UILabel *label = [[UILabel alloc]init];
    label.text = str;
    label.textAlignment = NSTextAlignmentCenter;
    label.adjustsFontSizeToFitWidth = YES;
    label.numberOfLines = 0;
    return label;
    
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 50;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return pickerView.bounds.size.width * 0.95;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectURL = [self.allURLs objectAtIndex:row];
}


- (void)cancelBtnClick:(id)sender {
    if (self.cancelHandle) {
        self.cancelHandle();
    }
}
- (void)doneBtnClick:(id)sender {
    if (self.doneHandle) {
        self.doneHandle(self.selectURL);
    }
    [self cancelBtnClick:nil];
}
- (void)tap:(id)sender {
    [self cancelBtnClick:nil];
}

@end
