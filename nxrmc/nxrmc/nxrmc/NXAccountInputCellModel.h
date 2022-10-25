//
//  NXAccountInputCellModel.h
//  nxrmc
//
//  Created by nextlabs on 11/30/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NXAccountInputCellModel : NSObject

@property(nonatomic, strong) NSString *promptText;
@property(nonatomic, strong) NSString *placeholder;
@property(nonatomic, strong) NSString *text;

- (instancetype)initWithText:(NSString *)text placeholder:(NSString *)placeholder prompt:(NSString *)prompt;

@end
