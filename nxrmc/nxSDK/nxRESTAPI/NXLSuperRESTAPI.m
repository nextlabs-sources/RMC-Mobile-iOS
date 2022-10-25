//
//  NXLSuperRESTAPI.m
//  nxrmc
//
//  Created by EShi on 6/7/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXLSuperRESTAPI.h"
#import "NXLRESTAPITransferCenter.h"
#import "NXLRESTAPIScheduleProtocol.h"
#import "NXLXMLDocument.h"
#import "NXLSDKDef.h"
#import "NXLCommonUtils.h"


#define NXLRESTFLAG       @"NXLRESTFlag"
#define NXLRESTTYPE       @"NXLRESTTyp"
#define NXLRESTSERVICE    @"NXLRESTServcie"
#define NXLRESTBODYDAT    @"NXLRESTBodyData"
#define NXLRESTREQUEST    @"NXLRESTRequest"


#pragma mark ----------NXLSuperRESTAPIRequest------------
@interface NXLSuperRESTAPIRequest()

@property(nonatomic, strong, readwrite) NSString *reqFlag;
@property(nonatomic, strong, readwrite) NSString *reqType;
@property(nonatomic, strong, readwrite) NSString *reqService;
@property(nonatomic, strong, readwrite) NSData *reqBodyData;
@end
@implementation NXLSuperRESTAPIRequest

-(instancetype) init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void) requestWithObject:(id) object Completion:(RequestCompletion) completion
{

    
    // 1. Regist the request in NXRESTAPITransferCenter
    BOOL regSuccess = [[NXLRESTAPITransferCenter sharedInstance] registRESTRequest:(id<NXLRESTAPIScheduleProtocol>)self];
    
    if (!regSuccess) {
        return;
    }
    
    // store completion block
    self.completion = completion;
    
    // 2. Get the request object
    NSMutableURLRequest *request = [(id<NXLRESTAPIScheduleProtocol>)self generateRequestObject:object];
    
    if (request && request.URL) {
        // 3. call NXRESTAPITransferCenter to do request
        if ([request isKindOfClass:[NSMutableURLRequest class]]) {
             [(NSMutableURLRequest *)request setValue:self.reqFlag forHTTPHeaderField:RESTAPIFLAGHEAD]; // set the rest-flag head to identify each rest requeset
             [(NSMutableURLRequest *)request setValue:[NXLCommonUtils deviceID] forHTTPHeaderField:RESTCLIENT_ID_HEAD];
        }
        [[NXLRESTAPITransferCenter sharedInstance] sendRESTRequest:request];
    }else
    {
        [[NXLRESTAPITransferCenter sharedInstance] registRESTRequest:(id<NXLRESTAPIScheduleProtocol>)self];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Bad request" forKey:NSLocalizedDescriptionKey];
        
        NSError *error = [NSError errorWithDomain:NXLSDKErrorRestDomain code:NXLSDKErrorBadRequest userInfo:userInfo];
        self.completion(nil, error);
    }
}



- (void) genRestRequest:(id) object;
{
    
}

- (NSData *) genRequestBodyData:(id) object
{
    return nil;
}


#pragma mark - NXLRESTAPIScheduleProtocol
-(NSMutableURLRequest *) generateRequestObject:(id) object
{
    NSAssert(NO, @"NXLSuperRESTAPIRequest::generateRequestObject should be overwirte by subclass!!");
    return nil;
}

- (Analysis)analysisReturnData
{
    NSAssert(NO, @"NXLSuperRESTAPIRequest::analysisReturnData should be overwirte by subclass!!");
    return nil;
}

#pragma mark - SETTER/GETTER
-(NSString *) reqService
{
    if (_reqService == nil) {
        _reqService = [NXLTenant currentTenant].rmsServerAddress;
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
    [aCoder encodeObject:self.reqFlag forKey:NXLRESTFLAG];
    [aCoder encodeObject:self.reqType forKey:NXLRESTTYPE];
    [aCoder encodeObject:self.reqService forKey:NXLRESTSERVICE];
    [aCoder encodeObject:self.reqBodyData forKey:NXLRESTBODYDAT];
    [aCoder encodeObject:self.reqRequest forKey:NXLRESTREQUEST];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.reqFlag = [aDecoder decodeObjectForKey:NXLRESTFLAG];
        self.reqType = [aDecoder decodeObjectForKey:NXLRESTTYPE];
        self.reqService = [aDecoder decodeObjectForKey:NXLRESTSERVICE];
        self.reqBodyData = [aDecoder decodeObjectForKey:NXLRESTBODYDAT];
        self.reqRequest = [aDecoder decodeObjectForKey:NXLRESTREQUEST];
    }
    return self;
}

@end

#pragma mark ----------NXSuperRESTAPIResponse------------
@implementation NXLSuperRESTAPIResponse
-(instancetype) init
{
    self = [super init];
    if (self) {
        _rmsStatuCode = -1;
        _rmsStatuMessage = @"";
    }
    return self;
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

    }
}

- (void) analysisXMLResponseStatus:(NSData *)responseData
{
    if (responseData.length != 0) {
        NXLXMLDocument* xmlDoc = [NXLXMLDocument documentWithData:responseData error:nil];
        NXLXMLElement* root = xmlDoc.root;
        // get status code
        NXLXMLElement *statusNode = [root childNamed:@"status"];
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





