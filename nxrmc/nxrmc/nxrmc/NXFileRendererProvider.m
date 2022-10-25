//
//  NXFileRendererProvider.m
//  nxrmc
//
//  Created by EShi on 11/21/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXFileRendererProvider.h"
#import "NXSAPRenderer.h"
#import "NXNormalRenderer.h"
#import "NXHoopsRenderer.h"
#import "NXMediaRenderer.h"
#import "NXRemoteViewerRenderer.h"

@implementation NXFileRendererProvider
+ (NXFileRendererBase *)fileRendererForType:(NXFileRendererType)renderType
{
    NXFileRendererBase *fileRenderer = nil;
    switch (renderType) {
        case NXFileRendererTypeNormal:
        {
            fileRenderer = [[NXNormalRenderer alloc] init];
        }
            break;
        case NXFileRendererTypeMedia:
        {
            fileRenderer = [[NXMediaRenderer alloc] init];
        }
            break;
        case NXFileRendererTypeHoops:
        {
            fileRenderer = [[NXHoopsRenderer alloc] init];
        }
            break;
        case NXFileRendererTypeSAP:
        {
            fileRenderer = [[NXSAPRenderer alloc] init];
        }
            break;
        case NXFileRendererTypeRemote:
        {
            fileRenderer = [[NXRemoteViewerRenderer alloc] init];
        }
            break;
    }
    fileRenderer.renderType = renderType;
    return fileRenderer;
}

@end
