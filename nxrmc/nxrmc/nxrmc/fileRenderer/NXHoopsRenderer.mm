//
//  NXHoopsRenderer.m
//  nxrmc
//
//  Created by nextlabs on 10/26/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXHoopsRenderer.h"

#import "Masonry.h"

#import "UserMobileSurface.h"
#import "MobileSurfaceView.h"
#import "MobileSurfaceViewDelegate.h"
#import "NXCommonUtils.h"

@interface NXHoopsRenderer ()<MobileSurfaceViewDelegate>

@property(nonatomic, strong) MobileSurfaceView *surfaceView;
@property(nonatomic, assign) BOOL isSimpleShadowSelected;

@end

@implementation NXHoopsRenderer

- (UIView *)renderFile:(NSURL *)filePath {
    UIView *v = [super renderFile:filePath];
    if (v) {
        NSString *fileExtension = [NXCommonUtils getExtension:filePath.path error:nil];
        BOOL supportCuttingSection = NO;
        if ([fileExtension compare:@"hsf" options:NSCaseInsensitiveSearch] == NSOrderedSame) { // only hsf file support cutting section
            supportCuttingSection = YES;
        }
        self.surfaceView = [MobileSurfaceView mobileSurfaceViewWithXibFileWithSupportCuttingSection:supportCuttingSection];
        self.surfaceView.delegate = self;
        [self.surfaceView removeOverlay];
        UserMobileSurface *mobileSurface = (UserMobileSurface*)self.surfaceView.surfacePointer;
        bool ret = mobileSurface->loadFile(filePath.path.UTF8String);
        if (!ret) {
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf.delegate fileRenderer:strongSelf didLoadFile:filePath error:[NSError errorWithDomain:NX_ERROR_RENDER_FILE code:NXRMC_ERROR_CODE_RENDER_FILE_FAILED userInfo:nil]];
            });
            NSLog(@"render hsf file:%@ failed", filePath);
            return  nil;
        }
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.delegate fileRenderer:strongSelf didLoadFile:filePath error:nil];
        });
        self.contentView = self.surfaceView;
        return self.surfaceView;
    }
    return nil;
}

- (void)addOverlayer:(UIView *)overlay {
    overlay.userInteractionEnabled = NO;
    overlay.frame = self.surfaceView.bounds;
    [self.surfaceView addOverlay:overlay];
    [overlay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.surfaceView);
    }];
    
}

- (void)removeOverlayer{
    [self.surfaceView removeOverlay];
}

- (void)snapShot:(getSnapshotCompletionBlock)block
{
    block([self.surfaceView snapshotImage]);
}

- (void)dealloc{
    UserMobileSurface *mobileSurface = (UserMobileSurface*)self.surfaceView.surfacePointer;
    mobileSurface->release(0);
}

#pragma mark - MobileSurfaceViewDelegate

- (void)segControlValueChanged:(UISegmentedControl *)sender
{
    UserMobileSurface *mobileSurface = (UserMobileSurface*)self.surfaceView.surfacePointer;
    mobileSurface->segControlValueChanged(sender.selectedSegmentIndex);
}

- (void) buttonPressed:(UIButton *)sender withSelectedSegmentIndex:(NSInteger)selectedSegmentIndex
{
    // Connect button presses with UserMobileSurface actions
    UserMobileSurface *mobileSurface = (UserMobileSurface*)self.surfaceView.surfacePointer;
    if (selectedSegmentIndex == TOOLBAR_OPERATORS) {
        if (sender.tag == 1) {
            mobileSurface->setOperatorOrbit();
        } else if (sender.tag == 2) {
            mobileSurface->setOperatorZoomArea();
        } else if (sender.tag == 3) {
            mobileSurface->setOperatorSelectPoint();
        } else if (sender.tag == 4) {
            mobileSurface->setOperatorSelectArea();
        } else if (sender.tag == 5) {
            mobileSurface->setOperatorFly();
        }
    } else if (selectedSegmentIndex == TOOLBAR_MODES) {
        if (sender.tag == 1) {
            self.isSimpleShadowSelected = !self.isSimpleShadowSelected;
            mobileSurface->onModeSimpleShadow(self.isSimpleShadowSelected);
        } else if (sender.tag == 2) {
            mobileSurface->onModeSmooth();
        } else if (sender.tag == 3) {
            mobileSurface->onModeHiddenLine();
        } else if (sender.tag == 4) {
            mobileSurface->onModeFrameRate();
        }
    } else if (selectedSegmentIndex == TOOLBAR_USER_CODE) {
        if (sender.tag == 1) {
            mobileSurface->onUserCode1();
        } else if (sender.tag == 2) {
            mobileSurface->onUserCode2();
        } else if (sender.tag == 3) {
            mobileSurface->onUserCode3();
        } else if (sender.tag == 4) {
            mobileSurface->onUserCode4();
        }
    }
}

@end
