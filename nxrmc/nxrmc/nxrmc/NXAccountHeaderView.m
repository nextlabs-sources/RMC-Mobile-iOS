//
//  NXAccountHeaderView.m
//  nxrmc
//
//  Created by nextlabs on 11/30/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXAccountHeaderView.h"

#import "UIView+UIExt.h"
#import "Masonry.h"
#import "NXProjectMemberHeaderView.h"
#import "NXRMCDef.h"
@interface NXAccountHeaderView()
@property(nonatomic, strong) NXProjectMemberHeaderView *memHeaderLabel;
@end

@implementation NXAccountHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
/* hide user photo
    [self.avatarImageView borderColor:[UIColor whiteColor]];
    [self.avatarImageView borderWidth:5];
    [self.avatarImageView cornerRadian:self.avatarImageView.bounds.size.width/2];
    self.avatarImageView.clipsToBounds = YES;
*/
}

#pragma mark

- (void)clicked:(id)sender {
    if (self.tapclickBlock) {
        self.tapclickBlock(sender);
    }
}

#pragma mark
- (void)commonInit {
    NXProjectMemberHeaderView *memheaderLabel = [[NXProjectMemberHeaderView alloc]init];
    [self addSubview:memheaderLabel];
    self.memHeaderLabel = memheaderLabel;
    self.backgroundColor = RMC_MAIN_COLOR;
    
     /* hide user photo
      UIImageView *avatorImageView = [[UIImageView alloc] init];
      UILabel *label = [[UILabel alloc] init];
      [self addSubview:avatorImageView];
      [self addSubview:label];
      
      avatorImageView.contentMode = UIViewContentModeScaleAspectFill;
      avatorImageView.userInteractionEnabled = YES;
      
      label.font = [UIFont systemFontOfSize:14];
      label.textColor = [UIColor whiteColor];
      label.textAlignment = NSTextAlignmentCenter;
      label.userInteractionEnabled = YES;
      label.text = NSLocalizedString(@"Change Photo", NULL);
      
      _avatarImageView = avatorImageView;

    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] init];
    [gesture addTarget:self action:@selector(clicked:)];
    [label addGestureRecognizer:gesture];
    [avatorImageView addGestureRecognizer:gesture];
    
    [avatorImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kMargin);
        make.centerX.equalTo(self);
        make.height.equalTo(self).multipliedBy(0.5);
        make.width.equalTo(avatorImageView.mas_height);
    }];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(avatorImageView.mas_bottom).offset(kMargin);
        make.centerX.equalTo(self);
          }];
  */
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [memheaderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.mas_safeAreaLayoutGuideTop).offset(kMargin * 2);
                make.centerX.equalTo(self.mas_safeAreaLayoutGuideCenterX);
                make.height.equalTo(@80);
                make.width.equalTo(@90);
            }];
        }
    }
    else
    {
        [memheaderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(kMargin * 2);
            make.centerX.equalTo(self);
            make.height.equalTo(@80);
            make.width.equalTo(@90);
        }];
    }
  

//#if 1
//    avatorImageView.image = [UIImage imageNamed:@"Profile"];
//#endif
}
- (void)setNameStr:(NSString *)nameStr {
    self.memHeaderLabel.hidden = NO;
    self.memHeaderLabel.items = @[nameStr];
    self.memHeaderLabel.sizeWidth = 70;
}
@end
