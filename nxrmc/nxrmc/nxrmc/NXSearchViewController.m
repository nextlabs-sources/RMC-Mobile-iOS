//
//  NXSearchViewController.m
//  nxrmc
//
//  Created by nextlabs on 12/30/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXSearchViewController.h"

@interface NXSearchViewController ()<UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate,UIGestureRecognizerDelegate>
@property(nonatomic, assign) BOOL shouldAutoDisplay;
@end

@implementation NXSearchViewController
- (instancetype)initWithSearchResultsController:(UIViewController *)searchResultsController shouldAutoDisplay:(BOOL)shouldAutoDisplay {
    if (self = [super initWithSearchResultsController:searchResultsController]) {
        self.shouldAutoDisplay = shouldAutoDisplay;
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithSearchResultsController:(UIViewController *)searchResultsController {
    return [self initWithSearchResultsController:searchResultsController shouldAutoDisplay:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if ([self.searchResultsController isKindOfClass:[NXSearchResultViewController class]]) {
        NXSearchResultViewController *searchVC = (NXSearchResultViewController *)self.searchResultsController;
        if (self.updateDelegate && [self.updateDelegate respondsToSelector:@selector(updateSearchResultsForSearchController: resultSeachVC:)]) {
            [self.updateDelegate updateSearchResultsForSearchController:self resultSeachVC:searchVC];
        }
    };
}

#pragma -mark UISearchControllerDelegate
- (void)willPresentSearchController:(UISearchController *)searchController {
    if (self.updateDelegate && [self.updateDelegate respondsToSelector:@selector(searchControllerWillPresent:)]) {
        [self.updateDelegate searchControllerWillPresent:self];
    }
}

- (void)willDismissSearchController:(UISearchController *)searchController
{
    if (self.updateDelegate && [self.updateDelegate respondsToSelector:@selector(searchControllerWillDissmiss:)]) {
        [self.updateDelegate searchControllerWillDissmiss:self];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
//    if (self.shouldAutoDisplay) {
//        self.active = NO;
//    }
    
    if (self.updateDelegate && [self.updateDelegate respondsToSelector:@selector(cancelButtonClicked:)]) {
        [self.updateDelegate cancelButtonClicked:self];
    }
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    if (self.updateDelegate && [self.updateDelegate respondsToSelector:@selector(searchControllerDidPresent:)]) {
        [self.updateDelegate searchControllerDidPresent:self];
    }
}

#pragma -mark
- (void)commonInit {
    self.searchBar.barTintColor = [UIColor whiteColor];
    self.searchBar.tintColor = RMC_SUB_COLOR;
    
    self.searchResultsUpdater = self;
    self.delegate = self;
    self.searchBar.delegate = self;
    self.dimsBackgroundDuringPresentation = YES;
     UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tapGR.delegate = self;
    [self.view addGestureRecognizer:tapGR];
    
    if (@available(iOS 11.0, *)) {
        [[self.searchBar.heightAnchor constraintEqualToConstant:44.0] setActive:YES];
        UIImage *searchBarBg = [self GetImageWithColor:[UIColor clearColor] andHeight:32.0f];
        //设置背景图片
        [self.searchBar setBackgroundImage:searchBarBg];
        //设置背景色
        [self.searchBar setBackgroundColor:[UIColor clearColor]];
        //设置文本框背景
        [self.searchBar setSearchFieldBackgroundImage:searchBarBg forState:UIControlStateNormal];
    }
}
- (void)tapAction:(UITapGestureRecognizer*)sender{
    [self.searchBar resignFirstResponder];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UITableView class]]) {
        return YES;
    }else  {
        return NO;
    }
}

- (UIImage*) GetImageWithColor:(UIColor*)color andHeight:(CGFloat)height
{
    CGRect r= CGRectMake(0.0f, 0.0f, 1.0f, height);
    UIGraphicsBeginImageContext(r.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, r);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}
@end
