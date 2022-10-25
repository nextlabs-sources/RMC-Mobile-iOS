//
//  NXProjectSearchResultVC.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2018/12/4.
//  Copyright © 2018年 nextlabs. All rights reserved.
//

#import "NXSearchResultViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface NXProjectSearchResultVC : NXSearchResultViewController
@property (nonatomic,assign) id delegate;
@end
@protocol NXProjectListSearchResultDelegate <NSObject>
@optional
- (void)projectListResultVC:(NXProjectSearchResultVC *)resultVC didSelectItem:(id)item;
- (void)projectListResultVC:(NXProjectSearchResultVC *)resultVC didClickPendingDeclineAccessButton:(id)item;
- (void)projectListResultVC:(NXProjectSearchResultVC *)resultVC didClickPendingAcceptButton:(id)item;

@end
NS_ASSUME_NONNULL_END
