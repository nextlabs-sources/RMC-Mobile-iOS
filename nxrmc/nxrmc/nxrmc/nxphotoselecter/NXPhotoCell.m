//
//  NXPhotoCell.m
//  xiblayout
//
//  Created by nextlabs on 10/17/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXPhotoCell.h"

#import "Masonry.h"
#import "NXRMCDef.h"
#import "UIImage+Cutting.h"

@interface NXPhotoCell ()

@property(nonatomic, weak) UIImageView *imageView;
@property(nonatomic, weak) UILabel *lengthLabel;

@end

@implementation NXPhotoCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedItemDidUpdated:) name:NOTIFICATION_PHOTO_SELECTED object:nil];
    }
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)selectedItemDidUpdated:(NSNotification *)notification
{
    self.selectButton.selected = [[NXPhotoTool sharedInstance] isItemSelected:self.model];
}

#pragma mark
- (void)selectButtonClicked:(id)sender {
    self.selectButton.selected = !self.selectButton.selected;
    if (self.selectBlock) {
        self.selectBlock(sender);
    }
}

- (NSString *)timeFormatted:(int)totalSeconds{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
//    int hours = totalSeconds / 3600;
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    //return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

- (void)setModel:(NXAssetItem *)model {
    _model = model;
    CGSize size = CGSizeMake(110, 120);  // fix the photo size, to make the photos display more fluency
    [[NXPhotoTool sharedInstance] requestImageFromPhoto:model size:size resizeMode:PHImageRequestOptionsResizeModeFast synchronous:YES completion:^(UIImage *image, NSDictionary *info) {
        CGFloat width = image.size.width > image.size.height ? image.size.height : image.size.width;
        self.imageView.image = [image imageCuttingToSize:CGSizeMake(width, width)];
    }];
    
    self.selectButton.selected = [[NXPhotoTool sharedInstance] isItemSelected:model];
    
    if (model.asset.duration > 0) {
        self.lengthLabel.text = [self timeFormatted:model.asset.duration];
    } else {
        self.lengthLabel.text = @"";
    }
}

#pragma mark 

- (void)commonInit {
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:imageView];
    self.imageView = imageView;
    
//    UIImageView *typeImageView = [[UIImageView alloc] init];
//    [self.contentView addSubview:typeImageView];
//    self.typeImageView = typeImageView;
//    typeImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UIButton *selectButton = [[UIButton alloc]init];
    [self.contentView addSubview:selectButton];
    self.selectButton = selectButton;
    
    selectButton.contentMode = UIViewContentModeScaleAspectFill;
    
    [selectButton setImage:[UIImage imageNamed:@"selectedIcon"] forState:UIControlStateSelected];
    [selectButton setImage:[UIImage imageNamed:@"originalIcon"] forState:UIControlStateNormal];
    
    [selectButton addTarget:self action:@selector(selectButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *lengthLabel = [[UILabel alloc] init];
    lengthLabel.font = [UIFont systemFontOfSize:12];
    lengthLabel.textAlignment = NSTextAlignmentRight;
    
    [self.contentView addSubview:lengthLabel];
    self.lengthLabel = lengthLabel;
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(2);
        make.right.equalTo(self.contentView).offset(-2);
        make.width.equalTo(self.contentView).multipliedBy(0.35);
        make.height.equalTo(self.contentView).multipliedBy(0.35);
    }];
    
    [lengthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView).offset(2);
        make.right.equalTo(self.contentView).offset(-2);
        make.height.equalTo(self.contentView).multipliedBy(0.35);
    }];
}

@end
