//
//  NXMediaRenderer.m
//  nxrmc
//
//  Created by nextlabs on 10/26/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXMediaRenderer.h"

#import "Masonry.h"

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

#import "VideoViewController.h"

@interface NXMediaRenderer ()<AVPlayerViewControllerDelegate>

@property(nonatomic, strong) VideoViewController *playerVC;
@property(nonatomic, strong) NSURL *filePath;

@end

@implementation NXMediaRenderer

- (UIView *)renderFile:(NSURL *)filePath {
    UIView *v = [super renderFile:filePath];
    
    if (v) {
        self.playerVC = [[VideoViewController alloc]init];
        
        AVPlayer *player = [[AVPlayer alloc] initWithURL:filePath];
        self.playerVC.player = player;
        [self.playerVC.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];

        self.playerVC.videoGravity = AVLayerVideoGravityResizeAspect;
        self.playerVC.showsPlaybackControls = YES;
        self.playerVC.allowsPictureInPicturePlayback = NO;
        self.filePath = filePath;
        self.contentView = self.playerVC.view;
        [self.playerVC.player play];
        return self.playerVC.view;
    }
    
    return v;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([object isEqual:self.playerVC.player] && [keyPath isEqualToString:@"status"]) {
        NSString * str = change[@"new"];
        AVPlayerStatus playerStatus = [str integerValue];
        switch (playerStatus) {
            case AVPlayerStatusReadyToPlay:
            {
                __weak typeof(self) weakSelf = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    [strongSelf.delegate fileRenderer:strongSelf didLoadFile:weakSelf.filePath error:nil];
                });
            }
                break;
            case AVPlayerStatusFailed:
            {
                __weak typeof(self) weakSelf = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    [strongSelf.delegate fileRenderer:strongSelf didLoadFile:weakSelf.filePath error:[NSError errorWithDomain:NX_ERROR_RENDER_FILE code:NXRMC_ERROR_CODE_RENDER_FILE_FAILED userInfo:nil]];
                });
            }
                break;
            default:
                break;
        }
    }
}

- (void)addOverlayer:(UIView *)overlay {
    overlay.userInteractionEnabled = NO;
    [self.playerVC addOverlay:overlay];
}

- (id)snap {
    return nil;
}

- (void)dealloc {
    NSLog(@"%@ %s", NSStringFromClass(self.class), __FUNCTION__);
    [self.playerVC.player removeObserver:self forKeyPath:@"status"];
}

@end
