//
//  NXMyDriveFileUploadAPI.m
//  nxrmc
//
//  Created by helpdesk on 5/12/16.
//  Copyright © 2016年 nextlabs. All rights reserved.
//

#import "NXMyDriveFileUploadAPI.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"

@implementation NXMyDriveFileUploadAPI
-(NSURLRequest *) generateRequestObject:(id) object {
    
    if (self.reqRequest==nil) {
        NSDictionary * paramobject=object[@"object"];
        NSData *fileData=object[@"fileData"];
        NSDictionary *jsonDict = @{@"parameters":paramobject};
        NSError *error;
        NSData *paramData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
        NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/myDrive/uploadFile",[NXCommonUtils currentRMSAddress]]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        [request setHTTPMethod:@"POST"];
        NSString *stringBoundary =@"ASDFGHJKLOP";
        [request setValue:@"multipart/form-data" forHTTPHeaderField:@"consumes"];
        NSMutableData *postData =[[NSMutableData alloc]init];
        [request setValue:[NSString stringWithFormat:@"multipart/form-data;boundary=%@",stringBoundary] forHTTPHeaderField:@"Content-Type"];
        
        [postData appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        // add post data
        NSString *endItemBoundary =[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary];
        NSDictionary *postDic = @{@"fileName":@"file",@"key":@"API-input",@"data":paramData,@"contentType":@"application/octet-stream"};
        
        
        NSString *postStr= [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", [postDic objectForKey:@"key"], [postDic objectForKey:@"fileName"]];
        
        [postData appendData:[postStr dataUsingEncoding:NSUTF8StringEncoding]];
        NSString *contentType =[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", [postDic objectForKey:@"contentType"]];
        [postData appendData:[contentType dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:paramData];
        [postData appendData:[endItemBoundary dataUsingEncoding:NSUTF8StringEncoding]];
        
        // add file data
        NSString *fileStr= [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"file",@"file"];
        [postData appendData:[fileStr dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[contentType dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:fileData];
        [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary]dataUsingEncoding:NSUTF8StringEncoding]];
        request.HTTPBody=postData;

        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[request.HTTPBody length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        
        self.reqRequest=request;
    }
        return self.reqRequest;
}
- (Analysis)analysisReturnData {
     Analysis analysis = (id)^(NSString *returnData, NSError* error){
         NXMyDriveFileUploadAPIResponse *response =[[NXMyDriveFileUploadAPIResponse alloc]init];
         NSData *backData =[returnData dataUsingEncoding:NSUTF8StringEncoding];
         if (backData) {
             [response analysisResponseStatus:backData];
             NSDictionary *returnDic =[NSJSONSerialization JSONObjectWithData:backData options:NSJSONReadingMutableContainers error:nil];
             
             NSDictionary *resultDic =returnDic[@"results"];
             NSDictionary *entry = resultDic[@"entry"];
             NXMyDriveUploadFileItem *item=[[NXMyDriveUploadFileItem alloc]initWithDictionary:entry];
             response.item=item;
         }
         return response;
         
       };
    return analysis;
    
}
@end

@implementation NXMyDriveFileUploadAPIResponse
- (NXMyDriveUploadFileItem*)item {
    if (!_item) {
        _item=[[NXMyDriveUploadFileItem alloc]init];
    }
    return _item;
}
@end
@implementation NXMyDriveUploadFileItem
-(instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self=[super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"lastModified"]) {
        self.lastModified = ((NSNumber *)value).longLongValue / 1000;
    }else{
        [super setValue:value forKey:key];
    }
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}
@end
