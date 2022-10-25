//
//  NXPeopleItemCell.h
//  nxrmc
//
//  Created by nextlabs on 1/20/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXProjectMemberModel.h"
#import "NXPendingProjectInvitationModel.h"

typedef void(^ButtonClickBlock)(id sender);

@interface NXPeopleItemCell : UITableViewCell

@property(nonatomic, strong) NXProjectMemberModel *model;
@property(nonatomic, strong) NXPendingProjectInvitationModel *pendingModel;
@property(nonatomic, weak) UIButton *accessButton;

@property(nonatomic, copy) ButtonClickBlock accessBlock;

@end
