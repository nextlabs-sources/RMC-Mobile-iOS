//
//  NXProjectOfflineFileVC.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2018/9/19.
//  Copyright © 2018年 nextlabs. All rights reserved.
//

#import "NXFileBaseViewController.h"
#import "NXSearchViewController.h"
#import "NXFileListSearchResultVC.h"
#import "MyVaultSeachResultViewController.h"
@interface NXProjectOfflineFileVC : NXFileBaseViewController<NXSearchDataSourceProtocol, NXMyVaultSearchResultDelegate>
@property(nonatomic, strong)NXProjectModel *projectModel;
@end
