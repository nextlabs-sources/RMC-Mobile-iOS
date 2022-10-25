//
//  NXDocumentClassificationView.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 15/3/18.
//  Copyright © 2018年 nextlabs. All rights reserved.
//

#import "NXDocumentClassificationView.h"
#import "Masonry.h"
#import "NXClassificationCategory.h"
#import "NXClassificationLab.h"
#import "UIView+UIExt.h"
@interface NXDocumentClassificationView ()
@property (nonatomic, strong)NSMutableArray *classificationInfoLabels;
@property (nonatomic, strong)UILabel *centralLabel;
@property (nonatomic, strong)UIView *contentView;
@property (nonatomic, strong)UILabel *lastLabel;
@end
@implementation NXDocumentClassificationView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}
- (UIColor *)colorWithValue:(CGFloat)value {
    UIColor *color = [UIColor colorWithRed:value/256.0 green:value/256.0 blue:value/256.0 alpha:1];
    return color;
}
- (void)commonInit {
    UILabel *titleLabel = [[UILabel alloc]init];
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    titleLabel.text = NSLocalizedString(@"UI_COMPANY_DEFINED_RIGHTS", NULL);
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.numberOfLines = 0;
    UIView *contentView = [[UIView alloc]init];
    [self addSubview:contentView];
    self.contentView = contentView;
    contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *centralLabel = [[UILabel alloc]init];
    centralLabel.text = NSLocalizedString(@"UI_FIILEINFO_CENTRAL_POLICY", NULL);
    centralLabel.font = [UIFont systemFontOfSize:14];
    centralLabel.numberOfLines = 0;
    centralLabel.textColor = [self colorWithValue:49];
    [contentView addSubview:centralLabel];
    self.centralLabel = centralLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(5);
        make.left.equalTo(self).offset(5);
        make.right.equalTo(self).offset(-5);
    }];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(kMargin);
        make.left.right.equalTo(titleLabel);
        make.bottom.equalTo(self).offset(-kMargin);
    }];
    [centralLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView).offset(kMargin * 2);
        make.left.equalTo(contentView).offset(kMargin);
        make.right.equalTo(contentView).offset(-kMargin);
    }];
}
- (void)setDocumentClassicationsArray:(NSArray<NXClassificationCategory *> *)documentClassicationsArray {
    __block BOOL isSelected = NO;
    [documentClassicationsArray enumerateObjectsUsingBlock:^(NXClassificationCategory * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.selectedLabs.count > 0) {
            isSelected = YES;
            *stop = YES;
        }
    }];
    if (!isSelected) {
        UIView *bgView = [[UIView alloc]init];
        [self.contentView addSubview:bgView];
        UILabel *tagLabel = [[UILabel alloc]init];
        tagLabel.text = @"No tag selected";
        tagLabel.textAlignment = NSTextAlignmentCenter;
        [bgView addSubview:tagLabel];
        [bgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.centralLabel.mas_bottom).offset(kMargin * 2);
            make.left.right.equalTo(self.centralLabel);
            make.height.equalTo(@40);
            make.bottom.equalTo(self.contentView).offset(-kMargin * 2);
        }];
        [tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(bgView);
            make.height.equalTo(@30);
            make.width.equalTo(bgView);
        }];
        return;
    }
    self.classificationInfoLabels = [NSMutableArray array];
    for (NXClassificationCategory *category in documentClassicationsArray) {
        NSString *labContent = @"";
        for (int i = 0; i<category.selectedLabs.count; i++) {
            NXClassificationLab *lab = category.selectedLabs[i];
            if (i == 0) {
                labContent = [labContent stringByAppendingFormat:@" %@",lab.name];
            }else{
                labContent = [labContent stringByAppendingFormat:@", %@",lab.name];
            }
        }
        // Not selected not dispaly
        if (labContent.length > 0) {
            NSAttributedString *labelText = [self createAttributeString:[NSString stringWithFormat:@"%@ :",category.name] subTitle1:labContent];
            UILabel *categoryInfoLabel = [[UILabel alloc]init];
            categoryInfoLabel.attributedText = labelText;
            categoryInfoLabel.numberOfLines = 0;
            [self.contentView addSubview:categoryInfoLabel];
            [self.classificationInfoLabels addObject:categoryInfoLabel];
        }
        
    }
    if (self.classificationInfoLabels.count == 1) {
        UILabel *tagInfoLabel = self.classificationInfoLabels[0];
        [tagInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.centralLabel.mas_bottom).offset(kMargin * 2);
            make.left.right.equalTo(self.centralLabel);
            make.bottom.equalTo(self.contentView).offset(-kMargin * 2);
        }];
        
    }else if (self.classificationInfoLabels.count > 1){
        
        for (int i = 0; i<self.classificationInfoLabels.count; i++) {
            UILabel *tagInfoLabel = self.classificationInfoLabels[i];
            if (i == 0) {
                [tagInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.centralLabel.mas_bottom).offset(kMargin * 1.5);
                    make.left.right.equalTo(self.centralLabel);
                }];
            } else if (i == self.classificationInfoLabels.count - 1) {
                [tagInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.lastLabel.mas_bottom).offset(kMargin * 1.5);
                    make.left.right.equalTo(self.centralLabel);
                    make.bottom.equalTo(self.contentView).offset(-kMargin * 2);
                }];
            } else {
                [tagInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.lastLabel.mas_bottom).offset(kMargin * 1.5);
                    make.left.right.equalTo(self.centralLabel);
                }];
            }
            self.lastLabel = tagInfoLabel;
        }
        
        
//        [self.classificationInfoLabels mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedSpacing:kMargin leadSpacing:kMargin * 8 tailSpacing:kMargin];
//        [self.classificationInfoLabels mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.right.equalTo(self.centralLabel);
//        }];
    }
}
#pragma mark   ----》NSAttributedString
- (NSAttributedString *)createAttributeString:(NSString *)title subTitle1:(NSString *)subtitle1 {
    NSMutableAttributedString *myprojects = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName :[self colorWithValue:80],NSFontAttributeName:[UIFont systemFontOfSize:16]}];
    
    NSAttributedString *sub1 = [[NSMutableAttributedString alloc] initWithString:subtitle1 attributes:@{NSForegroundColorAttributeName :[UIColor blackColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:16]}];
   
    [myprojects appendAttributedString:sub1];
   
    return myprojects;
}
@end
