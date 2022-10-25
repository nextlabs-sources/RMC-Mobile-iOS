//
//  NXProfileFooterView.m
//  nxrmc
//
//  Created by nextlabs on 11/28/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXProfileFooterView.h"
#import "Masonry.h"

@implementation NXProfileFooterView

- (instancetype)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

#pragma mark 
- (void)commonInit {
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nextlabs-logo"]];
    
    UIImageView *skyDrmImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rmsLogo"]];
    
    UILabel *viewerLabel = [[UILabel alloc] init];
    viewerLabel.textAlignment = NSTextAlignmentCenter;
    viewerLabel.textColor = [UIColor darkGrayColor];
    viewerLabel.font = [UIFont boldSystemFontOfSize:16];
    viewerLabel.text = NSLocalizedString(@"SkyDRM File Viewer", NULL);
    
    UILabel *versionLabel = [[UILabel alloc] init];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    versionLabel.textColor = [UIColor lightGrayColor];
    versionLabel.font = [UIFont systemFontOfSize:12];
    versionLabel.text = [NSString stringWithFormat:@"%@ %@.%@", NSLocalizedString(@"UI_VERSION", NULL), [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    
    [self addSubview:logoImageView];
    [self addSubview:skyDrmImageView];
    [self addSubview:viewerLabel];
    [self addSubview:versionLabel];
    
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(8);
        make.height.equalTo(@20);
        make.width.equalTo(self);
    }];
    
    [skyDrmImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(logoImageView.mas_bottom).offset(8);
        make.height.equalTo(logoImageView.mas_height).multipliedBy(2);
        make.width.equalTo(self);
    }];
    
    [viewerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(skyDrmImageView.mas_bottom).offset(8);
        make.width.equalTo(self);
    }];
    
    [versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(viewerLabel.mas_bottom);
        make.width.equalTo(self);
        make.bottom.equalTo(self).offset(-30);
    }];
    
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    skyDrmImageView.contentMode = UIViewContentModeScaleAspectFit;
    
#if 0
    self.backgroundColor = [UIColor blueColor];
    logoImageView.backgroundColor = [UIColor greenColor];
    skyDrmImageView.backgroundColor = [UIColor redColor];
    versionLabel.backgroundColor = [UIColor yellowColor];
    viewerLabel.backgroundColor = [UIColor orangeColor];
#endif
}

@end
