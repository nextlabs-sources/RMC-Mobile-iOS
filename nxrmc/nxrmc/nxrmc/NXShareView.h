//
//  NXShareView.h
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/3/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXRMCDef.h"

@interface NXShareView : UIView

@property(nonatomic, weak, readonly) UIImageView *imageView;
@property(nonatomic, weak, readonly) UIImageView *accessoryImageView;
@property(nonatomic, weak, readonly) UILabel *titleLabel;

@property(nonatomic, getter = isEnabled) BOOL enable;
@property(nonatomic, strong) ClickActionBlock buttonClickBlock;
@end
