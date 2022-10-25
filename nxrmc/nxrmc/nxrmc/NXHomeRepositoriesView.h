//
//  NXHomeRepositoriesView.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 28/4/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NXRepositoryModel;
@interface NXHomeRepositoriesView : UIView
@property (nonatomic ,copy) void(^clickRepoItemFinishedBlock) (NXRepositoryModel *model);
- (void)upDateNewInfoWith:(NSArray *)infos;
@end
