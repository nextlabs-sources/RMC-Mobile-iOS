//
//  NXCustomTitleView.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/23/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXCustomTitleView.h"

#import "Masonry.h"

@interface NXCustomTitleView()

@end

@implementation NXCustomTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:CGRectZero]) {
        self.textAlignment = NSTextAlignmentCenter;
        self.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return self;
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self sizeToFit];
}

@end
@interface NXCustomNavTitleView ()

@property(nonatomic, strong)UILabel *mainLabel;
@property(nonatomic, strong)UILabel *subLabel;
@end
@implementation NXCustomNavTitleView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:CGRectZero]) {
        [self commonInitUI];
    }
    return self;
}
- (void)commonInitUI{
    UILabel *mainTitleLabel = [[UILabel alloc] init];
    [self addSubview:mainTitleLabel];
//    mainTitleLabel.frame = CGRectMake(0, 0, 200, 30);
    mainTitleLabel.textAlignment = NSTextAlignmentCenter;
    mainTitleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    mainTitleLabel.font = [UIFont systemFontOfSize:15.5];
    self.mainLabel = mainTitleLabel;
    UILabel *subTitleLabel = [[UILabel alloc] init];
    [self addSubview:subTitleLabel];
    subTitleLabel.textAlignment = NSTextAlignmentCenter;
    subTitleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    subTitleLabel.textColor = [UIColor grayColor];
    subTitleLabel.font = [UIFont systemFontOfSize:14];
    self.subLabel = subTitleLabel;

    [mainTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.centerX.equalTo(self);
        make.height.equalTo(@28);
        make.width.equalTo(@200);
    }];
    [subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(mainTitleLabel.mas_bottom);
        make.centerX.equalTo(self);
        make.bottom.equalTo(self);
        make.width.equalTo(@160);
    }];
}
- (void)setMainTitle:(NSString *)mainTitle {
    self.mainLabel.text = mainTitle;
}
- (void)setSubTitle:(NSString *)subTitle {
    self.subLabel.text = subTitle;
}
@end
