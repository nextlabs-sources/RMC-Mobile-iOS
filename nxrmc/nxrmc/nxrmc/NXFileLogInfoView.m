//
//  NXFileLogInfoView.m
//  nxrmc
//
//  Created by helpdesk on 21/2/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXFileLogInfoView.h"
#import "Masonry.h"
@implementation NXFileLogInfoView

-(instancetype)initWithsubViewsMenus:(NSMutableArray *)array {
    self=[super init];
    if (self) {
        [self commoninitWithMenuArray:array];
       
    }
    return self;
}
-(void)commoninitWithMenuArray:(NSMutableArray*)menuArray {
    NSMutableArray *labels=@[].mutableCopy;
    UILabel *lastLabel = nil;
    if (menuArray) {
        for (int i = 0;i<menuArray.count;i++) {
            UILabel *menuLabel = [[UILabel alloc]init];
            NSString *title=menuArray[i];
            menuLabel.text = title;
            menuLabel.backgroundColor = [UIColor whiteColor];
            menuLabel.textAlignment = NSTextAlignmentCenter;
            menuLabel.font = [UIFont systemFontOfSize:14];
            menuLabel.numberOfLines = 0;
            menuLabel.adjustsFontSizeToFitWidth = YES;
            [self addSubview:menuLabel];
            [labels addObject:menuLabel];
            if (i == 0) {
                [menuLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(self);
                    make.left.equalTo(self).offset(10);
                    make.width.equalTo(@200);
                    make.height.equalTo(self).multipliedBy(0.9);
                }];
            } else if (i == 3 || i == 4) {
                [menuLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(self);
                    make.left.equalTo(lastLabel.mas_right).offset(2);
                    make.width.equalTo(@150);
                    make.height.equalTo(self).multipliedBy(0.9);
                }];
            }
            else {
                [menuLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(self);
                    make.left.equalTo(lastLabel.mas_right).offset(2);
                    make.width.equalTo(@120);
                    make.height.equalTo(self).multipliedBy(0.9);
                }];
            }
            lastLabel = menuLabel;
        }
        
//        [labels mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:2 leadSpacing:10 tailSpacing:20];
//        [labels mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(@5);
////            make.height.equalTo(@40);
//            make.bottom.equalTo(self).offset(-2);
//        }];
    }
    

}
@end
