//
//  NXHomeProjectView.m
//  nxrmc
//
//  Created by helpdesk on 10/2/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXHomeProjectView.h"
#import "Masonry.h"
#import "NXRMCDef.h"
static const CGFloat kTopSpace = 5.0f;
@interface NXHomeProjectView ()
@end

@implementation NXHomeProjectView
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commoninit];
    }
    return self;
}
- (void)commoninit {
    self.projectTypeLabel=[[UILabel alloc]init];
    [self addSubview:self.projectTypeLabel];
   
    self.projectContentView=[[UIView alloc]init];
    [self addSubview:self.projectContentView];
   
    
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [self.projectTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.mas_safeAreaLayoutGuideTop).offset(kTopSpace);
                make.height.equalTo(@30);
                make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(20);
            }];
            
            [self.projectContentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.projectTypeLabel.mas_bottom).offset(kTopSpace*3);
                make.left.equalTo(self.mas_safeAreaLayoutGuideLeft);
                make.right.equalTo(self.mas_safeAreaLayoutGuideRight);
                make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-kTopSpace);
            }];
        }
    }
    else
    {
        [self.projectTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(kTopSpace);
            make.height.equalTo(@30);
            make.left.equalTo(self).offset(20);
        }];
        
        [self.projectContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.projectTypeLabel.mas_bottom).offset(kTopSpace*3);
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.bottom.equalTo(self).offset(-kTopSpace);
        }];
    }
}

@end
