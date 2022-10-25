//
//  NXMyVaultFileTableViewController.h
//  nxrmc
//
//  Created by helpdesk on 16/2/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXSearchViewController.h"
#import "MyVaultSeachResultViewController.h"
#import "NXFileSort.h"
@class NXMyVaultListParModel;
@interface NXMyVaultFileTableViewController : UIViewController<NXSearchDataSourceProtocol,NXMyVaultSearchResultDelegate>
@property(nonatomic, strong) NXMyVaultListParModel *listParModel;
@property(nonatomic, assign) NXSortOption sortOption;
@end
