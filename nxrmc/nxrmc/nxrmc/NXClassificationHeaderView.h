//
//  NXClassificationHeaderView.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 15/3/18.
//  Copyright © 2018年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NXClassificationCategory;
@interface NXClassificationHeaderView : UICollectionReusableView
@property (nonatomic, strong)NXClassificationCategory *category;
@end
