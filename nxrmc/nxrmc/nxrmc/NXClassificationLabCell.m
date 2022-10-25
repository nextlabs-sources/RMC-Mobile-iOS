//
//  NXClassificationLabCell.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 15/3/18.
//  Copyright © 2018年 nextlabs. All rights reserved.
//

#import "NXClassificationLabCell.h"
#import "UIView+UIExt.h"
#import "NXClassificationLab.h"
#import "Masonry.h"
#define NXCELLBACKCOLOR [UIColor colorWithRed:224/256.0 green:224/256.0 blue:224/256.0 alpha:1]
@interface NXClassificationLabCell ()
@property (nonatomic, strong)UILabel *contentLabel;
@property (nonatomic, strong)UIButton *contentBtn;
@end
@implementation NXClassificationLabCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
        [self cornerRadian:3];
    }
    return self;
}
- (void)commonInit {
    self.backgroundColor = NXCELLBACKCOLOR;
    UILabel *contentLabel = [[UILabel alloc]init];
    [self.contentView addSubview:contentLabel];
    contentLabel.textAlignment = NSTextAlignmentCenter;
    contentLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    contentLabel.textColor = [UIColor blackColor];
    contentLabel.font = [UIFont systemFontOfSize:15];
    self.contentLabel = contentLabel;
    contentLabel.center = self.contentView.center;
    contentLabel.bounds = self.contentView.bounds;
//    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.contentView);
//
//    }];
}

- (void)setModel:(NXClassificationLab *)model {
    self.contentLabel.text = model.name;
    self.selected = model.defaultLab;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.backgroundColor = RMC_MAIN_COLOR;
        self.contentLabel.textColor = [UIColor whiteColor];
    }else{
        self.backgroundColor = NXCELLBACKCOLOR;
        self.contentLabel.textColor = [UIColor blackColor];
    }
}
@end
