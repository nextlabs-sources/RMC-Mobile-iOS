//
//  NXSearchViewController.h
//  nxrmc
//
//  Created by nextlabs on 12/30/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXSearchResultViewController.h"

@protocol NXSearchDataSourceProtocol <NSObject>
@required

- (NSArray *)getSearchDataSource;

@end

@class NXSearchViewController;

@protocol NXSearchVCUpdateDelegate <NSObject>
@optional
- (void)updateSearchResultsForSearchController:(NXSearchViewController *)vc resultSeachVC:(NXSearchResultViewController *)resultVC;

- (void)searchControllerWillDissmiss:(NXSearchViewController *)searchController;

- (void)searchControllerWillPresent:(NXSearchViewController *)searchController;

- (void)searchControllerDidPresent:(NXSearchViewController *)searchController;

- (void)cancelButtonClicked:(NXSearchViewController *)searchController;

@end

@interface NXSearchViewController : UISearchController
- (instancetype)initWithSearchResultsController:(UIViewController *)searchResultsController shouldAutoDisplay:(BOOL)shouldAutoDisplay;
@property(nonatomic, weak) id<NXSearchVCUpdateDelegate> updateDelegate;

@end
