//
//  NXWorkSpaceFileNavVC.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/9/23.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXFileSort.h"
NS_ASSUME_NONNULL_BEGIN
@class NXWorkSpaceFolder;
@interface NXWorkSpaceFileNavVC : UINavigationController
@property(nonatomic, assign) NXSortOption sortOption;
@property(nonatomic, strong)NXWorkSpaceFolder *currentFolder;;
@end

NS_ASSUME_NONNULL_END
