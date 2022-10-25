//
//  NXNormalCell.m
//  nxrmcUITest
//
//  Created by nextlabs on 11/7/16.
//  Copyright © 2016 zhuimengfuyun. All rights reserved.
//

#import "NXNormalCell.h"

#import "Masonry.h"
#import "NXRMCDef.h"
#import "NXFileBase.h"
#import "NXCommonUtils.h"

@interface NXNormalCell ()

@property(nonatomic, weak, readonly) UILabel *mainTitleLabel;
@property(nonatomic, weak, readonly) UILabel *subTitleLabel;
@property(nonatomic, weak, readonly) UIImageView *leftImageView;
@property(nonatomic, weak, readonly) UIImageView *rightImageView;

@property(nonatomic, strong) UIImage *leftImage;
@property(nonatomic, strong) UIImage *leftSelectedImage;

@property(nonatomic, strong) UIImage *rightImage;
@property(nonatomic, strong) UIImage *rightSelectedImage;

@property(nonatomic, strong) UIColor *mainTitleColor;
@property(nonatomic, strong) UIColor *mainTitleSelectedColor;

@property(nonatomic, strong) UIColor *subTitleSelectedColor;
@property(nonatomic, strong) UIColor *subTitleColor;

@property(nonatomic, strong) NSString *mainSelectedTitle;
@property(nonatomic, strong) NSString *mainTitle;

@property(nonatomic, strong) NSString *subSelectedTitle;
@property(nonatomic, strong) NSString *subTitle;

@end

@implementation NXNormalCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self commonInit];
    }
    [self reSet];
    return self;
}

