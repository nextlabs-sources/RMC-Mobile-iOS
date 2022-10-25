//
//  NXRESTAPITransferCenter.m
//  nxrmc
//
//  Created by EShi on 6/7/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXRESTAPITransferCenter.h"
#import "NXSuperRESTAPI.h"
#import "NXRestAPI.h"
#import "NXRMCDef.h"
#import "NX3rdRepoRESTAPI.h"
#import "NXCenterTokenManager.h"



static NXRESTAPITransferCenter* singleInstance = nil;


@interface NXRESTAPITransferCenter()<NXRestAPIDelegate>
@property(nonatomic, strong) NSMutableDictionary *reqCompletionDic;         // store the original request to do response analysis or re-send
@property(nonatomic, strong) NSMutableDictionary *reqRESTConnObjectDic;     // store the connection object to send/receive data from network
@property(nonatomic, strong) NSMutableDictionary *reqParameterDic;          // store the parameter for request(For example : download progresser and so on)
@property(nonatomic, strong) dispatch_queue_t transferCenterSerialQueue;
@property(nonatomic, strong) dispatch_queue_t nxRESTConObjectSerialQueue;
@property(nonatomic, strong) NSThread *workThread;

@end

@implementation NXRESTAPITransferCenter

+(instancetype) sharedInstance
{
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        singleInstance = [[super allocWithZone:nil] init];
    });
    
    return singleInstance;
}

