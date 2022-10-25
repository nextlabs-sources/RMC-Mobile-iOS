//
//  NXEditWatermarkView.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 15/11/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXEditWatermarkView.h"
#import "NXProjectInviteMemberView.h"
#import "NXWaterMarkView.h"
#import "NXRMCDef.h"
#import "NXDefine.h"
#import "Masonry.h"
#import "UIView+NXExtension.h"
#import "UIView+UIExt.h"
@interface NXEditWatermarkView ()<NXWaterMarkViewDelegate>
@property (nonatomic,retain) UILabel *titleLabel;
@property (nonatomic,strong) UIButton *okButton;
@property (nonatomic,strong) UIView *containerView;
@property (nonatomic,strong) NXWaterMarkView *watermarkView;
@property (nonatomic,strong) NXCustomAlertWindow *alertWindow;
@property (nonatomic, strong) NXCustomAlertWindowRootViewController *rootVC;

@property (nonatomic,assign) BOOL keyBoardIsShow;

@property (nonatomic,assign) CGFloat keyboardHeight;
@end
@implementation NXEditWatermarkView

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc]init];
        _containerView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_containerView];
    }
    return _containerView;
}
- (NXCustomAlertWindow *)alertWindow {
    if (!_alertWindow) {
        _alertWindow = [[NXCustomAlertWindow alloc] initWithFrame:NXMainScreenBounds];
        _alertWindow.alpha = 1.0;
        _alertWindow.rootViewController = _rootVC;
    }
    return _alertWindow;
}

- (void)show {
    
    self.containerView.layer.shouldRasterize = YES;
    _containerView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    UIScrollView *bgScrollView = [[UIScrollView alloc]init];
    bgScrollView.contentSize = CGSizeMake(0, 350);
    [_containerView addSubview:bgScrollView];
    
    UIView *headView = [[UIView alloc] init];
    
    UIButton *crossButton = [[UIButton alloc] init];
    crossButton.backgroundColor = [UIColor clearColor];
    crossButton.contentMode =  UIViewContentModeBottom;
    [crossButton setImage:[UIImage imageNamed:@"Close"] forState:UIControlStateNormal];
    [crossButton addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    crossButton.imageEdgeInsets = UIEdgeInsetsMake(2,0, 0, 0);
    UILabel *titleLabel = [[UILabel alloc] init];
    
    titleLabel.text = @"Edit watermark";
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel = titleLabel;
    
    UIButton *okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [okButton setTitle:@"Save" forState:UIControlStateNormal];
    okButton.contentMode = UIViewContentModeLeft;
    [okButton setTitleColor:[UIColor colorWithRed:0 green:122/255.0 blue:1 alpha:1] forState:UIControlStateNormal];
    okButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [okButton addTarget:self action:@selector(okBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.okButton = okButton;
    [headView addSubview:crossButton];
    [headView addSubview:titleLabel];
    [headView addSubview:okButton];
    [bgScrollView addSubview:headView];
    
    
//    UILabel *editLabel = [[UILabel alloc]init];
//    editLabel.text = @"Edit Watermark";
//    editLabel.font = [UIFont boldSystemFontOfSize:20];
//    [bgScrollView addSubview:editLabel];
    
    UILabel *lineLabel = [[UILabel alloc]init];
    lineLabel.backgroundColor = [UIColor grayColor];
    [bgScrollView addSubview:lineLabel];
    
    NXWaterMarkView *watermarkView = [[NXWaterMarkView alloc]init];
    [bgScrollView addSubview:watermarkView];
    watermarkView.delegate = self;
    watermarkView.origialWaterMarks = self.waterMarks;
    self.watermarkView = watermarkView;
//    UIButton *cancelBtn = [[UIButton alloc]init];
//    [cancelBtn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    cancelBtn.backgroundColor = [UIColor colorWithRed:189.0/255.0 green:189.0/255.0 blue:189.0/255.0 alpha:1.0];
//    [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
//    [bgScrollView addSubview:cancelBtn];
//    [cancelBtn cornerRadian:3];
//    UIButton *okBtn = [[UIButton alloc]init];
//    [okBtn setTitle:@"OK" forState:UIControlStateNormal];
//    [okBtn addTarget:self action:@selector(okBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    okBtn.backgroundColor = [UIColor colorWithRed:73.0/255.0 green:160.0/255.0 blue:84.0/255.0 alpha:1.0];
//    [bgScrollView addSubview:okBtn];
//    [okBtn cornerRadian:3];
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [self.alertWindow.rootViewController.view addSubview:self];
    [self.alertWindow makeKeyAndVisible];
    
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [self mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_alertWindow.rootViewController.view.mas_safeAreaLayoutGuideTop);
                make.bottom.equalTo(_alertWindow.rootViewController.view.mas_safeAreaLayoutGuideBottom);
                make.leading.equalTo(_alertWindow.rootViewController.view.mas_safeAreaLayoutGuideLeading);
                make.trailing.equalTo(_alertWindow.rootViewController.view.mas_safeAreaLayoutGuideTrailing);
            }];
        }
    }
    else
    {
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_alertWindow.rootViewController.view);
            make.bottom.equalTo(_alertWindow.rootViewController.view);
            make.leading.equalTo(_alertWindow.rootViewController.view);
            make.trailing.equalTo(_alertWindow.rootViewController.view);
        }];
    }
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(10);
        make.trailing.equalTo(self).offset(-10);
        make.height.equalTo(self).multipliedBy(0.55);
        make.top.equalTo(self).offset(10);
    }];
    [bgScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.containerView);
    }];
    [headView mas_makeConstraints:^(MASConstraintMaker *make) {
         make.top.equalTo(bgScrollView);
        make.left.equalTo(bgScrollView).offset(10);
        make.right.equalTo(self.containerView).offset(-10);
       
        make.height.equalTo(@35);
    }];
    [lineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(headView.mas_bottom);
        make.height.equalTo(@1);
    }];
    [watermarkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineLabel.mas_bottom).offset(5);
        make.left.right.equalTo(headView);
        make.height.equalTo(@260);
    }];
    
    [crossButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headView).offset(5);
        make.left.equalTo(headView).offset(5);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
    }];
    [okButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(crossButton);
        make.right.equalTo(headView).offset(-5);
        make.width.equalTo(@40);
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(headView);
        make.height.equalTo(headView);
    }];
    
