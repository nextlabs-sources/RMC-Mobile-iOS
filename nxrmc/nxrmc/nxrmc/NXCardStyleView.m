//
//  NXCardStyleView.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 29/3/18.
//  Copyright © 2018年 nextlabs. All rights reserved.
//

#import "NXCardStyleView.h"

@implementation NXCardStyleView
- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}
- (void)commonInit {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 20;
    self.layer.shadowColor = [UIColor grayColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(1,1);
    self.layer.shadowOpacity = 0.7;
}
@end
