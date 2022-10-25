//
//  NXSortView.m
//  nxrmc
//
//  Created by nextlabs on 2/16/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXSortView.h"

#import "NXRMCDef.h"
#import "UIView+UIExt.h"
#import "Masonry.h"

#define SORT_BY_BTN_HEIGHT 50
#define SORT_BY_BTN_WIDTH 125

@interface NXCircleButton ()

//@property(nonatomic, assign) CGFloat radius;
@property(nonatomic, assign) CGSize shadowOffset;
@property(nonatomic, assign) CGFloat shadowRadius;

@property(nonatomic, assign) CAShapeLayer *roundBackgroundLayer;

@property(nonatomic, assign) BOOL isCustomShadowPosition;

@end

@implementation NXCircleButton

- (instancetype)initWithRadius:(CGFloat)radius shadowOffset:(CGSize)shadowOffset shadowRadius:(CGFloat)shadowRadius {
    if (self = [super initWithFrame:CGRectMake(0, 0, 50, 50)]) {
//        _radius = radius;
        _isCustomShadowPosition = YES;
        _shadowOffset = shadowOffset;
        _shadowRadius = shadowRadius;
        [self commonInit];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.backgroundColor = self.selectedBackgroundColor ?: self.backgroundColor;
    } else {
        self.backgroundColor = self.normalBackgroundColor ?: self.backgroundColor;
    }
}

- (void)setNormalBackgroundColor:(UIColor *)normalBackgroundColor {
    _normalBackgroundColor = normalBackgroundColor;
    self.selected = self.isSelected;
}

- (void)setSelectedBackgroundColor:(UIColor *)selectedBackgroundColor {
    _selectedBackgroundColor = selectedBackgroundColor;
    self.selected = self.isSelected;
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    [super setImage:image forState:state];
    if (state == UIControlStateSelected) {
        [self setImage:image forState:UIControlStateHighlighted];
    }
}

#pragma mark
- (void)clicked:(id)sender {
    self.selected = !self.isSelected;
    if (self.clickBlock) {
        self.clickBlock(self);
    }
}

#pragma mark
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    [self cornerRadian:self.bounds.size.width/2];
    self.layer.cornerRadius = self.bounds.size.width/2;
    self.clipsToBounds = YES;
    self.layer.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.9].CGColor;
    self.layer.shadowOffset = self.isCustomShadowPosition? self.shadowOffset: CGSizeMake(1.0, 1.0); // work shadowRadius
    self.layer.shadowRadius = self.isCustomShadowPosition? self.shadowRadius: 2.0f;
    self.layer.shadowOpacity = 0.5;
}

#pragma mark

- (void)commonInit {
    [self addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
}

@end

@interface NXSortItemView()

@end

@implementation NXSortItemView

- (instancetype)initWithSortOption:(NXSortOption)sortOption {
    if (self = [super init]) {
        [self commonInit];
        self.sortOption = sortOption;
    }
    return self;
}

- (void)removeItemButton {
    [self.itemButton removeFromSuperview];
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.width.equalTo(self).multipliedBy(2.0f/3.0f);
        make.bottom.equalTo(self);
    }];
}

- (void)setSortOption:(NXSortOption)sortOption {
    _sortOption = sortOption;
    
    switch (_sortOption) {
        case NXSortOptionNameAscending:
        {
            self.titleLabel.text = NSLocalizedString(@"UI_COM_SORT_OPT_NAME_ASC", NULL);
            [self.itemButton setImage:[UIImage imageNamed:@"A-Z - white"] forState:UIControlStateNormal];
            [self.itemButton setImage:[UIImage imageNamed:@"A-Z - green"] forState:UIControlStateSelected];
        }
            break;
        case NXSortOptionNameDescending:
        {
            self.titleLabel.text = NSLocalizedString(@"UI_COM_SORT_OPT_NAME_DSC", NULL);
            [self.itemButton setImage:[UIImage imageNamed:@"Z-A - white"] forState:UIControlStateNormal];
            [self.itemButton setImage:[UIImage imageNamed:@"Z-A - green"] forState:UIControlStateSelected];
        }
            break;
        case NXSortOptionDateAscending:
        case NXSortOptionDateDescending:
        {
            self.titleLabel.text = NSLocalizedString(@"UI_COM_SORT_OPT_NEWEST", NULL);
            [self.itemButton setImage:[UIImage imageNamed:@"sort by date - white"] forState:UIControlStateNormal];
            [self.itemButton setImage:[UIImage imageNamed:@"sort by date - green"] forState:UIControlStateSelected];
        }
            break;
        case NXSortOptionDriveAscending:
        case NXSortOptionDriveDescending:
        {
            self.titleLabel.text = NSLocalizedString(@"UI_COM_SORT_OPT_REPO", NULL);
            [self.itemButton setImage:[UIImage imageNamed:@"sort by repo - white"] forState:UIControlStateNormal];
            [self.itemButton setImage:[UIImage imageNamed:@"sort by repo - green"] forState:UIControlStateSelected];
        }
            break;
        case NXSortOptionSizeAscending:
        case NXSortOptionSizeDescending:
        {
            self.titleLabel.text = NSLocalizedString(@"UI_COM_SORT_OPT_SIZE", NULL);
            [self.itemButton setImage:[UIImage imageNamed:@"sort by repo - white"] forState:UIControlStateNormal];
            [self.itemButton setImage:[UIImage imageNamed:@"sort by repo - green"] forState:UIControlStateSelected];
        }
        default:
            break;
    }
}

