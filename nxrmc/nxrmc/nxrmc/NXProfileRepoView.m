//
//  NXProfileRepoView.m
//  nxrmc
//
//  Created by nextlabs on 11/29/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXProfileRepoView.h"

#import "Masonry.h"

#import "NXLoginUser.h"
#import "NXCommonUtils.h"

@interface NXProfileRepoView()

//@property(nonatomic, weak) UILabel *titleLabel;
//@property(nonatomic, weak) UILabel *detailTextLabel;
//@property(nonatomic, weak) UILabel *accessoryLabel;
//@property(nonatomic, weak) UILabel *changePasswordLabel;
@end

@implementation NXProfileRepoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

//- (void)updateData {
//    NSMutableArray<NSString *> *array = [[NSMutableArray alloc] init];
//    NSArray *boundedservices = [NSArray arrayWithArray:[[NXLoginUser sharedInstance].myRepoSystem allReposiories]] ;
//    [boundedservices enumerateObjectsUsingBlock:^(NXRepositoryModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (idx < 2) {
//            [array addObject:obj.service_alias];
//        }
//    }];
//    
////
////    self.accessoryLabel.text = [NSString stringWithFormat:@"%ld", boundedservices.count];
//    if (boundedservices.count<3) {
//        self.detailTextLabel.text = [array componentsJoinedByString:@", "];
//    }else {
//        NSString *str1 = array[0];
//        NSString *str2 = array[1];
//        str1 = [self textTwoLongDotsInMiddleWithStr:str1];
//        str2 = [self textTwoLongDotsInMiddleWithStr:str2];
//    self.detailTextLabel.text = [NSString stringWithFormat:@"%@,%@,+%ld more",str1,str2,boundedservices.count-2];
//}
//}
#pragma mark
- (void)clicked:(id)sender {
    if (self.tapclickBlock) {
        self.tapclickBlock(sender);
    }
}
//- (NSString *)textTwoLongDotsInMiddleWithStr:(NSString *)str {
//    NSString *newStr = nil;
//    if (str.length>20) {
//        NSString *frontStr = [str substringToIndex:8];
//        NSString *behindStr = [str substringFromIndex:str.length-8];
//        NSString *dotStr = @"...";
//        newStr = [NSString stringWithFormat:@"%@%@%@",frontStr,dotStr,behindStr];
//        return newStr;
//    }
//    return str;
//}
#pragma mark
- (void)commonInit {
    self.backgroundColor = [UIColor whiteColor];
    
//    UILabel *titleLabel = [[UILabel alloc] init];
//    UILabel *detailTextLabel = [[UILabel alloc] init];
//    UILabel *accessoryLabel = [[UILabel alloc] init];
    UILabel *changePasswordLabel = [[UILabel alloc]init];
    changePasswordLabel.text = NSLocalizedString(@"UI_COM_PROFILE_CHANGE_PASSWORD", NULL);
    changePasswordLabel.accessibilityValue = @"PROFILE_CHANGE_PASSWPRD_LABEL";
    self.accessibilityValue = @"PROFILE_CHANGE_PASSWORD";
    changePasswordLabel.font = [UIFont systemFontOfSize:14];
    UIImageView *accessoryImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessoryIcon"]];
    
//    [self addSubview:titleLabel];
//    [self addSubview:detailTextLabel];
//    [self addSubview:accessoryLabel];
    [self addSubview:changePasswordLabel];
    [self addSubview:accessoryImageView];
    
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [changePasswordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.mas_safeAreaLayoutGuideTop);
                make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(10);
                make.width.equalTo(self.mas_safeAreaLayoutGuideWidth).multipliedBy(0.8);
                make.height.equalTo(self.mas_safeAreaLayoutGuideHeight);
            }];
            [accessoryImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.mas_safeAreaLayoutGuideRight).offset(-kMargin);
                make.height.equalTo(@20);
                make.width.equalTo(accessoryImageView.mas_height);
                make.centerY.equalTo(self);
            }];
        }
    }
    else
    {
        [changePasswordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.left.equalTo(self).offset(10);
            make.width.equalTo(self).multipliedBy(0.8);
            make.height.equalTo(self);
        }];
        [accessoryImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-kMargin);
            make.height.equalTo(@20);
            make.width.equalTo(accessoryImageView.mas_height);
            make.centerY.equalTo(self);
        }];
    }
  
    
//    [accessoryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(accessoryImageView.mas_left).offset(-kMargin/4);
//        make.centerY.equalTo(self);
//        make.width.equalTo(@20);
//        make.height.equalTo(@(20));
//    }];
//    
//    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self).offset(kMargin * 2);
//        make.right.equalTo(accessoryLabel.mas_left).offset(-kMargin/2);
//        make.bottom.equalTo(self.mas_centerY).offset(-0/4);
//    }];
//    
//    [detailTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(titleLabel);
//        make.right.equalTo(titleLabel);
//        make.top.equalTo(self.mas_centerY).offset(0);
//    }];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] init];
    [gesture addTarget:self action:@selector(clicked:)];
    [self addGestureRecognizer:gesture];
    
    self.backgroundColor = RMC_MAIN_COLOR;
    accessoryImageView.contentMode = UIViewContentModeScaleAspectFit;
    
//    titleLabel.font = [UIFont systemFontOfSize:14];
//    titleLabel.textColor = [UIColor darkGrayColor];
//    titleLabel.text = NSLocalizedString(@"Repositories", NULL);
//    
//    detailTextLabel.font = [UIFont systemFontOfSize:12];
//    detailTextLabel.textColor = [UIColor lightGrayColor];
//    
//    accessoryLabel.textAlignment = NSTextAlignmentRight;
//    accessoryLabel.textColor = [UIColor lightGrayColor];
    
//    _titleLabel = titleLabel;
//    _detailTextLabel = detailTextLabel;
//    _accessoryLabel = accessoryLabel;
    
#if 0
    self.titleLabel.text = @"Repositories";
    self.detailTextLabel.text = @"Dropbox, Sharepoint, +1 more";
    self.accessoryLabel.text = @"3";
#endif
    
#if 0
    titleLabel.backgroundColor = [UIColor blueColor];
    detailTextLabel.backgroundColor = [UIColor magentaColor];
    accessoryLabel.backgroundColor = [UIColor redColor];
    accessoryImageView.backgroundColor = [UIColor orangeColor];
#endif
    
}

@end
