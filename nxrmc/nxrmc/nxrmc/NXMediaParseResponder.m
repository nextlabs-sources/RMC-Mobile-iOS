//
//  NXMediaParseResponder.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 7/14/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXMediaParseResponder.h"
#import "NXMediaRenderer.h"
#import "NXCommonUtils.h"

@interface NXMediaParseResponder()<NXFileRendererDelegate>
@property(nonatomic, strong) NXMediaRenderer *mediaRender;
@property(nonatomic, copy) parseFileCompletion parseFinishBlock;
@property(nonatomic, strong) NXFileBase *curFile;
@end

@implementation NXMediaParseResponder
- (void)parseFile:(NXFileBase *)file withCompleteBlock:(parseFileCompletion)completion
{
    self.contentType = NXFileContentTypeMedia;
    NSString* mimetype = [NXCommonUtils getMiMeType:file.localPath];
    if ([[mimetype lowercaseString] hasPrefix:@"audio/"] || [[mimetype lowercaseString] hasPrefix:@"video/"]) {
        self.mediaRender = [[NXMediaRenderer alloc] init];
        self.mediaRender.delegate = self;
        self.curFile = file;
        UIView *contentView = [self.mediaRender renderFile:[NSURL fileURLWithPath:file.localPath]];
        completion(self, file, contentView, nil);
    }else{
        if (self.nextResponder) {
            [self.nextResponder parseFile:file withCompleteBlock:completion];
        }else{
            [super parseFile:file withCompleteBlock:completion];
        }
    }
}

- (void)addOverlay:(UIView *)overLay {
    [self.mediaRender addOverlayer:overLay];
}

- (id)snap {
    return nil;
}

- (void)snapShot:(getSnapShotCompletionBlock)block
{
    block(nil);
}

- (void)dealloc {
    DLog(@"%@ %s", NSStringFromClass(self.class), __FUNCTION__);
}

- (void)pauseMediaFile
{
    [self.mediaRender.playerVC.player pause];
}

#pragma mark - NXFileRendererDelegate
- (void)fileRenderer:(NXFileRendererBase *)fileRenderer didLoadFile:(NSURL *)filePath error:(NSError *)error
{
    
}
@end
