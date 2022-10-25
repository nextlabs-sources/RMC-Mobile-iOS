//
//  NXProjectMemberSearchResultVC.h
//  nxrmc
//
//  Created by xx-huang on 14/02/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXSearchResultViewController.h"

@class NXProjectMemberSearchResultVC;

@protocol NXProjectMemberListSearchResultDelegate <NSObject>
@optional
- (void)memberListResultVC:(NXProjectMemberSearchResultVC *)resultVC didSelectItem:(id)item;
- (void)memberListResultVC:(NXProjectMemberSearchResultVC *)resultVC didClickMemberAccessButton:(id)item;
- (void)memberListResultVC:(NXProjectMemberSearchResultVC *)resultVC didClickPendingAccessButton:(id)item;

@end

@interface NXProjectMemberSearchResultVC : NXSearchResultViewController
@property (nonatomic,assign) id<NXProjectMemberListSearchResultDelegate> delegate;

@end
