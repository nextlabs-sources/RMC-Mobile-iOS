//
//  NXPhotoNavigationController.m
//  xiblayout
//
//  Created by nextlabs on 10/18/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXPhotoNavigationController.h"
#import "NXItemDisplayViewController.h"

#import "NXRMCDef.h"
#import "UIImage+ColorToImage.h"

#import "NXPhotoTool.h"

@interface NXPhotoNavigationController ()<UINavigationControllerDelegate>

@end

@implementation NXPhotoNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.shadowImage = [[UIImage alloc] init];
    [self.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.translucent = YES;
    self.navigationBar.backgroundColor = [UIColor whiteColor];
    
    self.navigationBar.tintColor = RMC_MAIN_COLOR;
    self.toolbar.tintColor = RMC_MAIN_COLOR;
    self.toolbarHidden = NO;
    self.modalPresentationStyle = UIModalPresentationFullScreen;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    DLog();
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count > 0) {
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    } else {
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    }
    
    if (![viewController isKindOfClass:[NXItemDisplayViewController class]]) {
        self.toolbarHidden = YES;
        viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:[self rightButtonItemTitle] style:UIBarButtonItemStylePlain target:self action:@selector(sure:)];
    } else {
        self.toolbarHidden = NO;
        UIBarButtonItem *s = [[UIBarButtonItem alloc]initWithTitle:[self rightButtonItemTitle] style:UIBarButtonItemStylePlain target:self action:@selector(sure:)];
        UIBarButtonItem *space = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        viewController.toolbarItems = @[space, s];
    }
    
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController *viewController = [super popViewControllerAnimated:YES];
    viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:[self rightButtonItemTitle] style:UIBarButtonItemStylePlain target:self action:@selector(sure:)];
   
    if ([viewController isKindOfClass:[NXItemDisplayViewController class]]) {
        self.toolbarHidden = YES;
    }
    
    return viewController;
}

#pragma mark
- (void)back:(id)sender {
    [self popViewControllerAnimated:YES];
}

- (void)cancel:(id)sender {
    if (self.completionblock) {
        self.completionblock(YES);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sure:(id)sender {
    if (self.completionblock) {
        self.completionblock(NO);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 

- (NSString *)rightButtonItemTitle {
    return @"Next";
}
@end
