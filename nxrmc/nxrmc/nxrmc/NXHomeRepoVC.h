//
//  NXHomeRepoVC.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2020/9/10.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXBaseViewController.h"
#import "NXRepoFilesNavigationController.h"
#import "NXPageSelectMenuView.h"

typedef NS_ENUM(NSInteger, NXHomeRepoVCSelectedType)
{
    NXHomeRepoVCSelectedTypeSelectAll = 0,
    NXHomeRepoVCSelectedTypeDeselectAll = 1,
};
@class NXRepositoryModel;
@interface NXHomeRepoVC : UIViewController
@property(nonatomic, strong)NXRepositoryModel *currentRepoModel;
@property(nonatomic, assign) NSInteger currentPageIndex;
@property(nonatomic, assign) NSInteger selectPageIndex;
@property(nonatomic, strong) NXRepoFilesNavigationController *fileListNav;
@property(nonatomic, strong) NXRepoFilesNavigationController *onlyprotectedfileListNav;
@property(nonatomic, readonly) NXPageSelectMenuView *menuView;
@property(nonatomic, readonly) NSMutableArray *childVCArray;
@property(nonatomic, assign) NXHomeRepoVCSelectedType selectType;
- (NSMutableArray *)allSortByTypesAndCurrentSortByType;
@end