-(instancetype) init
{
    self = [super init];
    if (self) {
        // use this serial queue do sync the operation to _reqCompletionDic
        _transferCenterSerialQueue = dispatch_queue_create("com.skydrm.rmcent.RESTAPITransferCenter.transferCenterSerialQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}


+(instancetype) allocWithZone:(struct _NSZone *)zone
{
    return nil;
}
+(NSThread *) restWorkThread
{
    static NSThread * workThread = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        workThread = [[NSThread alloc] initWithTarget:self selector:@selector(workThreadEntryPoint:) object:nil];
        [workThread start];
    });
    return workThread;
    
}
+(void) workThreadEntryPoint:(id)__unused object
{
    @autoreleasepool {
        [[NSThread currentThread] setName:@"nextlabs"];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        // put one port in runloop to keep the runloop not exit
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}

#pragma mark - SETTER/GETTER
-(NSMutableDictionary *) reqCompletionDic
{
    if (_reqCompletionDic == nil) {
        _reqCompletionDic = [[NSMutableDictionary alloc] init];
    }
    
    return _reqCompletionDic;
}

-(NSMutableDictionary *) reqRESTConnObjectDic
{
    if (_reqRESTConnObjectDic == nil) {
        _reqRESTConnObjectDic = [[NSMutableDictionary alloc] init];
    }
    return _reqRESTConnObjectDic;
}

- (NSMutableDictionary *)reqParameterDic {
    @synchronized (self) {
        if (_reqParameterDic == nil) {
            _reqParameterDic = [[NSMutableDictionary alloc] init];
        }
        return _reqParameterDic;
    }
}

#pragma mark - REST Request Manager
-(BOOL) registRESTRequest:(id<NXRESTAPIScheduleProtocol>) request
{
    NSString *mapKey = ((NXSuperRESTAPIRequest *)request).reqFlag;
    __block BOOL ret = YES;
    WeakObj(self);
    dispatch_sync(self.transferCenterSerialQueue, ^{
        StrongObj(self);
        if ([[self.reqCompletionDic allKeys] containsObject:mapKey]) {
            ret = NO;
        }
        if (ret) {
            [self.reqCompletionDic setObject:request forKey:mapKey];

        }
    });
    
    return ret;  // here to return ret make sure return to the same thread???????
}

-(void) unregistRESTRequest:(id<NXRESTAPIScheduleProtocol>) request
{
    NSString *mapKey = ((NXSuperRESTAPIRequest *)request).reqFlag;
    WeakObj(self);
    dispatch_sync(self.transferCenterSerialQueue, ^{
        StrongObj(self);
        [self.reqCompletionDic removeObjectForKey:mapKey];
        [self.reqRESTConnObjectDic removeObjectForKey:mapKey];
    });
}

- (void)cancelRequest:(id<NXRESTAPIScheduleProtocol>)request
{
    NSString *mapKey = ((NXSuperRESTAPIRequest *)request).reqFlag;
    WeakObj(self);
    dispatch_sync(self.transferCenterSerialQueue, ^{
        StrongObj(self);
        NXRestAPI *restAPI = [self.reqRESTConnObjectDic objectForKey:mapKey];
        if (restAPI) {
            [restAPI cancel];
        }
        
        // the stored info will be removed by NSConnection call back
        
    });
}

#define REST_REQ_KEY @"REST_REQ_KEY"
#define UPLOAD_PROGRESS_KEY @"UPLOAD_PROGRESS_KEY"
#define DOWNLOAD_PROGRESS_KEY @"DOWNLOAD_PROGRESS_KEY"
- (void)sendRESTRequest:(NSURLRequest *)restRequest withUploadProgress:(NSProgress *)uploadprogress downloadProgress:(NSProgress *)downloadProgress
{
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    [paramDict setObject:restRequest forKey:REST_REQ_KEY];
    if (uploadprogress) {
        [paramDict setObject:uploadprogress forKey:UPLOAD_PROGRESS_KEY];
    }
    if(downloadProgress){
        [paramDict setObject:downloadProgress forKey:DOWNLOAD_PROGRESS_KEY];
    }
    [self performSelector:@selector(sendRequestOnWorkThread:) onThread:[[self class] restWorkThread] withObject:paramDict waitUntilDone:NO];
}

#pragma mark - Private Methods
-(void) sendRequestOnWorkThread:(NSDictionary *) paramDict
{
    NSMutableURLRequest *restRequest = paramDict[REST_REQ_KEY];
    NSProgress *uploadProgress = paramDict[UPLOAD_PROGRESS_KEY];
    NSProgress *downloadProgress = paramDict[DOWNLOAD_PROGRESS_KEY];
    
    
    // NXRestAPI do not support multi request, so need create NXRestAPI for every request
    NXRestAPI *restAPI = [[NXRestAPI alloc] init];
    restAPI.delegate = self;
    NSString *reqFlag = [restRequest valueForHTTPHeaderField:RESTAPIFLAGHEAD];
    
    // for center token  first check have access token ========
    NXSuperRESTAPIRequest *curReq = self.reqCompletionDic[reqFlag];
    // Need First check is cancelled
    if (curReq.isReqCancelled) {
        // cancled, just remove the store info
        // do not forget remove the rest request
        dispatch_async(self.transferCenterSerialQueue, ^{
            [self.reqCompletionDic removeObjectForKey:reqFlag];
            [self.reqRESTConnObjectDic removeObjectForKey:reqFlag];
            if([((NXSuperRESTAPIRequest *)curReq) isKindOfClass:[NX3rdRepoRESTAPIRequest class]]) {
                [self.reqParameterDic removeObjectForKey:reqFlag];
            }
        });
        return;
    }
    
    
    if ([curReq isKindOfClass:[NX3rdRepoRESTAPIRequest class]]) {
        NSString *repoId = ((NX3rdRepoRESTAPIRequest *)curReq).repo.service_id;
        NSString *accessTokenKeyword = ((NX3rdRepoRESTAPIRequest *)curReq).accessTokenKeyword;
        NSString *token = [[NXCenterTokenManager sharedInstance] accessTokenForRepository:repoId];
        
        // store the parameter , incase re-send when token is out of date or token == nil
        [self.reqParameterDic setObject:paramDict forKey:reqFlag];
        
        if (token) {
            
            [restRequest setValue:token forHTTPHeaderField:accessTokenKeyword];
            
        }else {
            WeakObj(self);
            // no token, 1. ask to refresh the token 2. cache current request and parameter
            [[NXCenterTokenManager sharedInstance] refreshAccessTokenForRepository:repoId withCompletion:^(NSString *repoId, NSString *accessToken, NSError *error) {
                StrongObj(self);
                if (self) {
                    if (error == nil) {
                        [self performSelector:@selector(sendRequestOnWorkThread:) onThread:[[self class] restWorkThread] withObject:paramDict waitUntilDone:NO];
                    }else{  // get access token failed, return error
                        __block id<NXRESTAPIScheduleProtocol> restReq = nil;
                        dispatch_sync(self.transferCenterSerialQueue, ^{
                            restReq = self.reqCompletionDic[reqFlag];
                        });
                        
                        if (restReq) {
                            RequestCompletion comp = ((NXSuperRESTAPIRequest *) restReq).completion;
                            Analysis analysis = [restReq analysisReturnData];
                            id response = analysis(nil, error);
                            // use dispathc_async to call comp, this can make the work thread do not need to
                            // wait the callbacker finish comp operation.
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                comp(response, error);
                            });
                            
                            // do not forget remove the rest request
                            dispatch_async(self.transferCenterSerialQueue, ^{
                                [self.reqCompletionDic removeObjectForKey:reqFlag];
                                [self.reqRESTConnObjectDic removeObjectForKey:reqFlag];
                                [self.reqParameterDic removeObjectForKey:reqFlag];
                            });
                            
                        }
                    }
                }
            }];
            // Do not have access token just return wait and wait for the access token refresh to continue
            return;
        }
    } // end center token ===============
    
    WeakObj(self);
    dispatch_sync(self.transferCenterSerialQueue, ^{
        StrongObj(self);
        [self.reqRESTConnObjectDic setObject:restAPI forKey:reqFlag];
    });
    [restAPI sendRESTRequest:restRequest withUploadProgress:uploadProgress downloadProgress:downloadProgress];
}

