//
//  NXTextView.h
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 7/17/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NXTextView : UITextView

@property(nonatomic, strong) NSString *placeholder;
@property(nonatomic, strong) UIFont *placeholderFont;
@property(nonatomic, strong) UIColor *placeholderColor;

@end
