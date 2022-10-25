//
//  NXAlertView.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 27/04/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXAlertView.h"
#import "UIView+NXExtension.h"
#import "UIImage+NXExtension.h"
#import "NSString+NXExtension.h"
#import "Masonry.h"

NSString *const NXAlertViewWillShowNotification     = @"NXAlertViewWillShowNotification";
NSString *const NXAlertViewDidShowNotification      = @"NXAlertViewDidShowNotification";
NSString *const NXAlertViewWillDismissNotification  = @"NXAlertViewWillDismissNotification";
NSString *const NXAlertViewDidDismissNotification   = @"NXAlertViewDidDismissNotification";

const static CGFloat NXCrossButtonWidth                    = 50;
const static CGFloat NXCrossButtonHeight                   = 50;

const static CGFloat NXTitleLabelHeight                   = 22;
const static CGFloat NXTitleLabelTopMargin                = 20;
const static CGFloat NXMessageLabelHeight                 = 20;
const static CGFloat NXTableViewTopMarginMessageLabel     = 10;



#pragma mark - NXAlertItem
@interface NXAlertItem : NSObject

/** item title */
@property (nonatomic, copy) NSString *title;
/** item style */
@property (nonatomic, assign) NXAlertViewItemType itemType;
/** item click Event */
@property (nonatomic,copy) NXAlertViewHandler handler;

@end


@implementation NXAlertItem

@end

#pragma mark - NXAlertWindow
@interface NXAlertWindow : UIWindow

/** Alert Background Style */
@property (nonatomic, assign) NXAlertViewBackgroundStyle style;

@end


@implementation NXAlertWindow

- (instancetype)initWithFrame:(CGRect)frame andStyle:(NXAlertViewBackgroundStyle)style {
    if (self = [super initWithFrame:frame]) {
        self.style = style;
        self.opaque = NO;
        self.windowLevel = 1999.0; // 不重叠系统的Alert, Alert的层级.
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    switch (self.style) {
        case NXAlertViewBackgroundStyleGradient: {
            size_t locationsCount = 2; // unsigned long
            CGFloat locations[2] = {0.0f, 1.0f};
            CGFloat colors[8] = {0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.75f};
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
            CGColorSpaceRelease(colorSpace);
            
            CGPoint center = CGPointMake(self.hd_width * 0.5, self.hd_height * 0.5);
            CGFloat radius = MIN(self.hd_width, self.hd_height) ;
            CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
            CGGradientRelease(gradient);
            break;
        }
            
        case NXAlertViewBackgroundStyleSolid: {
            [[UIColor colorWithWhite:0 alpha:0.66] set];
            CGContextFillRect(context, self.bounds);
            break;
        }
    }
}

@end

#pragma mark - NXAlertWindow rootViewController

@interface NXAlertWindowRootViewController : UIViewController
@end

@implementation NXAlertWindowRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


#pragma mark - NXAlertView
@interface NXAlertView ()<UITableViewDelegate,UITableViewDataSource,CAAnimationDelegate,UIGestureRecognizerDelegate>

/** 是否动画 */
@property (nonatomic, assign, getter = isAlertAnimating) BOOL alertAnimating;
/** 是否可见 */
@property (nonatomic, assign, getter = isVisible) BOOL visible;
/** 标题 */
@property (nonatomic, weak) UILabel *titleLabel;
/** 消息描述 */
@property (nonatomic, weak) UILabel *messageLabel;
/** 叉号按钮 */
@property (nonatomic, strong) UIButton *crossButton;
/** 容器视图 */
@property (nonatomic, weak) UIView *containerView;
/** 存放行动items */
@property (nonatomic, strong) NSMutableArray *items;
/** 展示的背景Window */
@property (nonatomic, strong) NXAlertWindow *alertWindow;

@property (nonatomic,strong) UITableView *contentTableView;

@property (nonatomic, strong) NXAlertWindowRootViewController *rooVC;

@property (nonatomic, assign) CGFloat containerViewHeight;


@end


@implementation NXAlertView

+ (void)initialize {
    if (self != [NXAlertView class]) return;
    
    NXAlertView *appearance = [self appearance];
    appearance.viewBackgroundColor = [UIColor whiteColor];
    appearance.titleColor = [UIColor blackColor];
    appearance.messageColor = [UIColor blackColor];
    appearance.titleFont = [UIFont systemFontOfSize:18.0];
    appearance.messageFont = [UIFont systemFontOfSize:16.0];
    appearance.cornerRadius = 10.0;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.frame = NXMainScreenBounds;
        [self setUpSubviews];
        _rooVC = [[NXAlertWindowRootViewController alloc] init];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapBackground:)];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationWillChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:_containerView]) {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)alertViewWithTitle:(NSString *)title andMessage:(NSString *)message {
    return [[self alloc] initWithTitle:title andMessage:message];
}

