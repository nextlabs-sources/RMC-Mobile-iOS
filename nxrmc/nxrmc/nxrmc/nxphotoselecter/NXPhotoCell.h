//
//  NXPhotoCell.h
//  xiblayout
//
//  Created by nextlabs on 10/17/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NXPhotoTool.h"

typedef void (^ButtonClickBlock)(id);

@interface NXPhotoCell : UICollectionViewCell

@property(nonatomic, strong) NXAssetItem *model;
@property(nonatomic, copy) ButtonClickBlock selectBlock;
@property(nonatomic, weak) UIButton *selectButton;
@end
