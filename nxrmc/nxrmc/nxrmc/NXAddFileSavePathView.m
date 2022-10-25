//
//  NXAddFileSavePathView.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2021/4/20.
//  Copyright © 2021 nextlabs. All rights reserved.
//

#import "NXAddFileSavePathView.h"
#import "Masonry.h"
@interface NXAddFileSavePathView ()
@property(nonatomic, strong)UILabel *savePathLabel;
@property(nonatomic, strong)UILabel *hintMessageLabel;
@property(nonatomic, strong)UIImageView *imageView;
@end
@implementation NXAddFileSavePathView

- (instancetype)initWithSavePathText:(NSString *)text {
    if (self = [super init]) {
        [self commonInitUIWithText:text];
    }
    return  self;
}
- (void)commonInitUIWithText:(NSString *)text {
    self.backgroundColor = [UIColor colorWithRed:232/255.0 green:253/255.0 blue:253/255.0 alpha:1];
    UIImageView *infoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info-icon"]];
    [self addSubview:infoImageView];
    self.imageView = infoImageView;
    UILabel *hintLabel = [[UILabel alloc] init];
    hintLabel.backgroundColor = self.backgroundColor;
    hintLabel.font = [UIFont systemFontOfSize:15.5];
    hintLabel.textColor = [UIColor lightGrayColor];
    self.hintMessageLabel = hintLabel;
    [self addSubview:hintLabel];
    UILabel *savePathLabel = [[UILabel alloc] init];
    [self addSubview:savePathLabel];
    savePathLabel.font = [UIFont boldSystemFontOfSize:17];
    self.savePathLabel = savePathLabel;
    savePathLabel.numberOfLines = 0;
    self.savePathLabel.text = text;
    
   
   
    [infoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kMargin);
        make.left.equalTo(self).offset(kMargin/2);
        make.width.height.equalTo(@25);
    }];
    [hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(infoImageView);
        make.left.equalTo(infoImageView.mas_right).offset(kMargin);
        make.right.equalTo(self).offset(-kMargin * 2);
        make.height.equalTo(@25);
    }];
    [savePathLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(infoImageView.mas_right).offset(kMargin);
        make.top.equalTo(hintLabel.mas_bottom).offset(kMargin);
        make.right.equalTo(self).offset(-kMargin * 2);
        make.bottom.equalTo(self).offset(-kMargin * 2);
    }];

   
}
- (void)setHintMessage:(NSString *)hintMessage andSavePath:(NSString *)savePath {
    self.hintMessageLabel.text = hintMessage;
    self.savePathLabel.text = savePath;
}


@end
