//
//  NXProjectFileTableViewController.h
//  nxrmc
//
//  Created by EShi on 1/24/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXProjectModel.h"
#import "NXProjectFolder.h"
#import "NXProjectFileListSearchResultViewController.h"
#import "NXSearchViewController.h"
#import "NXFileSort.h"

@interface NXProjectFileTableViewController : UIViewController<NXProjectFileListSearchResultDelegate, NXSearchDataSourceProtocol>

@property(nonatomic, assign) NXSortOption sortOption;
@property(nonatomic, strong) NSArray *allSortByTypes;
@property(nonatomic, strong, readonly) NXProjectFolder *currentFolder;

- (instancetype)initWithProjectModel:(NXProjectModel *)projectModel currentFolder:(NXProjectFolder *)projectFolder;

- (void)createFolderOrUploadFileWith:(id)sender;

@end
