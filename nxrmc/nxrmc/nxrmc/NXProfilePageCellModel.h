//
//  NXProfilePageCellModel.h
//  nxrmc
//
//  Created by nextlabs on 11/28/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NXProfilePageCellModel : NSObject

@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *message;
@property(nonatomic, strong) NSString *operation;
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message operation:(NSString *)operation;

@end
