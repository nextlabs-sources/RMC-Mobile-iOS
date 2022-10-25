//
//  NXRepositoriesVC.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/9/16.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class NXRepositoryModel;
@interface NXRepositoriesVC : UIViewController
- (void)showRepoFilesByRepo:(NXRepositoryModel *)repoModel;
@end

NS_ASSUME_NONNULL_END
