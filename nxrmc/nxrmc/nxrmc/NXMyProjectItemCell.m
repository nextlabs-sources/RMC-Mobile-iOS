//
//  NXMyProjectItemCell.m
//  nxrmc
//
//  Created by nextlabs on 1/20/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXMyProjectItemCell.h"

#import "UIView+UIExt.h"
#import "Masonry.h"

#import "NXRMCDef.h"
#import "NXProjectMemberHeaderView.h"
@interface NXMyProjectItemCell()<UIGestureRecognizerDelegate>

//@property(nonatomic, weak) UIImageView *thumbImageView;

//@property(nonatomic, weak) UILabel *inviteLabel;
@property(nonatomic, weak) UILabel *filesLabel;
@property(nonatomic, strong) NXProjectMemberHeaderView *headerView;

@end

@implementation NXMyProjectItemCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
//         [self addGestureRecognizer];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    [self.thumbImageView borderColor:[UIColor whiteColor]];
//    [self.thumbImageView borderWidth:5];
//    [self.thumbImageView cornerRadian:self.thumbImageView.bounds.size.width/2];
//    self.thumbImageView.clipsToBounds = YES;
}

- (void)setModel:(id)model {
    _model = model;
    self.titleLabel.text = self.model.name;
    self.titleLabel.accessibilityValue = @"HOME_PAGE_PROJECT_TITLE_LAB";
    self.filesLabel.text = (self.model.totalFiles > 0)? [NSString stringWithFormat:@"%ld %@", self.model.totalFiles, NSLocalizedString(@"Files", nil)]:NSLocalizedString(@"No Files", NULL);
//    self.inviteLabel.text = NSLocalizedString(@"Invite People", NULL);
    for (UILabel *label in self.headerView.subviews) {
        [label removeFromSuperview];
    }
    NSMutableArray *itemNames = [NSMutableArray array];
    for (NXProjectMemberModel *item in self.model.homeShowMembers) {
        [itemNames addObject:item.displayName];
    }
    if (self.model.totalMembers > self.model.homeShowMembers.count) {
        for (int i = 0; i < self.model.totalMembers - self.model.homeShowMembers.count; i++) {
            [itemNames addObject:@""];
        }
    }
    self.headerView.items = itemNames;
}

#pragma mark
- (void)commonInit {
    self.backgroundColor = [UIColor whiteColor];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [self.contentView addSubview:titleLabel];
    NXProjectMemberHeaderView *headerView = [[NXProjectMemberHeaderView alloc]init];
    [self.contentView addSubview:headerView];
    self.headerView = headerView;
//    UIImageView *thumbImageView = [[UIImageView alloc] init];
//    [self.contentView addSubview:thumbImageView];
//    
//    UILabel *inviteLabel = [[UILabel alloc] init];
//    [self.contentView addSubview:inviteLabel];
//    
    UILabel *filesLabel = [[UILabel alloc] init];
    [self.contentView addSubview:filesLabel];
    
    titleLabel.textColor = RMC_MAIN_COLOR;
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    
    
//    thumbImageView.contentMode = UIViewContentModeScaleAspectFit;
//    thumbImageView.image = [UIImage imageNamed:@"Profile"];
//    
//    inviteLabel.textColor = [UIColor blueColor];
//    inviteLabel.font = [UIFont boldSystemFontOfSize:14];
//    inviteLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
//    inviteLabel.numberOfLines = 1;
    
    
    filesLabel.textColor = [UIColor lightGrayColor];
    filesLabel.font = [UIFont boldSystemFontOfSize:12];
    filesLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    filesLabel.numberOfLines = 1;
    
    
//    self.thumbImageView  = thumbImageView;
    self.titleLabel = titleLabel;
//    self.inviteLabel = inviteLabel;
    self.filesLabel = filesLabel;
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(kMargin * 2);
        make.left.equalTo(self.contentView).offset(kMargin * 2);
        make.right.equalTo(self.contentView).offset(-kMargin * 2);
    }];
    
//    [thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(self.contentView);
//        make.left.equalTo(titleLabel);
//        make.width.and.height.equalTo(self.contentView.mas_height).multipliedBy(0.2);
//    }];
    
//    [inviteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(thumbImageView);
//        make.left.equalTo(thumbImageView.mas_right).offset(kMargin);
//        make.right.equalTo(self.contentView).offset(-kMargin);
//    }];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(5);
        make.right.equalTo(self.contentView).offset(-kMargin);
        make.top.equalTo(titleLabel.mas_bottom).offset(15);
        make.height.equalTo(@40);
    }];
    [filesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel);
        make.bottom.equalTo(self.contentView).offset(-kMargin * 2);
    }];
    
//    filesLabel.backgroundColor = [UIColor blueColor];
//    thumbImageView.backgroundColor = [UIColor redColor];
//    titleLabel.backgroundColor = [UIColor greenColor];
//    inviteLabel.backgroundColor = [UIColor magentaColor];
}

//- (void)addGestureRecognizer
//{
//    _inviteLabel.userInteractionEnabled = YES;
//    
//    UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(inviteLabelTouchUpInside:)];
//    
//    labelTapGestureRecognizer.delegate = self;
//    [_inviteLabel addGestureRecognizer:labelTapGestureRecognizer];
//}


#pragma -mark Button Click Method

-(void)inviteLabelTouchUpInside:(UITapGestureRecognizer *)recognizer
{
    if (_inviteLabelTouchUpInside){
        _inviteLabelTouchUpInside(_model);
    }
}

- (void)setInviteLabelTouchUpInside:(inviteLabelTouchUpInside)inviteLabelTouchUpInside
{
    _inviteLabelTouchUpInside = inviteLabelTouchUpInside;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

@end
