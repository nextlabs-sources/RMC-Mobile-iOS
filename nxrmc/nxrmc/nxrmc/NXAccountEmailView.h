//
//  NXAccountEmailView.h
//  nxrmc
//
//  Created by nextlabs on 11/30/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TapClickBlock)(id sender);

@interface NXAccountEmailView : UIView

@property(nonatomic, readonly, weak) UILabel *emaiLabel;
@property(nonatomic, readonly, weak) UIImageView *imageView;

@property(nonatomic, strong) TapClickBlock tapclickBlock;

@end
