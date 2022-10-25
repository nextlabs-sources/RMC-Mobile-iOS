//
//  NXSharedWithMeVC.h
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 8/1/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXFileBaseViewController.h"

#import "NXSearchViewController.h"
#import "MyVaultSeachResultViewController.h"

@interface NXSharedWithMeVC : NXFileBaseViewController<NXSearchDataSourceProtocol, NXMyVaultSearchResultDelegate>

@end