- (instancetype)initWithTitle:(NSString *)title andMessage:(NSString *)message {
    NXAlertView *alertView = [[[self class] alloc] init];
    
    alertView.title = title;
    alertView.message = message;
    alertView.items = [[NSMutableArray alloc] init];
    
    return alertView;
}

- (void)addItemWithTitle:(NSString *)title type:(NXAlertViewItemType)type handler:(NXAlertViewHandler)handler
{
    NXAlertItem *item = [[NXAlertItem alloc] init];
    
    item.title = title;
    item.itemType = type;
    item.handler = handler;
    [self.items addObject:item];
}

- (void)show {
    if (self.isVisible) return;
    if (self.isAlertAnimating) return;
    
    weakSelf(weakSelf)
    if (self.willShowHandler) {
        self.willShowHandler(weakSelf);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NXAlertViewWillShowNotification object:self userInfo:nil];
    
    self.visible = YES;
    self.alertAnimating = YES;
    
    [self.alertWindow.rootViewController.view addSubview:self];
    [self.alertWindow makeKeyAndVisible];
    
    CGFloat originalContainerViewHeight = (self.items.count *45) + NXTitleLabelHeight + NXTitleLabelTopMargin + NXMessageLabelHeight + NXTableViewTopMarginMessageLabel;
    
    CGFloat containerViewHeight = originalContainerViewHeight;
    if (NXMainScreenHeight - originalContainerViewHeight - 100 < 0) {
        containerViewHeight = NXMainScreenHeight - 150;
    }
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_alertWindow);
        make.bottom.equalTo(_alertWindow);
        make.leading.equalTo(_alertWindow);
        make.trailing.equalTo(_alertWindow);
    }];
    
    [_crossButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).offset(-25);
        make.width.equalTo(@(NXCrossButtonWidth));
        make.height.equalTo(@(NXCrossButtonHeight));
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_containerView).offset(NXTitleLabelTopMargin);
        make.leading.equalTo(_containerView);
        make.trailing.equalTo(_containerView);
        make.width.equalTo(_containerView);
        make.height.equalTo(@(NXTitleLabelHeight));
    }];
    
    if (_messageLabel.text.length > 0)
    {
        [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_titleLabel).offset(NXTitleLabelHeight);
            make.leading.equalTo(_containerView);
            make.trailing.equalTo(_containerView);
            make.width.equalTo(_containerView);
            make.height.equalTo(@(NXMessageLabelHeight));
        }];
        
        [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_messageLabel).offset(30);
            make.leading.equalTo(_containerView);
            make.trailing.equalTo(_containerView);
            make.width.equalTo(_containerView);
            make.bottom.equalTo(_containerView);
        }];
    }
    else
    {
        containerViewHeight = containerViewHeight - 20;
        originalContainerViewHeight = originalContainerViewHeight - 20;
        [_contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_titleLabel).offset(32);
            make.leading.equalTo(_containerView);
            make.trailing.equalTo(_containerView);
            make.width.equalTo(_containerView);
            make.bottom.equalTo(_containerView);
        }];
    }
    
    CGFloat horizontalMargin = 15.0;
    // 真机才有效,模拟器统一是25.0
    if ([[NSString hd_deviceType] isEqualToString:iPhone6]) {
        horizontalMargin = 15.0;
    }
    
    if ([[NSString hd_deviceType] isEqualToString:iPhone6Plus]) {
        horizontalMargin = 15.0;
    }
    
    CGFloat containerViewW = (NXMainScreenWidth - horizontalMargin * 2);

    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.equalTo(@(containerViewW));
        make.height.equalTo(@(containerViewHeight));
        make.bottom.equalTo(_crossButton).offset(-75);
    }];
    
    //_titleLabel.backgroundColor = [UIColor redColor];
   // _contentTableView.backgroundColor = [UIColor purpleColor];
    //_containerView.backgroundColor = [UIColor grayColor];
    _containerViewHeight = originalContainerViewHeight;
    
    [self transitionInCompletion:^{
        if (weakSelf.didShowHandler) {
            weakSelf.didShowHandler(weakSelf);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NXAlertViewDidShowNotification object:weakSelf userInfo:nil];
        
        weakSelf.alertAnimating = NO;
    }];
}

