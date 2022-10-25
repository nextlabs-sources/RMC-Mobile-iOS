//
//  NX3DConvertParseResponder.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 7/18/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NX3DConvertParseResponder.h"
#import "NXCommonUtils.h"
#import "NX3DFileConverter.h"
#import "NXHoopsRenderer.h"

@interface NX3DConvertParseResponder()<NXFileRendererDelegate>
@property(nonatomic, strong) NX3DFileConverter *fileConverter;
@property(nonatomic, strong) NXHoopsRenderer *hoopsRender;
@property(nonatomic, copy) parseFileCompletion parseCompletion;
@property(nonatomic, strong) NSString *convertFileOptId;
@property(nonatomic, strong) NSString *convertedFileTempPath;
@property(nonatomic, strong) UIView *contentView;
@end
@implementation NX3DConvertParseResponder
- (void)parseFile:(NXFileBase *)file withCompleteBlock:(parseFileCompletion)completion
{
    self.contentType = NXFileContentType3DNeedConvert;
    NSString *fileExtension = [NXCommonUtils getExtension:file.localPath error:nil];
    if([NXCommonUtils is3DFileNeedConvertFormat:fileExtension]){
        self.parseCompletion = completion;
        self.fileConverter = [[NX3DFileConverter alloc] init];
        WeakObj(self);
        self.convertFileOptId = [self.fileConverter convertFile:file data:[NSData dataWithContentsOfFile:file.localPath] progress:nil completion:^(NXFileBase *fileItem, NSData *data, NSError *error) {
            StrongObj(self);
            if (self) {
                if(error){
                    self.parseCompletion(self, file, nil, self.defaultError);
                }else{
                    if (data) {
                        NSString *tempPath = nil;
                        [self saveFile:data fileName:@"temp.hsf" fullPath:&tempPath];
                        self.convertedFileTempPath = tempPath;
                    }
                    
                    if (self.convertedFileTempPath) {
                        self.hoopsRender = [[NXHoopsRenderer alloc] init];
                        self.hoopsRender.delegate = self;
                        UIView *contentView = [self.hoopsRender renderFile:[NSURL fileURLWithPath:self.convertedFileTempPath]];
                        completion(self, file, contentView, nil);
                    }else{
                        completion(self, file, nil, self.defaultError);
                    }
                    
                }
            }
           
        }];
    }else{
        if(self.nextResponder){
            [self.nextResponder parseFile:file withCompleteBlock:completion];
        }else{
            [super parseFile:file withCompleteBlock:completion];
        }
    }
}

- (void)snapShot:(getSnapShotCompletionBlock)block
{
    [self.hoopsRender snapShot:^(id image) {
        block(image);
    }];
}

- (void)addOverlay:(UIView *)overLay
{
    [self.hoopsRender addOverlayer:overLay];
}
- (void)closeFile
{
    [[NSFileManager defaultManager] removeItemAtPath:self.convertedFileTempPath error:nil];
    [self.fileConverter cancelOperation:self.convertFileOptId];
    self.fileConverter = nil;
    self.hoopsRender = nil;
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

#pragma mark - NXFileRendererDelegate
- (void)fileRenderer:(NXFileRendererBase *)fileRenderer didLoadFile:(NSURL *)filePath error:(NSError *)error
{
    
}

@end
