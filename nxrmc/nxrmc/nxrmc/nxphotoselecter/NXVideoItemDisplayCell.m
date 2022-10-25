//
//  NXVideoItemDisplayCell.m
//  xiblayout
//
//  Created by nextlabs on 10/19/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXVideoItemDisplayCell.h"

#import "Masonry.h"
#import "UIImage+ColorToImage.h"

@interface NXVideoItemDisplayCell ()

@property(nonatomic, strong) AVPlayer *player;

@property(nonatomic, weak) UIButton *playerButton;
@property(nonatomic, weak) UIView *videoContainer;

@end

@implementation NXVideoItemDisplayCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

#pragma mark

- (void)setModel:(NXAssetItem *)model {
    [[NXPhotoTool sharedInstance] requestExportSessionForVideo:model resultHandler:^(AVURLAsset *exportSession, NSURL *url, NSDictionary *info) {
        AVPlayerItem *item = [[AVPlayerItem alloc]initWithURL:url];
        self.player = [AVPlayer playerWithPlayerItem:item];
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
        
        AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        layer.frame = self.bounds;
        [self.videoContainer.layer addSublayer:layer];
    }];
    
    self.playerButton.selected = NO;
}

- (void)singleTap:(id)sender {
    if (self.singleTapCallBack) {
        self.singleTapCallBack();
    }
}

- (void)playerClicked:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if (sender.selected) {
        [self startPlay];
    } else {
        [self pausePlay];
    }
}

- (void)itemDidFinishPlaying:(NSNotification *)notification {
    [self stopPlay];
}

#pragma mark 

- (void)commonInit {
    UIView *videoContainer = [[UIView alloc] init];
    [self addSubview:videoContainer];
    [videoContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    self.videoContainer = videoContainer;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [videoContainer addGestureRecognizer:singleTap];
    
    
    UIButton *playButton = [[UIButton alloc] init];
    [self addSubview:playButton];
    
    UIImage *pauseImage = [[UIImage imageNamed:@"playIcon"] imageByApplyingAlpha:0];
    [playButton setImage:[UIImage imageNamed:@"playIcon"] forState:UIControlStateNormal];
    [playButton setImage:pauseImage forState:UIControlStateSelected];

    self.playerButton = playButton;
    
    [playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.equalTo(self).multipliedBy(0.4);
        make.height.equalTo(playButton.mas_width);
    }];
    
    [playButton addTarget:self action:@selector(playerClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)startPlay {
    [self.player play];
    self.playerButton.selected = YES;
}

- (void)pausePlay {
    [self.player pause];
    self.playerButton.selected = NO;
}

- (void)stopPlay {
    [self.player seekToTime:kCMTimeZero];
    [self.player pause];
    self.playerButton.selected = NO;
}

@end
