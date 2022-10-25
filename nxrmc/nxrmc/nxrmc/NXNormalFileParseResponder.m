//
//  NXNormalFileParseResponder.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 7/13/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXNormalFileParseResponder.h"
#import "NXNormalRenderer.h"
#import "NXCommonUtils.h"
#import <WebKit/WebKit.h>
@interface NXNormalFileParseResponder()<NXFileRendererDelegate>
@property (strong, nonatomic) WKWebView *fileContentWebView;
@property(nonatomic, copy) parseFileCompletion parseFileCompletionBlock;
@property(nonatomic, strong) NXFileBase *currentFile;
@property(nonatomic, strong) NXNormalRenderer *normalRenderer;
@end

@implementation NXNormalFileParseResponder
- (void)parseFile:(NXFileBase *)file withCompleteBlock:(parseFileCompletion)completion
{
    self.contentType = NXFileContentTypeNormal;
    NSString *extension = [NXCommonUtils getExtension:file.localPath error:nil];
    BOOL shouldResponse = [NXCommonUtils isTheSupportedFormat:extension];
    if ([extension compare:FILEEXTENSION_PDF options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        shouldResponse = NO;
    }else if([NXCommonUtils isRemoteViewSupportFormat:extension]){
        shouldResponse = NO;
    }else if([NXCommonUtils is3DFileFormat:extension]){
        shouldResponse = NO;
    }else {
        NSString* mimetype = [NXCommonUtils getMiMeType:file.localPath];
        if ([[mimetype lowercaseString] hasPrefix:@"audio/"] || [[mimetype lowercaseString] hasPrefix:@"video/"]) {
            shouldResponse = NO;
        }
    }
    
    if (shouldResponse) {
        self.parseFileCompletionBlock = completion;
        self.currentFile = file;
        self.normalRenderer = [[NXNormalRenderer alloc] init];
        self.normalRenderer.delegate = self;
        NSURL *fileURL = [NSURL fileURLWithPath:file.localPath];
        UIView *contentView = [self.normalRenderer renderFile:fileURL];
        completion(self, file, contentView, nil);
        
    }else{
        if (self.nextResponder) {
            [self.nextResponder parseFile:file withCompleteBlock:completion];
        }else{
            [super parseFile:file withCompleteBlock:completion];
        }
    }
}

#pragma mark - NXFileRendererDelegate
- (void)fileRenderer:(NXFileRendererBase *)fileRenderer didLoadFile:(NSURL *)filePath error:(NSError *)error
{
    
}

- (void)snapShot:(getSnapShotCompletionBlock)block
{
    [self.normalRenderer snapShot:^(id image) {
        block(image);
    }];
}

- (void)addOverlay:(UIView *)overLay
{
    [self.normalRenderer addOverlayer:overLay];
}

- (void)closeFile
{
    self.normalRenderer = nil;
}
@end
