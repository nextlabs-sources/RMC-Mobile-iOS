//
//  NXSharedByMeVC.h
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 8/1/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXFileBaseViewController.h"

#import "MyVaultSeachResultViewController.h"
#import "NXSearchViewController.h"

@interface NXSharedByMeVC : NXFileBaseViewController<NXSearchDataSourceProtocol, NXMyVaultSearchResultDelegate>

@end
