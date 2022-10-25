//
//  NXSuperRESTAPI.m
//  nxrmc
//
//  Created by EShi on 6/7/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"
#import "NX3rdRepoRESTAPI.h"
#import "NXRESTAPITransferCenter.h"
#import "NXRESTAPIScheduleProtocol.h"
#import "NXLoginUser.h"
#import "NXXMLDocument.h"
#import "NXCommonUtils.h"
#import "NSData+NXExt.h"
#import "NXLProfile.h"
#define NXRESTFLAG       @"NXRESTFlag"
#define NXRESTTYPE       @"NXRESTTyp"
#define NXRESTSERVICE    @"NXRESTServcie"
#define NXRESTBODYDAT    @"NXRESTBodyData"
#define NXRESTREQUEST    @"NXRESTRequest"


#pragma mark ----------NXSuperRESTAPIRequest------------
@interface NXSuperRESTAPIRequest()

@property(nonatomic, strong, readwrite) NSString *reqFlag;
@property(nonatomic, strong, readwrite) NSString *reqType;
@property(nonatomic, strong, readwrite) NSString *reqService;
@property(nonatomic, strong, readwrite) NSData *reqBodyData;
@end
@implementation NXSuperRESTAPIRequest

-(instancetype) init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void) requestWithObject:(id) object Completion:(RequestCompletion) completion
{
    [self requestWithObject:object withUploadProgress:nil downloadProgress:nil Completion:completion];
}

- (void)requestWithObject:(id)object withUploadProgress:(NSProgress *)uploadProgress downloadProgress:(NSProgress *)downloadProgress Completion:(RequestCompletion)completion
{
    // 1. Regist the request in NXRESTAPITransferCenter
    BOOL regSuccess = [[NXRESTAPITransferCenter sharedInstance] registRESTRequest:(id<NXRESTAPIScheduleProtocol>)self];
    
    if (!regSuccess) {
        return;
    }
    
    // store completion block
    self.completion = completion;
    
    // 2. Get the request object
    NSMutableURLRequest *request = [(id<NXRESTAPIScheduleProtocol>)self generateRequestObject:object];
    
    if (request && request.URL) {
        // 3. call NXRESTAPITransferCenter to do request
        if ([request isKindOfClass:[NSMutableURLRequest class]]) {
             [(NSMutableURLRequest *)request setValue:self.reqFlag forHTTPHeaderField:RESTAPIFLAGHEAD]; // set the rest-flag head to identify each rest requeset
            if ([self isKindOfClass:[NX3rdRepoRESTAPIRequest class]]) {
                [request setValue:@"SkyDRM" forHTTPHeaderField:@"User-Agent"];
            }else { // Only RMS REST API Need set RMS headers
                [request setValue:[NXLoginUser sharedInstance].profile.userId forHTTPHeaderField:@"userId"];
                [request setValue:[NXLoginUser sharedInstance].profile.ticket forHTTPHeaderField:@"ticket"];
                [request setValue:[NXCommonUtils getPlatformId].stringValue forHTTPHeaderField:@"platformId"];
                
                [request setValue:[NXCommonUtils currentTenant] forHTTPHeaderField:@"tenant"];
                [request setValue:[NXCommonUtils deviceID] forHTTPHeaderField:@"clientId"];
                request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
                
                NSString *encodedString = [[UIDevice currentDevice].name stringByAddingPercentEncodingWithAllowedCharacters:[[NSCharacterSet characterSetWithCharactersInString:@"?!@#$^&%*+,:;='\"`<>()[]{}/\\| "] invertedSet]];
                
                [(NSMutableURLRequest *)request setValue:encodedString  forHTTPHeaderField:@"deviceId"];
            }
        }

        [[NXRESTAPITransferCenter sharedInstance] sendRESTRequest:request withUploadProgress:uploadProgress downloadProgress:downloadProgress];
    }else
    {
        [[NXRESTAPITransferCenter sharedInstance] unregistRESTRequest:(id<NXRESTAPIScheduleProtocol>)self];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Bad request" forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:NX_ERROR_REST_DOMAIN code:NXRMC_ERROR_BAD_REQUEST userInfo:userInfo];
        self.completion(nil, error);
    }
}


