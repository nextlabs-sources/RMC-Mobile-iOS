//
//  NXFileInfoView.m
//  nxrmcUITest
//
//  Created by nextlabs on 11/8/16.
//  Copyright © 2016 zhuimengfuyun. All rights reserved.
//

#import "NXFileInfoView.h"

#import "Masonry.h"

#import "NXSharePointFile.h"
#import "NXFile.h"

#import "NXCommonUtils.h"

@interface NXFileInfoView ()
@property(nonatomic, weak) UILabel *dateLabel;
@property(nonatomic, weak) UILabel *sizeLabel;
@end

@implementation NXFileInfoView

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

#pragma mark -

- (void)setModel:(NXFileBase *)model {
    if (_model == model) {
        return;
    }
    
    if (![model isKindOfClass:[NXFile class]] && ![model isKindOfClass:[NXSharePointFile class]]) {
        return;
    }
    
    _model = model;
    
    if (model.lastModifiedDate) {
        self.dateLabel.text = [NXCommonUtils timeStringFrom1970TimeInterval:0 orDate:model.lastModifiedDate];
    } else {
        self.dateLabel.text = @"";
    }
    self.dateLabel.accessibilityValue = @"FILE_PROPERTY_FILE_DATE_LAB";
    
    if ([model isKindOfClass:[NXMyVaultFile class]] && self.dateLabel.text.length == 0) {
        NXMyVaultFile *myvaultFile = (NXMyVaultFile *)model;
        self.dateLabel.text = [NXCommonUtils timeStringFrom1970TimeInterval:myvaultFile.sharedOn.longLongValue orDate:nil];
    }
    
    NSString *strSize = [NSByteCountFormatter stringFromByteCount:model.size countStyle:NSByteCountFormatterCountStyleBinary];
    self.sizeLabel.text = model.size ? strSize :@"N/A";
    self.sizeLabel.accessibilityValue = @"FILE_PROPERTY_FILE_SIZE_LAB";
}

#pragma mark -
- (void)commonInit {
//    UIImageView *imageView = [[UIImageView alloc] init];
//    [self addSubview:imageView];
//    
//    UILabel *namelabel = [[UILabel alloc] init];
//    [self addSubview:namelabel];
//    
//    UILabel *pathLabel = [[UILabel alloc] init];
//    [self addSubview:pathLabel];
    
    UILabel *dateLabel = [[UILabel alloc] init];
    [self addSubview:dateLabel];
    
    UILabel *datePromptLabel = [[UILabel alloc] init];
    [self addSubview:datePromptLabel];
    
    UILabel *sizeLabel = [[UILabel alloc] init];
    [self addSubview:sizeLabel];
    
    UILabel *sizePromptLabel = [[UILabel alloc] init];
    [self addSubview:sizePromptLabel];
    if (@available(iOS 11.0, *)) {
        [sizePromptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(kMargin);
            make.baseline.equalTo(datePromptLabel);
        }];
        
        [sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(sizePromptLabel);
            make.top.equalTo(sizePromptLabel.mas_bottom).offset(kMargin/2);
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-kMargin * 2);
        }];
        
        [datePromptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_safeAreaLayoutGuideTop).offset(kMargin);
            make.right.equalTo(self.mas_safeAreaLayoutGuideRight).offset(-kMargin * 2);
            make.width.equalTo(self.mas_safeAreaLayoutGuideWidth).multipliedBy(0.6);
        }];
        
        [dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.baseline.equalTo(sizeLabel);
            make.leading.equalTo(datePromptLabel);
            make.right.equalTo(self.mas_safeAreaLayoutGuideRight).offset(-kMargin);
        }];
    }else {
        [sizePromptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(kMargin);
            make.baseline.equalTo(datePromptLabel);
        }];
        
        [sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(sizePromptLabel);
            make.top.equalTo(sizePromptLabel.mas_bottom).offset(kMargin/2);
            make.bottom.equalTo(self).offset(-kMargin * 2);
        }];
        
        [datePromptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(kMargin);
            make.right.equalTo(self).offset(-kMargin * 2);
            make.width.equalTo(self).multipliedBy(0.6);
        }];
        
        [dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.baseline.equalTo(sizeLabel);
            make.leading.equalTo(datePromptLabel);
            make.right.equalTo(self).offset(-kMargin);
        }];
    }
    datePromptLabel.textColor = [UIColor darkGrayColor];
    datePromptLabel.font = [UIFont systemFontOfSize:14];
    datePromptLabel.text = NSLocalizedString(@"UI_LAST_MODIFIED_ON", NULL);
    
    dateLabel.font = [UIFont systemFontOfSize:kNormalFontSize];
    dateLabel.textColor = [UIColor blackColor];
    
    sizePromptLabel.textColor = [UIColor darkGrayColor];
    sizePromptLabel.font = [UIFont systemFontOfSize:14];
    sizePromptLabel.text = NSLocalizedString(@"UI_FILE_SIZE", NULL);
    
    sizeLabel.font = [UIFont systemFontOfSize:kNormalFontSize];
    sizeLabel.textColor = [UIColor blackColor];

    self.dateLabel = dateLabel;
    self.sizeLabel = sizeLabel;
}

@end
