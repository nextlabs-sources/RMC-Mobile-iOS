//
//  NXImageItemDisplayCell.h
//  xiblayout
//
//  Created by nextlabs on 10/19/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXPhotoTool.h"

@interface NXImageItemDisplayCell : UICollectionViewCell

@property(nonatomic, strong) NXAssetItem *model;

@property(nonatomic, copy) void (^singleTapCallBack)();

@end
