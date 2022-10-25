//
//  NXFolder.h
//  nxrmc
//
//  Created by Kevin on 15/5/7.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NXFileBase.h"

@interface NXFolder : NXFileBase<NSCopying>

@property (nonatomic, strong)  NSMutableArray *children;

+ (NXFileBase*) createRootFolder;

@end
