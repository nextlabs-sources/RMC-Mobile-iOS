//
//  NXSharedWithMeDownloadFileAPI.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 12/06/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXSharedWithMeDownloadFileAPI.h"

#import "NXLoginUser.h"
#import "NXCommonUtils.h"


@interface NXSharedWithMeDownloadFileAPIRequest ()

@property (nonatomic,strong) NSString *fileName;

@end

@implementation NXSharedWithMeDownloadFileAPIRequest
- (instancetype)initWithDownloadSize:(NSUInteger)downloadSize isForView:(BOOL)forView
{
    self = [super init];
    if (self) {
        _forViewer = forView;
        _downloadSize = downloadSize;
    }
    return self;
}

/**
 Request Object Format Is Just Like Follows:
 
 {
 "parameters": {
 "transactionCode":"07A8D85154920D18437C9D0DC488A7A0E300D917B8EA21787F4443C73ACF3225",
 "transactionId":"9e239ccb-65f1-4786-bf45-5084ae24a14e"
 }
 } */
-(NSURLRequest *)generateRequestObject:(id)object
{
    if (self.reqRequest==nil) {
        if ([object isKindOfClass:[NXSharedWithMeFile class]]) {
            NXSharedWithMeFile *sharedWithMeFile = (NXSharedWithMeFile *)object;
            self.sharedWithMefile = sharedWithMeFile;
        }else if([object isKindOfClass:[NXOfflineFile class]]){
            NXSharedWithMeFile *sharedWithMeFile = [[NXOfflineFileManager sharedInstance] getSharedWithMeFilePartner:object];
            self.sharedWithMefile = sharedWithMeFile;
            
        }else{
            return nil;
        }
        NSDictionary *paraDic = nil;
        if (self.downloadSize == 0) {
            paraDic = @{@"transactionCode": self.sharedWithMefile.transactionCode,@"transactionId": self.sharedWithMefile.transactionId,@"forViewer":self.forViewer?@"true":@"false"};
        }else{
            paraDic = @{@"transactionCode": self.sharedWithMefile.transactionCode,@"transactionId": self.sharedWithMefile.transactionId,@"forViewer":self.forViewer?@"true":@"false", @"start":@0, @"length":[NSNumber numberWithUnsignedInteger:self.downloadSize]};
        }
        NSDictionary *jsonDict = @{@"parameters":paraDic};
        NSError *error;
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
        NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/sharedWithMe/download",[NXCommonUtils currentRMSAddress]]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        [request setHTTPBody:bodyData];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        self.reqRequest=request;
    }
    return self.reqRequest;

}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        
        NXSharedWithMeDownloadFileAPIResponse *response = [[NXSharedWithMeDownloadFileAPIResponse alloc] init];
        NSData *contentData = nil;
        
        if ([returnData isKindOfClass:[NSString class]])
        {
            contentData=[returnData dataUsingEncoding:NSUTF8StringEncoding];
        }
        else
        {
            contentData =(NSData*)returnData;
            
            NSString *size = [[NSString alloc] initWithFormat:@"%lu",(unsigned long)contentData.length];
            if (self.sharedWithMefile.size == 0) {
                self.sharedWithMefile.size = size.longLongValue;
            }
            
            NSURL *sharedWithMeURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/sharedWithMe/download",[NXCommonUtils currentRMSAddress]]];
            NSString *fileName = [[NSUserDefaults standardUserDefaults] objectForKey:sharedWithMeURL.absoluteString] ;
            NSNumber *lastModified = [[NSUserDefaults standardUserDefaults] objectForKey:@"x-rms-last-modified"];
            
            if (self.sharedWithMefile.name == nil || self.sharedWithMefile.name.length == 0) {
                if (fileName.length > 0) {
                    
                    self.sharedWithMefile.name = fileName;
                }
                else
                {
                    self.sharedWithMefile.name = @"unknow";
                }
            }
            
            if (self.sharedWithMefile.lastModifiedTime == nil) {
                if (lastModified) {
                    
                    self.sharedWithMefile.lastModifiedTime = [NSString stringWithFormat:@"%0f", (lastModified).doubleValue/1000];
                    self.sharedWithMefile.lastModifiedDate = [NSDate dateWithTimeIntervalSince1970:lastModified.longLongValue/1000];
                }
            }
        
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:sharedWithMeURL.absoluteString];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"x-rms-last-modified"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        if (contentData)
        {
            [response analysisResponseStatus:contentData];
            if(response.rmsStatuCode == -1){ // God RMS API, only return error status code, but no success status code -_-|||
                response.rmsStatuCode = 200;
            }
        }
        
        response.fileData = contentData;
        response.file = self.sharedWithMefile;
        
        return response;
    };
    
    return analysis;
}

@end

@implementation NXSharedWithMeDownloadFileAPIResponse

- (NSData*)fileData
{
    if (!_fileData)
    {
        _fileData = [[NSData alloc] init];
    }
    
    return _fileData;
}

@end

