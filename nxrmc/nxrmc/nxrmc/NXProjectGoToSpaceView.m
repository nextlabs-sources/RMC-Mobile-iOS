//
//  NXProjectGoToSpaceView.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/12/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectGoToSpaceView.h"
#import "Masonry.h"

@implementation NXProjectGoToSpaceView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)tap:(UITapGestureRecognizer *)gesture {
    if (self.clickBlock) {
        self.clickBlock(nil);
    }
}

#pragma mark
- (void)commonInit {
    self.backgroundColor = [UIColor whiteColor];
    UILabel *goLabbel = [[UILabel alloc] init];
    goLabbel.text = NSLocalizedString(@"UI_COM_GO_TO", NULL);
    goLabbel.textColor = [UIColor lightGrayColor];
    goLabbel.font = [UIFont systemFontOfSize:kMiniFontSize];
    
    UILabel *spaceLabel = [[UILabel alloc] init];
    spaceLabel.text = NSLocalizedString(@"UI_MY_SPACE", NULL);
    spaceLabel.textColor = [UIColor blackColor];
    spaceLabel.font = [UIFont systemFontOfSize:kNormalFontSize];
    
    [self addSubview:goLabbel];
    [self addSubview:spaceLabel];
    
    if (IS_IPHONE_X) {
          if (@available(iOS 11.0, *)) {
              [goLabbel mas_makeConstraints:^(MASConstraintMaker *make) {
                  make.centerY.equalTo(self.mas_safeAreaLayoutGuideCenterY);
                  make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(kMargin*2);
              }];
              
              [spaceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                  make.right.equalTo(self.mas_safeAreaLayoutGuideRight).offset(-kMargin*2);
                  make.centerY.equalTo(self.mas_safeAreaLayoutGuideCenterY);
              }];
          }
    }
    else
    {
        [goLabbel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self).offset(kMargin*2);
        }];
        
        [spaceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-kMargin*2);
            make.centerY.equalTo(self);
        }];
    }
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] init];
    [self addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer addTarget:self action:@selector(tap:)];
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 0.5;
}

@end
