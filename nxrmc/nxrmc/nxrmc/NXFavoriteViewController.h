//
//  NXFavoriteViewController.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 22/08/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXFileBaseViewController.h"
#import "NXSearchViewController.h"
#import "MyVaultSeachResultViewController.h"
typedef NS_ENUM(NSInteger, NXFavoriteFileFilter) {
    NXFavoriteFileFilterMyVault = 1,
    NXFavoriteFileFilterMyDrive = 2,
    NXFavoriteFileFilterMyvaultAndMyDrive=3,
};
@interface NXFavoriteViewController : NXFileBaseViewController <NXSearchDataSourceProtocol,NXMyVaultSearchResultDelegate>
- (instancetype)initWithOfflineFilesFilter:(NXFavoriteFileFilter) fileFilter;
@end
