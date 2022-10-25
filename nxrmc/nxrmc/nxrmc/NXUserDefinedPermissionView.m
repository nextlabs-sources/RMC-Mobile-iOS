//
//  NXUserDefinedPermissionView.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2021/3/3.
//  Copyright © 2021 nextlabs. All rights reserved.
//

#import "NXUserDefinedPermissionView.h"
#import "Masonry.h"
@implementation NXUserDefinedPermissionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonUIInit];
    }
    return self;
}
- (void)commonUIInit {
    UILabel *userDefinedLabel = [[UILabel alloc] init];
    userDefinedLabel.text = NSLocalizedString(@"UI_USER_DEFINED_PERMISSIONS", NULL);
    userDefinedLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:userDefinedLabel];
    UIView *documentView = [[UIView alloc] init];
    documentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self addSubview:documentView];
    UILabel *contectLabel = [[UILabel alloc] init];
    contectLabel.text = @"User-defined rights are pre-defined permissions that you can apply to you documents.";
    contectLabel.font = [UIFont systemFontOfSize:15];
    contectLabel.numberOfLines = 0;
    contectLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [documentView addSubview:contectLabel];
    
    [userDefinedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kMargin);
        make.left.equalTo(self).offset(kMargin);
        make.right.equalTo(self).offset(-kMargin);
        make.height.equalTo(@30);
    }];
    [contectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(documentView).offset(8);
        make.left.equalTo(documentView).offset(10);
        make.right.equalTo(documentView).offset(-3);
        make.height.equalTo(@70);
    }];
    [documentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(userDefinedLabel.mas_bottom).offset(kMargin);
        make.left.right.equalTo(self);
        make.height.equalTo(@80);
        make.bottom.equalTo(self).offset(-kMargin);
    }];
    
}
@end