- (void)setSelected:(BOOL)selected {
    [self.itemButton setSelected:selected];
}

#pragma mark
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    self.itemButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.itemButton.layer.borderColor = [UIColor whiteColor].CGColor;
    if (self.selected) {
        self.itemButton.layer.borderWidth = 0.0;
    } else {
        self.itemButton.layer.borderWidth = 2.0;
    }
}

#pragma mark
- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = @"";
    _titleLabel.font = [UIFont systemFontOfSize:14.0f];
    
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.userInteractionEnabled = YES;
    [self addSubview:_titleLabel];
    UITapGestureRecognizer *titleLabtap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTitleLabelTap:)];
    [_titleLabel addGestureRecognizer:titleLabtap];
    _itemButton = [[NXCircleButton alloc] initWithRadius:25 shadowOffset:CGSizeZero shadowRadius:0];
    _itemButton.normalBackgroundColor = RMC_MAIN_COLOR;
    _itemButton.selectedBackgroundColor = [UIColor whiteColor];
    
    WeakObj(self);
    _itemButton.clickBlock = ^(id sender) {
        StrongObj(self);
        if (self.clickBlock) {
            self.clickBlock(self);
        }
    };
    
    [self addSubview:_itemButton];
    
    [_itemButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.left.equalTo(self.mas_left);
        make.width.equalTo(self).multipliedBy(1.0f/3.0f);
        make.height.equalTo(_itemButton.mas_width);
    }];
    
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.left.equalTo(_itemButton.mas_right).offset(20);
        make.width.equalTo(self).multipliedBy(2.0f/3.0f);
        make.bottom.equalTo(self);
    }];
}
- (void) tapTitleLabelTap:(id)sender {
    if (self.clickBlock) {
        self.clickBlock(self);
    }
}

@end

@interface NXSortView ()<CAAnimationDelegate>

@property(nonatomic, strong) NXCircleButton *mainItem;
@property(nonatomic, strong) NSMutableArray<NXSortItemView *> *sortItemViews;
@property(nonatomic, weak) NXCircleButton *sortButton; //当排序列表出现时的关闭按钮
@end

@implementation NXSortView

- (instancetype)initWithSortOptions:(NSArray *)options selectedOption:(NXSortOption)option {
    if (self = [super initWithFrame:CGRectZero]) {
        [self commonInit];
        self.currentOption = option;
        _sortOptions = options?:@[@(0)];
        _sortItemViews = [NSMutableArray array];
    }
    return self;
}

