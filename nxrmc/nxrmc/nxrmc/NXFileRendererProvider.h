//
//  NXFileRendererProvider.h
//  nxrmc
//
//  Created by EShi on 11/21/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXFileRendererBase.h"
@interface NXFileRendererProvider : NSObject
+ (NXFileRendererBase *)fileRendererForType:(NXFileRendererType)renderType;
@end
