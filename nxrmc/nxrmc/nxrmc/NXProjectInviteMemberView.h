//
//  NXProjectInviteMemberView.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 08/05/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXEmailView.h"
@class NXProjectInviteMemberView;
@class NXCommentInputView;
@interface NXCustomAlertWindow : UIWindow

@end

@interface NXCustomAlertWindowRootViewController : UIViewController
@end



typedef void (^onInviteClickHandle)(NXProjectInviteMemberView *alertView);

@interface NXProjectInviteMemberView : UIView

@property (nonatomic,strong) NXEmailView *emailView;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NXCommentInputView *invitationView;
@property (nonatomic, copy) onInviteClickHandle onInviteClickHandle;

- (instancetype)initWithTitle:(NSString *)title inviteHander:(onInviteClickHandle)hander;
- (void)show;
- (void)dismiss;
- (void)tempDismiss;
- (void)tempShow;
@end
