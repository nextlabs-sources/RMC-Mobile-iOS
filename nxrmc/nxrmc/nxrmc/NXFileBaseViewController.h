//
//  NXFileBaseViewController.h
//  nxrmc
//
//  Created by nextlabs on 1/19/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXFileOperationPageBaseVC.h"

#import "NXFileSort.h"
#import "NXLoginUser.h"
#import "DetailViewController.h"
#import "NXFileSort.h"
#define kCellIdentifier         @"kFileCellIdentifier"
#define kCellMyVault            @"kMyVualtCell"
@interface NXFileBaseViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, DetailViewControllerDelegate, NXOperationVCDelegate>

@property(nonatomic, strong, readonly) UITableView *tableView;
@property(nonatomic, strong, readonly) UIRefreshControl *refreshControl;

@property(nonatomic, strong) NSArray<NXFileBase *> *dataArray;
@property(nonatomic, strong) NSArray<NSDictionary<NSString *, NSArray*> *> *tableData;

@property(nonatomic, assign) BOOL isRefreshSupported;

@property(nonatomic, assign) NXSortOption sortOption;
@property(nonatomic, strong) NSArray  *allSortByTypes;
@property(nonatomic, assign) BOOL isOfflineVC;
@property(nonatomic, strong) UIView *offlineTopView;
@property(nonatomic, strong) NXFileBase *currentFolder;
- (void)updateData;
- (void)startSyncData;
- (void)stopSyncData;
- (void)pullDownRefreshWork;
- (Class)displayCellTypeClass;

- (void)showEmptyView:(NSString *)title image:(UIImage *)image;
- (void)removeEmptyView;

- (void)didSelectItem:(NXFileBase *)item;
- (void)moreButtonLClicked:(NXFileBase *)item;
- (void)swipeButtonClick:(NSInteger)type fileItem:(NXFileBase *)fileItem;

- (void)reloadData;
- (void)updateUI;
@end
