//
//  NXHomeHeaderView.m
//  nxrmc
//
//  Created by nextlabs on 1/12/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXHomeHeaderCell.h"

#import "NXHomeReposTableView.h"

#import "Masonry.h"
#import "UIView+UIExt.h"

#import "NXLoginUser.h"
#import "UIImage+Cutting.h"
#import "NXProcessPercentView.h"
#import "NXLProfile.h"
static const CGFloat kTopSpaces = 20.f;
@interface NXHomeHeaderCell ()

@property(nonatomic, weak) UIButton *mySpaceButton;

@end

@implementation NXHomeHeaderCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self commonInit];
    }
    return self;
}

#pragma mark ---->goto mySpace
- (void)GotoMySpace:(id)sender {
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.mySpaceButton cornerRadian:5];
    [self.mySpaceButton borderWidth:0.2];
    [self.mySpaceButton borderColor:[UIColor lightGrayColor]];
}

#pragma mark
- (void)commonInit {
    self.backgroundColor = [UIColor whiteColor];
    UILabel *welcome = [[UILabel alloc] init];
    [self.contentView addSubview:welcome];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    [self.contentView addSubview:nameLabel];
    
    UIImageView *avaterView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [self.contentView addSubview:avaterView];
    
//   tim test
    self.percentView=[[NXProcessPercentView alloc]init];
    [self.contentView addSubview:self.percentView];
    NXProcessItemModel *item1=[[NXProcessItemModel alloc]init];
    item1.name=@"MyDrive";
    item1.bgColor=[UIColor colorWithRed:52/256.0 green:153/256.0 blue:96/256.0 alpha:1];
    item1.percentAge=0.3;
    NXProcessItemModel *item2=[[NXProcessItemModel alloc]init];
    item2.name=@"MyVault";
    item2.bgColor=[UIColor colorWithRed:79/256.0 green:79/256.0 blue:79/256.0 alpha:1];
    item2.percentAge=0.4;
    
    welcome.text = @"Welcome ";
    welcome.textColor = [UIColor lightGrayColor];
    welcome.font = [UIFont systemFontOfSize:16];
    
    nameLabel.text = [NXLoginUser sharedInstance].profile.userName;
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.font = [UIFont systemFontOfSize:14];
    nameLabel.adjustsFontSizeToFitWidth=YES;
    
    [avaterView cornerRadian:avaterView.bounds.size.width/2];
    if ([NXLoginUser sharedInstance].profile.avatar) {
        avaterView.image = [UIImage imageWithBase64Str:[NXLoginUser sharedInstance].profile.avatar];
    }else {
         avaterView.image = [UIImage imageNamed:@"Account"];
    }
    
    UIButton *spaceButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.contentView addSubview:spaceButton];
    [spaceButton setTitle:@" Goto MySpace " forState:UIControlStateNormal];
    [spaceButton setTitleColor:[UIColor colorWithRed:48/256.0 green:128/256.0 blue:237/256.0 alpha:1] forState:UIControlStateNormal];
    [spaceButton addTarget:self action:@selector(GotoMySpace:) forControlEvents:UIControlEventTouchUpInside];
    spaceButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    
    self.mySpaceButton = spaceButton;
    _avaterImageView = avaterView;
    _nameLabel = nameLabel;
    
    [welcome mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(kTopSpaces*1.5);
        make.left.equalTo(self.contentView).offset(kMargin * 2);
    }];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.baseline.equalTo(welcome);
        make.left.equalTo(welcome.mas_right).offset(kMargin);
    }];
    
    [avaterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(welcome);
        make.right.equalTo(self.contentView).offset(-kMargin * 2);
        make.height.equalTo(@25);
        make.width.equalTo(@25);
    }];
    
    [self.percentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(avaterView.mas_bottom).offset(kTopSpaces*1.5);
        make.left.equalTo(welcome);
        make.right.equalTo(avaterView);
    }];

    [spaceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.percentView.mas_bottom).offset(kTopSpaces);
        make.centerX.equalTo(self.contentView);
        make.height.equalTo(@44);
        make.width.equalTo(self.contentView).multipliedBy(0.4);
        make.bottom.equalTo(self.contentView).offset(-kTopSpaces);
    }];
}

@end
