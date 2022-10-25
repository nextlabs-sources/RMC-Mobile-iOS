//
//  NXNormalRenderer.h
//  nxrmc
//
//  Created by nextlabs on 10/26/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXFileRendererBase.h"

@interface NXNormalRenderer : NXFileRendererBase
@property(nonatomic, strong, readonly) NSURL *filePath;
@end
