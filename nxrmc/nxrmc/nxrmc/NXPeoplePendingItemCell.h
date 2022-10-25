//
//  NXPeoplePendingItemCell.h
//  nxrmc
//
//  Created by helpdesk on 21/3/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^accessButtonClickBlock)(id sender);
@class NXPendingProjectInvitationModel;

@interface NXPeoplePendingItemCell : UITableViewCell

@property (nonatomic, strong)NXPendingProjectInvitationModel *model;
@property(nonatomic, copy) accessButtonClickBlock accessBlock;

@end