- (void)dismissAnimated:(BOOL)animated {
    [self dismissAnimated:animated cleanup:YES];
}

/**
 *  撤销弹窗提示
 *
 *  @param animated 是否动画
 *  @param cleanup  是否清除
 */
- (void)dismissAnimated:(BOOL)animated cleanup:(BOOL)cleanup {
    BOOL isVisible = self.isVisible;
    
    weakSelf(weakSelf)
    if (self.isVisible) {
        if (self.willDismissHandler) {
            self.willDismissHandler(weakSelf);
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NXAlertViewWillDismissNotification object:self userInfo:nil];
    }
    
    void (^dismissComplete)(void) = ^{
       
        weakSelf.visible = NO;
        weakSelf.alertAnimating =  NO;
        
        if (isVisible) {
            if (weakSelf.didDismissHandler) {
                weakSelf.didDismissHandler(weakSelf);
            }
            
        // [[NSNotificationCenter defaultCenter] postNotificationName:NXAlertViewDidDismissNotification object:weakSelf userInfo:nil];
        }
    };
    
    if (animated && isVisible) {
        self.alertAnimating =  YES;
        [self removeView];
        [self transitionOutCompletion:dismissComplete];
        
    } else {
        dismissComplete();
    }
}


#pragma mark - Transitions动画
/**
 *  进入的动画
 */
- (void)transitionInCompletion:(void(^)(void))completion {
    switch (self.transitionStyle) {
        case NXAlertViewTransitionStyleFade: {
            self.containerView.alpha = 0;
            self.crossButton.alpha = 0;
            
            [UIView animateWithDuration:0.3 animations:^{
                self.containerView.alpha = 1;
                self.crossButton.alpha = 1;
            } completion:^(BOOL finished) {
                if (completion) {
                    completion();
                }
            }];
            break;
        }
            
        case NXAlertViewTransitionStyleSlideFromTop: {
            CGRect rect = self.containerView.frame;
            CGRect originalRect = rect;
            rect.origin.y = -rect.size.height;
            self.containerView.frame = rect;
            
            CGRect rect1 = self.crossButton.frame;
            CGRect originalRect1 = rect1;
            rect1.origin.y = -rect1.size.height;
            self.crossButton.frame = rect1;
            
            [UIView animateWithDuration:0.3 animations:^{
                self.containerView.frame = originalRect;
                 self.containerView.frame = originalRect1;
            } completion:^(BOOL finished) {
                if (completion) {
                    completion();
                }
            }];
            break;
        }
            
        case NXAlertViewTransitionStyleSlideFromBottom: {
            CGRect rect = self.containerView.frame;
            CGRect originalRect = rect;
            rect.origin.y = self.hd_height;
            self.containerView.frame = rect;
            
            CGRect crossBtnrect = self.crossButton.frame;
            CGRect originalCrossBtnRect = crossBtnrect;
            crossBtnrect.origin.y = self.hd_height;
            self.crossButton.frame = crossBtnrect;
            
            [UIView animateWithDuration:0.1 animations:^{
                self.containerView.frame = originalRect;
                self.crossButton.frame = originalCrossBtnRect;
            } completion:^(BOOL finished) {
                if (completion) {
                    completion();
                }
            }];
            break;
        }
            
        case NXAlertViewTransitionStyleBounce: {
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
            animation.values = @[@(0.01), @(1.2), @(0.9), @(1)];
            animation.keyTimes = @[@(0), @(0.4), @(0.6), @(1)];
            animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
            animation.duration = 0.5;
            animation.delegate = self;
            [animation setValue:completion forKey:@"handler"];
            [self.containerView.layer addAnimation:animation forKey:@"bouce"];
            [self.crossButton.layer addAnimation:animation forKey:@"bouce"];
            break;
        }
            
        case NXAlertViewTransitionStyleDropDown: {
            CGFloat y = self.containerView.center.y;
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
            animation.values = @[@(y - self.bounds.size.height), @(y + 20), @(y - 10), @(y)];
            animation.keyTimes = @[@(0), @(0.5), @(0.75), @(1)];
            animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
            animation.duration = 0.4;
            animation.delegate = self;
            [animation setValue:completion forKey:@"handler"];
            
            CGFloat y1 = self.crossButton.center.y;
            CAKeyframeAnimation *animation1 = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
            animation1.values = @[@(y1 - self.bounds.size.height), @(y1 + 20), @(y1 - 10), @(y1)];
            animation1.keyTimes = @[@(0), @(0.5), @(0.75), @(1)];
            animation1.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
            animation1.duration = 0.4;
            animation1.delegate = self;
            [animation1 setValue:completion forKey:@"handler"];
            
            [self.containerView.layer addAnimation:animation forKey:@"dropdown"];
            [self.crossButton.layer addAnimation:animation1 forKey:@"dropdown"];
            break;
        }
            
        default:
            break;
    }
}

