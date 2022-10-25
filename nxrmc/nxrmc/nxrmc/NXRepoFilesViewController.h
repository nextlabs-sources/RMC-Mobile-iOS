//
//  NXRepoFilesViewController.h
//  nxrmc
//
//  Created by nextlabs on 2/15/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXFileBaseViewController.h"

#import "NXSearchViewController.h"
#import "NXFileListSearchResultVC.h"

@interface NXRepoFilesViewController : NXFileBaseViewController<NXSearchDataSourceProtocol, NXFileListSearchResultDelegate>
@property (nonatomic, assign)BOOL isOnlyNxlFile;
//@property(nonatomic, strong) NXFileBase *currentFolder;

//- (void)rightBarBtnClicked:(id)sender;

@end
