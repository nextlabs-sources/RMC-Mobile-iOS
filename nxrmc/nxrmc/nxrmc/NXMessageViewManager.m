//
//  NXMessageView.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 5/4/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXMessageViewManager.h"
#import "Masonry.h"
#import "NXRMCUIDef.h"
#import "NXCommonUtils.h"

#pragma mark - NXMessageView
@interface NXMessageView: UIView<CAAnimationDelegate>
@property(nonatomic, weak) UIImageView *messageIcon;
@property(nonatomic, weak) UILabel *titleLab;
@property(nonatomic, weak) UILabel *detailsLab;
@property(nonatomic, weak) UILabel *appendInfoLab;
@property(nonatomic, weak) UILabel *appendInfoLab2;
@property(nonatomic, assign) NXMessageViewManagerType viewType;
@property(nonatomic, weak) UIView *backGroundView;
@end

@implementation NXMessageView
- (void)showWithTitle:(NSString *)title details:(NSString *)details appendInfo:(NSString *)appendInfo appendInfo2:(NSString *)appendInfo2 image:(UIImage *)image dismissAfter:(NSTimeInterval) afterSecond type:(NXMessageViewManagerType)type
{
    self.viewType = type;
    UIView *backGroundView = [[UIView alloc] init];
    
    backGroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    UIView *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:backGroundView];
    
    [backGroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(keyWindow);
        make.centerX.centerY.equalTo(keyWindow);
    }];
    
    [backGroundView addSubview:self];
    if (afterSecond < 0) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageViewDidTaped:)];
        [backGroundView addGestureRecognizer:tap];
    }
   
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(backGroundView);
        make.height.equalTo(@230);
        make.centerY.centerX.equalTo(backGroundView);
    }];

    self.backGroundView = backGroundView;
    
    [self commonInit];
    if (title) {
        self.titleLab.text = title;
    }
    
    if (details) {
        self.detailsLab.text = details;
    }
    
    if (appendInfo) {
        self.appendInfoLab.text = appendInfo;
    }
    
    if (appendInfo2) {
        self.appendInfoLab2.text = appendInfo2;
    }
    
    if (image) {
        self.messageIcon.image = image;
    }
    
    if (afterSecond >0) {
        [NSTimer scheduledTimerWithTimeInterval:afterSecond target:self selector:@selector(dismissMessageView) userInfo:nil repeats:NO];
    }
    
}

- (void)messageViewDidTaped:(UITapGestureRecognizer *)tap
{
    [self dismissMessageView];
}

- (void)dismissMessageView
{
    self.clipsToBounds = YES;
    [UIView animateWithDuration:0.7 animations:^{
        self.frame = CGRectMake(self.frame.origin.x, self.backGroundView.frame.size.height * 0.5, self.frame.size.width, 0);
        
    } completion:^(BOOL finished) {
        [self.backGroundView removeFromSuperview];
    }];
}

