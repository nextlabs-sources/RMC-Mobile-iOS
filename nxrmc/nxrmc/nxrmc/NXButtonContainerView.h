//
//  NXButtonContainerView.h
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/2/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXRMCDef.h"

@interface NXButtonContainerView : UIView

@property(nonatomic, strong) ClickActionBlock buttonClickBlock;

@property(nonatomic, getter=isEnabled) BOOL enabled;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) UIImage *image;

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image;

@end
