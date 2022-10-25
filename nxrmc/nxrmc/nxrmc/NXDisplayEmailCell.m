//
//  NXDisplayEmailCell.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/4/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXDisplayEmailCell.h"

#import "Masonry.h"

@implementation NXDisplayEmailCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.errorButton removeFromSuperview];
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-kMargin/4);
        }];
    }
    return self;
}

@end
