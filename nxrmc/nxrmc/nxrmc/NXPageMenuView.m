//
//  NXPageMenuView.m
//  nxrmc
//
//  Created by helpdesk on 14/2/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXPageMenuView.h"
#import "Masonry.h"
#import "ImageTextButton.h"
#import "UIView+Extension.h"
@interface NXPageMenuView ()
@property(nonatomic, strong)UIControl *firstMenuButton;
@property(nonatomic, strong)NSMutableArray *menuButtonArray;
@end
@implementation NXPageMenuView
-(NSMutableArray*)menuButtonArray{
    if (!_menuButtonArray) {
        _menuButtonArray = [NSMutableArray array];
    }
    return _menuButtonArray;
}
-(instancetype)initWithsubViewsPictures:(NSMutableArray *)iconArray andButtonTitles:(NSMutableArray *)titlearray {
    self=[super init];
    if (self) {
        self.currentIndex = 0;
        self.backgroundColor = [UIColor whiteColor];
        [self commoninitWithPictures:iconArray andButtonTitles:titlearray];
    }
    return self;
}
-(void)commoninitWithPictures:(NSMutableArray*)iconArray andButtonTitles:(NSMutableArray*)titleArray {
   
    if (iconArray) {
        NSMutableArray *iconButtons = @[].mutableCopy;
        NSMutableArray *normalIcons = iconArray[0];
        NSMutableArray *selectIcons = iconArray[1];
        for (int i = 0;i<normalIcons.count;i++) {
            ImageTextButton *menuButton = [[ImageTextButton alloc]init];
            menuButton.tag = KMENUBTNTAG + i;
            menuButton.titleLabel.font = [UIFont systemFontOfSize:13];
            menuButton.titleLabel.adjustsFontSizeToFitWidth = YES;
            [menuButton addTarget:self action:@selector(selectMenuBtn:) forControlEvents:UIControlEventTouchUpInside];
            NSString *buttonTitle = titleArray[i];
            [menuButton setTitle:buttonTitle forState:UIControlStateNormal];
            [menuButton setImage:[UIImage imageNamed:normalIcons[i]] forState:UIControlStateNormal];
            [menuButton setImage:[UIImage imageNamed:selectIcons[i]] forState:UIControlStateSelected];
            [menuButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [menuButton setButtonTitleWithImageAlignment:UIButtonTitleWithImageAlignmentDown];
            [self addSubview:menuButton];
            if (i == 0) {
                self.firstMenuButton = menuButton;
                menuButton.selected = YES;
            }
           [iconButtons addObject:menuButton];
            self.menuButtonArray = iconButtons;
        }
        [iconButtons mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:20 leadSpacing:20 tailSpacing:20];
        [iconButtons mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@5);
            make.height.equalTo(@44);
            make.bottom.equalTo(self).offset(-10);
        }];
    }else {
        NSMutableArray *buttons = @[].mutableCopy;
        if (titleArray) {
            for (int i = 0;i<titleArray.count;i++) {
                UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
                menuButton.tag = KMENUBTNTAG + i;
                [menuButton addTarget:self action:@selector(selectMenuBtn:) forControlEvents:UIControlEventTouchUpInside];
                NSString *buttonTitle = titleArray[i];
                [menuButton setTitle:buttonTitle forState:UIControlStateNormal];
                [menuButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                menuButton.titleLabel.font = [UIFont systemFontOfSize:13];
                menuButton.titleLabel.adjustsFontSizeToFitWidth=YES;
                [menuButton setTitleColor:KGREENCOLOR forState:UIControlStateSelected];
                [self addSubview:menuButton];
                if (i == 0) {
                    self.firstMenuButton = menuButton;
                    menuButton.selected=YES;
                }
                [buttons addObject:menuButton];
                self.menuButtonArray = buttons;
            }
            if (titleArray.count>2) {
                [buttons mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:6 leadSpacing:0 tailSpacing:2];
                [buttons mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(@5);
                    make.height.equalTo(@30);
                    make.bottom.equalTo(self).offset(-6);
                }];

            } else {
            [buttons mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:30 leadSpacing:30 tailSpacing:30];
            [buttons mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(@5);
                make.height.equalTo(@30);
                make.bottom.equalTo(self).offset(-6);
            }];

            }
        }
    }
    
    UIView *slideView = [[UIView alloc]init];
    [self addSubview:slideView];
    slideView.backgroundColor = KGREENCOLOR;
    self.slideView = slideView;
    [slideView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.firstMenuButton);
        make.bottom.equalTo(self);
        make.height.equalTo(@2);
        make.width.equalTo(self.firstMenuButton).multipliedBy(0.8);
    }];
    
    

}
- (void)selectMenuBtn:(UIButton*)sender {
    self.currentIndex = sender.tag-KMENUBTNTAG;
    [self.slideView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(sender);
        make.bottom.equalTo(self);
        make.height.equalTo(@2);
        make.width.equalTo(sender).multipliedBy(0.8);
    }];
    [UIView animateWithDuration:0.3 animations:^{
       [self layoutIfNeeded];
    }];
    for (UIButton *menuButton in self.menuButtonArray) {
        menuButton.selected = NO;
    }
    sender.selected = YES;
    if ([self.delegate respondsToSelector:@selector(NXPageMenuView:selectMenuButtonClicked:)]) {
        [self.delegate NXPageMenuView:self selectMenuButtonClicked:sender];
    }
}
@end
