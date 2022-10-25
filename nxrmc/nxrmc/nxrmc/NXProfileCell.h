//
//  NXProfileCell.h
//  nxrmc
//
//  Created by nextlabs on 11/29/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NXProfilePageCellModel.h"

@interface NXProfileCell : UITableViewCell

@property(nonatomic, weak, readonly) UILabel *titleLabel;
@property(nonatomic, weak, readonly) UILabel *messageLabel;
@property(nonatomic, weak, readonly) UIView *customAccessView;
@property(nonatomic, weak, readonly) UILabel *infoLabel;
@property(nonatomic, strong) NXProfilePageCellModel *model;

@property(nonatomic, assign) BOOL accssViewHidden;

@end
