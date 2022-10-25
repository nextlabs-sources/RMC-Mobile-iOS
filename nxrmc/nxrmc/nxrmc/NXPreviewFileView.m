//
//  NXPreviewFileView.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/3/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXPreviewFileView.h"
#import "NXChooseDriveView.h"

#import "DetailViewController.h"

#import "NXCommonUtils.h"
#import "Masonry.h"
#import "NXFile.h"

@interface NXPreviewFileView ()<DetailViewControllerDelegate>
@property(nonatomic, weak, readonly) NXChooseDriveView *chooseDriveView;
@property(nonatomic, strong) DetailViewController *fileViewer;
@property(nonatomic, strong) UILabel *noSupportLabel;
@property(nonatomic, strong) UIButton *ChangeLocationBtn;
@end

@implementation NXPreviewFileView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (void)setSavedPath:(NSString *)savedPath {
    _savedPath = savedPath;
    self.chooseDriveView.model = savedPath;
}

- (void)setFileItem:(NXFileBase *)fileItem {
    _fileItem = fileItem;
    self.chooseDriveView.fileName = fileItem.name;
    NSString *extension = [NXCommonUtils getFileExtensionByFileName:self.fileItem];
    if ([NXCommonUtils isTheSupportedFormat:extension] && fileItem.localPath) {
        [_fileViewer openFileForPreview:fileItem];
        self.noSupportLabel.hidden = YES;
        [self sendSubviewToBack:self.noSupportLabel];
    } else {
        self.noSupportLabel.hidden = NO;
        [self bringSubviewToFront:self.noSupportLabel];
        self.chooseDriveView.isHiddenSmallPreview = YES;
    }
}

- (void)setPromptMessage:(NSString *)promptMessage {
    _promptMessage = promptMessage;
    self.chooseDriveView.promptMessage = promptMessage;
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    self.chooseDriveView.enabled = enabled;
}
- (void)setEnableReselect:(BOOL)enableReselect {
    _enableReselect = enableReselect;
    if (enableReselect) {
        UIButton *changeLocationBtn = [[UIButton alloc] init];
        [self addSubview:changeLocationBtn];
        [changeLocationBtn setTitle:@"Change save location" forState:UIControlStateNormal];
        [changeLocationBtn setTitleColor:[UIColor colorWithRed:147/255.0 green:200/255.0 blue:106/255.0 alpha:1] forState:UIControlStateNormal];
        [changeLocationBtn addTarget:self action:@selector(changePath:) forControlEvents:UIControlEventTouchUpInside];
        changeLocationBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [changeLocationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.chooseDriveView.mas_bottom).offset(-2);
            make.right.equalTo(self);
            make.height.equalTo(@30);
            make.width.equalTo(@200);
            
        }];
        
    }
    
}

- (void)changePath:(id)sender {
    if (self.changePathClick) {
        self.changePathClick(sender);
    }
}
- (void)showWholePreview:(id)sender {
    if (self.showPreviewClick) {
        self.showPreviewClick(sender);
    }
}
- (UIImage *)translatedImageFromView:(UIView *)view {
    CGSize size = view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)commonInit {

    self.backgroundColor = [UIColor blackColor];
    
    NXChooseDriveView *chooseDriveView = [[NXChooseDriveView alloc] init];
    [self addSubview:chooseDriveView];
    UIButton *changeLocationBtn = [[UIButton alloc] init];
    [self addSubview:changeLocationBtn];
    [changeLocationBtn setTitle:@"Change save location" forState:UIControlStateNormal];
    [changeLocationBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [changeLocationBtn addTarget:self action:@selector(changePath:) forControlEvents:UIControlEventTouchUpInside];
    WeakObj(self);
    
    chooseDriveView.clickActionBlock = ^(id sender) {
        StrongObj(self);
        [self changePath:sender];
    };
    chooseDriveView.clickImageViewBlock = ^(id sender) {
        StrongObj(self);
        [self showWholePreview:sender];
    };
    DetailViewController *fileViewer = [[DetailViewController alloc]init];
    [self addSubview:fileViewer.view];
    fileViewer.delegate = self;
    
    UILabel *noSupportLabel = [[UILabel alloc] init];
    noSupportLabel.text = NSLocalizedString(@"UI_FILE_NOT_SUPPORTED", NULL);
    noSupportLabel.textAlignment = NSTextAlignmentCenter;
    noSupportLabel.lineBreakMode = NSLineBreakByWordWrapping;
    noSupportLabel.numberOfLines = 0;
    noSupportLabel.backgroundColor = [UIColor whiteColor];
    [self addSubview:noSupportLabel];
    
    [chooseDriveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kMargin * 2);
        make.left.equalTo(self).offset(kMargin);
        make.right.equalTo(self).offset(-kMargin);
        make.height.equalTo(@65);
    }];
    
    [fileViewer.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(chooseDriveView.mas_bottom).offset(kMargin * 3);
        make.centerX.equalTo(self);
        make.width.equalTo(fileViewer.view.mas_height).multipliedBy(0.8);
        make.bottom.equalTo(self).offset(-kMargin);
    }];
    
    [noSupportLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(chooseDriveView.mas_bottom).offset(kMargin * 3);
        make.left.equalTo(self).offset(kMargin);
        make.right.equalTo(self).offset(-kMargin);
        make.bottom.equalTo(self).offset(-kMargin);
    }];
    
    _fileViewer = fileViewer;
    _chooseDriveView = chooseDriveView;
    _noSupportLabel = noSupportLabel;
    
#if 0
    self.backgroundColor = [UIColor redColor];
    _fileViewer.view.backgroundColor = [UIColor orangeColor];
#endif
}

- (void)showSmallPreImageView {
     self.chooseDriveView.fileImageView.image = [self translatedImageFromView:self.fileViewer.view];
}
- (void)afterOpenFile {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showSmallPreImageView];
        if ([self.delegate respondsToSelector:@selector(previewFileViewDidloadFileContent)]) {
           [self.delegate previewFileViewDidloadFileContent];
        }
    });
}
@end
