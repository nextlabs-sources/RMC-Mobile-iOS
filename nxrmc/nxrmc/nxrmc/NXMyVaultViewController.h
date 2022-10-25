//
//  MyVaultViewController.h
//  nxrmc
//
//  Created by nextlabs on 12/29/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXPageSelectMenuView.h"

//@interface NXMyVaultViewController : UITableViewController
@interface NXMyVaultViewController : UIViewController
@property(nonatomic, readonly) NXPageSelectMenuView *menuView;
@property(nonatomic, readonly) NSMutableArray *subViewControllers;
@property(nonatomic, readonly) NSInteger currentPageIndex;
@property(nonatomic, readonly) NSArray *allSortByTypes;
@property(nonatomic, assign) NSInteger currentSortBy_type;
//- (void)clickMySpaceDown:(UIButton *) sender;
- (void)configureBackButton;
- (void)configureMyVautTitle;
@end
