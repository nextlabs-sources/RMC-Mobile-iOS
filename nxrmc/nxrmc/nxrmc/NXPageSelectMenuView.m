//
//  NXPageSelectMenuView.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 4/5/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXPageSelectMenuView.h"
#import "Masonry.h"
#import "NXNetworkHelper.h"
#define MENUITEMSPACE 20
#define KMENUBTNTAG   20170504
#define TITLEFONT     13
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
@interface NXPageSelectMenuView ()<UIScrollViewDelegate>
@property(nonatomic, strong)UIView *slideView;
@property(nonatomic, strong)UIControl *currentMenuButton;
@property(nonatomic, strong)NSMutableArray *menuButtonArray;
@property(nonatomic, strong)UIScrollView *bgScrollView;
@property(nonatomic, strong)UIButton *lastBtn;
@property(nonatomic, assign)CGFloat itemSpace;
@property(nonatomic, assign)CGFloat totalSpace;
@property(nonatomic, strong)NSArray *items;
@property(nonatomic, assign) UIDeviceOrientation  lastOrient;
@property(nonatomic, strong)NSArray *unableArray;
@end
@implementation NXPageSelectMenuView

- (instancetype)initWithFrame:(CGRect)frame andItems:(NSArray *)items {
   self = [super initWithFrame:frame];
    if (self) {
        self.bounds = frame;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotateScreenSelectMenuView:) name:UIDeviceOrientationDidChangeNotification object:nil];
        self.lastOrient = [UIDevice currentDevice].orientation;
        self.currentIndex = 0;
        self.items = items;
        [self commonInitWithItems:items];
    }
    return self;
}
- (void)layoutSubviews {
    if (self.bounds.size.width>self.totalSpace) {
        self.bgScrollView.contentSize = CGSizeMake(0, 0);
    }else {
         self.bgScrollView.contentSize = CGSizeMake(self.totalSpace, 1);
    }

}
- (NSMutableArray *)menuButtonArray {
    if (!_menuButtonArray) {
        _menuButtonArray = [NSMutableArray array];
    }
    return _menuButtonArray;
}
- (void)setCurrentFrame:(CGRect)currentFrame {
    self.bounds = currentFrame;
}
- (CGFloat)getItemHspace:(NSArray *)items {
    
    CGFloat itemSpace = 0;
    CGFloat totalSpace = 0;
    for (NSString *itemStr in items) {
        CGSize itemSize = [self sizeOfLabelWithCustomMaxWidth:SCREEN_WIDTH systemFontSize:TITLEFONT andFilledTextString:itemStr];
        totalSpace = totalSpace + itemSize.width;
    }
    if (SCREEN_WIDTH >totalSpace+(items.count+1)*MENUITEMSPACE) {
        itemSpace = (SCREEN_WIDTH -totalSpace)/(items.count+1);
    }else {
        itemSpace = MENUITEMSPACE;
    }
    self.totalSpace = totalSpace + itemSpace*(items.count+1);
//    totalSpace = totalSpace + (items.count-1)*MENUITEMSPACE;
//    self.totalSpace = totalSpace;
//    if (self.bounds.size.width>totalSpace+MENUITEMSPACE*2) {
//        CGFloat multipeSpace = self.bounds.size.width/totalSpace;
//        itemSpace = MENUITEMSPACE *multipeSpace;
//    }else {
//        itemSpace = MENUITEMSPACE;
//    
//    }
    
    return itemSpace;
}

- (void)commonInitWithItems:(NSArray *)itemsArray {
    if (!itemsArray) {
        return ;
    }
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    self.itemSpace = [self getItemHspace:itemsArray];
    UIScrollView *bgScrollView = [[UIScrollView alloc]init];
    bgScrollView.backgroundColor = [UIColor whiteColor];
    bgScrollView.delegate = self;
    bgScrollView.showsHorizontalScrollIndicator = NO;
    bgScrollView.bounces = NO;
    bgScrollView.scrollsToTop = NO;
    [self addSubview:bgScrollView];
    self.bgScrollView = bgScrollView;
    [bgScrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    UIView *slideView = [[UIView alloc]init];
    [bgScrollView addSubview:slideView];
    slideView.backgroundColor = RMC_MAIN_COLOR;
    self.slideView = slideView;
    

    UIButton *lastItem = nil;
    for (int i = 0; i<itemsArray.count; i++) {
        UIButton *menuBtn = [[UIButton alloc]init];
        menuBtn.tag = KMENUBTNTAG + i;
        [menuBtn addTarget:self action:@selector(selectMenuBtn:) forControlEvents:UIControlEventTouchUpInside];
        [menuBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        menuBtn.titleLabel.font = [UIFont systemFontOfSize:TITLEFONT];
        [menuBtn setTitleColor:RMC_MAIN_COLOR forState:UIControlStateSelected];
        [menuBtn setTitle:itemsArray[i] forState:UIControlStateNormal];
        NSCharacterSet  *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *accessName = [itemsArray[i] stringByTrimmingCharactersInSet:set];
        menuBtn.accessibilityValue = [NSString stringWithFormat:@"FILES_SEGMENT_%@", accessName];
        menuBtn.accessibilityLabel = [NSString stringWithFormat:@"FILES_SEGMENT_LABEL_%@", accessName];
        CGSize btnSize = [self sizeOfLabelWithCustomMaxWidth:SCREEN_WIDTH systemFontSize:TITLEFONT andFilledTextString:itemsArray[i]];
        [bgScrollView addSubview:menuBtn];
        if (i == 0) {
            [menuBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(bgScrollView);
                make.left.equalTo(bgScrollView).offset(self.itemSpace);
                make.width.equalTo(@(btnSize.width));
                make.height.equalTo(bgScrollView).multipliedBy(0.8);
            }];
            
        }else{
            [menuBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(bgScrollView);
                make.left.equalTo(lastItem.mas_right).offset(self.itemSpace);
                make.width.equalTo(@(btnSize.width));
                make.height.equalTo(bgScrollView).multipliedBy(0.8);

            }];
        }
        if (self.currentIndex == i) {
            menuBtn.selected = YES;
        }
        lastItem = menuBtn;
        self.lastBtn = lastItem;
        [self.menuButtonArray addObject:menuBtn];
        
    }
    self.currentMenuButton = [self viewWithTag:self.currentIndex + KMENUBTNTAG];
    [slideView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.currentMenuButton);
        make.bottom.equalTo(self);
        make.height.equalTo(@2);
        make.width.equalTo(self.currentMenuButton);
    }];
   }
