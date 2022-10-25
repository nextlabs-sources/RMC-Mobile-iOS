 //
//  NXSharepointOnlineRemoteQuery.m
//  NXsharepointonline
//
//  Created by nextlabs on 5/28/15.
//  Copyright (c) 2015 nextlabs. All rights reserved.
//

#import "NXSharepointOnlineRemoteQuery.h"
#import "NXXMLDocument.h"
#import "NXRMCDef.h"
#import "NXCommonUtils.h"
#import "NXCenterTokenManager.h"
#import "NSString+Utility.h"

#define NOSUCHFILEHTTPCODE 500
#define SuccessHttpCode 200
#define FailureHttpCode 400

@interface NXSharepointOnlineRemoteQuery()<NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>
@property (nonatomic,strong) NSArray* cookies;

//for download progress.
@property long long filesize;
@property long long downloadsize;
@property NSString* downloadfiledestfullpath;
@property NSMutableData *receivedata;

@property(nonatomic, strong) NSURLSessionDataTask* dataTask;
@property(nonatomic, strong) NSURLSessionDownloadTask* downloadTask;
@property(nonatomic, strong) NSData *downloadData;
@end

@implementation NXSharepointOnlineRemoteQuery

# pragma mark public method

- (instancetype) initWithURL:(NSString*)url cookies:(NSArray *)cookies {
    if (self = [super init]) {
        self.queryUrl = url;
        _requestMethod = @"GET";
        _cookies = cookies;
    }
    return self;
}

- (instancetype) initWithURL:(NSString*)url repoId:(NSString *)repoId
{
    if (self = [super init]) {
        self.queryUrl = url;
        _requestMethod = @"GET";
        _repoId = repoId;
    }
    return self;
}
#pragma mark Getter/Setter functions


# pragma  mark  private method

- (NSMutableURLRequest*) initializeRequest {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[self.queryUrl toHTTPURLString]]];
    
    [request setHTTPMethod:_requestMethod];
    NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:_cookies];
    [request setAllHTTPHeaderFields:headers];
    
    return  request;
}

#pragma mark Private Interface
-(void) startNewDataTask:(NSMutableURLRequest*) request
{
    NSString *token = [[NXCenterTokenManager sharedInstance] accessTokenForRepository:self.repoId];
    if (token) {
        [request setValue:token forHTTPHeaderField:@"Authorization"];
        self.dataTask = [self.spSession dataTaskWithRequest:request];
        [self.dataTask resume];
    }
    else
    {
        [[NXCenterTokenManager sharedInstance] refreshAccessTokenForRepository:self.repoId withCompletion:^(NSString *repoId, NSString *accessToken, NSError *error) {
            if (!error) {
                 [request setValue:accessToken forHTTPHeaderField:@"Authorization"];
                self.dataTask = [self.spSession dataTaskWithRequest:request];
                [self.dataTask resume];
            }
        }];
    }
}

-(void) startNewDownLoadTask:(NSMutableURLRequest*) request
{
    NSString *token = [[NXCenterTokenManager sharedInstance] accessTokenForRepository:self.repoId];
    if (token) {
        [request setValue:token forHTTPHeaderField:@"Authorization"];
        self.downloadTask = [self.spSession downloadTaskWithRequest:request];
        [self.downloadTask resume];
    }
    else
    {
        [[NXCenterTokenManager sharedInstance] refreshAccessTokenForRepository:self.repoId withCompletion:^(NSString *repoId, NSString *accessToken, NSError *error) {
            if (!error) {
                NSString *token = [NSString stringWithFormat:@"Bearer %@",accessToken];
                [request setValue:token forHTTPHeaderField:@"Authorization"];
                self.downloadTask = [self.spSession downloadTaskWithRequest:request];
                [self.downloadTask resume];
            }
        }];
    }
}

- (void) executeQUery:(NSMutableURLRequest*)request {
    [self startNewDataTask:request];
}

# pragma mark

- (void) executeQueryWithRequestId:(NSInteger)requestid {
    self.queryID = requestid;
    NSMutableURLRequest *request = [self initializeRequest];
    
    if (self.queryID == kSPQueryDownloadFile) {
        NSDictionary *fileinfo = (NSDictionary*)self.additionData;
        _filesize =  [[fileinfo objectForKey:@"fileSize"] longLongValue];
        _downloadfiledestfullpath = [fileinfo objectForKey:@"destPath"];
        [self startNewDownLoadTask:request];
        
    } else {
        [self executeQUery:request];
    }
}

- (void) executeQueryWithRequestId:(NSInteger)requestid withAdditionData:(id) additionData {
    self.additionData = additionData;
    [self executeQueryWithRequestId: requestid];
}

