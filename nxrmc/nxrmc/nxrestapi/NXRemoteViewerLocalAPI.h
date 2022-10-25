//
//  NXRemoteViewerLocalAPI.h
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 6/15/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"


@interface NXRemoteViewerLocalModel:NSObject

@property(nonatomic, strong)NSString *fileName;
@property(nonatomic, strong)NSData *fileContent;
@property(nonatomic, assign)NSInteger operations;
//https://bitbucket.org/nxtlbs-devops/rightsmanagement-wiki/wiki/RMS/RESTful%20API/Remote%20Viewer%20REST%20API#markdown-header-supported-operations
@end

@interface NXRemoteViewerLocalRequest : NXSuperRESTAPIRequest

@end

@interface NXRemoteViewerResponse : NXSuperRESTAPIResponse

@property(nonatomic, strong) NSArray<NSString *> *cookies;
@property(nonatomic, strong) NSString *viewerURL;
@property(nonatomic, assign) BOOL isOwner;
@property(nonatomic, assign) long permissions;
@property(nonatomic, strong) NSString *duid;
@property(nonatomic, strong) NSString *ownerId;

@end