- (void)scrollButtonCentered:(UIButton *)button {
    CGRect centeredRect = CGRectMake(button.frame.origin.x + button.frame.size.width/2.0 - self.frame.size.width/2.0, button.frame.origin.y + button.frame.size.height/2.0 - self.frame.size.height/2.0, self.frame.size.width, self.frame.size.height);
    [self.bgScrollView scrollRectToVisible:centeredRect animated:YES];
}
- (void)selectMenuBtn:(UIButton *)sender {
    self.currentIndex = sender.tag - KMENUBTNTAG;
    [self scrollButtonCentered:sender];
    for (UIButton *menuButton in self.menuButtonArray) {
        menuButton.selected = NO;
    }
    sender.selected = YES;
    [self.slideView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(sender);
        make.bottom.equalTo(self);
        make.height.equalTo(@2);
        make.width.equalTo(sender);
    }];
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutIfNeeded];
        //            if (self.totalSpace<=self.bounds.size.width-MENUITEMSPACE*2) {
        //                return ;
        //            }
        //            float offsetX = CGRectGetMidX(sender.frame);
        //            if (offsetX < SCREEN_WIDTH/2) {
        //                    self.bgScrollView.contentOffset = CGPointMake(0, 0);
        //                }else if (offsetX >= SCREEN_WIDTH/2 && offsetX <= self.bgScrollView.contentSize.width - SCREEN_WIDTH/2) {
        //                    self.bgScrollView.contentOffset = CGPointMake(offsetX - SCREEN_WIDTH/2, 0);
        //                }else if (offsetX>=self.bgScrollView.contentSize.width-SCREEN_WIDTH/2 && offsetX<=self.bgScrollView.contentSize.width){
        //                    self.bgScrollView.contentOffset = CGPointMake(self.bgScrollView.contentSize.width - SCREEN_WIDTH, 0);
        //                }else {
        //                    self.bgScrollView.contentOffset = CGPointMake(self.bgScrollView.contentOffset.x, 0);
        //                }
    }];
    if ([self.delegate respondsToSelector:@selector(withNXPageSelectMenuView:selectMenuButtonClicked:)]) {
        [self.delegate withNXPageSelectMenuView:self selectMenuButtonClicked:sender];
    }
   }

- (void)setSelectIndex:(NSInteger)index {
    if (index < self.items.count) {
        UIButton *button = [self.bgScrollView viewWithTag:index + KMENUBTNTAG];
        if (button) {
             [self selectMenuBtn:button];
        } else {
            self.currentIndex = index;
            [self commonInitWithItems:self.items];
        }
       
    }
    
}
- (void)setUnableForButtons:(NSArray *)itemArray andDefaultSelect:(NSInteger)defaultIndex {
    self.unableArray = itemArray;
    for (NSString *title in itemArray) {
        for (UIButton *menuBtn in self.menuButtonArray) {
            if ([menuBtn.titleLabel.text isEqualToString:title]) {
                menuBtn.enabled = NO;
                [menuBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            }
        }
    }
    [self setSelectIndex:defaultIndex];
}
- (void)cancelUnableForButtions:(NSArray *)itemArray {
        for (UIButton *menuBtn in self.menuButtonArray) {
            menuBtn.enabled = YES;
             [menuBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
}
#pragma mark ---->return size from title size
- (CGSize)sizeOfLabelWithCustomMaxWidth:(CGFloat)width systemFontSize:(CGFloat)fontSize andFilledTextString:(NSString *)str{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width, 0)];
    label.text = str;
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:fontSize];
    [label sizeToFit];
    CGSize size = label.frame.size;
    return size;
}
#pragma mark ----->rotateScreenSelectMenuView
- (void)rotateScreenSelectMenuView:(NSNotification *)notification {
    UIDeviceOrientation  orient = [UIDevice currentDevice].orientation;
    if (orient == UIDeviceOrientationUnknown || orient ==  UIDeviceOrientationFaceUp || orient == UIDeviceOrientationFaceDown  ) {
        return;
    }
    if (self.lastOrient != orient) {
        [self commonInitWithItems:self.items];
        if (![[NXNetworkHelper sharedInstance] isNetworkAvailable]) {
            [self setUnableForButtons:self.unableArray andDefaultSelect:self.currentIndex];
        }
    }
    self.lastOrient = orient;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
