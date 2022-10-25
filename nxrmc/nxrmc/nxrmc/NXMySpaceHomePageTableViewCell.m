//
//  NXMySpaceHomePageTableViewCell.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2020/4/23.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXMySpaceHomePageTableViewCell.h"

@interface  NXMySpaceHomePageTableViewCell()

@property (nonatomic,strong) UIImageView *leftRepoImageView;
@property (nonatomic,strong) UIImageView *rightArrowImageView;
@property (nonatomic,strong) UIImageView *divideLineImageView;
@property (nonatomic,strong) UIImageView *usedStorageImageView;
@property (nonatomic,strong) UIImageView *proportionImageView;
@property (nonatomic,strong) UIImageView *myDriveProportionImageView;
@property (nonatomic,strong) UIImageView *myVaultProportionImageView;
@property (nonatomic,strong) UILabel *repoTitle;
@property (nonatomic,strong) UILabel *myDriveTitle;
@property (nonatomic,strong) UIImageView *myDriveSquareImageView;
@property (nonatomic,strong) UILabel *myVaultTitle;
@property (nonatomic,strong) UIImageView *myVaultSquareImageView;
@property (nonatomic,strong) UILabel *rightRepoFilesCountTitle;
@property (nonatomic,strong) UILabel *filesCountLabel;
@property (nonatomic,strong) UILabel *descriptionLabel;
@property (nonatomic,strong) UILabel *usedStorageLabel;
@property(nonatomic, weak) MASConstraint *w;
@property(nonatomic, weak) MASConstraint *myDriveW;
@property(nonatomic, weak) MASConstraint *myVaultW;
@property(nonatomic, weak) MASConstraint *myDriveLeftMargin;
@property(nonatomic, weak) MASConstraint *myVaultLeftMargin;
@property(nonatomic, weak) MASConstraint *desH;

@end

