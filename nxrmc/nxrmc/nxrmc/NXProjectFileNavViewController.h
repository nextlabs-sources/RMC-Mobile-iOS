//
//  NXProjectFileNavViewController.h
//  nxrmc
//
//  Created by helpdesk on 20/2/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXBaseNavigationController.h"

#import "NXFileSort.h"
#import "NXProjectFolder.h"

@interface NXProjectFileNavViewController : NXBaseNavigationController

@property(nonatomic, assign) NXSortOption sortOption;
@property(nonatomic, strong) NXProjectFolder *currentFolder;

@end
