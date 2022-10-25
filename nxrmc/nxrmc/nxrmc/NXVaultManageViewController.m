//
//  NXVaultManageViewController.m
//  nxrmc
//
//  Created by nextlabs on 1/3/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXVaultManageViewController.h"

#import "NXVaultManagePeopleVC.h"

#import "Masonry.h"
#import "NXRMCUIDef.h"
#import "UIView+UIExt.h"
#import "NXVaultManageInfoView.h"
#import "NXRightsDisplayView.h"
#import "NXEmailView.h"

#import "NXMBManager.h"
#import "UIImage+ColorToImage.h"

#import "NXLRights.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXMyVaultFile.h"

@interface NXVaultManageViewController ()<UIGestureRecognizerDelegate, NXOperationVCDelegate>

@property(nonatomic, strong) NXVaultManageInfoView *infoView;
@property(nonatomic, strong) NXRightsDisplayView *rightsDisplayView;
@property(nonatomic, strong) NXEmailView *emailsView;
@property(nonatomic, strong) UILabel *sharewithPromptLabel;
@property(nonatomic, strong) UIButton *manageButton;
@property(nonatomic, strong) UIButton *revokeButton;

@end

@implementation NXVaultManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
    [NXMBManager showLoadingToView:self.mainView];
    [self updateData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat height = CGRectGetHeight(self.infoView.bounds) + CGRectGetHeight(self.rightsDisplayView.bounds)  + CGRectGetHeight(self.sharewithPromptLabel.bounds) + CGRectGetHeight(self.emailsView.bounds) + CGRectGetHeight(self.revokeButton.bounds) ;
    
    CGFloat contentHeight = height + kMargin + kMargin + kMargin + (self.revokeButton?kMargin * 3:0);
    
    if (self.mainView.bounds.size.height > contentHeight) {
        self.mainView.contentSize = CGSizeMake(CGRectGetWidth(self.mainView.bounds), CGRectGetHeight(self.mainView.bounds) + 1);
    } else {
        //kMargin * 4 should be researched. for now just a demo
        self.mainView.contentSize = CGSizeMake(CGRectGetWidth(self.mainView.bounds), contentHeight + 1);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)dealloc {
    DLog(@"%s", __FUNCTION__);
}

#pragma mark

- (void)manageClick:(id)sender {
    NXVaultManagePeopleVC *vc = [[NXVaultManagePeopleVC alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.fileItem = self.fileItem;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)revokeButtonClicked:(id)sender {
    NSString *message = [NSString stringWithFormat:@"%@", NSLocalizedString(@"MSG_REMOVE_ALL_RIGHTS_WARNING", NULL)];
    WeakObj(self);
    [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message: message style:UIAlertControllerStyleAlert cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherActionTitles:@[NSLocalizedString(@"UI_BOX_OK", NULL)] inViewController:self position:self.view tapBlock:^(UIAlertAction *action, NSInteger index) {
        if (index == 1) {
            [NXMBManager showLoadingToView:self.view];
            [[NXLoginUser sharedInstance].nxlOptManager revokeDocument:self.fileItem withCompletion:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    StrongObj(self);
                    if (self) {
                        [NXMBManager hideHUDForView:self.view];
                        if (error) {
                            [NXMBManager showMessage:error.localizedDescription toView:self.view hideAnimated:YES afterDelay:kDelay];
                            return ;
                        }
                        [NXMBManager showMessage:NSLocalizedString(@"MSG_FILE_HAS_BEEN_REVOKED", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
                        if (self.manageRevokeFinishedBlock) {
                            self.manageRevokeFinishedBlock(error);
                        }
                        [self performSelector:@selector(backButtonClicked:) withObject:nil afterDelay:(kDelay + 0.5)];
                    }
                });
            }];
        }
    }];
}

#pragma mark
- (void)updateData {
    WeakObj(self);
    [[NXLoginUser sharedInstance].myVault metaData:self.fileItem withCompletetino:^(NXMyVaultFile *file, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            StrongObj(self);
            [NXMBManager hideHUDForView:self.mainView];
            if (error) {
                [NXMBManager showMessage:error.localizedDescription toView:self.view hideAnimated:YES afterDelay:kDelay];
                return;
            }
            self.fileItem.rights = file.rights;
            self.fileItem.recipients = file.recipients;
            
            [self updateUI:file];
        });
    }];
}

