//
//  NXMyDriveOfflineFilesVC.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 11/5/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXFileBaseViewController.h"
#import "NXSearchViewController.h"
#import "NXFileListSearchResultVC.h"

@interface NXMyDriveOfflineFilesVC : NXFileBaseViewController <NXSearchDataSourceProtocol, NXFileListSearchResultDelegate>

@end
