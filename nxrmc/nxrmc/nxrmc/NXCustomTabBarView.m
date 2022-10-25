//
//  NXCustomTabBarView.m
//  nxrmc
//
//  Created by helpdesk on 9/3/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXCustomTabBarView.h"
#import "ImageTextButton.h"
#import "Masonry.h"
#import "UIView+UIExt.h"
#define  KGREENCOLOR [UIColor colorWithRed:109/256.0 green:180/256.0 blue:90/256.0 alpha:1]
#define KMENUBUTTONTAG 95598
@interface NXCustomTabBarView ()
@property(nonatomic, strong)NSMutableArray *menuButtonArray;
@property(nonatomic, strong)UIControl *firstMenuButton;
@property(nonatomic, strong)UIView *shadowView;
@end
@implementation NXCustomTabBarView
-(NSMutableArray*)menuButtonArray{
    if (!_menuButtonArray) {
        _menuButtonArray = [NSMutableArray array];
    }
    return _menuButtonArray;
}
- (instancetype)initWithsubViewsPictures:(NSArray *)normalImages andSelectImages:(NSArray *)selectImages andButtonTitles:(NSArray *)titlearray {
    self = [super init];
    if (self) {
        [self commoninitWithNormalPictures:normalImages andSelectPictures:selectImages andButtonTitles:titlearray];
    }
    return self;
}
-(void)commoninitWithNormalPictures:(NSArray *)iconArray andSelectPictures:(NSArray *)selectedImages andButtonTitles:(NSArray *)titleArray {
    
    if (iconArray) {
        NSMutableArray *iconButtons=@[].mutableCopy;
        for (int i = 0;i<iconArray.count;i++) {
            ImageTextButton *menuButton = [[ImageTextButton alloc]init];
            menuButton.tag = KMENUBUTTONTAG+i;
            menuButton.titleLabel.font=[UIFont systemFontOfSize:13];
            menuButton.titleLabel.adjustsFontSizeToFitWidth = YES;
            [menuButton addTarget:self action:@selector(selectMenuBtn:) forControlEvents:UIControlEventTouchUpInside];
            NSString *buttonTitle = titleArray[i];
            [menuButton setTitle:buttonTitle forState:UIControlStateNormal];
            [menuButton setImage:[UIImage imageNamed:iconArray[i]] forState:UIControlStateNormal];
            [menuButton setImage:[UIImage imageNamed:selectedImages[i]] forState:UIControlStateSelected];
            [menuButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            [menuButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
            [menuButton setButtonTitleWithImageAlignment:UIButtonTitleWithImageAlignmentDown];
            [self addSubview:menuButton];
            if (i == 0) {
                self.firstMenuButton = menuButton;
                menuButton.selected = YES;
            }
            [iconButtons addObject:menuButton];
            self.menuButtonArray = iconButtons;
        }
        [iconButtons mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:15 leadSpacing:20 tailSpacing:20];
        [iconButtons mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(5);
            make.bottom.equalTo(self).offset(-2);
        }];
    }
    UIView *slideView = [[UIView alloc]init];
    [self addSubview:slideView];
    slideView.backgroundColor = KGREENCOLOR;
    self.slideView = slideView;
    UIView *shadowView = [[UIView alloc]init];
    self.shadowView = shadowView;
    [self addSubview:shadowView];
//    [shadowView addShadow:UIViewShadowPositionLeft | UIViewShadowPositionRight color:[UIColor blackColor] width:0.5 Opacity:0.9];
    [slideView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.firstMenuButton);
        make.top.equalTo(self).offset(-2);
        make.height.equalTo(@4);
        make.width.equalTo(@70);
    }];
    [shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(slideView).offset(1);
        make.right.equalTo(slideView).offset(-1);
        make.top.equalTo(self);
        make.height.equalTo(self);
        
    }];
        }

- (void)selectMenuBtn:(UIButton*)sender {
    self.currentIndex = sender.tag-KMENUBUTTONTAG;
    [self.slideView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(sender);
        make.top.equalTo(self).offset(-2);
        make.height.equalTo(@4);
        make.width.equalTo(@70);
    }];
//    [self.shadowView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.slideView).offset(2);
//        make.right.equalTo(self.slideView).offset(-2);
//        make.top.equalTo(self);
//        make.height.equalTo(self);
//    }];
    for (UIButton *menuButton in self.menuButtonArray) {
        menuButton.selected=NO;
    }
    sender.selected=YES;
    if ([self.delegate respondsToSelector:@selector(NXCustomTabBarView:selectMenuButtonClicked:)]) {
        [self.delegate NXCustomTabBarView:self selectMenuButtonClicked:sender];
    }
}
- (void)amountClickTabBarItem:(NSInteger)integer {
    UIButton *itemButton = self.menuButtonArray[integer];
    [self.slideView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(itemButton);
        make.top.equalTo(self).offset(-2);
        make.height.equalTo(@4);
        make.width.equalTo(@70);
    }];
    for (UIButton *menuButton in self.menuButtonArray) {
        menuButton.selected=NO;
    }
    itemButton.selected=YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.shadowView addShadow:UIViewShadowPositionLeft | UIViewShadowPositionRight color:[UIColor blackColor] width:0.2 Opacity:0.9];
    
    
}
@end
