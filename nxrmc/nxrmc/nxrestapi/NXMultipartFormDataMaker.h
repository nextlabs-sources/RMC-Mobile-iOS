//
//  NXMultipartFormDataMaker.h
//  nxrmc
//
//  Created by EShi on 12/22/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NXMultipartFormDataMaker : NSObject
- (instancetype)initWithBoundary:(NSString *)boundary;
- (void)addTextParameter:(NSString *)parameterName parameterValue:(NSString *)parameterValue;
- (void)addTextParameter:(NSString *)parameterName parameterJsonDataValue:(NSData *)jsonDataValue;
- (void)addFileParameter:(NSString *)parameterName fileName:(NSString *)fileName fileData:(NSData *)fileData;
-(void)addMetaDataPart:(NSData *)metaData;
-(void)addMediaDataPart:(NSData *)fileData mimeType:(NSString *)mimeType;
- (void)endFormData;

- (NSData *)getFormData;
@end