/**
 *  消失的动画
 */
- (void)transitionOutCompletion:(void(^)(void))completion {
    switch (self.transitionStyle) {
        case NXAlertViewTransitionStyleSlideFromBottom: {
            CGRect rect = self.containerView.frame;
            rect.origin.y = self.hd_height;
            
            CGRect crossBtnrect = self.crossButton.frame;
            crossBtnrect.origin.y = self.hd_height;
            
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.crossButton.frame = crossBtnrect;
                self.containerView.frame = rect;
               
            } completion:^(BOOL finished) {
                if (completion) {
                    completion();
                }
            }];
            break;
        }
            
        case NXAlertViewTransitionStyleSlideFromTop: {
            CGRect rect = self.containerView.frame;
            rect.origin.y = -rect.size.height;
            
            CGRect rect1 = self.crossButton.frame;
            rect1.origin.y = -rect1.size.height;
            
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.containerView.frame = rect;
                self.crossButton.frame = rect1;
            } completion:^(BOOL finished) {
                if (completion) {
                    completion();
                }
            }];
            break;
        }
            
        case NXAlertViewTransitionStyleFade: {
            [UIView animateWithDuration:0.25 animations:^{
                self.containerView.alpha = 0;
                self.crossButton.alpha = 0;
            } completion:^(BOOL finished) {
                if (completion) {
                    completion();
                }
            }];
            break;
        }
            
        case NXAlertViewTransitionStyleBounce: {
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
            animation.values = @[@(1), @(1.2), @(0.01)];
            animation.keyTimes = @[@(0), @(0.4), @(1)];
            animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
            animation.duration = 0.35;
            animation.delegate = self;
            [animation setValue:completion forKey:@"handler"];
            [self.containerView.layer addAnimation:animation forKey:@"bounce"];
            
            self.containerView.transform = CGAffineTransformMakeScale(0.01, 0.01);
            self.crossButton.transform = CGAffineTransformMakeScale(0.01, 0.01);
            break;
        }
            
        case NXAlertViewTransitionStyleDropDown: {
            CGPoint point = self.containerView.center;
            CGPoint point1 = self.crossButton.center;
            point.y += self.hd_height;
            point1.y += self.hd_height;
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.containerView.center = point;
                self.crossButton.center = point1;
                CGFloat angle = ((CGFloat)arc4random_uniform(100) - 50.f) / 100.f;
                self.containerView.transform = CGAffineTransformMakeRotation(angle);
            } completion:^(BOOL finished) {
                if (completion) {
                    completion();
                }
            }];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - Configure UI
