//
//  NXProjectHeaderBaseCell.m
//  nxrmcUITest
//
//  Created by nextlabs on 2/13/17.
//  Copyright © 2017 zhuimengfuyun. All rights reserved.
//

#import "NXProjectHeaderBaseCell.h"

@implementation NXProjectHeaderBaseCell

- (void)layoutSubviews {
    self.clipsToBounds = YES;
    self.layer.cornerRadius = self.contentView.bounds.size.width/2;
    self.backgroundColor = [UIColor whiteColor];
}

@end