- (void)setSelected:(BOOL)selected {
    [self setSelected:selected animated:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.leftImageView.image = self.isSelected ? (self.leftSelectedImage? self.leftSelectedImage:self.leftImage):self.leftImage;
    self.rightImageView.image = self.isSelected ? (self.rightSelectedImage? self.rightSelectedImage:self.rightImage):self.rightImage;
    self.mainTitleLabel.text = self.isSelected ? (self.mainSelectedTitle? self.mainSelectedTitle:self.mainTitle):self.mainTitle;
    self.subTitleLabel.text = self.isSelected ? (self.subSelectedTitle? self.subSelectedTitle:self.subTitle):self.subTitle;
    self.mainTitleLabel.textColor = self.isSelected ? (self.mainTitleSelectedColor? self.mainTitleSelectedColor:self.mainTitleColor):self.mainTitleColor;
    self.subTitleLabel.textColor = self.isSelected ? (self.subTitleSelectedColor? self.subTitleSelectedColor:self.subTitleColor):self.subTitleColor;
}

- (void)reSet {
    self.leftImage = nil;
    self.leftSelectedImage = nil;
    self.rightImage = nil;
    self.rightSelectedImage = nil;
    self.subTitle = nil;
    self.subSelectedTitle = nil;
    self.mainTitle = nil;
    self.mainSelectedTitle = nil;
    
    self.mainTitleColor = nil;
    self.mainTitleSelectedColor = nil;
    self.subTitleColor = nil;
    self.subTitleSelectedColor = nil;
    [self setSelected:self.isSelected];
}
- (void)setModel:(NXFileBase *)model {
    NSString *imageName = [NXCommonUtils getImagebyExtension:model.name];
    [self setMainTitle:model.name forState:UIControlStateNormal];
    [self setLeftImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    self.mainTitleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
//    [self.mainTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(self.contentView);
//        make.left.equalTo(self.leftImageView.mas_right).offset(16);
//        make.right.equalTo(self.rightImageView.mas_left).offset(-16);
//    }];
}
#pragma mark -
- (void)setRightImage:(UIImage *)rightImage forState:(UIControlState)state {
    if (state == UIControlStateNormal) {
        self.rightImage = rightImage;
    } else {
        self.rightSelectedImage = rightImage;
    }
    
}
- (void)setLeftImage:(UIImage *)leftImage forState:(UIControlState)state {
    if (state == UIControlStateNormal) {
        self.leftImage = leftImage;
    } else {
        self.leftSelectedImage = leftImage;
    }
}

- (void)setMainTitle:(NSString *)mainTitle forState:(UIControlState)state {
    if (state == UIControlStateNormal) {
        self.mainTitle = mainTitle;
    } else {
        self.mainSelectedTitle = mainTitle;
    }
}

- (void)setSubTitle:(NSString *)subTitle forState:(UIControlState)state {
    if (state == UIControlStateNormal) {
        self.subTitle = subTitle;
    } else {
        self.subSelectedTitle = subTitle;
    }
}

- (void)setMainTitleColor:(UIColor *)color forState:(UIControlState)state {
    if (state == UIControlStateNormal) {
        self.mainTitleColor = color;
    } else {
        self.mainTitleSelectedColor = color;
    }
}

- (void)setSubTitleColor:(UIColor *)color forState:(UIControlState)state {
    if (state == UIControlStateNormal) {
        self.subTitleColor = color;
    } else {
        self.subTitleSelectedColor = color;
    }
}

#pragma mark - setter
- (void)setLeftImage:(UIImage *)leftImage {
    _leftImage = leftImage;
    self.leftImageView.image = self.isSelected ? (self.leftSelectedImage? self.leftSelectedImage:self.leftImage):self.leftImage;
}

- (void)setLeftSelectedImage:(UIImage *)leftSelectedImage {
    _leftSelectedImage = leftSelectedImage;
    self.leftImageView.image = self.isSelected ? (self.leftSelectedImage? self.leftSelectedImage:self.leftImage):self.leftImage;
}

- (void)setRightImage:(UIImage *)rightImage {
    _rightImage = rightImage;
    self.rightImageView.image = self.isSelected ? (self.rightSelectedImage? self.rightSelectedImage:self.rightImage):self.rightImage;
}

- (void)setRightSelectedImage:(UIImage *)rightSelectedImage {
    _rightSelectedImage = rightSelectedImage;
    self.rightImageView.image = self.isSelected ? (self.rightSelectedImage? self.rightSelectedImage:self.rightImage):self.rightImage;
}

- (void)setMainTitle:(NSString *)mainTitle {
    _mainTitle = mainTitle;
    self.mainTitleLabel.text = self.isSelected ? (self.mainSelectedTitle? self.mainSelectedTitle:self.mainTitle):self.mainTitle;
}

- (void)setMainSelectedTitle:(NSString *)mainSelectedTitle {
    _mainSelectedTitle = mainSelectedTitle;
    self.mainTitleLabel.text = self.isSelected ? (self.mainSelectedTitle? self.mainSelectedTitle:self.mainTitle):self.mainTitle;
}

- (void)setSubTitle:(NSString *)subTitle {
    _subTitle = subTitle;
    self.subTitleLabel.text = self.isSelected ? (self.subSelectedTitle? self.subSelectedTitle:self.subTitle):self.subTitle;
}

- (void)setSubSelectedTitle:(NSString *)subSelectedTitle {
    _subSelectedTitle = subSelectedTitle;
    self.subTitleLabel.text = self.isSelected ? (self.subSelectedTitle? self.subSelectedTitle:self.subTitle):self.subTitle;
}

- (void)setMainTitleColor:(UIColor *)mainTitleColor {
    _mainTitleColor = mainTitleColor;
    self.mainTitleLabel.textColor = self.isSelected ? (self.mainTitleSelectedColor? self.mainTitleSelectedColor:self.mainTitleColor):self.mainTitleColor;
}

- (void)setMainTitleSelectedColor:(UIColor *)mainTitleSelectedColor {
    _mainTitleSelectedColor = mainTitleSelectedColor;
    self.mainTitleLabel.textColor = self.isSelected ? (self.mainTitleSelectedColor? self.mainTitleSelectedColor:self.mainTitleColor):self.mainTitleColor;
}

- (void)setSubTitleColor:(UIColor *)subTitleColor {
    _subTitleColor = subTitleColor;
    self.subTitleLabel.textColor = self.isSelected ? (self.subTitleSelectedColor? self.subTitleSelectedColor:self.subTitleColor):self.subTitleColor;
}

- (void)setSubTitleSelectedColor:(UIColor *)subTitleSelectedColor {
    _subTitleSelectedColor = subTitleSelectedColor;
    self.subTitleLabel.textColor = self.isSelected ? (self.subTitleSelectedColor? self.subTitleSelectedColor:self.subTitleColor):self.subTitleColor;
}

#pragma mark -
- (void)commonInit {
    UILabel *mainTitleLabel = [[UILabel alloc] init];
    [self.contentView addSubview:mainTitleLabel];
    mainTitleLabel.accessibilityValue = @"NXNORMALCELLMAINLABEL";
    
    UILabel *subTileLabel = [[UILabel alloc] init];
    [self.contentView addSubview:subTileLabel];
    
    UIImageView *leftImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:leftImageView];
    
    UIImageView *rightImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:rightImageView];
    rightImageView.accessibilityValue = @"NXNORMALCELLRIGHTIMAGEVIEW";
    
    _mainTitleLabel = mainTitleLabel;
    _subTitleLabel = subTileLabel;
    _leftImageView  = leftImageView;
    _rightImageView = rightImageView;
    
    self.mainTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.mainTitleLabel.font = [UIFont systemFontOfSize:14];
    self.mainTitleColor = [UIColor blackColor];
    
    self.subTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.subTitleColor = [UIColor lightGrayColor];
    self.subTitleLabel.font = [UIFont systemFontOfSize:12];
    
    self.leftImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.rightImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            
            [self.leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.contentView.mas_safeAreaLayoutGuideCenterY);
                make.width.equalTo(self.leftImageView.mas_height);
                make.height.equalTo(self.contentView.mas_safeAreaLayoutGuideHeight).multipliedBy(0.5);
                make.left.equalTo(self.contentView.mas_safeAreaLayoutGuideLeft).offset(16);
            }];
            
            [self.rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.contentView.mas_safeAreaLayoutGuideCenterY);
                make.height.equalTo(@20);
                make.width.equalTo(@(20));
                make.right.equalTo(self.contentView.mas_safeAreaLayoutGuideRight).offset(-16);
            }];
            
            [self.mainTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentView.mas_safeAreaLayoutGuideTop).offset(8);
                make.left.equalTo(self.leftImageView.mas_right).offset(16);
                make.right.equalTo(self.rightImageView.mas_left).offset(-16);
            }];
            
            [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.mainTitleLabel.mas_bottom).offset(0);
                make.right.equalTo(self.mainTitleLabel);
                make.left.equalTo(self.mainTitleLabel);
                make.height.equalTo(self.mainTitleLabel).multipliedBy(0.7);
                make.bottom.equalTo(self.contentView.mas_safeAreaLayoutGuideBottom).offset(-8);
            }];
        }
    }
    else
    {
        [self.leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.width.equalTo(self.leftImageView.mas_height);
            make.height.equalTo(self.contentView).multipliedBy(0.5);
            make.left.equalTo(self.contentView).offset(16);
        }];
        
        [self.rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.height.equalTo(@20);
            make.width.equalTo(@(20));
            make.right.equalTo(self.contentView).offset(-16);
        }];
        
        [self.mainTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.leftImageView.mas_right).offset(16);
            make.right.equalTo(self.rightImageView.mas_left).offset(-16);
        }];
        
        [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mainTitleLabel.mas_bottom).offset(0);
            make.right.equalTo(self.mainTitleLabel);
            make.left.equalTo(self.mainTitleLabel);
            make.height.equalTo(self.mainTitleLabel).multipliedBy(0.7);
            make.bottom.equalTo(self.contentView).offset(-8);
        }];
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    self.mainTitleLabel.backgroundColor = [UIColor blueColor];
//    self.subTitleLabel.backgroundColor = [UIColor greenColor];
//    self.rightImageView.backgroundColor = [UIColor redColor];
//    self.leftImageView.backgroundColor = [UIColor orangeColor];
}

@end
