//
//  NXHomeUpgradeView.h
//  nxrmc
//
//  Created by nextlabs on 1/12/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UpgradeBlock)(id sender);

@interface NXHomeUpgradeView : UIView

@property(nonatomic, strong) void(^upgradeBlock)(id sender);

- (CGFloat)height;

@end
