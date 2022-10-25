 //
//  NXGoogleDriveUploadAPI.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2020/5/12.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXGoogleDriveUploadAPI.h"
#import "NXMultipartFormDataMaker.h"
#import "NXCommonUtils.h"

@implementation NXGoogleDriveUploadAPIRequest

- (NSURLRequest*)generateRequestObject:(id)object {
    if (self.reqRequest==nil) {
        NSData *fileData = object[@"fileData"];
        NSString *name = object[@"name"];
        NSString *parentPathID = object[@"parentPath"];
        NSDictionary *jDict;
        if (parentPathID.length > 0) {
          jDict = @{@"name":name,@"parents":@[parentPathID]};
        }else{
          jDict = @{@"name":name};
        }
        NSString *mimeType = [NXCommonUtils MIMETypeFileName:name defaultMIMEType:@"binary/octet-stream"];
        
        NSData *bodyData =  [self jsonDataWithJsonObj:jDict];
        NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart"]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"multipart/related; boundary=foo_bar_baz" forHTTPHeaderField:@"Content-Type"];
        NXMultipartFormDataMaker *formDataMaker = [[NXMultipartFormDataMaker alloc] initWithBoundary:@"foo_bar_baz"];
        [formDataMaker addMetaDataPart:bodyData];
        [formDataMaker addMediaDataPart:fileData mimeType:mimeType];
        [formDataMaker endFormData];
        
        [request setHTTPBody:[formDataMaker getFormData]];
    
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[request.HTTPBody length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        self.reqRequest=request;
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error)
    {
        NXGoogleDriveUploadAPIResponse *apiResponse = [[NXGoogleDriveUploadAPIResponse alloc]init];
        NSData *contentData = nil;
        
        if ([returnData isKindOfClass:[NSString class]])
        {
            contentData=[returnData dataUsingEncoding:NSUTF8StringEncoding];
        }
        else
        {
            contentData =(NSData*)returnData;
        }
        
        if (contentData)
        {
            [apiResponse analysisResponseStatus:contentData];
            if (error == nil) {
                apiResponse.rmsStatuCode = 200;
                apiResponse.fileData = (NSData *)returnData;
            }
            else if (error.code == 401)
            {
                apiResponse.isAccessTokenExpireError = YES;
            }
        }
        return apiResponse;
    };
    return analysis;
}

- (NSData *)jsonDataWithJsonObj:(id)jsonObj {
    if (!jsonObj) {
        return nil;
    }
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObj options:0 error:&error];
    
    if (!jsonData) {
        NSLog(@"Error serializing dictionary: %@", error.localizedDescription);
        return nil;
    } else {
        return jsonData;
    }
}

@end

@implementation NXGoogleDriveUploadAPIResponse
@end
