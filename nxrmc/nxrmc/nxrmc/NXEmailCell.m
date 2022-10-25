//
//  NXEmailCell.m
//  nxrmcUITest
//
//  Created by nextlabs on 11/10/16.
//  Copyright © 2016 zhuimengfuyun. All rights reserved.
//

#import "NXEmailCell.h"

#import "Masonry.h"
#import "HexColor.h"

#import "NXCommonUtils.h"

#define kMinMargin  (kMargin/4)

@interface NXEmailCell ()

@end

@implementation NXEmailCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    if ([title isEqualToString:_title]) {
        return;
    }
    _title = title;
    //TBD
    if ([NXCommonUtils isValidateEmail:title]) {
        self.errorButton.backgroundColor = [UIColor colorWithHexString:@"#e4e4e4"];
    } else {
        self.errorButton.backgroundColor = [UIColor redColor];
    }
    self.titleLabel.text = title;
}

- (void)setEnable:(BOOL)enable {
    if (!self.enable) {
        self.errorButton.hidden = YES;
    } else {
        self.errorButton.hidden = NO;
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark 

- (void)deleteButtonClicked:(id)sender {
    if (self.deleteBlock) {
        self.deleteBlock(sender);
    }
}

#pragma mark
- (void)commonInit {
    UILabel *titleLabel = [[UILabel alloc] init];
    [self.contentView addSubview:titleLabel];
    
    UIButton *errorButton = [[UIButton alloc] init];
    [self.contentView addSubview:errorButton];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(kMinMargin);
        make.centerY.equalTo(self.contentView);
    }];
    
    [errorButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel.mas_right).offset(kMinMargin * 2);
        make.right.equalTo(self.contentView).offset(-kMinMargin * 2);
        make.centerY.equalTo(self.contentView);
        make.height.equalTo(titleLabel.mas_height);
        make.width.equalTo(titleLabel.mas_height);
    }];
    
    //herer font must be same with the font using to caculate size of title.
    titleLabel.font = [UIFont systemFontOfSize:kNormalFontSize];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor darkGrayColor];
    
    [errorButton setImage:[UIImage imageNamed:@"Close"] forState:UIControlStateNormal];
    [errorButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    errorButton.layer.cornerRadius = 3;
    
    self.layer.cornerRadius = 5;
    
    _errorButton = errorButton;
    _titleLabel = titleLabel;
}

+ (CGSize)sizeForTitle:(NSString *)title {
    NSMutableParagraphStyle *paragraph =[[NSMutableParagraphStyle alloc]init];
    [paragraph setLineBreakMode:NSLineBreakByTruncatingTail];
    [paragraph setAlignment:NSTextAlignmentCenter];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:kNormalFontSize], NSFontAttributeName,paragraph, NSParagraphStyleAttributeName, nil];
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:title attributes:attributes];
    
    CGSize size = [string size];
    return CGSizeMake(kMinMargin + size.width + kMinMargin * 2 + size.height + kMinMargin * 3, size.height + kMinMargin * 6);
}
@end
