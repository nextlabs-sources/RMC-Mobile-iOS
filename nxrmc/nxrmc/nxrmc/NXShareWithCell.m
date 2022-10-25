//
//  NXShareWithCell.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/1/9.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXShareWithCell.h"
#import "NXCommonUtils.h"
#import "Masonry.h"
#define kMinMargin  (kMargin/4)
#define KImageWidth 30

@interface NXShareWithCell ()
@property(nonatomic, strong)UIImageView *leftImageView;
@property(nonatomic, strong)UILabel *titleLabel;
@property(nonatomic, assign)BOOL isShowImage;
@property(nonatomic, weak, readonly) UIButton *deleteButton;
@end
@implementation NXShareWithCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}
- (UIImageView *)leftImageView {
    if (!_leftImageView) {
        _leftImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_leftImageView];
        [_leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(kMinMargin * 2);
            make.left.equalTo(self.contentView).offset(kMargin);
            make.height.width.equalTo(@KImageWidth);
        }];
    }
    return _leftImageView;
}
//- (void)setTitle:(NSString *)title {
//    if ([title isEqualToString:_title]) {
//        return;
//    }
//    _title = title;
//    //TBD
//
//    self.deleteButton.backgroundColor = [UIColor colorWithHexString:@"#e4e4e4"];
//
//    self.titleLabel.text = title;
//}
- (void)setShareWithType:(NXShareWithType)shareWithType {
    _shareWithType = shareWithType;
    switch (shareWithType) {
        case NXShareWithTypeProject:{
            if ([self.item isKindOfClass:[NXProjectModel class]]) {
                NXProjectModel *model = (NXProjectModel *)self.item;
                self.titleLabel.text = model.name;
                self.deleteButton.backgroundColor = [UIColor colorWithHexString:@"#e4e4e4"];
                
            }
            self.leftImageView.hidden = NO;
            self.leftImageView.image = [UIImage imageNamed:@"Projects-nav-bar-icon"];
            [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.leftImageView.mas_right).offset(kMinMargin * 2);
            }];
        }
            break;
        case NXShareWithTypeWorkSpace:{
            self.titleLabel.text = self.item;
            self.deleteButton.backgroundColor = [UIColor colorWithHexString:@"#e4e4e4"];
            self.leftImageView.hidden = NO;
            self.leftImageView.image = [UIImage imageNamed:@"Black-workspace-icon"];
            [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.leftImageView.mas_right).offset(kMinMargin * 2);
            }];
        }
            break;
        case NXShareWithTypeUser:{
            self.titleLabel.text = self.item;
            self.deleteButton.backgroundColor = [UIColor colorWithHexString:@"#e4e4e4"];
            self.leftImageView.hidden = YES;
            [self.leftImageView removeFromSuperview];
            self.leftImageView = nil;
            [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).offset(kMargin);
            }];
        }
            break;
        default:
            break;
    }
}
- (void)setEnable:(BOOL)enable {
    if (!self.enable) {
        self.deleteButton.hidden = YES;
    } else {
        self.deleteButton.hidden = NO;
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}
#pragma mark
- (void)commonInit {
    self.leftImageView.hidden = YES;
    UILabel *titleLabel = [[UILabel alloc] init];
    [self.contentView addSubview:titleLabel];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel = titleLabel;
    UIButton *errorButton = [[UIButton alloc] init];
    [self.contentView addSubview:errorButton];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.leftImageView.mas_right).offset(kMinMargin * 2);
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
    
    _deleteButton = errorButton;
    _titleLabel = titleLabel;
}
- (void)deleteButtonClicked:(id)sender {
    if (self.deleteBlock) {
        self.deleteBlock(sender);
    }
}
+ (CGSize)sizeForTitle:( NSString * _Nonnull )title {
    if (!title) {
        return CGSizeMake(0, 0);
    }
    NSMutableParagraphStyle *paragraph =[[NSMutableParagraphStyle alloc]init];
    [paragraph setLineBreakMode:NSLineBreakByTruncatingTail];
    [paragraph setAlignment:NSTextAlignmentCenter];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:kNormalFontSize], NSFontAttributeName,paragraph, NSParagraphStyleAttributeName, nil];
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:title attributes:attributes];
    CGSize size = [string size];
    return CGSizeMake(kMargin + kMinMargin * 2 + size.width + kMinMargin * 2 + size.height + kMinMargin * 3, size.height + kMinMargin * 6);
}
@end
