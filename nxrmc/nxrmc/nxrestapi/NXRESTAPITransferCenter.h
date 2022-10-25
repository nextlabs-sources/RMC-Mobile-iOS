//
//  NXRESTAPITransferCenter.h
//  nxrmc
//
//  Created by EShi on 6/7/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXRESTAPIScheduleProtocol.h"

@interface NXRESTAPITransferCenter : NSObject
+(instancetype) sharedInstance;

- (BOOL)registRESTRequest:(id<NXRESTAPIScheduleProtocol>) request;
- (void)unregistRESTRequest:(id<NXRESTAPIScheduleProtocol>) request;
- (void)cancelRequest:(id<NXRESTAPIScheduleProtocol>)request;
- (void)sendRESTRequest:(NSURLRequest *)restRequest withUploadProgress:(NSProgress *)uploadprogress downloadProgress:(NSProgress *)downloadProgress;
@end
