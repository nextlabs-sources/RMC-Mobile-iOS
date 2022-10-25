//
//  NXRepoFilesNavigationController.h
//  nxrmc
//
//  Created by nextlabs on 2/16/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXBaseNavigationController.h"
#import "NXFileSort.h"
#import "NXFolder.h"

@interface NXRepoFilesNavigationController : NXBaseNavigationController

@property(nonatomic, assign) NXSortOption sortOption;
@property(nonatomic, strong) NSArray *allSortByTypes;
@property(nonatomic, assign) BOOL isOnlyNxlFile;
@property(nonatomic, strong) NXFileBase *currentFolder;

@end
