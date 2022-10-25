//
//  NXSortByView.m
//  nxrmc
//
//  Created by EShi on 11/9/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXSortByView.h"
#import "NXSortByButtonRoundView.h"
#import "Masonry.h"


// SortBy button position
#define SORT_BY_BTN_HEIGHT 50
#define SORT_BY_BTN_WIDTH 125

@implementation NXSortByButtonView
- (void)setCurrentSortButtomImage:(NSString *)imageType
{
    if ([imageType isEqualToString:NSLocalizedString(@"UI_COM_SORT_OPT_NEWEST", nil)]) {
        [self setBtnImage:[UIImage imageNamed:@"sort by date - white"] forState:UIControlStateNormal];
    }
    
    if ([imageType isEqualToString:NSLocalizedString(@"UI_COM_SORT_OPT_NAME_ASC", nil)]) {
        [self setBtnImage:[UIImage imageNamed:@"A-Z - white"] forState:UIControlStateNormal];
    }
    
    if ([imageType isEqualToString:NSLocalizedString(@"UI_COM_SORT_OPT_REPO", nil)]) {
        [self setBtnImage:[UIImage imageNamed:@"sort by repo - white"] forState:UIControlStateNormal];
    }
    
    self.currentImageType = imageType;
}


@end


@class NXSortByItemView;
@protocol NXSortByItemViewDelegate <NSObject>

-(void) nxsortByItemView:(NXSortByItemView *) sortByItemView actionButtonClicked:(UIButton *)actionButton;
@end

@interface NXSortByItemView : UIView<NXRoundButtonViewDelegate>
- (instancetype) initWithTitle:(NSString *) title selectedImage:(UIImage *) selectedImage normalImage:(UIImage *) normalImage;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) NXSortByButtonRoundView *roundBtnView;
@property(nonatomic, weak) id<NXSortByItemViewDelegate> delegate;
@property(nonatomic, assign, getter=isSelected) BOOL selected;
@property(nonatomic, strong) UIImage *normalImage;
@end


@implementation NXSortByItemView

- (instancetype)initWithTitle:(NSString *) title selectedImage:(UIImage *) selectedImage normalImage:(UIImage *) normalImage
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = title;
        _titleLabel.font = [UIFont systemFontOfSize:14.0f];
        
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
       
        
        _normalImage = normalImage;
        
        [self addSubview:_titleLabel];
        
        _roundBtnView = [[NXSortByButtonRoundView alloc] initWithRadius:25];
        [_roundBtnView setBtnImage:selectedImage forState:UIControlStateSelected];
        [_roundBtnView setBtnImage:normalImage forState:UIControlStateNormal];
        [_roundBtnView setBtnBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _roundBtnView.delegate = self;
        [self addSubview:_roundBtnView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTitle:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)commonInit
{
    [self.roundBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.left.equalTo(self.mas_left);
        make.width.equalTo(self).multipliedBy(1.0f/3.0f);
        make.height.equalTo(self);
    }];
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.left.equalTo(self.roundBtnView.mas_right).offset(20);
        make.width.equalTo(self).multipliedBy(2.0f/3.0f);
        make.bottom.equalTo(self);
    }];

}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self commonInit];
}

- (BOOL)isSelected
{
    return self.roundBtnView.isSelected;
}

- (void)setSelected:(BOOL)selected
{
    self.roundBtnView.selected = selected;
}

- (void)tapTitle:(UITapGestureRecognizer *)tap
{
    [self nxroundButtonView:self.roundBtnView actionButtonClicked:self.roundBtnView.actionButton];
}
#pragma mark - NXRoundButtonViewDelegate
- (void)nxroundButtonView:(NXRoundButtonView *)roundButtonView actionButtonClicked:(UIButton *)actionButton
{
    
    if ([self.delegate respondsToSelector:@selector(nxsortByItemView:actionButtonClicked:)]) {
        [self.delegate nxsortByItemView:self actionButtonClicked:actionButton];
    }
}

- (BOOL)nxroundButtonView:(NXRoundButtonView *)roundButtonView actionButtonShouldClicked:(UIButton *)actionButton
{
    return YES;
}
@end


@interface NXSortByView()<NXSortByItemViewDelegate, CAAnimationDelegate>
@property(nonatomic, strong) NXSortByItemView *sortByNameView;
@property(nonatomic, strong) NXSortByItemView *sortByDateView;
@property(nonatomic, strong) NXSortByItemView *sortByRepoView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, assign) UIDeviceOrientation previousOrientation;
@property(nonatomic, strong) NSArray *sortByItemArray;
@end