@implementation NXMySpaceHomePageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)commonInit {
    self.backgroundColor = [UIColor whiteColor];
    UIImageView *leftRepoImageView = [[UIImageView alloc] init];
    leftRepoImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.leftRepoImageView = leftRepoImageView;
    [self.contentView addSubview:leftRepoImageView];
    
    UIImageView *rightArrowImageView = [[UIImageView alloc] init];
    rightArrowImageView.image = [UIImage imageNamed:@"arrow-right-icon"];
     rightArrowImageView.contentMode = UIViewContentModeCenter;
     self.rightArrowImageView = rightArrowImageView;
    [self.contentView addSubview:rightArrowImageView];
    
    UILabel *rightRepoFilesCountTitle = [[UILabel alloc] init];
    rightRepoFilesCountTitle.font = [UIFont systemFontOfSize:14.0];
    rightRepoFilesCountTitle.textColor = [UIColor colorWithRed:141.0/255.0 green:141.0/255.0 blue:141.0/255.0 alpha:1.0];
    rightRepoFilesCountTitle.textAlignment = NSTextAlignmentRight;
    self.rightRepoFilesCountTitle = rightRepoFilesCountTitle;
    [self.contentView addSubview:rightRepoFilesCountTitle];
    
    UIImageView *divideLineImageView = [[UIImageView alloc] init];
     self.divideLineImageView = divideLineImageView;
    [self.contentView addSubview:divideLineImageView];
    
    UIImageView *usedStorageImageView = [[UIImageView alloc] init];
    usedStorageImageView.layer.masksToBounds = YES;
    usedStorageImageView.layer.cornerRadius = 5.f;
    self.usedStorageImageView = usedStorageImageView;
    [self.contentView addSubview:usedStorageImageView];
    
    //UIImageView *proportionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(57, 0, 253, 18)];
     // UIImageView *proportionImageView = [[UIImageView alloc] init];
    // self.proportionImageView = proportionImageView;
//    proportionImageView.layer.masksToBounds = YES;
//    proportionImageView.layer.cornerRadius = 5.f;
   //  [self.contentView addSubview:proportionImageView];
    
    UIImageView *myDriveProportionImageView = [[UIImageView alloc] init];
    self.myDriveProportionImageView = myDriveProportionImageView;
    [self.contentView addSubview:myDriveProportionImageView];
    
     UIImageView *myVaultProportionImageView = [[UIImageView alloc] init];
     self.myVaultProportionImageView = myVaultProportionImageView;
     [self.contentView addSubview:myVaultProportionImageView];

    UILabel *repoTitle = [[UILabel alloc] init];
    repoTitle.font = [UIFont systemFontOfSize:18.0];
    self.repoTitle = repoTitle;
    [self.contentView addSubview:repoTitle];
    
    UILabel *filesCountLabel = [[UILabel alloc] init];
    filesCountLabel.textAlignment = NSTextAlignmentRight;
    filesCountLabel.font = [UIFont systemFontOfSize:18.0];
    filesCountLabel.textColor = [UIColor colorWithRed:147.0/255.0 green:147.0/255.0 blue:147.0/255.0 alpha:1.0];
    self.filesCountLabel = filesCountLabel;
    [self.contentView addSubview:filesCountLabel];
    
    UILabel *descriptionLabel = [[UILabel alloc] init];
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.font = [UIFont systemFontOfSize:14.0];
    descriptionLabel.textColor = [UIColor colorWithRed:141.0/255.0 green:141.0/255.0 blue:141.0/255.0 alpha:1.0];
    self.descriptionLabel = descriptionLabel;
    [self.contentView addSubview:descriptionLabel];
    
    UILabel *usedStorageLabel = [[UILabel alloc] init];
    usedStorageLabel.textAlignment = NSTextAlignmentRight;
    usedStorageLabel.font = [UIFont systemFontOfSize:12.0];
    usedStorageLabel.textColor = [UIColor colorWithRed:125.0/255.0 green:125.0/255.0 blue:125.0/255.0 alpha:1.0];
    self.usedStorageLabel = usedStorageLabel;
    [self.contentView addSubview:usedStorageLabel];
    
    UIImageView *myDriveSquareImageView = [[UIImageView alloc] init];
    myDriveSquareImageView.backgroundColor =  [UIColor colorWithRed:37.0/255.0 green:159.0/255.0 blue:244.0/255.0 alpha:1.0];
       self.myDriveSquareImageView = myDriveSquareImageView;
    [self.contentView addSubview:myDriveSquareImageView];
    
    UILabel *MyDriveLabel = [[UILabel alloc] init];
    MyDriveLabel.text = @"MyDrive";
    MyDriveLabel.font = [UIFont systemFontOfSize:10.0];
    self.myDriveTitle = MyDriveLabel;
    [self.contentView addSubview:MyDriveLabel];
    
    UIImageView *myVaultSquareImageView = [[UIImageView alloc] init];
    myVaultSquareImageView.backgroundColor =  [UIColor colorWithRed:247.0/255.0 green:210.0/255.0 blue:90.0/255.0 alpha:1.0];
    self.myVaultSquareImageView = myVaultSquareImageView;
    [self.contentView addSubview:myVaultSquareImageView];
      
      UILabel *MyVaultLabel = [[UILabel alloc] init];
      self.myVaultTitle = MyVaultLabel;
      MyVaultLabel.font = [UIFont systemFontOfSize:10.0];
      MyVaultLabel.text = @"MyVault";
      [self.contentView addSubview:MyVaultLabel];
    
    [_leftRepoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(15);
        make.left.equalTo(self.contentView).offset(15);
        make.height.equalTo(@32);
        make.width.equalTo(@32);
    }];
    
    [_repoTitle mas_makeConstraints:^(MASConstraintMaker *make) {
          make.top.equalTo(self.contentView).offset(18);
          make.left.equalTo(_leftRepoImageView.mas_right).offset(10);
          make.height.equalTo(@20);
          make.width.equalTo(@150);
      }];
    
    [_rightArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
             make.top.equalTo(self.contentView).offset(22);
             make.right.equalTo(self.contentView).offset(-20);
             make.height.equalTo(@12);
             make.width.equalTo(@7);
         }];
    
    [_rightRepoFilesCountTitle mas_makeConstraints:^(MASConstraintMaker *make) {
              make.top.equalTo(self.contentView).offset(22);
              make.right.equalTo(_rightArrowImageView).offset(-15);
              make.height.equalTo(@12);
              make.width.equalTo(@77);
    }];
    
    [_filesCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
           make.top.equalTo(self.contentView).offset(18);
           make.right.equalTo(_rightArrowImageView.mas_left).offset(-8);
           make.height.equalTo(@20);
           make.width.equalTo(@100);
       }];
     
    [_divideLineImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_repoTitle.mas_bottom).offset(15);
                make.right.equalTo(self.contentView).offset(-5);
                make.left.equalTo(self.contentView).offset(57);
                make.height.equalTo(@1);
    }];
    
    [_descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                  make.top.equalTo(_divideLineImageView).offset(12);
                  make.right.equalTo(self.contentView).offset(-5);
                  make.left.equalTo(self.contentView).offset(57);
                  make.height.equalTo(@35);
      }];
    
    [_usedStorageImageView mas_makeConstraints:^(MASConstraintMaker *make) {
             make.top.equalTo(_descriptionLabel.mas_bottom).offset(5);
             make.left.equalTo(_descriptionLabel);
             make.right.equalTo(_descriptionLabel).offset(-20);
             make.height.equalTo(@18);
             //make.width.equalTo(@253);
     }];
    