- (void) executeQueryWithRequestId:(NSInteger)requestid Headers:(NSDictionary *)headers RequestMethod:(NSString *)rqMethod BodyData:(NSData *)bodyData withAdditionData:(id)additionData {
    self.additionData = additionData;
    self.queryID = requestid;
    
    NSMutableURLRequest *request = (NSMutableURLRequest*)[self initializeRequest];
    
    // 1. set method
    [request setHTTPMethod:rqMethod];
    
    // 2. set request headers
    for (NSString* key in headers) {
        [request setValue:[headers objectForKey:key] forHTTPHeaderField:key];
    }
    
    // 3. set request body
    if (bodyData) {
        [request setHTTPBody:bodyData];
        NSString* contentLength = [NSString stringWithFormat:@"%lu", (unsigned long)bodyData.length];
        [request setValue:contentLength forHTTPHeaderField:@"content-length"];
    }else {
        [request setValue:@"0" forHTTPHeaderField:@"content-length"];
    }
    
    [self executeQUery:request];
}

-(void) cancelQueryWithRequestId:(NSInteger) requestid AdditionData:(id) additionData {
    self.queryID = requestid;
    self.additionData = additionData;
    
    
    if (requestid == kSPQueryDownloadFile) {
       // if (self.downloadTask.state == NSURLSessionTaskStateRunning || self.downloadTask.state == NSURLSessionTaskStateSuspended) {
            [self.downloadTask cancel];
            self.downloadTask = nil;
        [self.spSession invalidateAndCancel];
        self.spSession = nil;
      //  }
    }else
    {
        //if (self.dataTask.state == NSURLSessionTaskStateRunning || self.dataTask.state == NSURLSessionTaskStateSuspended) {
            [self.dataTask cancel];
        
            self.dataTask = nil;
        
        [self.spSession invalidateAndCancel];
         self.spSession = nil;
       // }
        NSError *error = [NSError errorWithDomain:NX_ERROR_SERVICEDOMAIN code:NXRMC_ERROR_CODE_CANCEL userInfo:nil];
        if ([self.delegate respondsToSelector:@selector(remoteQuery:didFailedWithError:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate remoteQuery:self didFailedWithError:error];
            });
        }
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpres = (NSHTTPURLResponse*)response;
        if ([httpres statusCode] == 200) {
            _receivedata = [[NSMutableData alloc] init];
            [_receivedata setLength:0];
        }
    }
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    [_receivedata appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{

    NSURLResponse * response = task.response;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) { // check html response error code
        NSHTTPURLResponse *httpres = (NSHTTPURLResponse*)response;
        
       if ([httpres statusCode] == NOSUCHFILEHTTPCODE) {
            NSError *error = [NXCommonUtils getNXErrorFromErrorCode:NXRMC_ERROR_CODE_NOSUCHFILE error:nil];
           if ([self.delegate respondsToSelector:@selector(remoteQuery:didFailedWithError:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate remoteQuery:self didFailedWithError:error];
                    [self.dataTask cancel];
                    self.dataTask = nil;
                });
            }
           return;
           
        }else if(httpres.statusCode < SuccessHttpCode || httpres.statusCode >= FailureHttpCode) {
            // http error code
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError* newError = [NSError errorWithDomain:NXHTTPSTATUSERROR code:httpres.statusCode userInfo:nil];
                [self.delegate remoteQuery:self didFailedWithError:newError];
            });
            return;
        }
    }
    
    if(error)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate remoteQuery:self didFailedWithError:error];

        });
        
    }else
    {
        if ([self.delegate respondsToSelector:@selector(remoteQuery:didCompleteQuery:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.queryID == kSPQueryDownloadFile) {
                    [self.delegate remoteQuery:self didCompleteQuery:_downloadData];
                }else if (self.queryID == kSPQueryCreateFolder) {
                    NSHTTPURLResponse *addResponse =(NSHTTPURLResponse*)task.response;
                    NSDictionary *dic =addResponse.allHeaderFields;
                    NSString *location=dic[@"Location"];
                    NSData *addData=[location dataUsingEncoding:NSUTF8StringEncoding];
                    [self.delegate remoteQuery:self didCompleteQuery:addData];
                }else
                {
                    [self.delegate remoteQuery:self didCompleteQuery:_receivedata];
                }
            });
        }
    }
}

#pragma mark downloadTask delegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    _downloadData = [NSData dataWithContentsOfFile:location.path];

}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
   
    CGFloat progress = (CGFloat)totalBytesWritten/_filesize;
    if ([self.delegate respondsToSelector:@selector(remoteQuery:downloadProcess:forFile:)]) {
        dispatch_async(dispatch_get_main_queue(),^{
            [self.delegate remoteQuery:self downloadProcess:progress forFile:_downloadfiledestfullpath];
        });
    }
}
@end
