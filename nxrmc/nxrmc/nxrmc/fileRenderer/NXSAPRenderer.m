//
//  NXSAPRenderer.m
//  nxrmc
//
//  Created by nextlabs on 10/26/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXSAPRenderer.h"

#import "Masonry.h"
#import "NXGLKViewController.h"

@interface NXSAPRenderer ()

@property(nonatomic, strong) NXGLKViewController *vdsVC;

@end

@implementation NXSAPRenderer

- (UIView *)renderFile:(NSURL *)filePath {
    UIView *v = [super renderFile:filePath];
    if(TARGET_IPHONE_SIMULATOR && TARGET_OS_IOS) {
    }else {
        if (v) {
            self.vdsVC = [[NXGLKViewController alloc] initWithNibName:@"NXGLKViewController" bundle:nil];
            bool res = [self.vdsVC loadVDSFile:filePath.path];
            if (res) {
                __weak typeof(self) weakSelf = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                       __strong typeof(weakSelf) strongSelf = weakSelf;
                        [strongSelf.delegate fileRenderer:strongSelf didLoadFile:filePath error:nil];
                    });
            }else{
                __weak typeof(self) weakSelf = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf.delegate fileRenderer:strongSelf didLoadFile:filePath error:[NSError errorWithDomain:NX_ERROR_RENDER_FILE code:NXRMC_ERROR_CODE_RENDER_FILE_FAILED userInfo:nil]];
                    });
            }
                self.contentView = self.vdsVC.view;
                return self.vdsVC.view;
        }
    }

    return v;
}

- (void)addOverlayer:(UIView *)overlay {
    overlay.userInteractionEnabled = NO;
    overlay.tag = 12121;
    [self.vdsVC.view addSubview:overlay];
    [overlay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.vdsVC.view);
    }];
}

- (void)removeOverlayer
{
    UIView *overlay = [self.vdsVC.view viewWithTag:12121];
    [overlay removeFromSuperview];
}

- (void)snapShot:(getSnapshotCompletionBlock)block
{
    block([self.vdsVC snapshotImage]);
}
- (void)dealloc {
    NSLog(@"%@%s", NSStringFromClass(self.class), __FUNCTION__);
}

@end
