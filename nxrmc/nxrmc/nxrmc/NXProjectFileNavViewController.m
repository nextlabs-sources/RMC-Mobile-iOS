//
//  NXProjectFileNavViewController.m
//  nxrmc
//
//  Created by helpdesk on 20/2/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXProjectFileNavViewController.h"
#import "NXProjectFileTableViewController.h"

#import "NXSortView.h"
#import "Masonry.h"


@interface NXProjectFileNavViewController ()<NXSortViewDelegate, UINavigationControllerDelegate>

@property(nonatomic, strong) NXSortView *sortView;

@end

@implementation NXProjectFileNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    [self commonInit];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController *viewController = [super popViewControllerAnimated:animated];
    
    if ([self.viewControllers.lastObject isKindOfClass:[NXProjectFileTableViewController class]]) {
        NXProjectFileTableViewController *vc = self.viewControllers.lastObject;
        self.currentFolder = vc.currentFolder;
    };
    return viewController;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isKindOfClass:[NXProjectFileTableViewController class]]) {
        NXProjectFileTableViewController *filesVC = (NXProjectFileTableViewController *)viewController;
        self.currentFolder = filesVC.currentFolder;
    }
    [super pushViewController:viewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//#pragma mark - NXSortViewDelegate
//
//- (void)sortView:(NXSortView *)sortView didSelectedSortOption:(NXSortOption)option {
//    NXProjectFileTableViewController *vc = (NXProjectFileTableViewController *)self.viewControllers.lastObject;
//    vc.sortOption = option;
//}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(nonnull NXProjectFileTableViewController *)viewController animated:(BOOL)animated {
    viewController.sortOption = self.sortOption;
}

#pragma mark
- (void)commonInit {
//    _sortView = [[NXSortView alloc] initWithSortOptions:@[@(NXSortOptionDateDescending), @(NXSortOptionNameAscending), @(NXSortOptionNameDescending),@(NXSortOptionSizeAscending)] selectedOption:NXSortOptionDateDescending];
//    _sortView.delegate = self;
//    [self.view addSubview:self.sortView];
//    [self.sortView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.view).offset(-kMargin * 3);
//        make.right.equalTo(self.view).offset(-kMargin * 3);
//        make.width.equalTo(@(45));
//        make.height.equalTo(self.sortView.mas_width);
//    }];
}

@end
