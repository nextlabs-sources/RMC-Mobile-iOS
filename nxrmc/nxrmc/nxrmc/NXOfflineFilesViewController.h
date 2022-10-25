//
//  NXOfflineFilesViewController.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2018/8/13.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NXFileBaseViewController.h"
#import "NXSearchViewController.h"
#import "NXFileListSearchResultVC.h"
#import "MyVaultSeachResultViewController.h"

typedef NS_ENUM(NSInteger, NXOfflineFileFilter) {
    NXOfflineFileFilterMyVaultAndSharedWithMe = 1,
    NXOfflineFileFilterWorkSpace=2,
    NXOfflineFileFilterSharedWithMe=3,
    NXOfflineFileFilterMyVault=4,
};

@interface NXOfflineFilesViewController : NXFileBaseViewController <NXSearchDataSourceProtocol,NXMyVaultSearchResultDelegate>
- (instancetype)initWithOfflineFilesFilter:(NXOfflineFileFilter) fileFilter;
@end
