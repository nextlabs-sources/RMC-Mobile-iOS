//
//  NXPolicyEngineWrapper.h
//  nxrmc
//
//  Created by Kevin on 15/6/5.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>


@class NXLRights;
@interface NXPolicyEngineWrapper : NSObject

+ (NXPolicyEngineWrapper*) sharedPolicyEngine;

@end
