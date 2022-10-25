//
//  NXFileContentTitleView.m
//  nxrmc
//
//  Created by EShi on 11/10/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXFileContentTitleView.h"
#import "Masonry.h"
#define FILE_TITLE_COLOR [UIColor blackColor]
#define FILE_TITLE_FONT [UIFont systemFontOfSize:19.0]
#define FILE_REPO_ALIAS_COLOR [UIColor whiteColor]
#define FILE_REPO_ALIAS_FONT [UIFont systemFontOfSize:10.0]

@interface NXFileContentTitleView()
@property(nonatomic, strong) UILabel *fileTitleLabel;
@property(nonatomic, strong) UILabel *fileRepoAliasLabel;
@end

@implementation NXFileContentTitleView
- (instancetype)initWithFrame:(CGRect) frame title:(NSString *)title repoAlias:(NSString *)alias
{
    self = [super initWithFrame:frame];
    if (self) {
        _fileTitleLabel = [[UILabel alloc] init];
        _fileTitleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _fileTitleLabel.numberOfLines = 1;
        _fileTitleLabel.textColor = FILE_TITLE_COLOR;
        _fileTitleLabel.font = FILE_TITLE_FONT;
        _fileTitleLabel.textAlignment = NSTextAlignmentCenter;
        _fileTitleLabel.text = title;
        
        _fileTitle = title;
        [self addSubview:_fileTitleLabel];
        
        _fileRepoAliasLabel = [[UILabel alloc] init];
        _fileRepoAliasLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _fileRepoAliasLabel.numberOfLines = 1;
        _fileRepoAliasLabel.textColor = FILE_REPO_ALIAS_COLOR;
        _fileRepoAliasLabel.font = FILE_REPO_ALIAS_FONT;
        _fileRepoAliasLabel.textAlignment = NSTextAlignmentCenter;
        _fileRepoAliasLabel.text = alias;
        
        _fileRepoAlias = alias;
        [self addSubview:_fileRepoAliasLabel];
        
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    [_fileTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.height.equalTo(self.mas_height).multipliedBy(2.0f/3.0f);
    }];
    
    [_fileRepoAliasLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fileTitleLabel.mas_bottom);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.height.equalTo(self.mas_height).multipliedBy(1.0f/3.0f);
    }];
    _fileTitleLabel.accessibilityValue = @"FILE_CONTENT_FILE_TITLE";
    _fileTitleLabel.accessibilityLabel = @"FILE_CONTENT_FILE_TITLE";
}

- (void)setFileTitle:(NSString *)fileTitle
{
    _fileTitle = fileTitle;
    self.fileTitleLabel.text = _fileTitle;
}

- (void)setFileRepoAlias:(NSString *)fileRepoAlias
{
    _fileRepoAlias = fileRepoAlias;
    self.fileRepoAliasLabel.text = fileRepoAlias;
}
@end