@implementation NXSortByView
#pragma mark - Init/Dealloc
- (instancetype)initWithSortButtonView:(NXSortByButtonView *) sortByBtnView
{
    self = [super init];
    if (self) {
        _sortByBtnView = sortByBtnView;
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"SORT BY";
        _titleLabel.font = [UIFont systemFontOfSize:16.0f];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.alpha = 0.0f;
        [self addSubview:_titleLabel];
        
        _sortByDateView = [[NXSortByItemView alloc] initWithTitle:NSLocalizedString(@"UI_COM_SORT_OPT_NEWEST", nil) selectedImage:[UIImage imageNamed:@"sort by date - green"] normalImage:[UIImage imageNamed:@"sort by date - white"]];
        _sortByDateView.delegate = self;
        _sortByDateView.alpha = 0.0f;
        [self addSubview:_sortByDateView];
        
        _sortByNameView = [[NXSortByItemView alloc] initWithTitle:NSLocalizedString(@"UI_COM_SORT_OPT_NAME_ASC", nil) selectedImage:[UIImage imageNamed:@"A-Z - green"] normalImage:[UIImage imageNamed:@"A-Z - white"]];
        _sortByNameView.delegate = self;
        _sortByNameView.alpha = 0.0f;
        [self addSubview:_sortByNameView];
        
        _sortByRepoView = [[NXSortByItemView alloc] initWithTitle:NSLocalizedString(@"UI_COM_SORT_OPT_REPO", nil) selectedImage:[UIImage imageNamed:@"sort by repo - green"] normalImage:[UIImage imageNamed:@"sort by repo - white"]];
        _sortByRepoView.delegate = self;
       _sortByRepoView.alpha = 0.0f;
        [self addSubview:_sortByRepoView];
        
        _sortByItemArray = @[_sortByRepoView, _sortByNameView, _sortByDateView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseToDeviceRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
        [sortByBtnView addObserver:self forKeyPath:@"currentImageType" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.sortByBtnView removeObserver:self forKeyPath:@"currentImageType"];
}

#pragma mark - Layout
- (void)verticalLayout
{
    [_sortByRepoView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.sortByBtnView.mas_top).offset(-10.0f);
        make.left.equalTo(self.sortByBtnView.mas_left).offset(-70.0f);
        make.height.equalTo(@(SORT_BY_BTN_HEIGHT));
        make.width.equalTo(@(SORT_BY_BTN_WIDTH));
    }];
    
    [_sortByDateView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.sortByRepoView.mas_top).offset(-20.0f);
        make.left.equalTo(self.sortByRepoView.mas_left);
        make.height.equalTo(@(SORT_BY_BTN_HEIGHT));
        make.width.equalTo(@(SORT_BY_BTN_WIDTH));
    }];
    
    [_sortByNameView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.sortByDateView.mas_top).offset(-20.0f);
        make.left.equalTo(self.sortByDateView.mas_left);
        make.height.equalTo(@(SORT_BY_BTN_HEIGHT));
        make.width.equalTo(@(SORT_BY_BTN_WIDTH));
    }];

    
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.sortByNameView.mas_top).offset(-10.0f);
        make.left.equalTo(self.sortByNameView.mas_left);
        make.height.equalTo(@(SORT_BY_BTN_HEIGHT));
        make.width.equalTo(@(SORT_BY_BTN_WIDTH));
    }];
}

- (void)horizontalLayout
{
    [_sortByRepoView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.sortByBtnView.mas_top).offset(-10.0f);
        make.left.equalTo(self.sortByBtnView.mas_left).offset(-70.0f);
        make.height.equalTo(@(SORT_BY_BTN_HEIGHT));
        make.width.equalTo(@(SORT_BY_BTN_WIDTH));
    }];
    
    [_sortByDateView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.sortByRepoView.mas_bottom);
        make.right.equalTo(self.sortByRepoView.mas_left).offset(-70.0f);
        make.height.equalTo(@(SORT_BY_BTN_HEIGHT));
        make.width.equalTo(@(SORT_BY_BTN_WIDTH));
    }];
    
    [_sortByNameView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.sortByDateView.mas_bottom);
        make.right.equalTo(self.sortByDateView.mas_left).offset(-70.0f);
        make.height.equalTo(@(SORT_BY_BTN_HEIGHT));
        make.width.equalTo(@(SORT_BY_BTN_WIDTH));
    }];
    
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.sortByNameView.mas_top).offset(-10.0f);
        make.left.equalTo(self.sortByNameView.mas_left);
        make.height.equalTo(@(SORT_BY_BTN_HEIGHT));
        make.width.equalTo(@(SORT_BY_BTN_WIDTH));
    }];
}
- (void)commonInit
{
    UIDeviceOrientation curOrientation = [[UIDevice currentDevice] orientation];
 
    self.previousOrientation = curOrientation;
    if (self.previousOrientation == UIDeviceOrientationPortrait || self.previousOrientation == UIDeviceOrientationFaceUp || self.previousOrientation == UIDeviceOrientationFaceDown) {
        
        [self verticalLayout];
        
    }else if(self.previousOrientation == UIDeviceOrientationLandscapeLeft || self.previousOrientation == UIDeviceOrientationLandscapeRight  || self.previousOrientation == UIDeviceOrientationPortraitUpsideDown)
    {
        NSInteger numOfItems = 5;
        if (self.bounds.size.height >= (numOfItems * SORT_BY_BTN_HEIGHT + 100)) {
            [self verticalLayout];
        }else
        {
            [self horizontalLayout];
        }
    }
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self commonInit];
}
-(void) responseToDeviceRotate:(NSNotification *) notification
{
    [self commonInit];
}

