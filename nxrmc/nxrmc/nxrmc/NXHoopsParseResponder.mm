//
//  NXHOOPSParseResponder.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 7/14/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXHoopsParseResponder.h"
#import "NXRMCDef.h"
#import "NXCommonUtils.h"
#import "NXHoopsRenderer.h"

@interface NXHoopsParseResponder()<NXFileRendererDelegate>
@property(nonatomic, strong) NXHoopsRenderer *hoopsRenderer;
@property(nonatomic, strong) NXFileBase *curFile;
@end

@implementation NXHoopsParseResponder
- (void)parseFile:(NXFileBase *)file withCompleteBlock:(parseFileCompletion)completion
{
    self.contentType = NXFileContentType3D;
    NSString *extension = [NXCommonUtils getExtension:file.localPath error:nil];
    
    if ([NXCommonUtils isHOOPSFileFormat:extension]) {
        [self closeFile];
        self.curFile = file;
        self.hoopsRenderer = [[NXHoopsRenderer alloc] init];
        self.hoopsRenderer.delegate = self;
        UIView *contentView = [self.hoopsRenderer renderFile:[NSURL fileURLWithPath:file.localPath]];
        completion(self, file, contentView, nil);
    }else {
        if (self.nextResponder) {
            [self.nextResponder parseFile:file withCompleteBlock:completion];
        }else{
            [super parseFile:file withCompleteBlock:completion];
        }
    }
}

- (void)snapShot:(getSnapShotCompletionBlock)block
{
    [self.hoopsRenderer snapShot:^(id image) {
        block(image);
    }];
}

- (void)addOverlay:(UIView *)overLay
{
    [self.hoopsRenderer addOverlayer:overLay];
}
- (void)closeFile
{
    [self.hoopsRenderer removeOverlayer];
    self.hoopsRenderer = nil;
}

#pragma mark - NXFileRendererDelegate
- (void)fileRenderer:(NXFileRendererBase *)fileRenderer didLoadFile:(NSURL *)filePath error:(NSError *)error
{
    
}
@end
