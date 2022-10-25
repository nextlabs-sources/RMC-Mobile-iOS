//
//  NXProjectPendingInvitationCell.h
//  nxrmc
//
//  Created by nextlabs on 1/20/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXProjectModel.h"
#import "NXPendingProjectInvitationModel.h"

typedef void(^projectInvAccept)(NXPendingProjectInvitationModel * pendingInvitation);
typedef void(^projectInvIgnore)(NXPendingProjectInvitationModel *pendingInvitation);
@interface NXProjectPendingInvitationCell : UICollectionViewCell
@property(nonatomic, weak) UILabel *titleLabel;
@property(nonatomic, strong) NXPendingProjectInvitationModel *model;
@property(nonatomic, copy) projectInvAccept acceptInvitationBlock;
@property(nonatomic, copy) projectInvIgnore ignoreInvitationBlock;

@end