- (void)setCurrentOption:(NXSortOption)currentOption {
    [self.mainItem setImage:[UIImage imageNamed:@"Close"] forState:UIControlStateNormal];
    
    switch (currentOption) {
        case NXSortOptionDateAscending:
        {
            [self.mainItem setImage:[UIImage imageNamed:@"sort by date - white"] forState:UIControlStateNormal];
        }
            break;
        case NXSortOptionDateDescending:
        {
            [self.mainItem setImage:[UIImage imageNamed:@"sort by date - white"] forState:UIControlStateNormal];
        }
            break;
        case NXSortOptionNameAscending:
        {
            [self.mainItem setImage:[UIImage imageNamed:@"A-Z - white"] forState:UIControlStateNormal];
        }
            break;
        case NXSortOptionNameDescending:
        {
            [self.mainItem setImage:[UIImage imageNamed:@"Z-A - white"] forState:UIControlStateNormal];
        }
            break;
        case NXSortOptionDriveAscending:
        case NXSortOptionDriveDescending:
        {
            [self.mainItem setImage:[UIImage imageNamed:@"sort by repo - white"] forState:UIControlStateNormal];
        }
            break;
        case NXSortOptionSizeAscending: {
            [self.mainItem setImage:[UIImage imageNamed:@"sort by repo - white"] forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
    if (_currentOption == currentOption) {
        return;
    }
    _currentOption = currentOption;
    
    if (DELEGATE_HAS_METHOD(_delegate, @selector(sortView:didSelectedSortOption:))) {
        [_delegate sortView:self didSelectedSortOption:_currentOption];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark
- (void)responseToDeviceRotate:(NSNotification *)notification {
    if (!self.sortButton) {
        return;
    }
    BOOL horizontal = YES;
    UIWindow  *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    if (keyWindow.bounds.size.height >= ((self.sortOptions.count + 2) * SORT_BY_BTN_HEIGHT + 100)) {
        horizontal = NO;
    }
    if (horizontal) {
        [self layoutHorizontalView:keyWindow];
    } else {
        [self layoutVerticalView:keyWindow];
    }
}

- (void)showSortoptions {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    UIView *sortView = [[UIView alloc] initWithFrame:keyWindow.bounds];
    sortView.tag = 323;
    sortView.backgroundColor = [UIColor colorWithRed:(57.0/255.0) green:(150.0/255.0) blue:(73.0/255.0) alpha:0.7];
    
    [keyWindow addSubview:sortView];
    [sortView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(keyWindow);
    }];
    
    NXCircleButton *button = [self createMainItem];
    button.selected = YES;
    self.sortButton = button;
    
    [sortView addSubview:button];
    
    //add title label for sort view.
    NXSortItemView *labelItem = [[NXSortItemView alloc] initWithSortOption:0];
    [labelItem removeItemButton];
    labelItem.titleLabel.text = NSLocalizedString(@"SORT BY", NULL);
    [self.sortItemViews insertObject:labelItem atIndex:0];
    [sortView addSubview:labelItem];
    [sortView bringSubviewToFront:labelItem];
    
    for (NSInteger index = 0; index < self.sortOptions.count; ++index) {
        NXSortItemView *itemView = [[NXSortItemView alloc] initWithSortOption:self.sortOptions[index].integerValue];
        if (self.sortOptions[index].integerValue == self.currentOption) {
            itemView.selected = YES;
        }
        WeakObj(self);
        itemView.clickBlock = ^(NXSortItemView *sender){
            StrongObj(self);
            self.currentOption = sender.sortOption;
            [button clicked:button];
            [self hideSortOptions];
        };
        [sortView addSubview:itemView];
        [sortView bringSubviewToFront:itemView];
        [self.sortItemViews insertObject:itemView atIndex:0];
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackGround:)];
    [sortView addGestureRecognizer:tap];
    //do auto layout.
    [self responseToDeviceRotate:nil];
 }

- (void)tapBackGround:(UITapGestureRecognizer *)tapGesture
{
    [self hideSortOptions];
    self.mainItem.selected = !self.mainItem.isSelected;
}

- (void)layoutVerticalView:(UIWindow *)keyWindow {
    if (!self.sortButton) {
        return;
    }
    
    CGRect rect = [self.mainItem convertRect:self.mainItem.bounds toView:keyWindow];
    [self.sortButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(keyWindow).offset(rect.origin.x);
        make.top.equalTo(keyWindow).offset(rect.origin.y);
        make.width.equalTo(@(rect.size.width));
        make.height.equalTo(@(rect.size.height));
    }];
    
    for (NSInteger index = 0; index < self.sortItemViews.count; index++) {
        NXSortItemView *itemView = self.sortItemViews[index];
        itemView.alpha = 0.0;
        if (index == 0) {
            [itemView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.sortButton.mas_top).offset(-10.0f);
                make.left.equalTo(self.sortButton.mas_left).offset(-70.0f);
                make.height.equalTo(@(SORT_BY_BTN_HEIGHT));
                make.width.equalTo(@(SORT_BY_BTN_WIDTH));
            }];
        } else {
            NXSortItemView *preItemView = self.sortItemViews[index - 1];
            [itemView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(preItemView.mas_top).offset(-10.0f);
                make.left.equalTo(self.sortButton.mas_left).offset(-70.0f);
                make.height.equalTo(@(SORT_BY_BTN_HEIGHT));
                make.width.equalTo(@(SORT_BY_BTN_WIDTH));
            }];
        }
    }
    [self showAnimation];
}

