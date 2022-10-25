//
//  NXSkyDRMItemsView.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/6/3.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class NXProjectModel;
typedef void(^afterSelectItemCompletion)(NSString *path);
typedef void(^afterSelectTableViewItemCompletion)(id itemModel);
@interface NXSkyDRMItemsView : UIView
@property(nonatomic, copy)afterSelectItemCompletion selectedCompletion;
@property(nonatomic, copy)afterSelectTableViewItemCompletion selectedItemModelCompletion;
@end

NS_ASSUME_NONNULL_END
