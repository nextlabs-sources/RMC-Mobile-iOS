//
//  NXActionSheetNavigationViewController.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 02/05/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXActionSheetNavigationViewController.h"
#import "NXActionSheetCommonViewController.h"
#import "UIImage+ColorToImage.h"
#import "Masonry.h"
#import "NXDefine.h"
#import "NXRMCDef.h"

@interface NXActionSheetNavigationViewController ()<UINavigationControllerDelegate>
@property(nonatomic, weak) MASConstraint *s;
@end

@implementation NXActionSheetNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.translucent = YES;
    self.navigationBar.backgroundColor = NXColor(237, 237, 241);
    
    self.navigationBar.tintColor = [UIColor blackColor];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor clearColor],
                                               NSFontAttributeName : [UIFont systemFontOfSize:15]};
    
    self.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [_s uninstall];
    if ([viewController isKindOfClass:[NXCustomActionSheetViewController class]]) {
        NXCustomActionSheetViewController *vc = (NXCustomActionSheetViewController *)viewController;
        
        CGFloat navigationViewHeight = (vc.currentItems.count * 50) + 10;
        if (NXMainScreenHeight - navigationViewHeight - 100 < 0) {
            navigationViewHeight = NXMainScreenHeight - 150;
        }
        
        CGFloat originY = NXMainScreenHeight - navigationViewHeight - 100;
        if (IS_IPHONE_X) {
            if (@available(iOS 11.0, *)) {
                originY =  originY - 34;
            } else {
                // Fallback on earlier versions
            }
        }
        
        self.view.frame = CGRectMake(self.view.frame.origin.x, originY , self.view.frame.size.width, navigationViewHeight);

//        [self.view mas_updateConstraints:^(MASConstraintMaker *make) {
//
//            if (IS_IPHONE_X) {
//                if (@available(iOS 11.0, *)) {
//                    make.leading.equalTo(_actionSheetWindow.mas_safeAreaLayoutGuideLeading);
//                    make.trailing.equalTo(_actionSheetWindow.mas_safeAreaLayoutGuideTrailing);
//                    make.bottom.equalTo(_actionSheetWindow.mas_safeAreaLayoutGuideBottom).offset(-100);
//                    make.width.equalTo(_actionSheetWindow.mas_safeAreaLayoutGuideWidth);
//                   // _s = make.height.equalTo(@(navigationViewHeight));
//                }
//            }
//            else
//            {
//                make.leading.equalTo(_actionSheetWindow);
//                make.trailing.equalTo(_actionSheetWindow);
//                make.bottom.equalTo(_actionSheetWindow).offset(-100);
//                make.width.equalTo(_actionSheetWindow);
//              //  _s = make.height.equalTo(@(navigationViewHeight));
//            }
//        }];
        
        self.navigationBar.hidden = YES;
    }
    else if ([viewController isKindOfClass:[NXActionSheetCommonViewController class]])
    {
        NXActionSheetCommonViewController *vc = (NXActionSheetCommonViewController *)viewController;
        CGFloat navigationViewHeight = (vc.items.count * 50) + 44;
        if (NXMainScreenHeight - navigationViewHeight - 100 < 0) {
            navigationViewHeight = NXMainScreenHeight - 150;
        }
         CGFloat originY = NXMainScreenHeight - navigationViewHeight - 100;
     if (IS_IPHONE_X) {
                if (@available(iOS 11.0, *)) {
                   originY = originY - 34;
                } else {
                    // Fallback on earlier versions
                }
     }
        
        self.view.frame = CGRectMake(self.view.frame.origin.x,originY, self.view.frame.size.width, navigationViewHeight);
        
//        [self.view mas_updateConstraints:^(MASConstraintMaker *make) {
//
//            if (IS_IPHONE_X) {
//                if (@available(iOS 11.0, *)) {
//                    make.leading.equalTo(_actionSheetWindow.mas_safeAreaLayoutGuideLeading);
//                    make.trailing.equalTo(_actionSheetWindow.mas_safeAreaLayoutGuideTrailing);
//                    make.bottom.equalTo(_actionSheetWindow.mas_safeAreaLayoutGuideBottom).offset(-100);
//                    make.width.equalTo(_actionSheetWindow.mas_safeAreaLayoutGuideWidth);
//                }
//            }
//            else
//            {
//                make.leading.equalTo(_actionSheetWindow);
//                make.trailing.equalTo(_actionSheetWindow);
//                make.bottom.equalTo(_actionSheetWindow).offset(-100);
//                make.width.equalTo(_actionSheetWindow);
//            }
//           // _s = make.height.equalTo(@(navigationViewHeight));
//        }];
//
        self.navigationBar.hidden = NO;
        ;
    }
//    [UIView animateWithDuration:0.6 animations:^{
//        [self.view layoutIfNeeded];
//    }];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //TODO
}

@end