//    [_proportionImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//              make.top.equalTo(_descriptionLabel.mas_bottom).offset(5);
//              make.left.equalTo(_descriptionLabel);
//              make.height.equalTo(@18);
//             _w = make.width.equalTo(@0);
//      }];
    
    [_myDriveProportionImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_descriptionLabel.mas_bottom).offset(5);
                _myDriveLeftMargin = make.left.equalTo(_descriptionLabel);
                make.height.equalTo(@18);
               _myDriveW = make.width.equalTo(@0);
        }];
    
    [_myVaultProportionImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_descriptionLabel.mas_bottom).offset(5);
               _myVaultLeftMargin = make.left.equalTo(_descriptionLabel);
                make.height.equalTo(@18);
               _myVaultW = make.width.equalTo(@0);
        }];
    
    [_usedStorageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
               make.top.equalTo(_usedStorageImageView.mas_bottom).offset(10);
               make.right.equalTo(_usedStorageImageView);
               make.height.equalTo(@15);
               make.width.equalTo(@200);
       }];
    
    [_usedStorageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                  make.top.equalTo(_usedStorageImageView.mas_bottom).offset(10);
                  make.right.equalTo(_usedStorageImageView);
                  make.height.equalTo(@15);
                  make.width.equalTo(@200);
    }];
    
    [_myDriveSquareImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(12));
        make.height.equalTo(@(12));
        make.left.equalTo(_usedStorageImageView);
        make.top.equalTo(_usedStorageImageView.mas_bottom).offset(10);
    }];
    
    [_myDriveTitle mas_makeConstraints:^(MASConstraintMaker *make) {
          make.height.equalTo(@(12));
          make.width.equalTo(@(40));
          make.left.equalTo(_myDriveSquareImageView.mas_right).offset(5);
          make.top.equalTo(_usedStorageImageView.mas_bottom).offset(10);
      }];
    
    [_myVaultSquareImageView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.width.equalTo(@(12));
          make.height.equalTo(@(12));
          make.left.equalTo(_myDriveTitle.mas_right).offset(10);
          make.top.equalTo(_usedStorageImageView.mas_bottom).offset(10);
      }];
      
      [_myVaultTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(12));
            make.width.equalTo(@(40));
            make.left.equalTo(_myVaultSquareImageView.mas_right).offset(5);
            make.top.equalTo(_usedStorageImageView.mas_bottom).offset(10);
        }];
}

