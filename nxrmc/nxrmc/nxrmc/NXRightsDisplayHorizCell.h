//
//  NXRightsDisplayHorizCell.h
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/10/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NXRightsCellModel.h"

@class NXLFileValidateDateModel;
@interface NXRightsDisplayHorizCell : UICollectionViewCell

@property(nonatomic, strong) NXRightsCellModel *model;
@property(nonatomic, strong) NXLFileValidateDateModel *fileValidityModel;

+ (CGFloat)widthForTitle:(NSString *)title;

@end
