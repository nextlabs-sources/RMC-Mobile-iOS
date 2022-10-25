//
//  NXMyDriveFilesNavigatonVC.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 11/5/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXBaseNavigationController.h"
#import "NXFileSort.h"
#import "NXFileBase.h"
@interface NXMyDriveFilesNavigatonVC : NXBaseNavigationController
@property(nonatomic, assign) NXSortOption sortOption;
@property(nonatomic, strong) NSArray *allSortByTypes;
@property(nonatomic, strong) NXFileBase *currentFolder;
@end
