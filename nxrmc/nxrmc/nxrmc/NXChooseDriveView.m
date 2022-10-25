//
//  NXChooseDriveView.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/5/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXChooseDriveView.h"

#import "Masonry.h"

@interface NXChooseDriveView()
@property(nonatomic, weak, readonly) UILabel *nameLabel;
@property(nonatomic, weak, readonly) UILabel *pathLabel;
@property(nonatomic, weak, readonly) UILabel *promptLabel;
@property(nonatomic, weak, readonly) UIButton *changeButton;
@property(nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation NXChooseDriveView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (void)setModel:(NSString *)model {
    if (model) {
        _model = model;
        self.pathLabel.text = model;
        self.pathLabel.accessibilityValue = @"CHANGE_PATH_LABEL";
        [self.changeButton setTitle:NSLocalizedString(@"UI_PROFILE_CHANGE_NAME", NULL) forState:UIControlStateNormal];
        self.changeButton.accessibilityValue = @"CHANGE_FILE_PATH";
    }
}
- (void)setFileName:(NSString *)fileName {
    if (fileName) {
        _fileName = fileName;
        self.nameLabel.text = fileName;
    }
}
- (void)setPromptMessage:(NSString *)promptMessage {
    _promptMessage = promptMessage;
    self.promptLabel.text = promptMessage;
}
- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
//    self.tapGesture.enabled = enabled;
    self.changeButton.hidden = !enabled;
}
- (void)setIsHiddenSmallPreview:(BOOL)isHiddenSmallPreview {
    if (isHiddenSmallPreview) {
        [self.fileImageView removeFromSuperview];
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(kMargin/2);
            make.left.equalTo(self).offset(kMargin/2);
            make.right.equalTo(self.changeButton.mas_left).offset(-kMargin/2);
        }];
        [self.promptLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).offset(kMargin/2);
            make.left.equalTo(self).offset(kMargin/2);
            make.right.equalTo(self.changeButton.mas_left).offset(-kMargin/2);
        }];
        
        [self.pathLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.changeButton.mas_left).offset(-kMargin/2);
            make.left.equalTo(self.promptLabel);
            make.top.equalTo(self.promptLabel.mas_bottom).offset(kMargin/2);
            make.bottom.equalTo(self).offset(-kMargin/2);
        }];
        
        [self.changeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.right.equalTo(self).offset(-kMargin/2);
            make.width.equalTo(@55);
        }];
    }
}
- (void)setIsForNewFolder:(BOOL)isForNewFolder {
    if (isForNewFolder) {
        [self.fileImageView removeFromSuperview];
        [self.nameLabel removeFromSuperview];
        [self.promptLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(kMargin/2);
            make.left.equalTo(self).offset(kMargin/2);
            make.right.equalTo(self.changeButton.mas_left).offset(-kMargin/2);
        }];
        
        [self.pathLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.changeButton.mas_left).offset(-kMargin/2);
            make.left.equalTo(self.promptLabel);
            make.top.equalTo(self.promptLabel.mas_bottom).offset(kMargin/2);
            make.bottom.equalTo(self).offset(-kMargin/2);
        }];
        
        [self.changeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.right.equalTo(self).offset(-kMargin/2);
            make.width.equalTo(@55);
        }];
    }
}
#pragma mark
- (void)click:(id)sender {
    if (self.clickActionBlock) {
        self.clickActionBlock(sender);
    }
}
- (void)clickFileImageView:(id)sender {
    if (self.clickImageViewBlock) {
        self.clickImageViewBlock(sender);
    }
}
#pragma mark
- (void)commonInit {
    self.backgroundColor = [UIColor colorWithHexString:@"#4f4f4f"];
    UILabel *nameLabel = [[UILabel alloc]init];
    nameLabel.textColor = [UIColor colorWithRed:9/256.0 green:233/256.0 blue:63/256.0 alpha:1];
    nameLabel.lineBreakMode = kCTLineBreakByTruncatingMiddle;
    nameLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:nameLabel];
    _nameLabel = nameLabel;
    UIImageView *imageView = [[UIImageView alloc]init];
    [self addSubview:imageView];
    self.fileImageView = imageView;
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [tap addTarget:self action:@selector(clickFileImageView:)];
    [imageView addGestureRecognizer:tap];
    self.tapGesture = tap;
    UILabel *promptlabel = [[UILabel alloc] init];
    promptlabel.text = NSLocalizedString(@"UI_FILE_WILL_BE_SAVED_TO", NULL);
    promptlabel.textColor = [UIColor whiteColor];
    promptlabel.font = [UIFont systemFontOfSize:kMiniFontSize];
    [self addSubview:promptlabel];
    
    UILabel *pathLabel = [[UILabel alloc] init];
    pathLabel.textColor = [UIColor whiteColor];
    pathLabel.text = NSLocalizedString(@"UI_SELECT_POSITION_TO_SAVE", NULL);
    pathLabel.numberOfLines = 0;
    pathLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    pathLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:pathLabel];
    
    UIButton *button = [[UIButton alloc] init];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:NSLocalizedString(@"UI_SELECT", NULL) forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14.5];
    [button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset(2);
        make.height.equalTo(self).multipliedBy(0.9);
        make.width.equalTo(imageView.mas_height);
    }];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kMargin/2);
        make.left.equalTo(imageView.mas_right).offset(kMargin/2);
        make.right.equalTo(button.mas_left).offset(-kMargin/2);
    }];
    [promptlabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLabel.mas_bottom).offset(kMargin/2);
        make.left.equalTo(imageView.mas_right).offset(kMargin/2);
        make.right.equalTo(button.mas_left).offset(-kMargin/2);
    }];
    
    [pathLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(button.mas_left).offset(-kMargin/2);
        make.left.equalTo(promptlabel);
        make.top.equalTo(promptlabel.mas_bottom).offset(kMargin/2);
        make.bottom.equalTo(self).offset(-kMargin/2);
    }];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-kMargin/2);
        make.width.equalTo(@55);
    }];
    _pathLabel = pathLabel;
    _changeButton = button;
    _promptLabel = promptlabel;
}

@end
