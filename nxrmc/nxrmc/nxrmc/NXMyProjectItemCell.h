//
//  NXMyProjectItemCell.h
//  nxrmc
//
//  Created by nextlabs on 1/20/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXProjectModel.h"

typedef void(^inviteLabelTouchUpInside)(NXProjectModel *projectModel);

@interface NXMyProjectItemCell : UICollectionViewCell
@property(nonatomic, weak) UILabel *titleLabel;
@property(nonatomic, strong) NXProjectModel *model;

@property (nonatomic,copy) inviteLabelTouchUpInside inviteLabelTouchUpInside;

@end
