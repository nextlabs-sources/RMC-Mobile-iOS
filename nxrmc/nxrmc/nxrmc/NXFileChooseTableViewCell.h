//
//  NXFileChooseTableViewCell.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 5/3/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXFileBase.h"

typedef NS_ENUM(NSInteger, NXFileChooseTableViewCellType){
    NXFileChooseTableViewCellTypeChooseFile = 1,
    NXFileChooseTableViewCellTypeChooseFolder = 2,
};

@interface NXFileChooseTableViewCell : UITableViewCell
@property(nonatomic, assign) BOOL isSelected;
@property(nonatomic, strong) NXFileBase *model;
@property(nonatomic, assign) NXFileChooseTableViewCellType cellType;
@property(nonatomic, strong) UIImageView *selectedImageView;
- (void)isShowSelectedRightImage:(BOOL)isShow;
@end
