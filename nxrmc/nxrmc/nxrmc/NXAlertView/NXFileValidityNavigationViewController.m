//
//  NXFileValidityNavigationViewController.m
//  Calender
//
//  Created by Stepanoval (Xinxin) Huang on 07/11/2017.
//  Copyright © 2017 NextLabs. All rights reserved.
//

#import "NXFileValidityNavigationViewController.h"
#import "NXFileValidityPickViewController.h"
#import "Masonry.h"
#import "NXDefine.h"
#import "NXRMCDef.h"

@interface NXFileValidityNavigationViewController () <UINavigationControllerDelegate>
@property(nonatomic, weak) MASConstraint *s;

@end

@implementation NXFileValidityNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [super viewDidLoad];
    self.navigationBar.translucent = YES;
    self.navigationBar.backgroundColor = [UIColor colorWithRed:237.0/255.0 green:237.0/255.0 blue:241.0/255.0 alpha:1.0];
    
    self.navigationBar.tintColor = [UIColor blackColor];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor clearColor],
                                               NSFontAttributeName : [UIFont systemFontOfSize:15]};
    
    self.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate{
    return NO;
}

#pragma -mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [_s uninstall];
    if ([viewController isKindOfClass:[NXFileValidityDateChooseViewController class]]) {
             
             CGFloat originY = NXMainScreenHeight - _viewHeight;
             if (IS_IPHONE_X) {
                 if (@available(iOS 11.0, *)) {
                     originY =  originY - 34;
                 } else {
                     // Fallback on earlier versions
                 }
             }
        
             self.view.frame = CGRectMake(self.view.frame.origin.x, originY , self.view.frame.size.width, _viewHeight);
        
//        [self.view mas_updateConstraints:^(MASConstraintMaker *make) {
//                if (@available(iOS 11.0, *)) {
//                    make.leading.equalTo(_fileValidityWindow.mas_safeAreaLayoutGuideLeading);
//                    make.trailing.equalTo(_fileValidityWindow.mas_safeAreaLayoutGuideTrailing);
//                    make.bottom.equalTo(_fileValidityWindow.mas_safeAreaLayoutGuideBottom);
//                    make.width.equalTo(_fileValidityWindow.mas_safeAreaLayoutGuideWidth);
//                    _s = make.height.equalTo(@(_viewHeight));
//                }
//            else
//            {
//                make.leading.equalTo(_fileValidityWindow);
//                make.trailing.equalTo(_fileValidityWindow);
//                make.bottom.equalTo(_fileValidityWindow);
//                make.width.equalTo(_fileValidityWindow);
//                _s = make.height.equalTo(@(_viewHeight));
//            }
       // }];
        self.navigationBar.hidden = YES;
    }
    else if ([viewController isKindOfClass:[NXFileValidityPickViewController class]])
    {
        CGFloat originY = NXMainScreenHeight - _viewHeight;
                  if (IS_IPHONE_X) {
                      if (@available(iOS 11.0, *)) {
                          originY =  originY - 34;
                      } else {
                          // Fallback on earlier versions
                      }
                  }
        
             self.view.frame = CGRectMake(self.view.frame.origin.x, originY , self.view.frame.size.width, _viewHeight);
//        [self.view mas_updateConstraints:^(MASConstraintMaker *make) {
//            if (@available(iOS 11.0, *)) {
//                make.leading.equalTo(_fileValidityWindow.mas_safeAreaLayoutGuideLeading);
//                make.trailing.equalTo(_fileValidityWindow.mas_safeAreaLayoutGuideTrailing);
//                make.bottom.equalTo(_fileValidityWindow.mas_safeAreaLayoutGuideBottom);
//                make.width.equalTo(_fileValidityWindow.mas_safeAreaLayoutGuideWidth);
//                _s = make.height.equalTo(@(_viewHeight));
//            }
//            else
//            {
//                make.leading.equalTo(_fileValidityWindow);
//                make.trailing.equalTo(_fileValidityWindow);
//                make.bottom.equalTo(_fileValidityWindow);
//                make.width.equalTo(_fileValidityWindow);
//                _s = make.height.equalTo(@(_viewHeight));
//            }
      //  }];
        self.navigationBar.hidden = NO;
    }
    
    // [UIView animateWithDuration:0.6 animations:^{
    [self.view layoutIfNeeded];
    // }];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //TODO
}


@end
