//
//  NXRightsDisplayCell.m
//  nxrmcUITest
//
//  Created by nextlabs on 11/9/16.
//  Copyright © 2016 zhuimengfuyun. All rights reserved.
//

#import "NXRightsDisplayCell.h"
#import "Masonry.h"
#import "UIView+UIExt.h"

#import "NXLRights.h"

@interface NXRightsDisplayCell ()

@property(nonatomic, weak) UILabel *titleLabel;
@property(nonatomic, weak) UIImageView *imageView;

@end

@implementation NXRightsDisplayCell

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
    
    self.titleLabel.text = model.title;
    
    switch (model.value) {
        case NXLRIGHTVIEW: //View
        {
            _imageView.image = [UIImage imageNamed:@"View"];
        }
            break;
        case NXLRIGHTEDIT://Edit
        {
            _imageView.image = [UIImage imageNamed:@"Edit"];
        }
            break;
        case NXLRIGHTDECRYPT:
        {
            _imageView.image = [UIImage imageNamed:@"Extract"];
        }
            break;
        case NXLRIGHTPRINT://Print
        {
            _imageView.image = [UIImage imageNamed:@"Print"];
        }
            break;
        case NXLRIGHTSHARING://Share
        {
            _imageView.image = [UIImage imageNamed:@"Share"];
        }
            break;
        case NXLRIGHTSDOWNLOAD://Download
        {
            _imageView.image = [UIImage imageNamed:@"SaveAs_P"];
        }
            break;
        case NXLOBLIGATIONWATERMARK://Watermark
        {
            _imageView.image = [UIImage imageNamed:@"Watermark"];
        }
            break;
        case NXLRIGHTSCREENCAP://Screen capture
        {
            _imageView.image = [UIImage imageNamed:@"Screen_capture"];
        }
            break;
        default:
        {
            _imageView.image = [UIImage imageNamed:@""];
        }
            break;
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
    
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:kMiniFontSize];
    label.textAlignment = NSTextAlignmentCenter;
    
    self.titleLabel = label;
    self.imageView = imageView;
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(kMargin/2);
        make.left.equalTo(self.contentView).offset(kMargin * 1.5);
        make.height.equalTo(@45);
        make.width.equalTo(@(45));
    }];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(imageView);
        make.top.equalTo(imageView.mas_bottom).offset(kMargin/4);
    }];
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
