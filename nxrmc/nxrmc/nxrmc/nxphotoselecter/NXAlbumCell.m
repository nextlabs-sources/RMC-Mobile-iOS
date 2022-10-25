//
//  NXAlbumCell.m
//  xiblayout
//
//  Created by nextlabs on 10/17/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXAlbumCell.h"
#import "Masonry.h"

@interface NXAlbumCell ()

@end

@implementation NXAlbumCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:imageView];
    self.thumbImageView = imageView;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [self.contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UILabel *countLabel = [[UILabel alloc] init];
    [self.contentView addSubview:countLabel];
    self.countLabel = countLabel;
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(8);
        make.width.equalTo(self.contentView).multipliedBy(0.25);
        make.top.equalTo(self.contentView).offset(8);
        make.bottom.equalTo(self.contentView).offset(-8);
        make.height.equalTo(imageView.mas_width);
    }];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageView.mas_right).offset(8);
        make.centerY.equalTo(imageView);
    }];
    
    [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(imageView);
        make.left.equalTo(titleLabel.mas_right).offset(8);
    }];
}

@end