- (void)commonInit
{
    if (self.viewType == NXMessageViewManagerTypeGreen) {
        self.backgroundColor = RMC_MAIN_COLOR;
    }else if (self.viewType == NXMessageViewManagerTypeWhite){
        self.backgroundColor = [UIColor whiteColor];
    }
    
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:imageView];
    self.messageIcon = imageView;
    
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.numberOfLines = 1;
    titleLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
    titleLab.font = [UIFont systemFontOfSize:25.0f];
    if (self.viewType == NXMessageViewManagerTypeGreen) {
        titleLab.textColor = [UIColor whiteColor];
    }else if (self.viewType == NXMessageViewManagerTypeWhite){
        titleLab.textColor = [UIColor blackColor];;
    }

    [self addSubview:titleLab];
    self.titleLab = titleLab;
    
    UILabel *detailsLab = [[UILabel alloc] init];
    detailsLab.numberOfLines = 2;
    detailsLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
    detailsLab.textAlignment = NSTextAlignmentCenter;
    detailsLab.font = [UIFont systemFontOfSize:15.0f];
    if (self.viewType == NXMessageViewManagerTypeGreen) {
        detailsLab.textColor = [UIColor whiteColor];
    }else if (self.viewType == NXMessageViewManagerTypeWhite){
        detailsLab.textColor = [UIColor blackColor];
    }
    [self addSubview:detailsLab];
    self.detailsLab = detailsLab;
    
    UILabel *appendInfoLab = [[UILabel alloc] init];
    appendInfoLab.numberOfLines = 3;
    appendInfoLab.textAlignment = NSTextAlignmentCenter;
    appendInfoLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
    appendInfoLab.font = [UIFont systemFontOfSize:10.0f];
    if (self.viewType == NXMessageViewManagerTypeGreen) {
        appendInfoLab.textColor = [UIColor orangeColor];
    }else if (self.viewType == NXMessageViewManagerTypeWhite){
        appendInfoLab.textColor = [UIColor blackColor];
    }
    [self addSubview:appendInfoLab];
    self.appendInfoLab = appendInfoLab;
    
    UILabel *appenInfoLab2 = [[UILabel alloc] init];
    appenInfoLab2.numberOfLines = 1;
    appenInfoLab2.textAlignment = NSTextAlignmentCenter;
    appenInfoLab2.lineBreakMode = NSLineBreakByTruncatingMiddle;
    appenInfoLab2.font = [UIFont systemFontOfSize:15.0f];
    if (self.viewType == NXMessageViewManagerTypeGreen) {
        appenInfoLab2.textColor = [UIColor whiteColor];
    }else if (self.viewType == NXMessageViewManagerTypeWhite){
        appenInfoLab2.textColor = [UIColor blackColor];
    }
    [self addSubview:appenInfoLab2];
    self.appendInfoLab2 = appenInfoLab2;
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.height.equalTo(self).multipliedBy(0.38);
        make.top.equalTo(self).offset(kMargin*2);
    }];
    
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(imageView);
        make.top.equalTo(imageView.mas_bottom).offset(kMargin*0.5);
        make.left.equalTo(self).offset(kMargin);
       // make.right.equalTo(self).offset(-kMargin);
       // make.height.equalTo(@25);
    }];
    
    [detailsLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(titleLab);
        make.left.equalTo(self).offset(kMargin);
        make.top.equalTo(titleLab.mas_bottom).offset(kMargin*0.5);
        //make.right.equalTo(self).offset(-kMargin);
        //make.height.equalTo(@15);
    }];
    
    [appendInfoLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(detailsLab);
        make.left.equalTo(self).offset(kMargin);
        make.top.equalTo(detailsLab.mas_bottom).offset(kMargin*0.5);
    }];
    
    [appenInfoLab2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(detailsLab);
        make.left.equalTo(self).offset(kMargin);
        make.top.equalTo(appendInfoLab.mas_bottom).offset(kMargin*0.5);
        make.bottom.equalTo(self).offset(-kMargin * 0.5);
    }];
    
    
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutIfNeeded];
    }];
}


@end

#pragma mark - NXMessageViewManager
@interface NXMessageViewManager()


@end

@implementation NXMessageViewManager
+ (void) showMessageViewWithTitle:(NSString *)title details:(NSString *)details appendInfo:(NSString *)appendInfo image:(UIImage *)image type:(NXMessageViewManagerType)type
{
    NXMessageView *msgBox = [[NXMessageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [msgBox showWithTitle:title details:details appendInfo:appendInfo appendInfo2:nil image:image dismissAfter:-1 type:type];
}
+ (void) showMessageViewWithTitle:(NSString *)title details:(NSString *)details appendInfo:(NSString *)appendInfo image:(UIImage *)image dismissAfter:(NSTimeInterval)afterSecond type:(NXMessageViewManagerType)type
{
    NXMessageView *msgBox = [[NXMessageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [msgBox showWithTitle:title details:details appendInfo:appendInfo appendInfo2:nil image:image dismissAfter:afterSecond type:type];
}

+ (void) showMessageViewWithTitle:(NSString *)title details:(NSString *)details appendInfo:(NSString *)appendInfo appendInfo2:(NSString *)appendInfo2 image:(UIImage *)image type:(NXMessageViewManagerType)type
{
    NXMessageView *msgBox = [[NXMessageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [msgBox showWithTitle:title details:details appendInfo:appendInfo appendInfo2:appendInfo2 image:image dismissAfter:-1 type:type];
}

+ (void) showMessageViewWithTitle:(NSString *)title details:(NSString *)details appendInfo:(NSString *)appendInfo appendInfo2:(NSString *)appendInfo2 image:(UIImage *)image dismissAfter:(NSTimeInterval)afterSecond type:(NXMessageViewManagerType)type
{
    NXMessageView *msgBox = [[NXMessageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [msgBox showWithTitle:title details:details appendInfo:appendInfo appendInfo2:appendInfo2 image:image dismissAfter:afterSecond type:type];
}
@end


