//
//  NXFileRendererBase.m
//  nxrmc
//
//  Created by EShi on 10/25/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXFileRendererBase.h"
@implementation NXFileRendererBase
- (UIView *)renderFile:(NSURL *)filePath {
    BOOL isDirectory;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath.path isDirectory:&isDirectory]) {
        if (isDirectory) {
            return nil;
        }
        return [[UIView alloc] init];
    }
    return nil;
}

- (void)addOverlayer:(UIView *)overlay {
    
}

- (void)removeOverlayer{
}

- (void)snapShot:(getSnapshotCompletionBlock)block
{
    assert(0);
    block(nil);
}


@end
