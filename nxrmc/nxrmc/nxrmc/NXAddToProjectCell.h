//
//  NXAddToProjectCell.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/3/13.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class NXProjectModel;
@interface NXAddToProjectCell : UITableViewCell
@property (nonatomic, strong)NXProjectModel *model;
- (void)isShowRightImageView:(BOOL)isShow;
- (void)isShowAccessBtnIconImage:(BOOL)isShow;
@end

NS_ASSUME_NONNULL_END