//    [okBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(watermarkView.mas_bottom).offset(5);
//        make.right.equalTo(watermarkView);
//        make.width.equalTo(@80);
//        make.height.equalTo(@30);
//    }];
//    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.width.height.equalTo(okBtn);
//        make.right.equalTo(okBtn.mas_left).offset(-10);
//        make.bottom.equalTo(bgScrollView.mas_bottom).offset(-15);
//    }];
    _containerView.layer.opacity = 0.5f;
    _containerView.layer.transform = CATransform3DMakeScale(1.3f, 1.3f, 1.0);
    
    [UIView animateWithDuration:0.1f delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3f];
                         _containerView.layer.opacity = 1.0f;
                         _containerView.layer.transform = CATransform3DMakeScale(1, 1, 1);
                     }
                     completion:nil
     ];
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        _rootVC = [[NXCustomAlertWindowRootViewController alloc] init];
    }
    return self;
}
- (instancetype)initWithInviteHander:(onOkClickHandle)hander {
    _onOkClickHandle = hander;
    return [self init];
}
- (instancetype)initWithWatermarks:(NSArray *)watermarks InviteHander:(onOkClickHandle)hander {
    _onOkClickHandle = hander;
    self.waterMarks = watermarks;
    return [self init];
}
- (void)cancelBtnClick:(id)sender {
    self.alertWindow.alpha = 0;
    [self.alertWindow removeFromSuperview];
    self.alertWindow.rootViewController = nil;
    self.alertWindow = nil;
    [self hd_removeAllSubviews];
    [self removeFromSuperview];
    
    [NXFirstWindow makeKeyAndVisible];
}
- (void)okBtnClick:(id)sender {
    NSArray *textViewWatermarks = [self.watermarkView getTheWaterMarkValuesFromTextViewUI];
    if (self.onOkClickHandle) {
        self.onOkClickHandle(textViewWatermarks);
    }
    [self cancelBtnClick:nil];
}
- (void)watermarkViewTextDidChange:(BOOL)isValid {
    if (isValid) {
        self.okButton.enabled = YES;
        [self.okButton setTitleColor:[UIColor colorWithRed:0 green:122/255.0 blue:1 alpha:1] forState:UIControlStateNormal];
    }else{
        self.okButton.enabled = NO;
        [self.okButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    
}
@end