- (NSString *)findDocumentpath{
    //寻找documents路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *value = paths.lastObject;
    NSLog(@"value--%@",value);
    return value;
}


//-(BOOL)writeDataValue:(NSMutableURLRequest *)request{
//
//    NSDate *date = [NSDate date];
//    NSTimeZone *zone = [NSTimeZone systemTimeZone];
//    NSInteger interval = [zone secondsFromGMTForDate:date];
//    NSDate *localeDate = [date  dateByAddingTimeInterval:interval];
//
//    NSMutableData *contentData = [[NSMutableData alloc] init];
//    NSDictionary *httpHeader = request.allHTTPHeaderFields;
//    NSString *url = request.URL.absoluteString;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:httpHeader options:0 error:nil];
//    NSString *contentLine = [NSString stringWithFormat:@"\n--------------BODY:\n"];
//    NSData *contentLineData = [contentLine dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *bodyData = request.HTTPBody;
//    NSString *divideLine = [NSString stringWithFormat:@"\nDate:%@--------------------Start\nURL:%@\nHeader:",localeDate,url];
//    NSString *endLine = [NSString stringWithFormat:@"\n--------------------END\n"];
//    NSData *endLineData = [endLine dataUsingEncoding:NSUTF8StringEncoding];
//       NSData *startLineData = [divideLine dataUsingEncoding:NSUTF8StringEncoding];
//
//    [contentData appendData:startLineData];
//    [contentData appendData:jsonData];
//    [contentData appendData:contentLineData];
//    [contentData appendData:bodyData];
//    [contentData appendData:endLineData];
//
//    NSString *path = [self findDocumentpath];
//    NSString *file = [NSString stringWithFormat:@"%@/shareWithCrashFilelog.txt",path];
//    NSLog(@"path:%@",file);
//
//    NSString *tempSavePath = file;
// //   [contentData writeToFile:file atomically:YES];
//    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:tempSavePath];
//      [fileHandle seekToEndOfFile];
//      [fileHandle writeData:contentData];
//      [fileHandle closeFile];
//   // BOOL result = [contentData writeToFile:file atomically:YES];
//    return YES;
//}

- (void)cancelRequest
{
    self.isReqCancelled = YES;
    [[NXRESTAPITransferCenter sharedInstance] cancelRequest:self];
}



- (void) genRestRequest:(id) object;
{
    
}

- (NSData *) genRequestBodyData:(id) object
{
    return nil;
}


#pragma mark - NXRESTAPIScheduleProtocol
-(NSMutableURLRequest *) generateRequestObject:(id) object
{
    // should be overwrite by sub class, never called
    NSAssert(NO, @"NXSuperRESTAPIRequest::generateRequestObject should be overwrite by sub class!!");
    return nil;
}

- (Analysis)analysisReturnData
{
    // should be overwrite by sub class, never called
    NSAssert(NO, @"NXSuperRESTAPIRequest::analysisReturnData should be overwrite by sub class!!");
    return nil;
}

#pragma mark - SETTER/GETTER
-(NSString *) reqService
{
    if (_reqService == nil) {
        _reqService = [NXLoginUser sharedInstance].profile.rmserver;
    }
    return _reqService;
}

-(NSString *) reqFlag
{
    if (_reqFlag == nil) {
        _reqFlag = [self restRequestFlag];
    }
    
    return _reqFlag;
}

-(NSString *) reqType
{
    if (_reqType == nil) {
        _reqType = [self restRequestType];
    }
    
    return _reqType;
}

-(NSString *) restRequestType
{
    return RESTSUPERBASE;
}

