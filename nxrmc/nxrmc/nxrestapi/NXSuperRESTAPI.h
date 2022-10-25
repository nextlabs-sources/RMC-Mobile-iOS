//
//  NXSuperRESTAPI.h
//  nxrmc
//
//  Created by EShi on 6/7/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXRESTAPIScheduleProtocol.h"
#import "NXRMCStruct.h"
#import "NSData+NXExt.h"
#import "NSDictionary+NXExt.h"
#import "NSString+NXExt.h"
#import "NXCommonUtils.h"
#import "NSString+Utility.h"

@class NXSuperRESTAPIResponse;

typedef void(^RequestCompletion)(NXSuperRESTAPIResponse* response, NSError *error);

@interface NXSuperRESTAPIRequest : NSObject<NSCoding, NXRESTAPIScheduleProtocol>
@property(nonatomic, strong) NSMutableURLRequest *reqRequest;
@property(nonatomic, strong, readonly) NSString *reqFlag;
@property(nonatomic, strong, readonly) NSString *reqType;
@property(nonatomic, strong, readonly) NSString *reqService;
@property(nonatomic, strong, readonly) NSData *reqBodyData;
@property(nonatomic, copy) RequestCompletion completion;
@property(nonatomic, assign) BOOL isReqCancelled;

- (void)requestWithObject:(id)object Completion:(RequestCompletion) completion;
- (void)requestWithObject:(id)object withUploadProgress:(NSProgress *)uploadProgress downloadProgress:(NSProgress *)downloadProgress Completion:(RequestCompletion)completion;
- (void)cancelRequest;
-(NSString *) restRequestType;
-(NSString *) restRequestFlag;

// Just hold rest request object and save it. Used in the case do not send REST request, but only serialize it to disk. So need subclass generate restRequest and pass it to
// NXSuperRESTAPIRequest to hold it
- (void) genRestRequest:(id) object;
- (NSData *) genRequestBodyData:(id) object; // need overwrite by subchild

// Generate URL Request Tools function
-(NSURLRequest *) generatePOSTRequestWithPostData:(NSData *) postData contentType:(NSString *) contentType;

// NXRESTAPIScheduleProtocol
-(NSMutableURLRequest *) generateRequestObject:(id) object;
- (Analysis)analysisReturnData;
@end

@interface NXSuperRESTAPIResponse: NSObject<NSCoding>

@property(nonatomic) NSInteger rmsStatuCode;
@property(nonatomic, strong) NSString *rmsStatuMessage;
@property(nonatomic, assign) NSTimeInterval serverTime;

- (void)analysisResponseStatus:(NSData *) responseData;
- (void)analysisXMLResponseStatus:(NSData *)responseData;
- (void)analysisResponseData:(NSData *)responseData;
- (void)analysisResponseJSONDict:(NSDictionary *)jsonDict;

@end
