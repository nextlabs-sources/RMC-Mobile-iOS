//
//  NXSAPParserResponder.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 7/13/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXSAPParserResponder.h"
#import "NXSAPRenderer.h"
#import "NXCommonUtils.h"

@interface NXSAPParserResponder()<NXFileRendererDelegate>
@property(nonatomic, strong) NXSAPRenderer *sapRenderer;
@property(nonatomic, strong) NXFileBase *curFile;
@end

@implementation NXSAPParserResponder
- (void)parseFile:(NXFileBase *)file withCompleteBlock:(parseFileCompletion)completion
{
    self.contentType = NXFileContentType3D;
    NSString *fileExtension = [NXCommonUtils getExtension:file.localPath error:nil];
    if ([fileExtension compare:FILEEXTENSION_VDS options:NSCaseInsensitiveSearch] == NSOrderedSame || [fileExtension compare:FILEEXTENSION_RH options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        self.curFile = file;
        self.sapRenderer = [[NXSAPRenderer alloc] init];
        self.sapRenderer.delegate = self;
        UIView *contentView = [self.sapRenderer renderFile:[NSURL fileURLWithPath:file.localPath]];
        completion(self, file, contentView, nil);
    }else{
        if (self.nextResponder) {
            [self.nextResponder parseFile:file withCompleteBlock:completion];
        }else{
            [super parseFile:file withCompleteBlock:completion];
        }
    }
}

- (void)snapShot:(getSnapShotCompletionBlock)block
{
    [self.sapRenderer snapShot:^(id image) {
        block(image);
    }];
}
- (void)addOverlay:(UIView *)overLay
{
    [self.sapRenderer addOverlayer:overLay];
}

- (void)closeFile
{
    [self.sapRenderer removeOverlayer];
    self.sapRenderer = nil;
}
#pragma mark - NXFileRendererDelegate
- (void)fileRenderer:(NXFileRendererBase *)fileRenderer didLoadFile:(NSURL *)filePath error:(NSError *)error
{
    
}
@end
