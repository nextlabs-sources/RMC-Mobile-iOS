//
//  NXConvertFile.m
//  nxrmc
//
//  Created by helpdesk on 7/7/15.
//  Copyright (c) 2015 nextlabs. All rights reserved.
//

#import "NXConvertFile.h"
#import "NXRestAPI.h"
#import "NXRMCDef.h"
#import "NXCommonUtils.h"

#import "GTMBase64.h"

@interface NXConvertFile ()<NXRestAPIDelegate>

@property (nonatomic, strong) NXRestAPI* restAPI;
@property (nonatomic, copy) completionBlock block;
@property (nonatomic, copy) NSString *fileName;

@end


static NSString *gFileType_HSF = @"hsf";

@implementation NXConvertFile

- (instancetype)init
{
    if(self = [super init])
    {
        _state = NXConvertFileStateNotWork;
    }
    return self;
}

- (void)dealloc
{
    if (self.uploadProgress) {
        [self.uploadProgress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([object isEqual:self.uploadProgress]) {
        NSLog(@"Uploading %f", self.uploadProgress.fractionCompleted);
        double uploadProgress = self.uploadProgress.fractionCompleted * 0.7;
        NSNumber *progress = [NSNumber numberWithDouble:uploadProgress];
        if (_delegate && [_delegate respondsToSelector:@selector(nxConvertFile:convertProgress:forFile:)]) {
            dispatch_main_async_safe(^{
                [_delegate nxConvertFile:self convertProgress:progress forFile:_fileName];

            });
        }
    }
}

- (void)convertFile:(int)agentId fileName:(NSString *)filename data:(NSData *)data toFormat:(NSString *)fmt isNxl:(BOOL)nxl completion:(completionBlock)block
{
    if (self.uploadProgress) {
         [self.uploadProgress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
    }
    NSString *tempFileName = [NSString stringWithFormat:@"tempFile.%@", filename.pathExtension];
    _uploadProgress = [[NSProgress alloc] init];
    [self.uploadProgress addObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted)) options:NSKeyValueObservingOptionNew context:nil];
    
    [self.restAPI convertFile:agentId fileContent:data fileName:tempFileName toFormat:fmt isNxl:nxl uploadProgress:self.uploadProgress downloadProgress:nil];
    self.state = NXConvertFileStateConverting;
    self.block = block;
    _fileName = filename;
}

-(void) cancel
{
    if (self.state == NXConvertFileStateConverting) {
        [self.restAPI cancel];
        self.restAPI = nil;
        self.state = NXConvertFileStateNotWork;
    }
}


#pragma mark - NXRestAPIDelegate

- (void) restAPIResponse:(NSURL*) url result: (NSString*)result data:(NSData *) data error: (NSError*)err
{
    NSString *path = nil;
    if(!err) {
        if(data && [self saveFile:data fileName:@"tempConvert.hsf" fullPath:&path]) {
            //success.
        } else {
            err = [NXCommonUtils getNXErrorFromErrorCode:NXRMC_ERROR_CODE_CONVERTFILEFAILED error:err];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
       
        if (_delegate && [_delegate respondsToSelector:@selector(nxConvertFile:convertProgress:forFile:)]) {
            [_delegate nxConvertFile:self convertProgress:@1.0 forFile:_fileName];
        }
        self.block(path,err);
        self.state = NXConvertFileStateNotWork;
        self.restAPI = nil;
    });
}

- (BOOL)saveFile:(NSData*)binary fileName:(NSString*)fileName fullPath:(NSString**)fullPath
{
    // detect the directory if is exist,if not create a new directory named "ConvertFile" in tmp
    NSString *path = [NXCommonUtils getConvertFileTempPath];
    
    // save the file to local disk,like /tmp/nxrmcTmp/xxxx.hsf
    path = [path stringByAppendingPathComponent:fileName];
    if([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        //if this name's file exist,now just delete this file,in the future maybe need change
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }

    if(![binary writeToFile:path atomically:YES])
    {
        NSLog(@"convert file receive data  but write file fail");
        return NO;
    }
    
    *fullPath = path;
    return YES;
}

// override the get method
- (id)restAPI
{
    if(_restAPI == nil)
    {
        _restAPI = [[NXRestAPI alloc] init];
        _restAPI.delegate = self;
    }
    return _restAPI;
}
@end


