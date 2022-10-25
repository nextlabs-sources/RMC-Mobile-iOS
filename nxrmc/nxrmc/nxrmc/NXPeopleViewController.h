//
//  NXPeopleViewController.h
//  nxrmc
//
//  Created by nextlabs on 1/20/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXProjectModel.h"
#import "NXProjectMemberSearchResultVC.h"
#import "NXSearchViewController.h"
#import "NXFileSort.h"
@interface NXPeopleViewController : UITableViewController<NXProjectMemberListSearchResultDelegate,NXSearchDataSourceProtocol>

@property(nonatomic, strong) NXProjectModel *projectModel;
@property(nonatomic, assign) NXSortOption sortOption;

- (void)reloadNewData;
- (void)configureNavigationRightBarButtons;

@end
