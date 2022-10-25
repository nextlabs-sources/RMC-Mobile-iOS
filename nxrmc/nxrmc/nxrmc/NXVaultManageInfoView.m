//
//  NXVaultManageInfoView.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/4/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXVaultManageInfoView.h"

#import "Masonry.h"
#import "NXMBManager.h"
#import "UIView+UIExt.h"

#import "NXCommonUtils.h"

@interface NXVaultManageInfoView ()

//@property(nonatomic, weak, readonly) UIImageView *thumbImageView;
//@property(nonatomic, weak, readonly) UILabel *nameLabel;
@property(nonatomic, weak, readonly) UILabel *promptLabel;
@property(nonatomic, weak, readonly) UILabel *timeLabel;

@property(nonatomic, weak, readonly) UILabel *linkPromptLabel;
@property(nonatomic, weak, readonly) UILabel *linkLabel;

@property(nonatomic, weak) UILabel *revokeLabel;


@end
@implementation NXVaultManageInfoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    
    return self;
}

- (void)setModel:(NXMyVaultFile *)model {
    _model = model;
    
    if (self.model.isDeleted) {
        [self.revokeLabel setText:NSLocalizedString(@"UI_FILE_DELETED", NULL)];
        self.revokeLabel.hidden = NO;
        return;
    } else if (self.model.isRevoked) {
        [self.revokeLabel setText:NSLocalizedString(@"UI_FILE_REVOKED", NULL)];
        self.revokeLabel.hidden = NO;
        return;
    } else {
        self.revokeLabel.hidden = YES;
    }
    
    if (model.isShared) {
        self.promptLabel.text = NSLocalizedString(@"UI_SHARE_ON", NULL);
    } else {
        self.promptLabel.text = NSLocalizedString(@"UI_PROTECT_ON", NULL);
    }
    
    self.timeLabel.text = [NXCommonUtils timeStringFrom1970TimeInterval:model.sharedOn.unsignedLongLongValue orDate:nil]?:@"";
    
    if (self.timeLabel.text.length == 0) {
        NSDate *lastModifiedDate = [NSDate dateWithTimeIntervalSince1970:model.lastModifiedTime.longLongValue];
        NSDateFormatter* dateFormtter = [[NSDateFormatter alloc] init];
        [dateFormtter setDateFormat:@"dd MMM yyyy, HH:mm"];
        NSString *lastModifiedStr = [dateFormtter stringFromDate:lastModifiedDate];
        self.timeLabel.text = lastModifiedStr;
    }
    
    if (model.fileLink) {
        NSAttributedString *fileLink = [[NSAttributedString alloc] initWithString:model.fileLink attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12], NSForegroundColorAttributeName:[UIColor lightGrayColor],NSObliquenessAttributeName:@(0.2)}];
        self.linkLabel.attributedText = fileLink;
        self.linkPromptLabel.text = NSLocalizedString(@"UI_FILE_ACCESS_LINK", NULL);
    } else {
        self.linkLabel.text = model.fileLink;
        self.linkPromptLabel.text = @"";
    }
}

#pragma mark
- (void)click:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (self.linkLabel.text) {
        pasteboard.string = self.linkLabel.text;
        [NXMBManager showMessage:NSLocalizedString(@"MSG_COPY_LINK_SUCCESSFULLY", NULL) hideAnimated:YES afterDelay:0.5];
    } else {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_NO_COPY_LINK", NULL) hideAnimated:YES afterDelay:0.5];
    }
}

