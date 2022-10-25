//
//  NXFileOperationToolBar.m
//  CoreAnimationDemo
//
//  Created by EShi on 11/3/16.
//  Copyright © 2016 Eren. All rights reserved.
//

#import "NXFileOperationToolBar.h"
#import "UIView+UIExt.h"
#import "NXRoundButtonView.h"
#import "NXHalfCornerButton.h"
#import "NXRMCUIDef.h"
#import "NXRMCDef.h"
#define BTN_CORNER 5.0

@interface NXFileOperationToolBar()
@property(nonatomic, strong) NSArray *viewArray;
@property(nonatomic, strong) UIButton *btnFav;
@property(nonatomic, strong) UIButton *btnOffline;
@property(nonatomic, strong) UIButton *btnProtect;
@property(nonatomic, strong) UIButton *btnShare;
@property(nonatomic, strong) UIView *shadowView;
@property(nonatomic, assign) NXFileOperationToolBarType type;
@end

@implementation NXFileOperationToolBar
- (instancetype) initWithFrame:(CGRect)frame file:(NXFile *)file type:(NXFileOperationToolBarType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        _type = type;
        self.backgroundColor = [UIColor clearColor];
        if(OFFLINE_ON){
            _btnOffline = [[NXHalfCornerButton alloc] initWithFrame:CGRectMake(0, 0, FILE_TOOL_BAR_SHOW_WIDTH, FILE_TOOL_BAR_HEIGHT) cornerSide:NXHalfCornerButtonCornerSideRight radius:5.0f];
            _btnOffline.translatesAutoresizingMaskIntoConstraints = NO;
            _btnOffline.tag = NXFileOperationToolBarItemTypeOffline;
            _btnOffline.backgroundColor = [UIColor whiteColor];
            [_btnOffline addTarget:self action:@selector(fileOperationBtnSelected:) forControlEvents:UIControlEventTouchUpInside];
            [_btnOffline setImage:[UIImage imageNamed:@"down arrow - white"] forState:UIControlStateSelected];
            [_btnOffline setImage:[UIImage imageNamed:@"down arrow - green"] forState:UIControlStateHighlighted];
            [_btnOffline setImage:[UIImage imageNamed:@"down arrow - green"] forState:UIControlStateNormal];
            [_btnOffline setAdjustsImageWhenHighlighted:NO];
            [self addSubview:_btnOffline];
            
            if (file.isOffline) {
                [_btnOffline setSelected:YES];
                _btnOffline.backgroundColor = [UIColor blackColor];
            }
            
            _shadowView = [[UIView alloc] init];
            _shadowView.translatesAutoresizingMaskIntoConstraints = NO;
            _shadowView.backgroundColor = [UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:0.0];
            [self addSubview:_shadowView];
        }
      
        _btnFav = nil;
        if (OFFLINE_ON) {
            _btnFav = [[NXHalfCornerButton alloc] initWithFrame:CGRectMake(0, 0, FILE_TOOL_BAR_HEIGHT, FILE_TOOL_BAR_HEIGHT) cornerSide:NXHalfCornerButtonCornerSideLeft radius:5.0f];
        }else{
            
            if (FAVORITE_ON) {
                _btnFav = [[UIButton alloc] init];
                _btnFav.translatesAutoresizingMaskIntoConstraints = NO;
                [_btnFav cornerRadian:5.0f];
                [_btnFav borderColor:[UIColor blackColor]];
                [_btnFav borderWidth:1.0f];

            }
        }
        
        if (FAVORITE_ON) {
            //_btnFav.contentMode = UIViewContentModeScaleAspectFit;
            _btnFav.translatesAutoresizingMaskIntoConstraints = NO;
            _btnFav.backgroundColor = [UIColor whiteColor];
            _btnFav.tag = NXFileOperationToolBarItemTypeFavorite;
            [_btnFav addTarget:self action:@selector(fileOperationBtnSelected:) forControlEvents:UIControlEventTouchUpInside];
            [_btnFav setImage:[UIImage imageNamed:@"fav - white"] forState:UIControlStateSelected];
            [_btnFav setImage:[UIImage imageNamed:@"fav - green"] forState:UIControlStateNormal];
            [_btnFav setAdjustsImageWhenHighlighted:NO];
            
            if (file.isFavorite) {
                [_btnFav setSelected:YES];
                _btnFav.backgroundColor = [UIColor blackColor];
            }
            
            
            [self addSubview:_btnFav];
            
            [self bringSubviewToFront:_btnFav];

        }
        
        
        
        _btnProtect = [[UIButton alloc] init];
        _btnProtect.translatesAutoresizingMaskIntoConstraints = NO;
        _btnProtect.backgroundColor = [UIColor blackColor];
        _btnProtect.tag = NXFileOperationToolBarItemTypeProtect;
        [_btnProtect addTarget:self action:@selector(fileOperationBtnSelected:) forControlEvents:UIControlEventTouchUpInside];
        [_btnProtect setImage:[UIImage imageNamed:@"protect - white"] forState:UIControlStateNormal];
        [_btnProtect setImage:[UIImage imageNamed:@"protect - white"] forState:UIControlStateSelected];
        [_btnProtect setImage:[UIImage imageNamed:@"protect - white"] forState:UIControlStateHighlighted];
        [_btnProtect setAdjustsImageWhenHighlighted:NO];
        [_btnProtect cornerRadian:5.0f];
        [self addSubview:_btnProtect];
        
        if (self.type == NXFileOperationToolBarTypeFileContent) {
            _btnShare = [[UIButton alloc] init];
            _btnShare.translatesAutoresizingMaskIntoConstraints = NO;
            _btnShare.backgroundColor = [UIColor blackColor];
            _btnShare.tag = NXFileOperationToolBarItemTypeShare;
            [_btnShare setAdjustsImageWhenHighlighted:NO];
            [_btnShare setImage:[UIImage imageNamed:@"share - white"] forState:UIControlStateNormal];
            [_btnShare setImage:[UIImage imageNamed:@"share - white"] forState:UIControlStateSelected];
            [_btnShare setImage:[UIImage imageNamed:@"share - white"] forState:UIControlStateHighlighted];
            [_btnShare setTitle:@"SHARE" forState:UIControlStateNormal];
            [_btnShare setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_btnShare cornerRadian:BTN_CORNER];
            _btnShare.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
            _btnShare.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
            [_btnShare addTarget:self action:@selector(fileOperationBtnSelected:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_btnShare];
            
            _btnShow = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, FILE_TOOL_BAR_SHOW_WIDTH, FILE_TOOL_BAR_SHOW_WIDTH)];
            _btnShow.translatesAutoresizingMaskIntoConstraints = NO;
            _btnShow.backgroundColor = [UIColor blackColor];
            _btnShow.alpha = 0.4f;
            [_btnShow setImage:[UIImage imageNamed:@"backArrow-gray"] forState:UIControlStateNormal];
            [_btnShow setAdjustsImageWhenHighlighted:NO];
            [_btnShow addTarget:self action:@selector(fileOperationBtnSelected:) forControlEvents:UIControlEventTouchUpInside];
            _btnShow.tag = NXFileOperationToolBarItemTypeShow;
            [_btnShow cornerRadian:2.0];
            [self addSubview:_btnShow];
        }
        if (self.type == NXFileOperationToolBarTypeFileContent) {
            if (OFFLINE_ON) {
                _viewArray = @[_btnFav, _shadowView, _btnOffline, _btnProtect, _btnShare];
            }else{
                if (FAVORITE_ON) {
                    _viewArray = @[_btnFav, _btnProtect, _btnShare];
                }else{
                    _viewArray = @[_btnProtect, _btnShare];
                }
                
            }
            
        }else
        {
            if (OFFLINE_ON) {
                _viewArray = @[_btnFav, _shadowView, _btnOffline, _btnProtect];
            }else{
                if (FAVORITE_ON) {
                    _viewArray = @[_btnFav, _btnProtect];
                }else{
                    _viewArray = @[_btnProtect];
                }
                
            }
            
        }
        _toolBarVisible = YES;
        _file = file;
        
        if (_file) {
            if (FAVORITE_ON) {
                [_file addObserver:self forKeyPath:@"isFavorite" options:NSKeyValueObservingOptionNew context:nil];
            }
            
            if(OFFLINE_ON){
                [_file addObserver:self forKeyPath:@"isOffline" options:NSKeyValueObservingOptionNew context:nil];
            }
          
        }
    }
    
    return self;
}
- (instancetype) initWithFrame:(CGRect)frame type:(NXFileOperationToolBarType)type
{
    return [self initWithFrame:frame file:nil type:type];
}

