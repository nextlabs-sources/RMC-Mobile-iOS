//
//  NXhomeReposCollectionViewCell.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 28/4/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXhomeReposCollectionViewCell.h"
#import "Masonry.h"
#import "NXRMCDef.h"
#import "NXRepositoryModel.h"
#import "UIView+UIExt.h"
#import "NXCommonUtils.h"
@interface NXhomeReposCollectionViewCell()
@property(nonatomic, strong) UIImageView *driveIcon;
@property(nonatomic, strong) UIImageView *providerIcon;
@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) NSDictionary *repoSelIconDict;
@property(nonatomic, strong) NSDictionary *repoIconDict;
@property(nonatomic, strong) CAShapeLayer *shapeLayer;
@end
@implementation NXhomeReposCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
        [self cornerRadian:2];
        self.contentView.backgroundColor = [UIColor whiteColor];
        
    }
    return self;
}
- (void)commonInit {
    _repoIconDict = @{[NSNumber numberWithInteger:kServiceDropbox]:[UIImage imageNamed:@"dropbox - gray"],
                      [NSNumber numberWithInteger:kServiceSharepointOnline]:[UIImage imageNamed:@"sharepoint - gray"],
                      [NSNumber numberWithInteger:kServiceSharepoint]:[UIImage imageNamed:@"sharepoint - gray"],
                      [NSNumber numberWithInteger:kServiceOneDrive]:[UIImage imageNamed:@"onedrive - gray"],
                      [NSNumber numberWithInteger:kServiceGoogleDrive]:[UIImage imageNamed:@"google-drive-notSelected"],
                      [NSNumber numberWithInteger:kServiceBOX]:[UIImage imageNamed:@"box - black"],
                      [NSNumber numberWithInteger:kServiceSkyDrmBox]:[UIImage imageNamed:@"MyDrive - gray"],
                      [NSNumber numberWithInteger:kServiceOneDriveApplication]:[UIImage imageNamed:@"onedrive - gray"],
                      [NSNumber numberWithInteger:KServiceSharepointOnlineApplication]:[UIImage imageNamed:@"sharepoint - gray"],
    };
    
    _repoSelIconDict = @{[NSNumber numberWithInteger:kServiceDropbox]:[UIImage imageNamed:@"dropbox - black"],
                         [NSNumber numberWithInteger:kServiceSharepointOnline]:[UIImage imageNamed:@"sharepoint - black"],
                         [NSNumber numberWithInteger:kServiceSharepoint]:[UIImage imageNamed:@"sharepoint - black"],
                         [NSNumber numberWithInteger:kServiceOneDrive]:[UIImage imageNamed:@"onedrive - black"],
                         [NSNumber numberWithInteger:kServiceGoogleDrive]:[UIImage imageNamed:@"google-drive-color"],
                         [NSNumber numberWithInteger:kServiceBOX]:[UIImage imageNamed:@"box - black"],
                         [NSNumber numberWithInteger:kServiceSkyDrmBox]:[UIImage imageNamed:@"MyDrive"],
                         [NSNumber numberWithInteger:kServiceOneDriveApplication]:[UIImage imageNamed:@"onedrive - black"],
                         [NSNumber numberWithInteger:KServiceSharepointOnlineApplication]:[UIImage imageNamed:@"sharepoint - black"],
    };
    _driveIcon = [[UIImageView alloc] init];
    [self.contentView addSubview:_driveIcon];
    _driveIcon.contentMode = UIViewContentModeScaleAspectFit;
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.numberOfLines = 0;
    _nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _nameLabel.font = [UIFont systemFontOfSize:12];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_nameLabel];
    _providerIcon = [[UIImageView alloc] init];
    _providerIcon.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_providerIcon];
    [_driveIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(10);
        make.centerX.equalTo(self.contentView);
        make.height.equalTo(@30);
        make.width.equalTo(@30);
    }];
    [_providerIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(5);
        make.right.equalTo(self.contentView).offset(-5);
        make.height.width.equalTo(@25);
    }];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_driveIcon.mas_bottom).offset(5);
        make.centerX.equalTo(self.contentView);
        make.width.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
}
- (void)setModel:(NXRepositoryModel *)model {
    if (self.shapeLayer) {
        [self.shapeLayer removeFromSuperlayer];
        self.shapeLayer = nil;
    }
    if (model.isAddItem) {
        _driveIcon.image = [UIImage imageNamed:@"Connect"];
        _driveIcon.tintColor = [UIColor whiteColor];
        _nameLabel.text = NSLocalizedString(@"UI_CONNECT", NULL);
        _nameLabel.textColor = [UIColor whiteColor];
        CAShapeLayer *borderLayer = [CAShapeLayer layer];
        borderLayer.bounds = self.contentView.bounds;
        borderLayer.position = CGPointMake(CGRectGetMidX(self.contentView.bounds), CGRectGetMidY(self.contentView.bounds));
        borderLayer.path = [UIBezierPath bezierPathWithRoundedRect:borderLayer.bounds cornerRadius:5].CGPath;
        borderLayer.lineWidth = 3;
        borderLayer.lineDashPattern = @[@6,@6];
        borderLayer.fillColor = [UIColor clearColor].CGColor;
        borderLayer.strokeColor = [UIColor whiteColor].CGColor;
        [self.contentView.layer addSublayer:borderLayer];
        self.contentView.backgroundColor = [UIColor colorWithRed:47/256.0 green:126/256.0 blue:62/256.0 alpha:1];
        self.shapeLayer = borderLayer;
        _providerIcon.image = nil;
    }else {
        if (model.service_isAuthed.boolValue) {
            _driveIcon.image = self.repoSelIconDict[model.service_type];
            _nameLabel.textColor = [UIColor blackColor];
        }else {
            _driveIcon.image = self.repoIconDict[model.service_type];
            _nameLabel.textColor = [UIColor grayColor];
        }
        _nameLabel.text = model.service_alias;
        _providerIcon.image = [NXCommonUtils getProviderIconByRepoProviderClass:model.service_providerClass];

        self.contentView.backgroundColor = [UIColor whiteColor];
    }
}
@end
