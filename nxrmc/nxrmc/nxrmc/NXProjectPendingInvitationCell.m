//
//  NXProjectPendingInvitationCell.m
//  nxrmc
//
//  Created by nextlabs on 1/20/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectPendingInvitationCell.h"

#import "Masonry.h"
#import "NXRMCDef.h"

@interface NXProjectPendingInvitationCell ()


@property(nonatomic, weak) UILabel *inviteLabel;
@property(nonatomic, weak) UILabel *ownerLabel;

@end

@implementation NXProjectPendingInvitationCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)setModel:(id)model {
    _model = model;
    self.inviteLabel.text = self.model.inviterDisplayName;
    self.titleLabel.text = self.model.projectInfo.name;
    self.ownerLabel.text = self.model.projectInfo.projectOwner.name;
}

#pragma mark
- (void)commonInit {
    self.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [self.contentView addSubview:titleLabel];
    
    UILabel *promptOwner = [[UILabel alloc] init];
    [self.contentView addSubview:promptOwner];
    
    UILabel *promptInviteLabel = [[UILabel alloc] init];
    [self.contentView addSubview:promptInviteLabel];
    
    UILabel *ownerLabel = [[UILabel alloc] init];
    ownerLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [self.contentView addSubview:ownerLabel];
    
    UILabel *inviteLabel = [[UILabel alloc] init];
    inviteLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [self.contentView addSubview:inviteLabel];
    
    UIButton *acceptButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.contentView addSubview:acceptButton];
    
    UIButton *ignoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:ignoreButton];
    
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    
    ownerLabel.textColor = [UIColor blackColor];
    ownerLabel.font = [UIFont boldSystemFontOfSize:12];
    
    inviteLabel.textColor = [UIColor blackColor];
    inviteLabel.font = [UIFont boldSystemFontOfSize:12];

    promptOwner.textColor = [UIColor lightGrayColor];
    promptOwner.font = [UIFont boldSystemFontOfSize:10];
    promptOwner.text = NSLocalizedString(@"UI_OWNER", NULL);
    
    promptInviteLabel.textColor = [UIColor lightGrayColor];
    promptInviteLabel.font = [UIFont boldSystemFontOfSize:10];
    promptInviteLabel.text = NSLocalizedString(@"UI_INVITE_BY", NULL);
    
    [acceptButton setTitle:NSLocalizedString(@"UI_ACCECT_INVITATION", NULL) forState:UIControlStateNormal];
    [acceptButton setTitleColor:RMC_TINT_BTN_BLUE forState:UIControlStateNormal];
    acceptButton.backgroundColor = [UIColor whiteColor];
    acceptButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    acceptButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [acceptButton addTarget:self action:@selector(acceptBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    ignoreButton.backgroundColor = [UIColor whiteColor];
    [ignoreButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [ignoreButton setTitle:NSLocalizedString(@"UI_DECLINE", NULL) forState:UIControlStateNormal];
     ignoreButton.titleLabel.textAlignment = NSTextAlignmentRight;
    ignoreButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [ignoreButton addTarget:self action:@selector(ignoreBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.titleLabel = titleLabel;
    self.inviteLabel = inviteLabel;
    self.ownerLabel = ownerLabel;
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(kMargin * 2);
        make.left.equalTo(self.contentView).offset(kMargin);
        make.right.equalTo(self.contentView).offset(-kMargin);
    }];
    
    [promptOwner mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView.mas_centerY).offset(-kMargin/4);
        make.left.equalTo(titleLabel);
    }];
    
    [promptInviteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(promptOwner.mas_right).offset(kMargin);
        make.top.equalTo(promptOwner);
        make.right.equalTo(titleLabel);
        make.width.equalTo(promptOwner);
    }];
    
    [ownerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_centerY).offset(kMargin/4);
        make.left.equalTo(self.contentView).offset(kMargin);
        make.width.equalTo(titleLabel).multipliedBy(0.45);
    }];
    
    [inviteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-kMargin);
        make.top.equalTo(ownerLabel);
         make.width.equalTo(titleLabel).multipliedBy(0.45);
    }];
    
    [acceptButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView).offset(-kMargin);
        make.left.equalTo(titleLabel);
        make.width.equalTo(@40);
        make.height.equalTo(@40);
    }];
    
    [ignoreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(acceptButton.mas_right).offset(kMargin);
        make.centerY.equalTo(acceptButton);
        make.right.equalTo(titleLabel);
        make.width.equalTo(acceptButton);
    }];
    
//    titleLabel.backgroundColor = [UIColor blueColor];
//    ownerLabel.backgroundColor = [UIColor redColor];
//    inviteLabel.backgroundColor = [UIColor greenColor];
//    promptInviteLabel.backgroundColor = [UIColor magentaColor];
}

- (void)acceptBtnClicked:(UIButton *)button
{
    if (self.acceptInvitationBlock) {
        self.acceptInvitationBlock(self.model);
    }
}

- (void)ignoreBtnClicked:(UIButton *)button
{
    if (self.ignoreInvitationBlock) {
        self.ignoreInvitationBlock(self.model);
    }
}

@end
    
