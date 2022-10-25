//
//  NXAutoPurgeCache.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 7/4/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "NXAutoPurgeCache.h"

@implementation NXAutoPurgeCache
- (id)init
{
    self = [super init];
    if (self) {
        // 这里当监听到内存告急时，会自动删除所有的cahce
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllObjects) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    
}

@end
