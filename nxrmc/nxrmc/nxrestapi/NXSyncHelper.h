//
//  NXSyncHelper.h
//  nxrmc
//
//  Created by EShi on 7/8/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXSuperRESTAPI.h"

typedef void(^UploadFailedRESTRequestComplection)(id object, NSError *error);

@interface NXSyncHelper : NSObject
@property(nonatomic, readonly, strong) dispatch_queue_t uploadPerviousFailedRESTQueue;

+(instancetype) sharedInstance;
- (void)cacheRESTAPI:(NXSuperRESTAPIRequest *)restAPI cacheURL:(NSURL *) cacheURL;
- (void)cacheRESTAPI:(NXSuperRESTAPIRequest *)restAPI directlyURL:(NSURL *)cacheURL;
- (void)removeCachedRESTAPI:(NXSuperRESTAPIRequest *)restAPI cacheURL:(NSURL *)cacheURL;
- (void)removeCachedRESTAPI:(NXSuperRESTAPIRequest *)restAPI directlyCacheURL:(NSURL *)cacheURL;
- (void)syncCacheRESTAPI:(NXSuperRESTAPIRequest *)restAPI cacheURL:(NSURL *) cacheURL;
-(void) uploadPreviousFailedRESTRequestWithCachedURL:(NSURL *) cachedURL mustAllSuccess:(BOOL) mustAllSuccess Complection:(UploadFailedRESTRequestComplection) complectionBlock;
@end
