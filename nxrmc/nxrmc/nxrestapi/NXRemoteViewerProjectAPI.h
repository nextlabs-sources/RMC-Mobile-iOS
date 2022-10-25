//
//  NXRemoteViewerProjectAPI.h
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 7/6/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"
#import "NXRemoteViewerLocalAPI.h"

@class NXProjectFile;

@interface NXRemoteViewerProjectModel : NSObject

@property(nonatomic, strong)NXProjectFile *file;
@property(nonatomic, assign)NSInteger operations;

- (instancetype)initWithProjectFile:(NXProjectFile *)file rights:(NSInteger)operations;

@end

@interface NXRemoteViewerProjectRequest : NXSuperRESTAPIRequest

@end
