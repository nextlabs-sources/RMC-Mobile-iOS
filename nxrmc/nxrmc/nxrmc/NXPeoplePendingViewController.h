//
//  NXPeoplePendingViewController.h
//  nxrmc
//
//  Created by helpdesk on 22/3/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXBaseViewController.h"
@class NXPendingProjectInvitationModel;
@interface NXPeoplePendingViewController : NXBaseViewController
@property (nonatomic, strong)NXPendingProjectInvitationModel *currentModel;
@property (nonatomic, assign) BOOL isOwerByMe;
@end
