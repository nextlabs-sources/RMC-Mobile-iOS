//
//  NXRightsDisplayHorizCell.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/10/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXRightsDisplayHorizCell.h"
#import "NXRightsDisplayCell.h"
#import "Masonry.h"
#import "UIView+UIExt.h"

#import "NXLRights.h"
#import  "NXLFileValidateDateModel.h"
@interface NXRightsDisplayHorizCell ()

@property(nonatomic, weak) UILabel *titleLabel;
@property(nonatomic, weak) UIImageView *imageView;
@property(nonatomic, weak) UILabel *descriptionLabel;

@end

@implementation NXRightsDisplayHorizCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    self.imageView.layer.cornerRadius = self.imageView.bounds.size.width/2;
//    self.imageView.clipsToBounds = YES;
}

- (void)setModel:(NXRightsCellModel *)model {
    if (_model == model) {
        return;
    }
    _model = model;
    
//    self.titleLabel.text = model.title;
    
    switch (model.value) {
//        case NXLRIGHTVIEW: //View
//        {
//            _imageView.image = [UIImage imageNamed:@"View"];
//        }
//            break;
//        case NXLRIGHTPRINT://Print
//        {
//            _imageView.image = [UIImage imageNamed:@"Print"];
//        }
//            break;
//        case NXLRIGHTSHARING://Share
//        {
//            _imageView.image = [UIImage imageNamed:@"Share"];
//        }
//            break;
//        case NXLRIGHTSDOWNLOAD://Download
//        {
//            _imageView.image = [UIImage imageNamed:@"Download"];
//        }
//            break;
        case NXLOBLIGATIONWATERMARK://Watermark
        {
            _imageView.image = [UIImage imageNamed:@"Watermark"];
        }
            break;
        default:
        {
            _imageView.image = [UIImage imageNamed:@""];
        }
            break;
    }
    
    if (model.modelType == MODELTYPEValidity) {
        _imageView.image = [UIImage imageNamed:@"Validity"];
        self.descriptionLabel.hidden = NO;
        self.descriptionLabel.text = model.title;
//         _fileValidityModel = [model.extDic objectForKey:@"VALIDITY_MODEL"];
//        if (_fileValidityModel) {
//              _descriptionLabel.text = [_fileValidityModel getValidateDateDescriptionString];
//        }
    }
    else
    {
        self.descriptionLabel.hidden = YES;
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    self.imageView.backgroundColor = backgroundColor;
}

#pragma mark
- (void)commonInit {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
    [self.contentView addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] init];
    [self.contentView addSubview:label];
    
    UILabel *descriptionLabel = [[UILabel alloc] init];
    descriptionLabel.textAlignment = NSTextAlignmentLeft;
//    descriptionLabel.textColor = [UIColor colorWithRed:172.0/255.0 green:172.0/255.0 blue:172.0/255.0 alpha:1.0];
     descriptionLabel.textColor = [UIColor blackColor];
    descriptionLabel.font = [UIFont systemFontOfSize:kMiniFontSize];
//    descriptionLabel.text = @"Friday,November 3,2017 - Friday,December 29,2017"; //standard format for
//    descriptionLabel.adjustsFontSizeToFitWidth = YES;
    self.descriptionLabel = descriptionLabel;
    [self.contentView addSubview:descriptionLabel];
    
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:kMiniFontSize];
    label.textAlignment = NSTextAlignmentLeft;
    
    self.titleLabel = label;
    self.imageView = imageView;
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(kMargin/2);
        make.left.equalTo(self.contentView).offset(kMargin * 1.5);
        make.height.equalTo(@45);
        make.width.equalTo(@(45));
    }];
    
    [descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(imageView);
        make.top.equalTo(imageView.mas_bottom).offset(kMargin/4);
    }];
//    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.contentView).offset(kMargin*1.5);
//        make.top.equalTo(self.contentView).offset(kMargin/2);
//        make.height.equalTo(@45);
//        make.width.equalTo(@(45));
//    }];
//
//    [label mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(imageView);
//        make.left.equalTo(imageView.mas_right).offset(kMargin/4);
//        make.right.equalTo(self.contentView).offset(-kMargin/4);
//    }];
//
//    [descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.contentView).offset(kMargin*1.5);
//        make.top.equalTo(imageView.mas_bottom);
//        make.width.equalTo(@(260));
//        make.height.equalTo(@(15));
//    }];
}

#pragma mark
+ (CGFloat)widthForTitle:(NSString *)title {
    NSMutableParagraphStyle *paragraph =[[NSMutableParagraphStyle alloc]init];
    [paragraph setLineBreakMode:NSLineBreakByWordWrapping];
    [paragraph setAlignment:NSTextAlignmentCenter];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:kMiniFontSize], NSFontAttributeName,paragraph, NSParagraphStyleAttributeName, nil];
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:title attributes:attributes];
    return attrStr.size.width + kMargin * 3;
}
@end
