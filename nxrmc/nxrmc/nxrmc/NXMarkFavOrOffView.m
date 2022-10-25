//
//  NXMarkFavOrOffView.m
//  nxrmcUITest
//
//  Created by nextlabs on 11/9/16.
//  Copyright © 2016 zhuimengfuyun. All rights reserved.
//

#import "NXMarkFavOrOffView.h"

#import "ImageTextButton.h"
#import "Masonry.h"
#import "UIView+UIExt.h"

#import "NXFileBase.h"
#import "NXLoginUser.h"
#import "NXRMCDef.h"
#import "NXFileMarker.h"
#import "NXCommonUtils.h"
#import "NXOfflineFileManager.h"
#import "NXMBManager.h"
#import "NXNetworkHelper.h"

@interface NXMarkFavOrOffView()

@property(nonatomic, weak) ImageTextButton *favButton;
@property(nonatomic, weak) ImageTextButton *offButton;

@end

@implementation NXMarkFavOrOffView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_offButton addShadow:UIViewShadowPositionTop | UIViewShadowPositionLeft | UIViewShadowPositionBottom | UIViewShadowPositionRight color:[UIColor lightGrayColor] width:1 Opacity:0.5];
    
    [_favButton addShadow:UIViewShadowPositionTop | UIViewShadowPositionLeft | UIViewShadowPositionBottom | UIViewShadowPositionRight color:[UIColor lightGrayColor] width:1 Opacity:0.5];
}

#pragma mark
- (void)setModel:(NXFileBase *)model {
    _model = model;
    _favButton.selected = model.isFavorite;
    NXFileState state = [[NXOfflineFileManager sharedInstance] currentState:model];
    if (state == NXFileStateOfflined) {
        _offButton.selected = YES;
    }else{
         _offButton.selected = NO;
    }
    
    if (![NXCommonUtils isOfflineViewSupportFormat:self.model]) {
        _offButton.enabled = NO;
    }else{
        _offButton.enabled = YES;
    }
    
    if ([model isKindOfClass:[NXOfflineFile class]] || [model isKindOfClass:[NXProjectFile class]] || [model isKindOfClass:[NXMyVaultFile class]]) {
        [self updateUI];
    }else{
        [self updateUITwo];
    }
    
    if (_isFromFavoritePage) {
         [self updateUITwo];
    }
}

#pragma mark
- (void)markOffline:(UIButton *)sender {
    
    // step1. check network
    if (![[NXNetworkHelper sharedInstance] isNetworkAvailable]) {
        dispatch_main_async_safe(^{
            NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NETWORK_DOMAIN code:NXRMC_ERROR_NO_NETWORK userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_NETWORK_UNUSABLE", nil)}];
           [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2.0];
        });
        return;
    }
    
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {
        [[NXOfflineFileManager sharedInstance] markFileAsOffline:self.model withCompletion:^(NXFileBase *fileItem, NSError *error) {
            if (error) {
                 [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2.0];
            }
        }];
    } else {
        [[NXOfflineFileManager sharedInstance] unmarkFileAsOffline:self.model withCompletion:^(NXFileBase *fileItem, NSError *error) {
            if (error) {
                [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2.0];
            }
        }];
    }
}

- (void)markFavorite:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {
        [[NXLoginUser sharedInstance].favFileMarker markFileAsFav:self.model withCompleton:^(NXFileBase *file) {
            // mark as favorite
        }];
    } else {
        [[NXLoginUser sharedInstance].favFileMarker unmarkFileAsFav:self.model withCompletion:^(NXFileBase *file) {
            // unmark as favorite
        }];
    }
}

#pragma mark
- (void)commonInit {
    self.clipsToBounds = YES;
    if (OFFLINE_ON && FAVORITE_ON) {
        [self.favButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(kMargin);
            make.top.equalTo(self).offset(kMargin/2);
            make.bottom.equalTo(self).offset(-kMargin/2);
        }];
        
        [self.offButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.favButton.mas_right).offset(kMargin*2);
            make.right.equalTo(self).offset(-kMargin);
            make.width.equalTo(self.favButton);
            make.top.equalTo(self.favButton);
            make.height.equalTo(self.favButton);
        }];
    } else if (FAVORITE_ON) {
        [self.favButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(kMargin/2);
            make.centerX.equalTo(self);
            make.width.equalTo(self).multipliedBy(0.5);
            make.bottom.equalTo(self).offset(-kMargin/2);
        }];
    } else if (OFFLINE_ON) {
        [self.offButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(kMargin/2);
            make.centerX.equalTo(self);
            make.width.equalTo(self).multipliedBy(0.5);
            make.bottom.equalTo(self).offset(-kMargin/2);
        }];
    }
}