- (void)setFile:(NXFile *)file {
    _file = file;
    if (FAVORITE_ON) {
        [_file removeObserver:self forKeyPath:@"isFavorite"];
        [_file addObserver:self forKeyPath:@"isFavorite" options:NSKeyValueObservingOptionNew context:nil];
        
        if (_file.isFavorite) {
            [_btnFav setSelected:YES];
            _btnFav.backgroundColor = [UIColor blackColor];
        }else{
            [_btnFav setSelected:NO];
            _btnFav.backgroundColor = [UIColor whiteColor];
            
        }
    }
    
    
    if (OFFLINE_ON) {
        [_file removeObserver:self forKeyPath:@"isOffline"];
        [_file addObserver:self forKeyPath:@"isOffline" options:NSKeyValueObservingOptionNew context:nil];
        if (_file.isOffline) {
            [_btnOffline setSelected:YES];
            _btnOffline.backgroundColor = [UIColor blackColor];
        }else
        {
            [_btnOffline setSelected:NO];
            _btnOffline.backgroundColor = [UIColor whiteColor];
            
        }
    }
}

- (void) dealloc
{
    if (FAVORITE_ON) {
        [_file removeObserver:self forKeyPath:@"isFavorite"];
    }
    
    if (OFFLINE_ON) {
         [_file removeObserver:self forKeyPath:@"isOffline"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    NSNumber *newVal = (NSNumber *)change[@"new"];
    if (newVal) {
        if ([keyPath isEqualToString:@"isFavorite"]) {
            [self.btnFav setSelected:newVal.boolValue];
            if (newVal.boolValue) {
                self.btnFav.backgroundColor = [UIColor blackColor];
            }else
            {
                self.btnFav.backgroundColor = [UIColor whiteColor];
            }
            
        }else if([keyPath isEqualToString:@"isOffline"])
        {
            [self.btnOffline setSelected:newVal.boolValue];
            if (newVal.boolValue) {
                self.btnOffline.backgroundColor = [UIColor blackColor];
            }else
            {
                self.btnOffline.backgroundColor = [UIColor whiteColor];
            }
        }

    }
}
- (void) layoutSubviews
{
    [super layoutSubviews];
    NSDictionary *viewDict  = nil;
    if (self.type == NXFileOperationToolBarTypeFileContent) {
        if (OFFLINE_ON) {
            viewDict = @{@"btnFav":_btnFav, @"btnOffline":_btnOffline, @"btnProtect":_btnProtect, @"btnShare":_btnShare, @"shadowView":_shadowView, @"btnShow":_btnShow};
        }else{
            if (FAVORITE_ON) {
                viewDict = @{@"btnFav":_btnFav, @"btnProtect":_btnProtect, @"btnShare":_btnShare,@"btnShow":_btnShow};
            }else{
                viewDict = @{@"btnProtect":_btnProtect, @"btnShare":_btnShare,@"btnShow":_btnShow};
            }
            
        }
        
    }else
    {
        if (OFFLINE_ON) {
            viewDict = @{@"btnFav":_btnFav, @"btnOffline":_btnOffline, @"btnProtect":_btnProtect, @"shadowView":_shadowView};
        }else{
            if (FAVORITE_ON) {
                viewDict = @{@"btnFav":_btnFav, @"btnProtect":_btnProtect};
            }else{
                viewDict = @{@"btnProtect":_btnProtect};
            }
            
        }
    }

    NSDictionary *sizeDict = @{@"btnFavWidth":@FILE_TOOL_BAR_HEIGHT, @"btnOfflineWidth":@FILE_TOOL_BAR_HEIGHT, @"btnProtectWidth":@FILE_TOOL_BAR_HEIGHT, @"btnProtectWidth":@FILE_TOOL_BAR_HEIGHT};
    if (self.type == NXFileOperationToolBarTypeFileContent) {
        if (OFFLINE_ON) {
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[btnShow(20)]-[btnFav(btnFavWidth)][btnOffline(btnOfflineWidth)]-[btnProtect(btnProtectWidth)]-[btnShare]|" options:0 metrics:sizeDict views:viewDict]];
        }else{
            if (FAVORITE_ON) {
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[btnShow(20)]-[btnFav(btnFavWidth)]-[btnProtect(btnProtectWidth)]-[btnShare]|" options:0 metrics:sizeDict views:viewDict]];
            }else{
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[btnShow(20)]-[btnProtect(btnProtectWidth)]-[btnShare]|" options:0 metrics:sizeDict views:viewDict]];
            }
            
        }
        
    }else
    {
        if (OFFLINE_ON) {
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[btnFav(btnFavWidth)][btnOffline(btnOfflineWidth)]-[btnProtect(btnProtectWidth)]" options:0 metrics:sizeDict views:viewDict]];
        }else{
            if (FAVORITE_ON) {
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[btnFav(btnFavWidth)]-[btnProtect(btnProtectWidth)]" options:0 metrics:sizeDict views:viewDict]];
            }else{
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[btnProtect(btnProtectWidth)]" options:0 metrics:sizeDict views:viewDict]];
            }
            
        }
        
    }
    if (FAVORITE_ON) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[btnFav]|" options:0 metrics:nil views:viewDict]];
    }
    
    if(OFFLINE_ON){
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(1)-[shadowView]-(1)-|" options:0 metrics:nil views:viewDict]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[btnOffline]|" options:0 metrics:nil views:viewDict]];
    }
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[btnProtect]|" options:0 metrics:nil views:viewDict]];
    if (self.type == NXFileOperationToolBarTypeFileContent) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[btnShare]|" options:0 metrics:nil views:viewDict]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[btnShow]|" options:0 metrics:nil views:viewDict]];
    }
    if (OFFLINE_ON) {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.btnOffline attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.shadowView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
         [self addConstraint:[NSLayoutConstraint constraintWithItem:self.shadowView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0.5]];
    }
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if(OFFLINE_ON){
         [self.shadowView addShadow:UIViewShadowPositionRight color:[UIColor blackColor] width:0.5f Opacity:0.4];
    }
   
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
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
    if (button.tag == NXFileOperationToolBarItemTypeOffline || button.tag == NXFileOperationToolBarItemTypeFavorite) {
        button.backgroundColor = button.isSelected? [UIColor blackColor]: [UIColor whiteColor];
    }
    
    if ([self.delegate respondsToSelector:@selector(fileOperationToolBar:didSelectItem:)]) {
        [self.delegate fileOperationToolBar:self didSelectItem:button.tag];
    }
}

