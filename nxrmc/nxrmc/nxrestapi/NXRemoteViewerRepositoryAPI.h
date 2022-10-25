//
//  NXRemoteViewerRepositoryAPI.h
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 7/6/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"
#import "NXRemoteViewerLocalAPI.h"

@class NXFileBase;

@interface NXRemoteViewerRepositoryModel : NSObject

@property(nonatomic, strong) NXFileBase *file;
@property(nonatomic, assign) NSInteger operations;

- (instancetype)initWithRepoFile:(NXFileBase *)file rights:(NSInteger)operations;

@end

@interface NXRemoteViewerRepositoryResquest : NXSuperRESTAPIRequest

@end
