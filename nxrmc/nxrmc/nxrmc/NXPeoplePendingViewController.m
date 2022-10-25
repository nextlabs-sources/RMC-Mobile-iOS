//
//  NXPeoplePendingViewController.m
//  nxrmc
//
//  Created by helpdesk on 22/3/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXPeoplePendingViewController.h"
#import "NXPendingProjectInvitationModel.h"
#import "NXProjectMemberDetailHeaderView.h"
#import "UIView+UIExt.h"
#import "Masonry.h"
#import "NXLoginUser.h"
#import "NXMBManager.h"
#import "NXCommonUtils.h"
@interface NXPeoplePendingViewController ()
@property(nonatomic, strong) UIButton *revokeButton;
@property(nonatomic, strong) UIButton *reSendButton;
@property(nonatomic, strong) UIScrollView *bgScrollView;
@end

@implementation NXPeoplePendingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     [self commomInit];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(projectMemberDidUpdated:) name:NOTIFICATION_PROJECT_MEMBER_UPDATED object:nil];
}

- (void)projectMemberDidUpdated:(NSNotification *)notification
{
    NXProjectModel *model = [[NXLoginUser sharedInstance].myProject getProjectModelForProjectId:self.currentModel.projectId];
    WeakObj(self);
    [[NXLoginUser sharedInstance].myProject listPendingInvitationsForProject:model WithCompletion:^(NXProjectModel *project, NSArray *invitationsArray, NSError *error) {
        StrongObj(self);
        if (self) {
            if (!error) {
                if (![invitationsArray containsObject:self.currentModel]) {
                    dispatch_main_async_safe(^{
                        self.revokeButton.backgroundColor = [UIColor grayColor];
                        self.revokeButton.enabled = NO;
                        self.reSendButton.backgroundColor = [UIColor grayColor];
                        self.reSendButton.enabled = NO;
                    });
                }
            }
        }
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLayoutSubviews {
    self.bgScrollView.contentSize = CGSizeMake(0, 600);
}
- (void)commomInit {
    self.navigationController.navigationBarHidden = NO;
//    self.navigationItem.title = self.currentModel.inviteeEmail;
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UIScrollView *bgView = [[ UIScrollView alloc]init];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    self.bgScrollView = bgView;
    NXProjectMemberDetailHeaderView *headerView = [[NXProjectMemberDetailHeaderView alloc]init];

    headerView.nameStr = _currentModel.displayName;
    headerView.nameLabel.text = _currentModel.displayName;

    //headerView.avatarImageView.image = [UIImage imageNamed:@"Account"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.currentModel.inviteTime/1000]];
    NSString *invitedStr = NSLocalizedString(@"UI_INVITED", NULL);
    NSString *astr = [NSString stringWithFormat:@"%@ %@",invitedStr,strDate];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:astr];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, invitedStr.length)];
    headerView.joinTimeLabel.attributedText = attrStr;
    [bgView addSubview:headerView];
    UILabel * invitedByLabel = [[UILabel alloc]init];
     NSString *invitedByStr = NSLocalizedString(@"UI_INVITE_BY",NULL);
    NSString *inviterStr = [NSString stringWithFormat:@"%@ %@",invitedByStr,self.currentModel.inviterDisplayName];
    NSMutableAttributedString *inviteStr = [[NSMutableAttributedString alloc]initWithString:inviterStr];
    [inviteStr addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, invitedByStr.length)];
    invitedByLabel.attributedText = inviteStr;
    invitedByLabel.textAlignment =  NSTextAlignmentCenter;
    invitedByLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [bgView addSubview:invitedByLabel];
    
    UIButton *resendBtn = [[UIButton alloc]init];
    [resendBtn setTitle:NSLocalizedString(@"UI_RESEND_INVITATION", NULL) forState:UIControlStateNormal];
    resendBtn.backgroundColor = RMC_MAIN_COLOR;
    [resendBtn addTarget:self action:@selector(resendInvitation:) forControlEvents:UIControlEventTouchUpInside];
    [resendBtn cornerRadian:4];
    resendBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    self.reSendButton = resendBtn;
    [bgView addSubview:resendBtn];
    
    UIButton *revokeBtn = [[UIButton alloc]init];
    revokeBtn.backgroundColor = [UIColor colorWithRed:227.0/255.0 green:84.0/255.0 blue:84.0/255.0 alpha:1.0];
    [revokeBtn setTitle:NSLocalizedString(@"UI_REVOKE_INVITATION", NULL) forState:UIControlStateNormal];
    [revokeBtn addTarget:self action:@selector(revokeInvitation:) forControlEvents:UIControlEventTouchUpInside];
    [revokeBtn cornerRadian:4];
    revokeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    self.revokeButton = revokeBtn;
    [bgView addSubview:revokeBtn];
    if (!self.isOwerByMe) {
        revokeBtn.hidden = YES;
        resendBtn.hidden = YES;
    }
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(bgView).offset(20);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@280);
    }];
    [invitedByLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerView.mas_bottom);
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view).multipliedBy(0.9);
        make.height.equalTo(@40);
    }];
    [resendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(invitedByLabel.mas_bottom).offset(35);
        make.right.equalTo(self.view.mas_centerX).offset(-20);
        make.width.equalTo(@120);
        make.height.equalTo(@44);
        
    }];
    [revokeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(invitedByLabel.mas_bottom).offset(35);
        make.left.equalTo(self.view.mas_centerX).offset(20);
        make.width.equalTo(@120);
        make.height.equalTo(@44);
        
    }];
    
}

