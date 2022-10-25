//
//  NXTreeFolderCell.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/6/2.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXTreeFolderCell.h"
#import "Masonry.h"
#define KMAXTIER 6
@interface NXTreeFolderCell ()
@property(nonatomic, strong)UIImageView *leftView;
@property(nonatomic, strong)UIImageView *folderView;
@property(nonatomic, strong)UILabel *titleView;
@end
@implementation NXTreeFolderCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self commonInitUI];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}
- (void)commonInitUI {
    UIImageView *leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessoryIcon"]];
    [self.contentView addSubview:leftView];
    self.leftView = leftView;
    UIImageView *folderView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"folder - black"]];
    [self.contentView addSubview:folderView];
    self.folderView = folderView;
    UILabel *titleLabel = [[UILabel alloc] init];
    [self.contentView addSubview:titleLabel];
    self.titleView = titleLabel;
    [leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(5);
        make.centerY.equalTo(self.contentView);
        make.width.height.equalTo(@(20));
    }];
    [folderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(leftView.mas_right).offset(5);
        make.centerY.equalTo(self.contentView);
        make.width.height.equalTo(@(30));
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(folderView.mas_right).offset(5);
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-10);
        make.height.equalTo(@30);
    }];
}
- (void)setModel:(NXFolderModel *)model {
    _model = model;
    int level = model.level;
    NSString *title = model.title;
    if (level < KMAXTIER) {
        [self.leftView mas_updateConstraints:^(MASConstraintMaker *make) {
               make.left.equalTo(self.contentView).offset(5 + level * 15);
        }];
        
    }else{
        [self.leftView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(5 + KMAXTIER * 15);
        }];
        
    }
    if (model.expanded) {
        self.leftView.transform = CGAffineTransformMakeRotation(M_PI_2);
    }else{
        self.leftView.transform = CGAffineTransformMakeRotation(0);
    }
    if (model.selected) {
        self.contentView.backgroundColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:0.8];
    }else{
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    self.titleView.text = title;
    
}
- (void)refreshArrowDirection:(CGFloat)angle animated:(BOOL)animated
{
    if (CGAffineTransformEqualToTransform(_leftView.transform, CGAffineTransformMakeRotation(angle))) return;
    
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            _leftView.transform = CGAffineTransformMakeRotation(angle);
        }];
    } else {
        _leftView.transform = CGAffineTransformMakeRotation(angle);
    }
}
@end
@implementation NXFolderModel
@end