- (void)setUpSubviews {
    /** Container View */
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor whiteColor];
    containerView.layer.cornerRadius = self.cornerRadius;
    containerView.layer.masksToBounds = YES;
    [self addSubview:containerView];
    self.containerView = containerView;
    
    /** Title */
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    //titleLabel.backgroundColor = [UIColor yellowColor];
    titleLabel.font = self.titleFont;
    titleLabel.textColor = self.titleColor;
    titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [self.containerView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    /** Message Description */
    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    //messageLabel.backgroundColor = [UIColor redColor];
    messageLabel.font = self.messageFont;
    messageLabel.font = [UIFont systemFontOfSize:16.0];
    messageLabel.textColor = self.messageColor;
    messageLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
   
    
    /** Cross Button */
    UIButton *crossButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [crossButton setFrame:CGRectMake(0, 0, NXCrossButtonWidth, NXCrossButtonHeight)];
    crossButton.layer.cornerRadius = 0.5*crossButton.bounds.size.width;
    crossButton.backgroundColor = [UIColor clearColor];
    [crossButton setImage:[UIImage imageNamed:@"Cancel White"] forState:UIControlStateNormal];

    [crossButton addTarget:self action:@selector(crossBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UITableView *contentTableView = [[UITableView alloc] init];
    contentTableView.rowHeight = 45;
    contentTableView.sectionFooterHeight = 0.1;
    contentTableView.sectionHeaderHeight = 0.1;
    contentTableView.scrollEnabled = YES;
    contentTableView.showsVerticalScrollIndicator = YES;
    contentTableView.userInteractionEnabled = YES;
    contentTableView.bounces = YES;
    contentTableView.layer.cornerRadius = 10.0;
    contentTableView.delegate = self;
    contentTableView.dataSource = self;
    contentTableView.cellLayoutMarginsFollowReadableWidth = NO;
    [contentTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"buttonItemCell"];
    self.contentTableView = contentTableView;
    
    self.crossButton = crossButton;
    [self.containerView addSubview:messageLabel];
    [self.containerView addSubview:contentTableView];
    [self addSubview:_crossButton];
    self.messageLabel = messageLabel;
}

/**
 *  crossButton Event
 */
- (void)crossBtnClick:(id)sender
{
    [self dismissAnimated:YES];
}

/**
 *  init alertWindow
 */
- (NXAlertWindow *)alertWindow {
    if (!_alertWindow) {
        _alertWindow = [[NXAlertWindow alloc] initWithFrame:NXMainScreenBounds andStyle:self.backgroundStyle];
        _alertWindow.alpha = 1.0;
        _alertWindow.rootViewController = _rooVC;
    }
    
    return _alertWindow;
}

/**
 *  remove Window
 */
- (void)removeView {
    self.alertWindow.alpha = 0;
    [self.alertWindow removeFromSuperview];
    self.alertWindow = nil;
    [self hd_removeAllSubviews];
    [self removeFromSuperview];
    
    [NXFirstWindow makeKeyAndVisible];
}

- (void)onTapBackground:(id)sender
{
    [self removeView];
}

#pragma mark - 动画的代理
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    void(^completion)(void) = [anim valueForKeyPath:@"handler"];
    
    if (completion) {
        completion();
    }
}

#pragma -mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    if (section == 0) {
        view.backgroundColor = [UIColor whiteColor];
    } else {
        view.backgroundColor = [UIColor whiteColor];
    }
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"buttonItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NXAlertItem *obj = [_items objectAtIndex:indexPath.row];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = obj.title;
    cell.textLabel.font = [UIFont systemFontOfSize:[UIFont buttonFontSize]];
    
    if (obj.itemType == NXAlertViewItemTypeDestructive ) {
        cell.textLabel.textColor = [UIColor colorWithRed:235.0/255.0 green:87.0/255.0 blue:87.0/255.0 alpha:1.0];
    }
    else if (obj.itemType == NXAlertViewItemTypeClickForbidden){
          cell.textLabel.textColor = [UIColor lightGrayColor];
    }else{
        cell.textLabel.textColor = [UIColor colorWithRed:47.0/255.0 green:128.0/255.0 blue:237.0/255.0 alpha:1.0];
    }
    
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NXAlertItem *obj = [_items objectAtIndex:indexPath.row];
    if (obj.itemType == NXAlertViewItemTypeClickForbidden) {
        return;
    }
    
    [self dismissAnimated:YES];
    
    if (obj.handler) {
        obj.handler(self);
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 1.0)];
    
    horizontalLine.backgroundColor = NXColor(225, 225, 225);
    
    return horizontalLine;
}