#pragma mark --- >resend
- (void)resendInvitation:(UIButton *)sender {
    [NXMBManager showLoadingToView:self.view];
    WeakObj(self);
    [[NXLoginUser sharedInstance].myProject resendProjectInvitation:self.currentModel withComoletion:^(NSString *statusCode, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            StrongObj(self);
            [NXMBManager hideHUDForView:self.view];
            if (!error&&[statusCode isEqualToString:@"200"]) {
                
                [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_RESEND_INVITATION_SUCCESS", nil) hideAnimated:YES afterDelay:1.5];
                self.reSendButton.backgroundColor = [UIColor grayColor];
                self.reSendButton.enabled = NO;
                 [self performSelector:@selector(closePage) withObject:self afterDelay:1.5];
            }
            else
            {
                [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_INVITE_FAILED", nil) hideAnimated:YES afterDelay:1.5];
                [self performSelector:@selector(closePage) withObject:self afterDelay:1.8];
            }
        });
        
    }];

}
#pragma mark ----->revoke
- (void)revokeInvitation:(UIButton *)sender {
    
     NSString *message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"MSG_DO_YOU_WANT_TO_REMOVE", NULL), self.currentModel.inviteeEmail];
    [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message: message style:UIAlertControllerStyleAlert cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherActionTitles:@[NSLocalizedString(@"UI_BOX_OK", NULL)] inViewController:self position:self.view tapBlock:^(UIAlertAction *action, NSInteger index) {
        if (index == 1) {
            [NXMBManager showLoadingToView:self.view];
            WeakObj(self);
            [[NXLoginUser sharedInstance].myProject revokeProjectInvitation:self.currentModel withComoletion:^(NSString *statusCode, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                StrongObj(self);
                [NXMBManager hideHUDForView:self.view];
                if (!error&&[statusCode isEqualToString:@"200"]) {
    
                    [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_REVOKE_INVITATION_SUCCESS", nil) hideAnimated:YES afterDelay:1.5];
                    self.revokeButton.backgroundColor = [UIColor grayColor];
                    self.revokeButton.enabled = NO;
                    self.reSendButton.backgroundColor = [UIColor grayColor];
                    self.reSendButton.enabled = NO;
                    [self performSelector:@selector(closePage) withObject:self afterDelay:1.5];
                }
                else
                {
                    [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_REVOKE_INVITATION_FAILED", nil) hideAnimated:YES afterDelay:1.5];
                    [self performSelector:@selector(closePage) withObject:self afterDelay:1.8];
                }
            });

}];
        }
    }];
     }

- (void)closePage {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