#pragma mark - NXRestAPIDelegate
- (void) restAPIResponse:(NSURL*) url result: (NSString*)result data:(NSData *) data error: (NSError*)err
{
    // do not care this callback
}

-(void) restAPIResponse:(NSURL *)url requestFlag:(NSString *)reqFlag result:(NSString *)result error:(NSError *)err
{
    if (reqFlag) {
        __block id<NXRESTAPIScheduleProtocol> restReq = nil;
        dispatch_sync(self.transferCenterSerialQueue, ^{
           restReq = self.reqCompletionDic[reqFlag];
        });
        
        if (restReq) {
            RequestCompletion comp = ((NXSuperRESTAPIRequest *) restReq).completion;
            Analysis analysis = [restReq analysisReturnData];
            
            id response = analysis(result, err);
           
            // center token : token is out of date===========================
            if ([((NXSuperRESTAPIRequest *) restReq) isKindOfClass:[NX3rdRepoRESTAPIRequest class]] && ((NX3rdRepoRESTAPIResponse *)response).isAccessTokenExpireError) {
                WeakObj(self);
                // access token out of date, we try to access token and try again
                [[NXCenterTokenManager sharedInstance] refreshAccessTokenForRepository:(((NX3rdRepoRESTAPIRequest *)restReq).repo.service_id) withCompletion:^(NSString *repoId, NSString *accessToken, NSError *error) {
                    StrongObj(self);
                    if (self) {
                        if (error == nil) {
                            NSDictionary *paramDict = self.reqParameterDic[reqFlag];
                            [self performSelector:@selector(sendRequestOnWorkThread:) onThread:[[self class] restWorkThread] withObject:paramDict waitUntilDone:NO];
                        }else { // return error
                            // use dispathc_async to call comp, this can make the work thread do not need to
                            // wait the callbacker finish comp operation.
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                comp(response, err);
                            });
                            
                            // do not forget remove the rest request
                            dispatch_async(self.transferCenterSerialQueue, ^{
                                [self.reqCompletionDic removeObjectForKey:reqFlag];
                                [self.reqRESTConnObjectDic removeObjectForKey:reqFlag];
                                [self.reqParameterDic removeObjectForKey:reqFlag];
                            });
                        }
                    }
                }];
            }else { // end center token : token is out of date===========================
                // use dispathc_async to call comp, this can make the work thread do not need to
                // wait the callbacker finish comp operation.
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    comp(response, err);
                });
                
                // do not forget remove the rest request
                dispatch_async(self.transferCenterSerialQueue, ^{
                    [self.reqCompletionDic removeObjectForKey:reqFlag];
                    [self.reqRESTConnObjectDic removeObjectForKey:reqFlag];
                    if([((NXSuperRESTAPIRequest *)restReq) isKindOfClass:[NX3rdRepoRESTAPIRequest class]]) {
                         [self.reqParameterDic removeObjectForKey:reqFlag];
                    }
                });
            }
        }
    }
}
@end
