//
//  NXMultipartFormDataMaker.m
//  nxrmc
//
//  Created by EShi on 12/22/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXMultipartFormDataMaker.h"

#import "NXCommonUtils.h"

@interface NXMultipartFormDataMaker()
@property(nonatomic, strong) NSMutableData *formData;
@property(nonatomic, copy) NSString *boundary;
@end


@implementation NXMultipartFormDataMaker
- (instancetype)init
{
    NSAssert(NO, @"use initWithBoundary to init");
    return nil;
}
- (instancetype)initWithBoundary:(NSString *)boundary
{
    self = [super init];
    if (self) {
        _boundary = boundary;
    }
    return self;
}
- (NSMutableData *)formData
{
    if (_formData == nil) {
        _formData = [[NSMutableData alloc] init];
    }
    return _formData;
}

- (void)addTextParameter:(NSString *)parameterName parameterValue:(NSString *)parameterValue
{
    [self.formData  appendData:[[NSString stringWithFormat:@"--%@\r\n", self.boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [self.formData  appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterName] dataUsingEncoding:NSUTF8StringEncoding]];
    [self.formData  appendData:[parameterValue dataUsingEncoding:NSUTF8StringEncoding]];
    [self.formData appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
}

- (void)addTextParameter:(NSString *)parameterName parameterJsonDataValue:(NSData *)jsonDataValue
{
    [self.formData  appendData:[[NSString stringWithFormat:@"--%@\r\n", self.boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [self.formData  appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterName] dataUsingEncoding:NSUTF8StringEncoding]];
    [self.formData  appendData:jsonDataValue];
    [self.formData appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
}

-(void)addMetaDataPart:(NSData *)metaData{
       [self.formData  appendData:[[NSString stringWithFormat:@"--%@\r\n", self.boundary] dataUsingEncoding:NSUTF8StringEncoding]];
       [self.formData  appendData:[[NSString stringWithFormat:@"Content-Type:application/json; charset=UTF-8\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
       [self.formData  appendData:metaData];
       [self.formData appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
}

-(void)addMediaDataPart:(NSData *)fileData mimeType:(NSString *)mimeType;
{
         [self.formData  appendData:[[NSString stringWithFormat:@"--%@\r\n", self.boundary] dataUsingEncoding:NSUTF8StringEncoding]];
         [self.formData  appendData:[[NSString stringWithFormat:@"Content-Type:\"%@\"\r\n\r\n", mimeType] dataUsingEncoding:NSUTF8StringEncoding]];
         [self.formData  appendData:fileData];
         [self.formData appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)addFileParameter:(NSString *)parameterName fileName:(NSString *)fileName fileData:(NSData *)fileData
{
    [self.formData  appendData:[[NSString stringWithFormat:@"--%@\r\n", self.boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [self.formData  appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", parameterName, fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *mimeType = [NXCommonUtils getMimeTypeByFileName:fileName];
    if (mimeType) {
        [self.formData  appendData:[[NSString stringWithFormat:@"Content-Type:%@\r\n", mimeType] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [self.formData appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [self.formData appendData:fileData];
    [self.formData appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
}
- (void)endFormData
{
    [self.formData appendData:[[NSString stringWithFormat:@"--%@--", self.boundary] dataUsingEncoding:NSUTF8StringEncoding]];
}
- (NSData *)getFormData
{
    return self.formData;
}
@end
