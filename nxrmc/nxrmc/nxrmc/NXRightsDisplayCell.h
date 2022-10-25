//
//  NXRightsDisplayCell.h
//  nxrmcUITest
//
//  Created by nextlabs on 11/9/16.
//  Copyright © 2016 zhuimengfuyun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NXRightsCellModel.h"

@interface NXRightsDisplayCell : UICollectionViewCell

@property(nonatomic, strong) NXRightsCellModel *model;

+ (CGFloat)widthForTitle:(NSString *)title;
@end
