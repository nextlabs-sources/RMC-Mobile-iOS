//
//  NXInviteMessageCell.m
//  nxrmc
//
//  Created by nextlabs on 1/12/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXInviteMessageCell.h"

#import "Masonry.h"
#import "UIView+UIExt.h"
#import "NXPendingProjectInvitationModel.h"
#import "NXProjectModel.h"
@interface NXInviteMessageCell ()

@property(nonatomic, weak) UILabel *messageLabel;
@property(nonatomic, weak) UIButton *confirmButton;

@end

@implementation NXInviteMessageCell

//- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
//    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//        [self commonInit];
//    }
//    return self;
//}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}
- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
}
- (void)setModel:(id)model {
    if ([model isKindOfClass:[NXPendingProjectInvitationModel class]]) {
        NXPendingProjectInvitationModel *pendingModel =(NXPendingProjectInvitationModel *)model;
        NSMutableAttributedString *name = [[NSMutableAttributedString alloc] initWithString:pendingModel.inviterDisplayName attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:40/255.0 green:125/255.0 blue:240/255.0 alpha:1], NSFontAttributeName:[UIFont systemFontOfSize:14]}];
        NSAttributedString *message = [[NSAttributedString alloc] initWithString:@" has invited you to join " attributes:@{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName:[UIFont systemFontOfSize:14]}];
        NSAttributedString *protect = [[NSAttributedString alloc] initWithString:pendingModel.projectInfo.name attributes:@{NSForegroundColorAttributeName : [UIColor blueColor], NSFontAttributeName:[UIFont systemFontOfSize:14]}];
        
        [name appendAttributedString:message];
        [name appendAttributedString:protect];
        self.messageLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        self.messageLabel.attributedText = name;
    }
    
    
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self cornerRadian:5];
    [self.confirmButton cornerRadian:3];
    [self.confirmButton borderWidth:0.1];
    [self.confirmButton borderColor:[UIColor lightGrayColor]];
    
    [self.confirmButton addShadow:UIViewShadowPositionTop|UIViewShadowPositionLeft|UIViewShadowPositionBottom|UIViewShadowPositionRight color:[UIColor blackColor] width:0.5 Opacity:1];
    [self addShadow:UIViewShadowPositionTop|UIViewShadowPositionLeft|UIViewShadowPositionBottom|UIViewShadowPositionRight color:[UIColor blackColor] width:0.2 Opacity:0.5];
}
#pragma mark
- (void)confirm:(id)sender {
    if (self.clickAcceptFinishedBlock) {
        self.clickAcceptFinishedBlock(nil);
    }
}

- (void)cancel:(id)sender {
    if (self.clickIgnoreFinishedBlock) {
        self.clickIgnoreFinishedBlock(nil);
    }
    
}

#pragma mark
- (void)commonInit {
    self.backgroundColor = [UIColor whiteColor];
    UILabel *messageLabel = [[UILabel alloc] init];
    [self.contentView addSubview:messageLabel];
    
    UIButton *confirmButton = [[UIButton alloc] init];
    [self.contentView addSubview:confirmButton];
    
    UIButton *cancelButton = [[UIButton alloc] init];
    [self.contentView addSubview:cancelButton];
    
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    [messageLabel setAdjustsFontSizeToFitWidth:YES];
    [confirmButton setTitle:@" Accept Invitation " forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:12];
    
    [cancelButton setTitle:@"Decline" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:12];
    self.messageLabel = messageLabel;
    self.confirmButton = confirmButton;
    
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(kMargin);
        make.left.equalTo(self.contentView).offset(kMargin);
        make.right.equalTo(self.contentView).offset(-kMargin);
    }];
    
    [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(messageLabel.mas_bottom).offset(kMargin*1.5);
        make.right.equalTo(self.contentView.mas_centerX).offset(-kMargin*2);
        make.height.equalTo(@(30));
        make.width.equalTo(@100);
        make.bottom.equalTo(self.contentView).offset(-kMargin);
    }];
    
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(messageLabel.mas_bottom).offset(kMargin*1.5);
        make.left.equalTo(self.contentView.mas_centerX).offset(kMargin*2);
        make.height.equalTo(@(30));
        make.width.equalTo(@100);
        make.bottom.equalTo(self.contentView).offset(-kMargin);
    }];
    
}

@end
