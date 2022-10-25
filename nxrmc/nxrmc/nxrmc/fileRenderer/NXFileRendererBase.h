//
//  NXFileRendererBase.h
//  nxrmc
//
//  Created by EShi on 10/25/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NXRMCDef.h"
#import "NXFileBase.h"

typedef NS_ENUM(NSInteger, NXFileRendererType) {
    NXFileRendererTypeNormal = 1,
    NXFileRendererTypeMedia,
    NXFileRendererTypeHoops,
    NXFileRendererTypeSAP,
    NXFileRendererTypeRemote,
};

typedef void(^getSnapshotCompletionBlock)(id image);

@class NXFileRendererBase;

@protocol NXFileRendererDelegate <NSObject>

@optional
- (void)fileRenderer:(NXFileRendererBase *)fileRenderer didLoadFile:(NSURL *)filePath error:(NSError *)error;
@end

@interface NXFileRendererBase : NSObject

- (UIView *)renderFile:(NSURL *)filePath;
- (void)addOverlayer:(UIView *)overlay;
- (void)removeOverlayer;
- (void)snapShot:(getSnapshotCompletionBlock)block;



@property(nonatomic, weak) id<NXFileRendererDelegate> delegate;
@property(nonatomic, strong) UIView *contentView;
@property(nonatomic, assign) NXFileRendererType renderType;
@end