- (void)setModel:(NXMySpaceHomePageRepoModel *)model {
    [self.filesCountLabel setHidden:YES];
//    [_w uninstall];
    [_myVaultW uninstall];
    [_myDriveW uninstall];
    [_myDriveLeftMargin uninstall];
    [_myVaultLeftMargin  uninstall];
//    [_desH uninstall];
//
//    if (model.repoDescription.length == 0) {
//        [_descriptionLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//            _desH = make.height.equalTo(@1);
//        }];
//    }
  //  double proportion = model.proportion;
    double myDriveproportion = model.myDriveProportion;
    double myVaultProportion = model.myVaultProportion;
//    if (model.proportion < 0.01) {
//        proportion = 0.01;
//    }
    if (model.myDriveProportion < 0.01) {
             myDriveproportion = 0.01;
        }
    
    if (model.myVaultProportion < 0.01) {
           myVaultProportion = 0.01;
       }
    
    [self.rightArrowImageView setHidden:NO];
    [self.rightRepoFilesCountTitle setHidden:NO];
    [self.myVaultTitle setHidden:NO];
    [self.myDriveTitle setHidden:NO];
    [self.myDriveSquareImageView setHidden:NO];
    [self.myVaultSquareImageView setHidden:NO];
    [self.divideLineImageView setHidden:NO];
    if (model.type == NXMySpaceHomePageRepoModelTypeMySpace) {
        [self.rightArrowImageView setHidden:YES];
        [self.usedStorageLabel setHidden:NO];
        [self.usedStorageImageView setHidden:NO];
        [self.proportionImageView setHidden:YES];
        [self.rightRepoFilesCountTitle setHidden:YES];
        self.repoTitle.text = model.title;
        self.filesCountLabel.text = model.filesCount;
        self.descriptionLabel.text = model.repoDescription;
        self.usedStorageLabel.text = model.spaceUsedDesStr;
        self.leftRepoImageView.image = [UIImage imageNamed:@"X - NextLabs Inc. Logo"];
        self.myDriveProportionImageView.backgroundColor =  [UIColor colorWithRed:37.0/255.0 green:159.0/255.0 blue:244.0/255.0 alpha:1.0];
        self.myVaultProportionImageView.backgroundColor =  [UIColor colorWithRed:247.0/255.0 green:210.0/255.0 blue:90.0/255.0 alpha:1.0];
        
//   [_myDriveProportionImageView mas_updateConstraints:^(MASConstraintMaker *make) {
//                                  _myDriveW = make.width.equalTo(_usedStorageImageView).multipliedBy(proportion);
//                           }];
//
//                 [_myVaultProportionImageView mas_updateConstraints:^(MASConstraintMaker *make) {
//                                        _myVaultW = make.width.equalTo(_usedStorageImageView).multipliedBy(proportion);
//                             }];
                 
                 if (model.myVaultProportion > model.myDriveProportion) {
                     [_myVaultProportionImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                                        
                                      _myVaultW = make.width.equalTo(_usedStorageImageView).multipliedBy(myVaultProportion);
                                     _myVaultLeftMargin = make.left.equalTo(_descriptionLabel);
                                   }];
                         
                         [_myDriveProportionImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                               _myDriveW = make.width.equalTo(_usedStorageImageView).multipliedBy(myDriveproportion);
                              _myDriveLeftMargin = make.left.equalTo(_myVaultProportionImageView.mas_right);
                                     }];
                 }else{
                                  [_myDriveProportionImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                                       _myDriveW = make.width.equalTo(_usedStorageImageView).multipliedBy(myDriveproportion);
                                      _myDriveLeftMargin = make.left.equalTo(_descriptionLabel);
                                              }];
                     
                     [_myVaultProportionImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                           _myVaultW = make.width.equalTo(_usedStorageImageView).multipliedBy(myVaultProportion);
                                                             _myVaultLeftMargin = make.left.equalTo(_myDriveProportionImageView.mas_right);
                                                      }];
                 }
      }
    
    if (model.type == NXMySpaceHomePageRepoModelTypeMyDrive) {
        [self.usedStorageLabel setHidden:YES];
        [self.usedStorageImageView setHidden:YES];
        [self.proportionImageView setHidden:YES];
        [self.myVaultTitle setHidden:YES];
        [self.myDriveTitle setHidden:YES];
        [self.myDriveSquareImageView setHidden:YES];
        [self.myVaultSquareImageView setHidden:YES];
        self.repoTitle.text = model.title;
        self.filesCountLabel.text = model.filesCount;
        self.descriptionLabel.text = model.repoDescription;
        // display files count
         self.rightRepoFilesCountTitle.text =model.filesCount;
         self.leftRepoImageView.image = [UIImage imageNamed:@"MyDrive-icon"];
          self.proportionImageView.backgroundColor =  [UIColor colorWithRed:37.0/255.0 green:159.0/255.0 blue:244.0/255.0 alpha:1.0];
        
//        [_proportionImageView mas_updateConstraints:^(MASConstraintMaker *make) {
//                _w = make.width.equalTo(_usedStorageImageView).multipliedBy(proportion);
//         }];
    }
    
    if (model.type == NXMySpaceHomePageRepoModelTypeMyVault) {
        [self.usedStorageLabel setHidden:YES];
        [self.usedStorageImageView setHidden:YES];
        [self.proportionImageView setHidden:YES];
         [self.myVaultTitle setHidden:YES];
         [self.myDriveTitle setHidden:YES];
         [self.myDriveSquareImageView setHidden:YES];
         [self.myVaultSquareImageView setHidden:YES];
//       self.repoTitle.text = @"MyVault";
//       self.filesCountLabel.text = @"671 files";
//       self.descriptionLabel.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Inter aliquet odio ut elit";
//       self.usedStorageLabel.text = @"34 KB of 1GB Used";
       self.repoTitle.text = model.title;
       self.filesCountLabel.text = model.filesCount;
        self.descriptionLabel.text = model.repoDescription;
        // display files count
        self.rightRepoFilesCountTitle.text = model.filesCount;
       self.leftRepoImageView.image = [UIImage imageNamed:@"myVault-icon"];
       self.proportionImageView.backgroundColor =  [UIColor colorWithRed:112.0/255.0 green:181.0/255.0 blue:91.0/255.0 alpha:1.0];
//        [_proportionImageView mas_updateConstraints:^(MASConstraintMaker *make) {
//               _w = make.width.equalTo(_usedStorageImageView).multipliedBy(proportion);
//        }];
    }
    
     if (model.type == NXMySpaceHomePageRepoModelTypeSharedWithMe) {
            [self.usedStorageLabel setHidden:YES];
            [self.usedStorageImageView setHidden:YES];
            [self.proportionImageView setHidden:YES];
             [self.myVaultTitle setHidden:YES];
             [self.myDriveTitle setHidden:YES];
             [self.myDriveSquareImageView setHidden:YES];
             [self.myVaultSquareImageView setHidden:YES];
             [self.divideLineImageView setHidden:NO];
             self.descriptionLabel.text = model.repoDescription;
             self.repoTitle.text = model.title;
            self.filesCountLabel.text = model.filesCount;
            self.rightRepoFilesCountTitle.text = model.filesCount;
           self.leftRepoImageView.image = [UIImage imageNamed:@"Shared with me"];
           self.proportionImageView.backgroundColor =  [UIColor colorWithRed:112.0/255.0 green:181.0/255.0 blue:91.0/255.0 alpha:1.0];
        }
    
    self.divideLineImageView.backgroundColor = [UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0];
    self.usedStorageImageView.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:241.0/255.0 blue:247.0/255.0 alpha:1.0];
    // self.usedStorageImageView.backgroundColor = [UIColor redColor];
    [self setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.6 delay:0.1 options:UIViewAnimationOptionTransitionNone animations:^{
         [self.myDriveProportionImageView layoutIfNeeded];
        [self.myVaultProportionImageView layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
    
//    [UIView transitionWithView:self.proportionImageView duration:0.6 options:UIViewAnimationOptionCurveLinear animations:^{
//         [self.proportionImageView layoutIfNeeded];
//    } completion:^(BOOL finished) {
//
//    }];
    
   [self layoutIfNeeded];
//   UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.proportionImageView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(5, 5)];
//   CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//   maskLayer.frame = self.proportionImageView.bounds;
//    maskLayer.path = path.CGPath;
//    self.proportionImageView.layer.mask = maskLayer;
    
    if (model.myVaultProportion > model.myDriveProportion){
        [self.myVaultProportionImageView layoutIfNeeded];
            UIBezierPath *path1 = [UIBezierPath bezierPathWithRoundedRect:self.myVaultProportionImageView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(5, 5)];
            CAShapeLayer *maskLayer1 = [[CAShapeLayer alloc] init];
            maskLayer1.frame = self.myVaultProportionImageView.bounds;
             maskLayer1.path = path1.CGPath;
             self.myVaultProportionImageView.layer.mask = maskLayer1;
    }else{
        [self.myDriveProportionImageView layoutIfNeeded];
          UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.myDriveProportionImageView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(5, 5)];
          CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
          maskLayer.frame = self.myDriveProportionImageView.bounds;
           maskLayer.path = path.CGPath;
           self.myDriveProportionImageView.layer.mask = maskLayer;
    }
#if 0
self.usedStorageLabel.backgroundColor = [UIColor yellowColor];
self.rightArrowImageView.backgroundColor = [UIColor greenColor];
self.filesCountLabel.backgroundColor = [UIColor blueColor];
self.leftRepoImageView.backgroundColor = [UIColor redColor];
self.repoTitle.backgroundColor = [UIColor yellowColor];
self.descriptionLabel.backgroundColor = [UIColor purpleColor];
self.repoUsedSpaceTitle.backgroundColor = [UIColor yellowColor];
#endif
}

@end
