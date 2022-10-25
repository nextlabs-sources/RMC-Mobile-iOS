//
//  NXHomeSpaceCollectionViewCell.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 27/4/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
//@interface NXProcessItemInfoModel : NSObject
//@property (nonatomic, strong) NSString *name;
//@property (nonatomic, strong) UIColor *bgColor;
//@property (nonatomic, assign) double percentAge;
//@property (nonatomic, strong) NSString *usageStr;
//@property (nonatomic, assign) double percentAgeDrive;
//@property (nonatomic, assign) double percentAgeVault;
//@end
@class NXHomeSpaceItemModel;
@interface NXHomeSpaceCollectionViewCell : UICollectionViewCell
@property(nonatomic, strong) NXHomeSpaceItemModel *model;
@end
@interface NXHomeMySpaceViewCell : UICollectionViewCell
@property(nonatomic, strong) NXHomeSpaceItemModel *model;
@end