-(void) disableBtn:(NXFileOperationToolBarItemType) btnType
{
    switch (btnType) {
        case NXFileOperationToolBarItemTypeProtect:
        {
            [self.btnProtect removeTarget:self action:@selector(fileOperationBtnSelected:) forControlEvents:UIControlEventTouchUpInside];
            self.btnProtect.backgroundColor = [UIColor groupTableViewBackgroundColor];
        }
            break;
        case NXFileOperationToolBarItemTypeOffline:
        {
             [self.btnOffline removeTarget:self action:@selector(fileOperationBtnSelected:) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
        case NXFileOperationToolBarItemTypeFavorite:
        {
            [self.btnFav removeTarget:self action:@selector(fileOperationBtnSelected:) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
        case NXFileOperationToolBarItemTypeShare:
        {
            [self.btnShare removeTarget:self action:@selector(fileOperationBtnSelected:) forControlEvents:UIControlEventTouchUpInside];
            self.btnShare.backgroundColor = [UIColor groupTableViewBackgroundColor];
        }
            break;
        default:
            break;
    }
}

-(void) enableBtn:(NXFileOperationToolBarItemType) btnType
{
    switch (btnType) {
        case NXFileOperationToolBarItemTypeProtect:
        {
            [self.btnProtect addTarget:self action:@selector(fileOperationBtnSelected:) forControlEvents:UIControlEventTouchUpInside];
            self.btnProtect.backgroundColor = [UIColor blackColor];
        }
            break;
        case NXFileOperationToolBarItemTypeOffline:
        {
            [self.btnOffline addTarget:self action:@selector(fileOperationBtnSelected:) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
        case NXFileOperationToolBarItemTypeFavorite:
        {
            [self.btnFav addTarget:self action:@selector(fileOperationBtnSelected:) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
        case NXFileOperationToolBarItemTypeShare:
        {
            [self.btnShare addTarget:self action:@selector(fileOperationBtnSelected:) forControlEvents:UIControlEventTouchUpInside];
            self.btnShare.backgroundColor = [UIColor blackColor];
        }
            break;
        default:
            break;
    }
}

@end
