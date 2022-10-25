//
//  NXWorkSpaceTableViewController.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/9/23.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXFileSort.h"
#import "NXWorkSpaceFileSearchResultVC.h"
NS_ASSUME_NONNULL_BEGIN
@class NXWorkSpaceFolder;
@interface NXWorkSpaceTableViewController : UIViewController<NXWorkSpaceFileListSearchResultDelegate>
@property(nonatomic, assign) NXSortOption sortOption;
@property(nonatomic, strong) NSArray *allSortByTypes;
@property(nonatomic, strong,readonly)NXWorkSpaceFolder *currentFolder;
- (instancetype)initWithCurrentFolder:(NXWorkSpaceFolder*)folder;
@end

NS_ASSUME_NONNULL_END