- (void)updateUI:(NXMyVaultFile *)file {
    NXLRights *rights = [[NXLRights alloc] initWithRightsObs:file.rights obligations:nil];
    [rights setFileValidateDate:file.validateFileModel];
    self.infoView.model = file;
    
    self.rightsDisplayView.rights = rights;
    [self.rightsDisplayView showSteward:YES];
    [self.rightsDisplayView setIsOwner:YES];
    self.emailsView.emailsArray = [NSMutableArray arrayWithArray:file.recipients];
    
    if (!file.recipients.count) {
        self.sharewithPromptLabel.hidden = YES;
    } else {
        self.sharewithPromptLabel.hidden = NO;
    }
    
    if (file.isRevoked) {
        self.revokeButton.hidden = YES;
    } else {
        self.revokeButton.hidden = NO;
    }
    
    [self.mainView addSubview:self.infoView];
    [self.infoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(kMargin);
        make.top.equalTo(self.mainView).offset(kMargin);
        make.right.equalTo(self.view).offset(-kMargin);
    }];
    
    [self.mainView addSubview:self.rightsDisplayView];
    [self.rightsDisplayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(kMargin);
        make.right.equalTo(self.view).offset(-kMargin);
        make.top.equalTo(self.infoView.mas_bottom).offset(kMargin);
    }];
    
    [self.mainView addSubview:self.sharewithPromptLabel];
 
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [self.sharewithPromptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).offset(kMargin);
                make.top.equalTo(self.rightsDisplayView.mas_bottom).offset(kMargin);
            }];
        }
    }
    else
    {
        [self.sharewithPromptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(kMargin);
            make.top.equalTo(self.rightsDisplayView.mas_bottom).offset(kMargin);
        }];
    }
    
    [self.mainView addSubview:self.emailsView];
    [self.emailsView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(kMargin);
        make.right.equalTo(self.view).offset(-kMargin);
        make.top.equalTo(self.sharewithPromptLabel.mas_bottom).offset(0);
    }];
    
    if (file.isRevoked) {
        self.revokeButton = nil;
        self.manageButton = nil;
        self.manageButton.hidden = YES;
    } else {
        [self.mainView addSubview:self.manageButton];
        [self.manageButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.baseline.equalTo(self.sharewithPromptLabel);
            make.right.equalTo(self.view).offset(-kMargin);
            make.left.equalTo(self.sharewithPromptLabel.mas_right).offset(kMargin);
            make.height.equalTo(@30);
            make.width.equalTo(@80);
        }];
        
        [self.mainView addSubview:self.revokeButton];
        [self.revokeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.emailsView.mas_bottom).offset(3*kMargin);
            make.centerX.equalTo(self.view);
            make.width.equalTo(self.view).multipliedBy(0.6);
            make.height.equalTo(@(40));
        }];
    }
    
    self.revokeButton.layer.borderColor = [UIColor redColor].CGColor;
    self.revokeButton.layer.borderWidth = 0.6;
    self.revokeButton.layer.cornerRadius = 5;
    
    [self.mainView layoutIfNeeded];
}
#pragma mark - NXOperationVCDelegate
- (void)viewcontroller:(NXFileOperationPageBaseVC *)vc didfinishedOperationFile:(NXFileBase *)file toFile:(NXFileBase *)resultFile {
    [self updateData];
}

#pragma mark -
- (void)commonInit {
    self.topView.model = self.fileItem;
    WeakObj(self);
    self.topView.backClickAction = ^(id sender) {
        StrongObj(self);
        [self backButtonClicked:nil];
    };
    
    [self.bottomView removeFromSuperview];
    [self.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
    }];
    
    NXVaultManageInfoView *infoView = [[NXVaultManageInfoView alloc]initWithFrame:CGRectZero];
    self.infoView = infoView;
    
    NXRightsDisplayView *displayView = [[NXRightsDisplayView alloc] init];
    self.rightsDisplayView = displayView;
    
    NXEmailView *emailView = [[NXEmailView alloc] init];
    emailView.editable = NO;
    self.emailsView = emailView;
    self.emailsView.promptMessage = @"";
    
    UILabel *promptLabel = [[UILabel alloc] init];
    promptLabel.text = NSLocalizedString(@"UI_SHARE_WITH", NULL);
    self.sharewithPromptLabel = promptLabel;
    
#if 0
    emailView.backgroundColor = [UIColor redColor];
    infoView.backgroundColor = [UIColor greenColor];
    manageButton.backgroundColor = [UIColor orangeColor];
#endif
}

- (UIButton *)revokeButton {
    if (!_revokeButton) {
        UIButton *revokeButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [revokeButton addTarget:self action:@selector(revokeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [revokeButton setTitle:NSLocalizedString(@"UI_REVOKE_ALL_RIGHTS", NULL) forState:UIControlStateNormal];
        [revokeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [revokeButton cornerRadian:4];
        _revokeButton = revokeButton;
    }
    return _revokeButton;
}

- (UIButton *)manageButton {
    if (!_manageButton) {
        UIButton *manageButton = [[UIButton alloc] init];
        [manageButton setTitle:NSLocalizedString(@"UI_MANAGE", NULL) forState:UIControlStateNormal];
        [manageButton addTarget:self action:@selector(manageClick:) forControlEvents:UIControlEventTouchUpInside];
        manageButton.titleLabel.font = [UIFont systemFontOfSize:kNormalFontSize];
        [manageButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _manageButton = manageButton;
    }
    return _manageButton;
}

@end
