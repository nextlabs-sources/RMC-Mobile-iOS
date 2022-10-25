//
//  NXAddRepoPageCellModel.h
//  nxrmc
//
//  Created by nextlabs on 11/28/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NXRMCDef.h"

@interface NXAddRepoPageCellModel : NSObject

@property(nonatomic, readonly, strong) NSString *title;
@property(nonatomic, readonly, strong) NSString *imagename;
@property(nonatomic, readonly, assign) ServiceType type;

- (instancetype)initWithServiceType:(ServiceType)type;

@end
