//
//  NXAccountInputCellModel.m
//  nxrmc
//
//  Created by nextlabs on 11/30/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXAccountInputCellModel.h"

@implementation NXAccountInputCellModel

- (instancetype)initWithText:(NSString *)text placeholder:(NSString *)placeholder prompt:(NSString *)prompt {
    if (self = [super init]) {
        _text = text;
        _placeholder = placeholder;
        _promptText = prompt;
    }
    return self;
}
@end