- (void)layoutHorizontalView:(UIWindow *)keyWindow {
    if (!self.sortButton) {
        return;
    }
    CGRect rect = [self.mainItem convertRect:self.mainItem.bounds toView:keyWindow];
    [self.sortButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(keyWindow).offset(rect.origin.x);
        make.top.equalTo(keyWindow).offset(rect.origin.y);
        make.width.equalTo(@(rect.size.width));
        make.height.equalTo(@(rect.size.height));
    }];
    
    for (NSInteger index = 0; index < self.sortItemViews.count; index++) {
        NXSortItemView *itemView = self.sortItemViews[index];
        itemView.alpha = 0.0;
        if (index == 0) {
            [itemView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(_sortButton.mas_top).offset(-10.0f);
                make.left.equalTo(_sortButton.mas_left).offset(-70.0f);
                make.height.equalTo(@(SORT_BY_BTN_HEIGHT));
                make.width.equalTo(@(SORT_BY_BTN_WIDTH));
            }];
        } else if (index == self.sortItemViews.count - 1) {
            NXSortItemView *preItemView = self.sortItemViews[index - 1];
            [itemView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(preItemView.mas_top).offset(-10.0f);
                make.left.equalTo(preItemView.mas_left);
                make.height.equalTo(@(SORT_BY_BTN_HEIGHT));
                make.width.equalTo(@(SORT_BY_BTN_WIDTH));
            }];
        } else {
            NXSortItemView *preItemView = self.sortItemViews[index - 1];
            [itemView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(preItemView.mas_bottom);
                make.right.equalTo(preItemView.mas_left).offset(-10.0f);
                make.height.equalTo(@(SORT_BY_BTN_HEIGHT));
                make.width.equalTo(@(SORT_BY_BTN_WIDTH));
            }];
        }
    }
    [self showAnimation];
}

- (void)hideSortOptions {
    [_sortItemViews removeAllObjects];
    [[[UIApplication sharedApplication].keyWindow viewWithTag:323] removeFromSuperview];
}

- (void)showAnimation {
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

    
    for (NSInteger index = 0; index < self.sortItemViews.count; ++index) {
        NXSortItemView *itemView = self.sortItemViews[index];
        CAAnimationGroup *animaGroup = [CAAnimationGroup animation];
        animaGroup.duration = 0.2f;
        animaGroup.beginTime = CACurrentMediaTime() + 0.1 *index;
        animaGroup.fillMode = kCAFillModeForwards;
        animaGroup.removedOnCompletion = NO;
        animaGroup.animations = @[shakeAnim, opacityAnima];
        animaGroup.delegate = self;
        [itemView.layer addAnimation:animaGroup forKey:@"Animation"];
    }
}

#pragma mark - Animation delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    
    for (NSInteger index = 0; index < self.sortItemViews.count; ++index) {
        NXSortItemView *itemView = self.sortItemViews[index];
        if ([anim isEqual:[itemView.layer animationForKey:@"Animation"]]) {
            itemView.alpha = 1.0f;
        }
        
    }
    
}

#pragma mark
- (NXCircleButton *)createMainItem {
    NXCircleButton *mainItem = [[NXCircleButton alloc] initWithRadius:0 shadowOffset:CGSizeZero shadowRadius:0];
    mainItem.selectedBackgroundColor = [UIColor whiteColor];
    mainItem.normalBackgroundColor = RMC_MAIN_COLOR;
    [mainItem setImage:[UIImage imageNamed:@"Close"] forState:UIControlStateSelected];
    mainItem.clickBlock = ^(NXCircleButton *sender){
        if (sender != self.mainItem) {
            self.mainItem.selected = !self.mainItem.isSelected;
        }
        if (sender.selected) {
            [self showSortoptions];
        } else {
            [self hideSortOptions];
        }
    };
    return mainItem;
}

#pragma mark
- (void)commonInit {
    
    NXCircleButton *mainItem = [self createMainItem];
    [self addSubview:mainItem];
    
    self.mainItem = mainItem;
    
    [mainItem mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.and.width.equalTo(self);
        make.center.equalTo(self);
    }];
    
    self.backgroundColor = [UIColor clearColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseToDeviceRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

@end
