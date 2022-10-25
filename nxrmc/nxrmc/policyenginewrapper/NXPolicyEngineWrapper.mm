//
//  NXPolicyEngineWrapper.m
//  nxrmc
//
//  Created by Kevin on 15/6/5.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import "NXPolicyEngineWrapper.h"

#import <map>
#import <vector>

#import "NXPolicyEngine.h"
#import "NXLoginUser.h"
#import "NXLMetaData.h"
#import "NXLRights.h"
static NXPolicyEngineWrapper* sharedObj = nil;


@implementation NXPolicyEngineWrapper


+ (NXPolicyEngineWrapper*) sharedPolicyEngine
{
    @synchronized(self)
    {
        if (sharedObj == nil) {
            sharedObj = [[super allocWithZone:nil] init];
        }
    }
    
    return sharedObj;
}

+ (id) allocWithZone:(struct _NSZone *)zone
{
    return nil;
}

@end



