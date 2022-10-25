//
//  NXHomeSpaceCollectionViewCell.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 27/4/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXHomeSpaceCollectionViewCell.h"
#import "Masonry.h"
#import "NXHomeSpaceItemModel.h"
#import "UIView+UIExt.h"
@interface NXHomeSpaceCollectionViewCell ()
@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) UILabel *fileCountLabel;
@property(nonatomic, strong) UILabel *usedSizeLabel;
@property(nonatomic, strong) UIImageView *leftImageView;
@end

//@implementation NXProcessItemModel 
//@end

@implementation NXHomeSpaceCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
        [self.contentView cornerRadian:2];
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}
- (void)commonInit {
    _leftImageView = [[UIImageView alloc]init];
    [self.contentView addSubview:_leftImageView];
    _nameLabel = [[UILabel alloc]init];
    [self.contentView addSubview:_nameLabel];
    _fileCountLabel = [[UILabel alloc]init];
    [self.contentView addSubview:_fileCountLabel];
    _fileCountLabel.textColor = [UIColor grayColor];
    _usedSizeLabel = [[UILabel alloc]init];
    [self.contentView addSubview:_usedSizeLabel];
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.image = [UIImage imageNamed:@"right chevron - black"];
    [self.contentView addSubview:imageView];
    
    //_leftImageView.backgroundColor = [UIColor redColor];
    _leftImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [_leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(30);
        make.left.equalTo(self.contentView).offset(15);
        make.height.equalTo(@35);
        make.width.equalTo(@40);
    }];

    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(15);
        make.left.equalTo(_leftImageView.mas_right).offset(5);
        make.width.equalTo(@100);
        make.height.equalTo(@30);
    }];
    [_fileCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_nameLabel.mas_bottom);
        make.left.width.equalTo(_nameLabel);
    }];
    [_usedSizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_fileCountLabel.mas_bottom);
        make.left.equalTo(_nameLabel);
        make.width.equalTo(_nameLabel);
    }];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_nameLabel).offset(10);
        make.right.equalTo(self.contentView).offset(-10);
        make.width.height.equalTo(@15);
    }];
}
- (void)setModel:(NXHomeSpaceItemModel *)model {
    _nameLabel.text = model.name;
    _leftImageView.image = model.leftImage;
    if (model.showFileNumber) {
        _fileCountLabel.hidden = NO;
         _fileCountLabel.text = [NSString stringWithFormat:@"%ld files",model.fileCount];
    }else{
        _fileCountLabel.hidden = YES;
    }
  
    _nameLabel.accessibilityValue = [NSString stringWithFormat:@"HOME_PAGE_%@", model.name];
    _usedSizeLabel.text = model.usageStr;
     [self.usedSizeLabel setHidden:YES];
}
@end
@interface NXHomeMySpaceViewCell ()
@property(nonatomic, strong)UILabel *nameLabel;
@property(nonatomic, strong)UILabel *freeLabel;
@property(nonatomic, strong)UIView *mySpaceView;
@property(nonatomic, strong)UIView *myDriveView;
@property(nonatomic, strong)UIView *myVaultView;
@end
@implementation NXHomeMySpaceViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
        self.backgroundColor = [UIColor whiteColor];
        [self.contentView cornerRadian:2];
    }
    return self;
}
- (void)commonInit {
    UILabel *nameLabel = [[UILabel alloc]init];
    [self.contentView addSubview:nameLabel];
    self.nameLabel = nameLabel;
    UILabel *freeLabel = [[UILabel alloc]init];
    freeLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:freeLabel];
    self.freeLabel = freeLabel;
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.image = [UIImage imageNamed:@"right chevron - black"];
    [self.contentView addSubview:imageView];
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(18);
        make.left.equalTo(self.contentView).offset(15);
        make.width.equalTo(@80);
        make.height.equalTo(@30);
    }];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLabel).offset(10);
        make.right.equalTo(self.contentView).offset(-15);
        make.width.height.equalTo(@15);
    }];
    [freeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLabel);
        make.right.equalTo(imageView).offset(-25);
        make.width.equalTo(@150);
        make.height.equalTo(@30);
    }];
    UIView *mySpaceView = [[UIView alloc]init];
    [self.contentView addSubview:mySpaceView];
    mySpaceView.backgroundColor = [UIColor lightGrayColor];
    self.mySpaceView = mySpaceView;
    UIView *myDriveView = [[UIView alloc]init];
    [mySpaceView addSubview:myDriveView];
    self.myDriveView = myDriveView;
    myDriveView.backgroundColor = [UIColor colorWithRed:47/256.0 green:128/256.0 blue:237/256.0 alpha:1];
    UIView *myVaultView = [[UIView alloc]init];
    [mySpaceView addSubview:myVaultView];
    self.myVaultView = myVaultView;
    myVaultView.backgroundColor = [UIColor colorWithRed:153/256.0 green:206/256.0 blue:101/256.0 alpha:1];
}
- (void)setModel:(NXHomeSpaceItemModel *)model {
   
   self.nameLabel.text = model.name;
    self.nameLabel.accessibilityValue = [NSString stringWithFormat:@"HOME_PAGE_%@", model.name];
    NSMutableAttributedString *rightInfoText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ",model.usageStr] attributes:@{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName:[UIFont systemFontOfSize:17]}];
    NSAttributedString *message = [[NSAttributedString alloc] initWithString:@"available" attributes:@{NSForegroundColorAttributeName : [UIColor grayColor], NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    [rightInfoText appendAttributedString:message];
    self.freeLabel.attributedText = rightInfoText;
    
    double myDriveSize = model.percentAgeDrive;
    double myVaultSize = model.percentAgeVault;
    
    [self.mySpaceView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.freeLabel.mas_bottom).offset(20);
        make.left.equalTo(self.nameLabel);
        make.right.equalTo(self.freeLabel);
        make.height.equalTo(@5);
    }];
    if (myDriveSize>0) {
        [self.myDriveView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.height.equalTo(self.mySpaceView);
            make.width.equalTo(self.mySpaceView).multipliedBy(myDriveSize);
        }];
    }
    if (myVaultSize>0) {
        [self.myVaultView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.height.equalTo(self.mySpaceView);
            make.left.equalTo(self.myDriveView.mas_right);
            make.width.equalTo(self.mySpaceView).multipliedBy(myVaultSize);
        }];
    }
    
   
}
@end