-(NSString *) restRequestFlag
{
    return [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

#pragma - mark tool methods
-(NSURLRequest *) generatePOSTRequestWithPostData:(NSData *) postData contentType:(NSString *) contentType
{
    NSParameterAssert(postData);
    
    self.reqBodyData = postData;  // hold the post data in case store post data to disk when the REST API failed
    
//    NSString *dd = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
//    NSLog(@"%@", dd);
    
    NSString *url = [NSString stringWithFormat:@"%@/%@", [self makeRmserver:self.reqService], self.reqType];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    
    [request setHTTPBody:postData];
    if(contentType)
    {
        [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
        
    }else
    {
        [request setValue:@"text/plain, charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    }
    
    [request addValue:self.reqFlag forHTTPHeaderField:RESTAPIFLAGHEAD]; // set the rest-flag head to identify each rest requeset
    
    return request;

}

- (NSString *)makeRmserver:(NSString *)rmserver {
    return [NSString stringWithFormat:@"%@%@", rmserver, RESTAPITAIL];
}

#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.reqFlag forKey:NXRESTFLAG];
    [aCoder encodeObject:self.reqType forKey:NXRESTTYPE];
    [aCoder encodeObject:self.reqService forKey:NXRESTSERVICE];
    [aCoder encodeObject:self.reqBodyData forKey:NXRESTBODYDAT];
    [aCoder encodeObject:self.reqRequest forKey:NXRESTREQUEST];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.reqFlag = [aDecoder decodeObjectForKey:NXRESTFLAG];
        self.reqType = [aDecoder decodeObjectForKey:NXRESTTYPE];
        self.reqService = [aDecoder decodeObjectForKey:NXRESTSERVICE];
        self.reqBodyData = [aDecoder decodeObjectForKey:NXRESTBODYDAT];
        self.reqRequest = [aDecoder decodeObjectForKey:NXRESTREQUEST];
    }
    return self;
}

@end

#pragma mark ----------NXSuperRESTAPIResponse------------
@implementation NXSuperRESTAPIResponse
-(instancetype) init
{
    self = [super init];
    if (self) {
        _rmsStatuCode = -1;
        _rmsStatuMessage = @"";
    }
    return self;
}

- (NSString *) description
{
    NSString *description = [NSString stringWithFormat:@"rmsState=%ld  message=%@", (long)self.rmsStatuCode, self.rmsStatuMessage];
    return description;
}

-(void) analysisResponseStatus:(NSData *)responseData
{
    if (responseData) {
        NSError *error;
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
        if (error) {
            NSLog(@"parse data failed:%@", error.localizedDescription);
            return;
        }
        
        if ([result objectForKey:@"statusCode"]) {
            self.rmsStatuCode = [[result objectForKey:@"statusCode"] integerValue];
        }
        
        if ([result objectForKey:@"message"]) {
            self.rmsStatuMessage = [result objectForKey:@"message"];
        }
        
        if ([result objectForKey:@"serverTime"]) {
            self.serverTime = ((NSNumber *)[result objectForKey:@"serverTime"]).doubleValue / 1000;
        }
        
#define RMS_SESSION_OUTDATE 401
        if (self.rmsStatuCode == RMS_SESSION_OUTDATE) {
            dispatch_main_async_safe(^{
                [NXCommonUtils forceUserLogout];
            });     
        }

    }
}

- (void)analysisResponseData:(NSData *)responseData
{
    [self analysisResponseStatus:responseData];
    [self analysisResponseJSONDict:[responseData toJSONDict:nil]];
    
}

- (void)analysisResponseJSONDict:(NSDictionary *)jsonDict
{
    NSAssert(NO, @"Should never be called, must overwrite by sub class");
}

- (void) analysisXMLResponseStatus:(NSData *)responseData
{
    if (responseData.length != 0) {
        NXXMLDocument* xmlDoc = [NXXMLDocument documentWithData:responseData error:nil];
        NXXMLElement* root = xmlDoc.root;
        // get status code
        NXXMLElement *statusNode = [root childNamed:@"status"];
        self.rmsStatuCode = [statusNode childNamed:@"code"].value.integerValue;
        self.rmsStatuMessage = [statusNode childNamed:@"message"].value;
    }
}

#pragma mark - NSCoding
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _rmsStatuCode = [[aDecoder decodeObjectForKey:@"kRmsStatusCode"] integerValue];
        _rmsStatuMessage = [aDecoder decodeObjectForKey:@"kRmsStatusMessage"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSNumber numberWithInteger:_rmsStatuCode] forKey:@"kRmsStatusCode"];
    [aCoder encodeObject:_rmsStatuMessage forKey:@"kRmsStatusMessage"];
}

@end





