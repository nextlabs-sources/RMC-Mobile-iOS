//
//  NXHomeUpgradesView.h
//  nxrmc
//
//  Created by helpdesk on 10/2/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface NXHomeUpgradesView : UIView
@property (nonatomic ,copy) void(^upgradeBlock)(id sender);

@end
