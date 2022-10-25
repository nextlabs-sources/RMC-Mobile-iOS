//
//  NXFileOperationToolBar.m
//  CoreAnimationDemo
//
//  Created by EShi on 11/3/16.
//  Copyright © 2016 Eren. All rights reserved.
//

#import "NXFileOperationToolBar.h"
#import "UIView+UIExt.h"


#define BTN_CORNER 5.0

@interface NXFileOperationToolBar()
@property(nonatomic, strong) NSArray *viewArray;
@property(nonatomic, strong) UIButton *btnFav;
@property(nonatomic, strong) UIButton *btnOffline;
@property(nonatomic, strong) UIButton *btnProtect;
@property(nonatomic, strong) UIButton *btnShare;
@property(nonatomic, strong) UIView *shadowView;
@end

@implementation NXFileOperationToolBar
- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _btnFav = [[UIButton alloc] init];
        _btnFav.translatesAutoresizingMaskIntoConstraints = NO;
        _btnFav.tag = kFavorite;
        [_btnFav addTarget:self action:@selector(fileOperationBtnSelected:) forControlEvents:UIControlEventTouchUpInside];
        [_btnFav setBackgroundImage:[UIImage imageNamed:@"favSel"] forState:UIControlStateSelected];
        [_btnFav setBackgroundImage:[UIImage imageNamed:@"favUnSel"] forState:UIControlStateNormal];
        [_btnFav setAdjustsImageWhenHighlighted:NO];
        
        [self addSubview:_btnFav];
        
        
        _btnOffline = [[UIButton alloc] init];
        _btnOffline.translatesAutoresizingMaskIntoConstraints = NO;
        _btnOffline.tag = kOffline;
        [_btnOffline addTarget:self action:@selector(fileOperationBtnSelected:) forControlEvents:UIControlEventTouchUpInside];
        [_btnOffline setBackgroundImage:[UIImage imageNamed:@"offlineSel"] forState:UIControlStateSelected];
        [_btnOffline setBackgroundImage:[UIImage imageNamed:@"offlineUnSel"] forState:UIControlStateNormal];
        [_btnOffline setAdjustsImageWhenHighlighted:NO];
        
        [self addSubview:_btnOffline];
        
        _btnProtect = [[UIButton alloc] init];
        _btnProtect.translatesAutoresizingMaskIntoConstraints = NO;
        _btnProtect.backgroundColor = [UIColor yellowColor];
        _btnProtect.tag = kProtect;
        [_btnProtect setBackgroundImage:[UIImage imageNamed:@"protect"] forState:UIControlStateNormal];
        [_btnProtect addTarget:self action:@selector(fileOperationBtnSelected:) forControlEvents:UIControlEventTouchUpInside];
        [_btnProtect setAdjustsImageWhenHighlighted:NO];
        [_btnProtect cornerRadian:BTN_CORNER];
        [self addSubview:_btnProtect];

        _btnShare = [[UIButton alloc] init];
        _btnShare.translatesAutoresizingMaskIntoConstraints = NO;
        _btnShare.backgroundColor = [UIColor blueColor];
        _btnShare.tag = kShare;
        [_btnShare setAdjustsImageWhenHighlighted:NO];
        [_btnShare cornerRadian:BTN_CORNER];
        
        [_btnShare addTarget:self action:@selector(fileOperationBtnSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_btnShare];
        
        
        _viewArray = @[_btnFav, _btnOffline, _btnProtect, _btnShare];
        _toolBarVisible = YES;


    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    NSDictionary *viewDict = @{@"btnFav":_btnFav, @"btnOffline":_btnOffline, @"btnProtect":_btnProtect, @"btnShare":_btnShare};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[btnFav(50)][btnOffline(btnFav)]-[btnProtect(50)]-[btnShare]|" options:0 metrics:nil views:viewDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[btnFav]|" options:0 metrics:nil views:viewDict]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[btnOffline]|" options:0 metrics:nil views:viewDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[btnProtect]|" options:0 metrics:nil views:viewDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[btnShare]|" options:0 metrics:nil views:viewDict]];

}

- (void) disappearToolBar
{
    if (self.isToolBarVisible == YES) {
        [self disappearItem:0];
    }
}

- (void) disappearItem:(NSInteger) index
{
    if (index >= self.viewArray.count) {
        self.toolBarVisible = NO;
        return;
    }
    __weak typeof(self) weakSelf = self;
    UIButton *button = self.viewArray[index];
    [UIView animateWithDuration:0.05 animations:^{
        button.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            NSInteger nextIndex = index + 1;
            [strongSelf disappearItem:nextIndex];
        }
    }];
}

- (void) showToolBar
{
    if (self.isToolBarVisible == NO) {
        [self showItem:0];
    }
}

- (void) showItem:(NSInteger) index
{
    if (index >= self.viewArray.count) {
        self.toolBarVisible = YES;
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    UIButton *button = self.viewArray[index];
    [UIView animateWithDuration:0.05 animations:^{
        button.alpha = 1.0;
    } completion:^(BOOL finished) {
        if (finished) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            NSInteger nextIndex = index + 1;
            [strongSelf showItem:nextIndex];
        }
    }];
}

- (void) fileOperationBtnSelected:(UIButton *) button
{
    [button setSelected:!button.isSelected];
    
    if ([self.delegate respondsToSelector:@selector(fileOperationToolBar:didSelectItem:)]) {
        [self.delegate fileOperationToolBar:self didSelectItem:button.tag];
    }
}
@end