#pragma mark
- (void)commonInit {
//    UIImageView *imageView = [[UIImageView alloc] init];
//    imageView.contentMode = UIViewContentModeScaleAspectFit;
//    [self addSubview:imageView];
//    
//    UILabel *nameLabel = [[UILabel alloc] init];
//    nameLabel.font = [UIFont systemFontOfSize:kNormalFontSize];
//    [self addSubview:nameLabel];
    
    UILabel *promptLabel = [[UILabel alloc] init];
    promptLabel.font = [UIFont systemFontOfSize:kNormalFontSize];
    [self addSubview:promptLabel];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.font = [UIFont systemFontOfSize:kMiniFontSize];
    [self addSubview:timeLabel];
    
    UILabel *linkPromptLabel = [[UILabel alloc] init];
    linkPromptLabel.font = [UIFont systemFontOfSize:kNormalFontSize];
    linkPromptLabel.text = NSLocalizedString(@"UI_FILE_ACCESS_LINK", NULL);
    [self addSubview:linkPromptLabel];
    
    UILabel *linkLabel = [[UILabel alloc] init];
    linkLabel.font = [UIFont systemFontOfSize:kMiniFontSize];
    linkLabel.textColor = [UIColor lightGrayColor];
    linkLabel.numberOfLines = 1;
    linkLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [self addSubview:linkLabel];
    
    UIButton *copyButton = [[UIButton alloc] init];
    [copyButton setTitle:NSLocalizedString(@"UI_COPY_LINK", NULL) forState:UIControlStateNormal];
    [copyButton addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    copyButton.titleLabel.font = [UIFont systemFontOfSize:kMiniFontSize];
    copyButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [copyButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    [self addSubview:copyButton];
    
    UILabel *revokeLabel = [[UILabel alloc] init];
    revokeLabel.backgroundColor = [UIColor colorWithHexString:@"#f2f2f2"];
   // [revokeLabel setText:NSLocalizedString(@"This file has been revoked", NULL)];
    revokeLabel.numberOfLines = 0;
    revokeLabel.textColor = [UIColor redColor];
    revokeLabel.textAlignment = NSTextAlignmentCenter;
    revokeLabel.layer.borderColor = [UIColor redColor].CGColor;
    [revokeLabel cornerRadian:3];
    revokeLabel.layer.borderWidth = 1;
    
    self.revokeLabel = revokeLabel;
    [self addSubview:revokeLabel];
    
//    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self);
//        make.left.equalTo(self);
//        make.width.equalTo(@40);
//        make.height.equalTo(@60);
//    }];
//    
//    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(imageView);
//        make.left.equalTo(imageView.mas_right).offset(kMargin/2);
//        make.right.equalTo(self).offset(-kMargin);
//    }];
    
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.mas_safeAreaLayoutGuideTop).offset(kMargin/2);
                make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(kMargin);
                make.right.equalTo(self.mas_safeAreaLayoutGuideRight).offset(-kMargin);
            }];
        }
    }
    else
    {
        [promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(kMargin/2);
            make.left.equalTo(self).offset(kMargin);
            make.right.equalTo(self).offset(-kMargin);
        }];
    }
    
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(promptLabel.mas_bottom).offset(kMargin/4);
        make.left.equalTo(promptLabel);
        make.right.equalTo(promptLabel);
    }];
    
    [linkPromptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(timeLabel.mas_bottom).offset(kMargin);
        make.left.and.right.equalTo(timeLabel);
    }];
    
    [linkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(linkPromptLabel.mas_bottom).offset(kMargin/4);
        make.left.and.right.equalTo(linkPromptLabel);
    }];
    
    [copyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(linkLabel.mas_bottom).offset(kMargin/4);
        make.left.equalTo(linkLabel);
        make.height.equalTo(@25);
        make.bottom.equalTo(self.mas_bottom).offset(-kMargin/2);
    }];
    
    [revokeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(promptLabel.mas_top).offset(-kMargin/4);
        make.left.equalTo(promptLabel);
        make.right.equalTo(promptLabel).offset(kMargin/4);
        make.bottom.equalTo(copyButton).offset(kMargin/4);
    }];
    
//    _thumbImageView = imageView;
//    _nameLabel = nameLabel;
    
    _promptLabel = promptLabel;
    _timeLabel = timeLabel;
    _linkLabel = linkLabel;
    _linkPromptLabel = linkPromptLabel;
}

@end