// divide line from left
-(void)viewDidLayoutSubviews
{
    if ([self.contentTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [self.contentTableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.contentTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [self.contentTableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


#pragma mark - setter方法
- (void)setTitle:(NSString *)title {
    if (_title == title) return;
    
    _title = title;
    self.titleLabel.text = title;
}

- (void)setMessage:(NSString *)message {
    if (_message == message) return;
    
    _message = message;
    self.messageLabel.text = message;
}

- (void)setViewBackgroundColor:(UIColor *)viewBackgroundColor {
    if (_viewBackgroundColor == viewBackgroundColor) return;
    
    _viewBackgroundColor = viewBackgroundColor;
    self.containerView.backgroundColor = viewBackgroundColor;
}

- (void)setTitleFont:(UIFont *)titleFont {
    if (_titleFont == titleFont) return;
    
    _titleFont = titleFont;
    self.titleLabel.font = titleFont;
}

- (void)setMessageFont:(UIFont *)messageFont {
    if (_messageFont == messageFont) return;
    
    _messageFont = messageFont;
    self.messageLabel.font = messageFont;
}

- (void)setTitleColor:(UIColor *)titleColor {
    if (_titleColor == titleColor) return;
    
    _titleColor = titleColor;
    self.titleLabel.textColor = titleColor;
}

- (void)setMessageColor:(UIColor *)messageColor {
    if (_messageColor == messageColor) return;
    
    _messageColor = messageColor;
    self.messageLabel.textColor = messageColor;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    if (_cornerRadius == cornerRadius) return;
    
    _cornerRadius = cornerRadius;
    self.containerView.layer.cornerRadius = cornerRadius;
}

#pragma -mark Count Dialog Size And Screen Size  Method

- (CGSize)countContainerViewSize
{
    CGFloat dialogWidth = _containerView.frame.size.width;
    CGFloat dialogHeight = _containerView.frame.size.height;
    
    return CGSizeMake(dialogWidth, dialogHeight);
}

- (void)deviceOrientationWillChange:(NSNotification *)notification
{
    CGSize containerViewSize = [self countContainerViewSize];
    CGFloat containerViewHeight = containerViewSize.height;
    
    CGFloat horizontalMargin = 15.0;
    // 真机才有效,模拟器统一是25.0
    if ([[NSString hd_deviceType] isEqualToString:iPhone6]) {
        horizontalMargin = 15.0;
    }
    
    if ([[NSString hd_deviceType] isEqualToString:iPhone6Plus]) {
        horizontalMargin = 15.0;
    }
    
    CGFloat containerViewW = (NXMainScreenWidth - horizontalMargin * 2);
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        
        if (containerViewHeight > NXMainScreenHeight - 150) {
            containerViewHeight = NXMainScreenHeight - 150;
        }
        
        [_containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.width.equalTo(@(containerViewW));
            make.height.equalTo(@(containerViewHeight));
            make.bottom.equalTo(_crossButton).offset(-75);
        }];
    }
    else
    {
        [_containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.width.equalTo(@(containerViewW));
            make.height.equalTo(@(_containerViewHeight));
            make.bottom.equalTo(_crossButton).offset(-75);
        }];
        
        //_containerView.backgroundColor = [UIColor redColor];
        //[_contentTableView  setBackgroundColor:[UIColor clearColor]];
    }
}

@end
