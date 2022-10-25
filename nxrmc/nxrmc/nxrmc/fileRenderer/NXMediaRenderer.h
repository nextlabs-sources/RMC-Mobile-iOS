//
//  NXMediaRenderer.h
//  nxrmc
//
//  Created by nextlabs on 10/26/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXFileRendererBase.h"
#import "VideoViewController.h"

@interface NXMediaRenderer : NXFileRendererBase

@property(nonatomic, readonly) VideoViewController *playerVC;

@end