- (void)updateUI{
    self.clipsToBounds = YES;
    [self.offButton setHidden:NO];
    [self.favButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(kMargin);
        make.top.equalTo(self).offset(kMargin/2);
        make.bottom.equalTo(self).offset(-kMargin/2);
    }];
    
    [self.offButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.favButton.mas_right).offset(kMargin*2);
        make.right.equalTo(self).offset(-kMargin);
        make.width.equalTo(self.favButton);
        make.top.equalTo(self.favButton);
        make.height.equalTo(self.favButton);
    }];
}

- (void)updateUITwo{
    self.clipsToBounds = YES;
    [self.offButton setHidden:YES];
    
    [self.favButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kMargin/2);
        make.centerX.equalTo(self);
        make.width.equalTo(self).multipliedBy(0.5);
        make.bottom.equalTo(self).offset(-kMargin/2);
    }];
}

- (ImageTextButton *)favButton {
    if (!_favButton) {
        ImageTextButton *favButton = [[ImageTextButton alloc] initWithFrame:CGRectZero];
        [self addSubview:favButton];
        NSAttributedString *favStr = [[NSAttributedString alloc]initWithString:NSLocalizedString(@"UI_COM_OPT_UNMARK_AS_FAVORITE", NULL) attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:kNormalFontSize]}];
        NSAttributedString *unFavStr = [[NSAttributedString alloc]initWithString:NSLocalizedString(@"UI_MARK_AS_FAVORITE", NULL) attributes:@{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont systemFontOfSize:kNormalFontSize]}];
        favButton.backgroundColor = [UIColor whiteColor];
        [favButton setAttributedTitle:unFavStr forState:UIControlStateNormal];
        [favButton setAttributedTitle:favStr forState:UIControlStateSelected];
        [favButton setImage:[UIImage imageNamed:@"Mark as favorite"] forState:UIControlStateNormal];
        [favButton setImage:[UIImage imageNamed:@"available favorited"] forState:UIControlStateSelected];
        [favButton setButtonTitleWithImageAlignment:UIButtonTitleWithImageAlignmentDown];
        [favButton addTarget:self action:@selector(markFavorite:) forControlEvents:UIControlEventTouchUpInside];
        favButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        favButton.titleLabel.minimumScaleFactor = 0.6;
        
        _favButton = favButton;
    }
    return _favButton;
}

- (ImageTextButton *)offButton {
    if (!_offButton) {
        ImageTextButton *offButton = [[ImageTextButton alloc] initWithFrame:CGRectZero];
        [self addSubview:offButton];
        
        NSAttributedString *offStr = [[NSAttributedString alloc]initWithString:NSLocalizedString(@"UI_AVAILABLE_OFFLINE", NULL) attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor], NSObliquenessAttributeName:@0.3, NSFontAttributeName:[UIFont systemFontOfSize:kNormalFontSize]}];
        NSAttributedString *unOffStr = [[NSAttributedString alloc]initWithString:NSLocalizedString(@"UI_MARK_AVAILABLE_OFFLINE", NULL) attributes:@{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont systemFontOfSize:kNormalFontSize]}];
        offButton.backgroundColor = [UIColor whiteColor];
        [offButton setAttributedTitle:unOffStr forState:UIControlStateNormal];
        [offButton setAttributedTitle:offStr forState:UIControlStateSelected];
        [offButton setImage:[UIImage imageNamed:@"mark as offline"] forState:UIControlStateNormal];
        [offButton setImage:[UIImage imageNamed:@"available offline"] forState:UIControlStateSelected];
        [offButton setButtonTitleWithImageAlignment:UIButtonTitleWithImageAlignmentDown];
        [offButton addTarget:self action:@selector(markOffline:) forControlEvents:UIControlEventTouchUpInside];
        offButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        offButton.titleLabel.minimumScaleFactor = 0.5;
        _offButton  = offButton;
    }
    return _offButton;
}

@end
