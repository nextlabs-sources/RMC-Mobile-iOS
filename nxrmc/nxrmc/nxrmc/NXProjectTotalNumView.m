//
//  NXProjectTotalNumView.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 30/10/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXProjectTotalNumView.h"
#import "Masonry.h"
@implementation NXProjectTotalNumView
- (instancetype)initWithProjectNumber:(NSNumber *)number andProjectType:(NXProjectTotalNumViewType)type {
    self = [super init];
    if (self) {
        [self commonInitDetailViewWithNumber:number andProjectType:type];
    }
    return self;
}
- (void)commonInitDetailViewWithNumber:(NSNumber *)number andProjectType:(NXProjectTotalNumViewType)type {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTapBackgroundView:)];
    [self addGestureRecognizer:tap];
    UIImageView *bgView = [[UIImageView alloc]init];
    bgView.backgroundColor = [UIColor colorWithRed:205/255.0 green:238/255.0 blue:219/255.0 alpha:1];
    [self addSubview:bgView];
    UILabel *numLabel = [[UILabel alloc]init];
    numLabel.font = [UIFont systemFontOfSize:22];
//    numLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:numLabel];
    UILabel *projectLabel = [[UILabel alloc]init];
    projectLabel.font = [UIFont systemFontOfSize:14];
    projectLabel.textAlignment = NSTextAlignmentCenter;
    if([number integerValue] < 10){
        numLabel.text = [NSString stringWithFormat:@"%@%@",@"0",[number stringValue]];
    }else{
        numLabel.text = [number stringValue];
    }
    if ([number integerValue] > 1) {
        projectLabel.text = @"Projects";
    } else {
        projectLabel.text = @"Project";
    }
    [self addSubview:projectLabel];
    UILabel *typeLabel1 = [[UILabel alloc]init];
    typeLabel1.font = [UIFont systemFontOfSize:12];
    [self addSubview:typeLabel1];
    UILabel *typeLabel2 = [[UILabel alloc]init];
    [typeLabel2 setAdjustsFontSizeToFitWidth:YES];
    [self addSubview:typeLabel2];
    switch (type) {
        case NXProjectTotalNumViewTypeForByMe:
            numLabel.textColor = [UIColor colorWithRed:82/255.0 green:194/255.0 blue:130/255.0 alpha:1];
            projectLabel.textColor = numLabel.textColor;
            typeLabel1.textColor = numLabel.textColor;
            typeLabel2.textColor = [UIColor colorWithRed:0 green:135/255.0 blue:54/255.0 alpha:1];
            typeLabel1.text = @"Created by";
            typeLabel2.text = @"ME";
            bgView.image = [UIImage imageNamed:@"CreatedBG"];
            break;
        case NXProjectTotalNumViewTypeForPending:
            typeLabel1.text = @"Invitation";
            typeLabel2.text = @"PENDING";
            bgView.image = [UIImage imageNamed:@"PendingBG"];
            numLabel.textColor = [UIColor colorWithRed:245/255.0 green:166/255.0 blue:89/255.0 alpha:1];
            projectLabel.textColor = numLabel.textColor;
            typeLabel1.textColor = numLabel.textColor;
            typeLabel2.textColor = [UIColor colorWithRed:1 green:126/255.0 blue:0 alpha:1];
            break;
        case NXProjectTotalNumViewTypeForByOthers:
            typeLabel1.text = @"Invited by";
            typeLabel2.text = @"OTHERS";
            bgView.image = [UIImage imageNamed:@"InvitedBG"];
            numLabel.textColor = [UIColor colorWithRed:88/255.0 green:156/255.0 blue:244/255.0 alpha:1];
            projectLabel.textColor = numLabel.textColor;
            typeLabel1.textColor = numLabel.textColor;
            typeLabel2.textColor = [UIColor colorWithRed:0 green:108/255.0 blue:173/255.0 alpha:1];
            break;
    }
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(5);
        make.left.equalTo(self).offset(20);
        make.height.equalTo(@30);
    }];
    [projectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(numLabel);
        make.height.equalTo(numLabel).multipliedBy(0.8);
        make.left.equalTo(numLabel.mas_right).offset(5);
    }];
    [typeLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(numLabel.mas_bottom);
        make.left.equalTo(numLabel);
        make.height.equalTo(@15);
        make.width.equalTo(self).multipliedBy(0.7);
    }];
    [typeLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(typeLabel1.mas_bottom);
        make.left.equalTo(numLabel);
        make.height.equalTo(@25);
        make.width.equalTo(self).multipliedBy(0.7);
        make.bottom.equalTo(self.mas_bottom).offset(-5);
    }];
}
- (void) userDidTapBackgroundView:(id) sender {
    if (self.clickBgViewFinishedBlock) {
        self.clickBgViewFinishedBlock(nil);
    }
}

@end
