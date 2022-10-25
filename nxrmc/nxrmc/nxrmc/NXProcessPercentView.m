//
//  NXProcessPercentView.m
//  NXGradientProcessView
//
//  Created by helpdesk on 12/1/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXProcessPercentView.h"
#import "Masonry.h"
static const CGFloat kTopSpaces = 5.f;
static const CGFloat kLeftSpaces = 12.f;
static const CGFloat KFreeLabelWidth = 80.f;
static const CGFloat KFreeLabelHeight = 20.f;
static const CGFloat KItemLabelHeight = 12.f;
static const CGFloat KIntervalSpaces = 8.f;
static const CGFloat KProcessViewHeight = 12.f;
@interface NXProcessPercentView ()
@property (nonatomic, strong) UIView *processView;
@property (nonatomic, assign) CGFloat processHight;// default 15.f
@property (nonatomic, strong) UIColor *processBackgroundColor;// default grayColor
@property (nonatomic, assign) CGFloat usedPerentAge;
@property (nonatomic, strong) UIView *coverView;

@end
@implementation NXProcessPercentView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.processBackgroundColor = [UIColor whiteColor];
        self.processHight = KProcessViewHeight;
    }
    return self;
}
- (void)makeProcessViewTypeWithItems:(NSDictionary *)dic {
    _processView = [[UIView alloc]init];
    self.processView.backgroundColor = self.processBackgroundColor;
    self.processView.layer.cornerRadius = self.processHight/2;
    self.processView.layer.masksToBounds = YES;
    self.processView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.processView.layer.borderWidth = 0.5;
    self.processView.tag = 20170406;
    [self addSubview:self.processView];
    [self.processView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(kTopSpaces);
        make.left.equalTo(self.mas_left).offset(kLeftSpaces);
        make.right.equalTo(self.mas_right).offset(-kLeftSpaces);
        make.height.equalTo(@(self.processHight));
        
    }];
    UILabel *usedLabel = [[UILabel alloc]init];
    usedLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:usedLabel];
    [usedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.processView.mas_bottom).offset(KIntervalSpaces);
        make.left.equalTo(self.processView);
        make.height.equalTo(@(KFreeLabelHeight));
        make.width.equalTo(@(KFreeLabelWidth));
        
    }];
    UILabel *freeLabel = [[UILabel alloc]init];
    freeLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:freeLabel];
    [freeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.processView.mas_bottom).offset(KIntervalSpaces);
        make.right.equalTo(self.processView);
        make.height.equalTo(@(KFreeLabelHeight));
        make.width.equalTo(@(KFreeLabelWidth));
        
    }];
    UIImageView *bottedImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"botted.png"]];
    [self addSubview:bottedImageView];
    [bottedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(freeLabel.mas_bottom).offset(KIntervalSpaces*2);
        make.centerX.equalTo(self.processView);
        make.height.equalTo(@(5));
        make.width.equalTo(self.processView).multipliedBy(0.7);
    }];
    UILabel *leftIconLabel = [[UILabel alloc]init];
    [self addSubview:leftIconLabel];
    UILabel *leftInfoLabel = [[UILabel alloc]init];
    [self addSubview:leftInfoLabel];
    UILabel *rightIconLabel = [[UILabel alloc]init];
    [self addSubview:rightIconLabel];
    UILabel *rightInfoLabel = [[UILabel alloc]init];
    [self addSubview:rightInfoLabel];
    [leftIconLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bottedImageView.mas_bottom).offset(KIntervalSpaces*2);
        make.left.equalTo(self.processView);
        make.width.equalTo(@(KItemLabelHeight));
        make.height.equalTo(@(KItemLabelHeight));
        make.bottom.equalTo(self.mas_bottom).offset(-KIntervalSpaces);
    }];
    [leftInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bottedImageView.mas_bottom).offset(KIntervalSpaces*2);
        make.left.equalTo(leftIconLabel.mas_right).offset(KIntervalSpaces/2);
        make.height.equalTo(@(KItemLabelHeight));
        make.width.equalTo(self.processView).multipliedBy(0.44);
    }];
    [rightIconLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bottedImageView.mas_bottom).offset(KIntervalSpaces*2);
        make.left.equalTo(leftInfoLabel.mas_right).offset(KIntervalSpaces);
        make.width.equalTo(@(KItemLabelHeight));
        make.height.equalTo(@(KItemLabelHeight));
        make.bottom.equalTo(self.mas_bottom).offset(-KIntervalSpaces);
    }];
    [rightInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bottedImageView.mas_bottom).offset(KIntervalSpaces*2);
        make.left.equalTo(rightIconLabel.mas_right).offset(KIntervalSpaces/2);
        make.height.equalTo(@(KItemLabelHeight));
        make.width.equalTo(self.processView).multipliedBy(0.44);
    }];

    
    long long quotaSize = [(NSNumber *)dic[@"quota"] longLongValue];
    long long myVaultUsageSize = [(NSNumber *)dic[@"myVaultUsage"] longLongValue];
    long long usageSize = [(NSNumber *)dic[@"usage"] longLongValue];
    long long myDriveUsageSize = [(NSNumber *)dic[@"usage"] longLongValue] - [(NSNumber *)dic[@"myVaultUsage"] longLongValue];
    long long freeSize = quotaSize - usageSize;
    NXProcessItemModel *item1 = [[NXProcessItemModel alloc]init];
    item1.name = @"MyDrive";
    if (myDriveUsageSize == 0) {
        item1.usageStr = @"0 KB";
    }else {
        item1.usageStr = [NSByteCountFormatter stringFromByteCount:myDriveUsageSize countStyle:NSByteCountFormatterCountStyleBinary];
    }
    item1.bgColor = [UIColor colorWithRed:52/256.0 green:153/256.0 blue:96/256.0 alpha:1];
    item1.percentAge = (double)myDriveUsageSize/quotaSize;
    
    NXProcessItemModel *item2 = [[NXProcessItemModel alloc]init];
    item2.name = @"MyVault";
    if (myVaultUsageSize == 0) {
        item2.usageStr = @"0 KB";
    }else {
        item2.usageStr = [NSByteCountFormatter stringFromByteCount:myVaultUsageSize countStyle:NSByteCountFormatterCountStyleBinary];
    }
    item2.bgColor = [UIColor colorWithRed:79/256.0 green:79/256.0 blue:79/256.0 alpha:1];
    item2.percentAge = (double)myVaultUsageSize/quotaSize;
    NSArray *itemsArray = @[item1,item2];
    
    self.usedPerentAge = 0;
    UIView *lastView = [[UIView alloc]init];
    for (int i = 0; i<itemsArray.count; i++) {
        NXProcessItemModel *item=itemsArray[i];
        self.usedPerentAge = self.usedPerentAge+item.percentAge;
        UIView *partView = [[UIView alloc]init];
        partView.backgroundColor = item.bgColor;
        [self.processView addSubview:partView];
        
        if (i == 0) {
            leftIconLabel.backgroundColor = item.bgColor;
            NSMutableAttributedString *leftInfoText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ",item.name] attributes:@{NSForegroundColorAttributeName : [UIColor grayColor], NSFontAttributeName:[UIFont systemFontOfSize:11]}];
            NSAttributedString *message = [[NSAttributedString alloc] initWithString:item.usageStr attributes:@{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName:[UIFont systemFontOfSize:10]}];
            [leftInfoText appendAttributedString:message];
            leftInfoLabel.attributedText = leftInfoText;
            if (item.percentAge > 0) {
                [partView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.processView);
                    make.left.equalTo(self.processView);
                    make.width.equalTo(self.processView).multipliedBy(item.percentAge);
                    make.height.equalTo(self.processView);
                }];
            }
            
        }else {
            rightIconLabel.backgroundColor = item.bgColor;
            NSMutableAttributedString *rightInfoText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ",item.name] attributes:@{NSForegroundColorAttributeName : [UIColor grayColor], NSFontAttributeName:[UIFont systemFontOfSize:11]}];
            NSAttributedString *message = [[NSAttributedString alloc] initWithString:item.usageStr attributes:@{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName:[UIFont systemFontOfSize:10]}];
            [rightInfoText appendAttributedString:message];
            rightInfoLabel.attributedText = rightInfoText;
            if (item.percentAge>0) {
                [partView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.processView);
                    make.left.equalTo(lastView.mas_right);
                    make.width.equalTo(self.processView).multipliedBy(item.percentAge);
                    make.height.equalTo(self.processView);
                }];
            }
            
        }
        lastView = partView;
        
    }

    self.coverView = [[UIView alloc]init];
    self.coverView.backgroundColor = self.processBackgroundColor;
    self.coverView.layer.cornerRadius = self.processHight/3;
    self.coverView.layer.masksToBounds = YES;
    [self addSubview:self.coverView];
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(kTopSpaces);
        make.left.equalTo(self.mas_left).offset(kLeftSpaces);
        make.height.equalTo(@(self.processHight));
        make.right.equalTo(self.mas_right).offset(-kLeftSpaces);
    }];
    if (freeSize<0 || freeSize == 0) {
        freeLabel.text = @"0 kB free";
    }else {
        freeLabel.text = [NSString stringWithFormat:@"%@ free",[NSByteCountFormatter stringFromByteCount:freeSize countStyle:NSByteCountFormatterCountStyleBinary]];
    }
    freeLabel.textColor = [UIColor blackColor];
    freeLabel.font = [UIFont systemFontOfSize:14];
       if (usageSize == 0) {
        usedLabel.text = @"0 KB used";
    }else {
        usedLabel.text = [NSString stringWithFormat:@"%@ used",[NSByteCountFormatter stringFromByteCount:usageSize countStyle:NSByteCountFormatterCountStyleBinary]];
    }
    usedLabel.textColor = [UIColor grayColor];
    usedLabel.font = [UIFont systemFontOfSize:14];
    
}
- (void)makeProcessViewAnimatedWithDuration:(CGFloat)animatedTime {
    self.coverView.hidden = NO;
    [self.coverView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(kTopSpaces);
        make.right.equalTo(self.mas_right).offset(-kLeftSpaces);
        make.height.equalTo(@(self.processHight));
        make.width.equalTo(@(0));
          }];
    [UIView animateWithDuration:animatedTime animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.coverView removeFromSuperview];
        self.coverView = nil;
    }];
}

@end
@implementation NXProcessItemModel
@end
