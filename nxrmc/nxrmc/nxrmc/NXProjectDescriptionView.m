//
//  NXProjectDescriptionView.m
//  nxrmc
//
//  Created by helpdesk on 28/2/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXProjectDescriptionView.h"
#import "Masonry.h"
@implementation NXProjectDescriptionView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}
- (void)commonInit {
    UILabel *nameLabel = [[UILabel alloc]init];
    [self addSubview:nameLabel];
    nameLabel.font = [UIFont systemFontOfSize:17];
    nameLabel.text = @"Project Name:";
    UILabel *nameTextLabel = [[UILabel alloc]init];
     nameTextLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:nameTextLabel];
    self.projectNameLabel = nameTextLabel;
    UILabel *descriptionLabel = [[UILabel alloc]init];
    descriptionLabel.font = [UIFont systemFontOfSize:17];
    descriptionLabel.text = @"Desciption:";
    [self addSubview:descriptionLabel];
    
    UILabel *descriptionTextLabel = [[UILabel alloc]init];
    descriptionTextLabel.numberOfLines = 0;
    descriptionTextLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:descriptionTextLabel];
    self.projectDescriptionLabel = descriptionTextLabel;
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(20);
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(20);
        make.height.equalTo(@30);
    }];
    [nameTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLabel.mas_bottom).offset(5);
        make.left.right.and.height.equalTo(nameLabel);
    }];
    [descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameTextLabel.mas_bottom).offset(5);
        make.left.right.and.height.equalTo(nameTextLabel);
    }];
    [descriptionTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(descriptionLabel.mas_bottom).offset(5);
        make.left.right.equalTo(descriptionLabel);
        make.bottom.equalTo(self).offset(-20);
    }];
}
@end
