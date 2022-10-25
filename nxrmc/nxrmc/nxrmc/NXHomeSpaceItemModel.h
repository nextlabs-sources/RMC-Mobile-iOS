//
//  NXHomeSpaceItemModel.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 28/4/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NXHomeSpaceItemModel : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, assign) long fileCount;
@property (nonatomic, assign) double percentAge;
@property (nonatomic, strong) NSString *usageStr;
@property (nonatomic, assign) double percentAgeDrive;
@property (nonatomic, assign) double percentAgeVault;
@property (nonatomic, strong) UIImage *leftImage;
@property (nonatomic, assign) BOOL showFileNumber;
@end
