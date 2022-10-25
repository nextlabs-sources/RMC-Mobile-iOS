//
//  NXFilesViewController.h
//  nxrmc
//
//  Created by nextlabs on 1/13/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXBaseViewController.h"
#import "NXRepoFilesNavigationController.h"
#import "NXPageSelectMenuView.h"
#import "NXSharedByMeVC.h"
#import "NXSharedWithMeVC.h"
#import "NXFavoriteViewController.h"
#import "NXOfflineFilesViewController.h"

@interface NXFilesViewController : UIViewController

@property(nonatomic, assign) NSInteger currentPageIndex;
@property(nonatomic, assign) NSInteger selectPageIndex;
@property(nonatomic, strong) NXRepoFilesNavigationController *fileListNav;

@property(nonatomic, readonly) NXSharedByMeVC *sharedByMe;
@property(nonatomic, readonly) NXSharedWithMeVC *sharedWithMe;
@property(nonatomic, readonly) NXFavoriteViewController *favoriteVC;
@property(nonatomic, readonly) NXOfflineFilesViewController *offlineVC;
@property(nonatomic, readonly) NXPageSelectMenuView *menuView;
@property(nonatomic, readonly) NSMutableArray *childVCArray;
- (NSMutableArray *)allSortByTypesAndCurrentSortByType;
    
@end