#pragma mark Public method
- (void) setHidenSortByRepoView:(BOOL)hidden
{
    self.sortByRepoView.hidden = hidden;
}

- (void)showSortByItems
{
    CABasicAnimation *opacityAnima = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnima.fromValue = @(0.0);
    opacityAnima.toValue = @(1.0);
    opacityAnima.fillMode = kCAFillModeForwards;
    opacityAnima.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    CAKeyframeAnimation *shakeAnim = [CAKeyframeAnimation animation];
    shakeAnim.keyPath = @"transform.translation.x";
    shakeAnim.duration = 0.2;
    CGFloat delta = 10;
    shakeAnim.values = @[@0, @(delta), @0];
    shakeAnim.repeatCount = 1;
    
    CAAnimationGroup *animaGroup = [CAAnimationGroup animation];
    animaGroup.duration = 0.2f;
    animaGroup.fillMode = kCAFillModeForwards;
    animaGroup.removedOnCompletion = NO;
    animaGroup.animations = @[shakeAnim, opacityAnima];
    animaGroup.delegate = self;
    
    CAAnimationGroup *animaGroup2 = [CAAnimationGroup animation];
    animaGroup2.duration = 0.2f;
    animaGroup2.beginTime = CACurrentMediaTime() + 0.1;
    animaGroup2.fillMode = kCAFillModeForwards;
    animaGroup2.removedOnCompletion = NO;
    animaGroup2.animations = @[shakeAnim, opacityAnima];
    animaGroup2.delegate = self;
    
    CAAnimationGroup *animaGroup3 = [CAAnimationGroup animation];
    animaGroup3.duration = 0.2f;
    animaGroup3.beginTime = CACurrentMediaTime() + 0.2;
    animaGroup3.fillMode = kCAFillModeForwards;
    animaGroup3.removedOnCompletion = NO;
    animaGroup3.animations = @[shakeAnim, opacityAnima];
    animaGroup3.delegate = self;
    
    CAAnimationGroup *animaGroup4= [CAAnimationGroup animation];
    animaGroup4.duration = 0.2f;
    animaGroup4.beginTime = CACurrentMediaTime() + 0.3;
    animaGroup4.fillMode = kCAFillModeForwards;
    animaGroup4.removedOnCompletion = NO;
    animaGroup4.animations = @[shakeAnim, opacityAnima];
    animaGroup4.delegate = self;
    
    if (!self.sortByRepoView.hidden) {
         [self.sortByRepoView.layer addAnimation:animaGroup forKey:@"Animation"];
    }
   
    [self.sortByDateView.layer addAnimation:animaGroup2 forKey:@"Animation"];
    [self.sortByNameView.layer addAnimation:animaGroup3 forKey:@"Animation"];
    [self.titleLabel.layer addAnimation:animaGroup4 forKey:@"Animation"];
    
   // self.sortByNameView.alpha = 1.0f;
}

- (void)hideSortByItems
{
    self.titleLabel.alpha = 0.0f;
    self.sortByRepoView.alpha = 0.0f;
    self.sortByDateView.alpha = 0.0f;
    self.sortByNameView.alpha = 0.0f;
}

#pragma mark - KVO
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([object isEqual:self.sortByBtnView] && [keyPath isEqualToString:@"currentImageType"]) {
        NSString *imageType = change[@"new"];
        for (NXSortByItemView *view in self.sortByItemArray) {
            if (![view.titleLabel.text isEqualToString:imageType]) {
                view.selected = NO;
            }else
            {
                view.selected = YES;
            }
        }
    }
}
#pragma mark - NXSortByItemViewDelegate
-(void) nxsortByItemView:(NXSortByItemView *) sortByItemView actionButtonClicked:(UIButton *)actionButton
{
    sortByItemView.selected = YES;
    
    for (NXSortByItemView *view in self.sortByItemArray) {
        if (![view isEqual:sortByItemView]) {
            view.selected = NO;
        }
        view.alpha = 0.0f;
    }
    
    self.hidden = YES;
    
    [self.sortByBtnView setBtnImage:sortByItemView.normalImage forState:UIControlStateNormal];
    [self.sortByBtnView setSelected:NO];
    
    if ([self.delegate respondsToSelector:@selector(nxsortByView:didSelectedSortTitle:)]) {
        [self.delegate nxsortByView:self didSelectedSortTitle:sortByItemView.titleLabel.text];
    }
}

#pragma mark - Animation delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([anim isEqual:[self.sortByNameView.layer animationForKey:@"Animation"]]) {
        self.sortByNameView.alpha = 1.0f;
    }
    
    if ([anim isEqual:[self.sortByDateView.layer animationForKey:@"Animation"]]) {
        self.sortByDateView.alpha = 1.0f;
    }
    
    if ([anim isEqual:[self.sortByRepoView.layer animationForKey:@"Animation"]]) {
        self.sortByRepoView.alpha = 1.0f;
    }
}
@end
