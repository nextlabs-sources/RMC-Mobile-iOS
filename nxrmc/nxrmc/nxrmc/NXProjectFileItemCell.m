//
//  NXProjectFileItemCell.m
//  nxrmc
//
//  Created by EShi on 3/2/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectFileItemCell.h"

#import "NXProjectFile.h"
#import "NXProjectFolder.h"
#import "NXOfflineFileManager.h"
#import "Masonry.h"
#import "NXSharedWithProjectFile.h"
#import "NXLoginUser.h"
#import "NXRMCUIDef.h"
@interface NXProjectFileItemCell ()
@property(nonatomic, strong)UIButton *shareFromBtn;
@end
@implementation NXProjectFileItemCell
- (void)dealloc
{
}
- (UIButton *)shareFromBtn {
    if (!_shareFromBtn) {
        _shareFromBtn = [[UIButton alloc] init];
        [_shareFromBtn setImage:[[UIImage imageNamed:@"share - black"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_shareFromBtn setTitleColor:RMC_MAIN_COLOR forState:UIControlStateNormal];
        _shareFromBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _shareFromBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        _shareFromBtn.userInteractionEnabled = YES;
        [self.contentView addSubview:_shareFromBtn];
    }
    return _shareFromBtn;
}
- (void)setModel:(NXFileBase *)model {
    [super setModel:model];
    bool isShowShareFrom = NO;
    if ([model isKindOfClass:[NXSharedWithProjectFile class]]) {
        NSInteger idInteger = [((NXSharedWithProjectFile *)model).sharedByProject integerValue];
     NXProjectModel *projectModel =  [[NXLoginUser sharedInstance].myProject getProjectModelFromAllProjectForProjectId:[NSNumber numberWithInteger:idInteger]];
        if (projectModel) {
            isShowShareFrom = YES;
            [self.shareFromBtn setTitle:[NSString stringWithFormat:@" From Project %@",projectModel.name] forState:UIControlStateNormal];
        }
        
    
    }
    NXFileState state = [[NXOfflineFileManager sharedInstance] currentState:model];
    switch (state) {
        case NXFileStateNormal:
            if (isShowShareFrom) {
                [self updateUIForNormalForShareFromBtn];
            }else{
                [self updateUIForNormal];
            }
            
            [self.fileStateTipsLabel setHidden:YES];
            [self.fileStateImageView setHidden:YES];
            self.bottomImageView.image = nil;
            break;
        case NXFileStateOfflined:
        {
            if (isShowShareFrom) {
                [self updateUIForNormalForShareFromBtn];
            }else{
                [self updateUIForNormal];
            }
            [self.fileStateTipsLabel setHidden:YES];
            [self.fileStateImageView setHidden:YES];
            self.bottomImageView.image = [UIImage imageNamed:@"offline file"];
        }
            break;
        case NXFileStateConvertingOffline:
        {
            [self.fileStateTipsLabel setHidden:NO];
            [self.fileStateTipsLabel setText:@"Updating..."];
            [self.fileStateTipsLabel setTextColor:[UIColor colorWithRed:112.0/255.0 green:112.0/255.0 blue:113.0/255.0 alpha:1.0]];
            [self.fileStateImageView setHidden:NO];
            [self.fileStateImageView setImage:[UIImage imageNamed:@"Updating..."]];
            [self.bottomImageView setImage:[UIImage imageNamed:@"FileUpdating"]];
            if (isShowShareFrom) {
                [self updateUIForOfflineForShareFromBtn];
            }else{
                [self updateUIForOffline];
            }
        }
            break;
        case NXFileStateOfflineFailed:
        {
            [self.fileStateTipsLabel setHidden:NO];
            [self.fileStateTipsLabel setText:@"Error in downloading file"];
            [self.fileStateTipsLabel setTextColor:[UIColor colorWithRed:255.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0]];
            [self.fileStateImageView setHidden:NO];
            [self.fileStateImageView setImage:[UIImage imageNamed:@"fa-exclamation-triangle"]];
            [self.bottomImageView setImage:[UIImage imageNamed:@"FileUpdating"]];
            if (isShowShareFrom) {
                [self updateUIForOfflineForShareFromBtn];
            }else{
                [self updateUIForOffline];
            }
        }
            break;
        default:
            break;
    }
    
}
- (void)updateUIForNormalForShareFromBtn {
     [self.subTypeLabel setHidden:NO];
        [self.fileStateTipsLabel setHidden:YES];
        [self.fileStateImageView setHidden:YES];
        
        [self.mainImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.contentView).offset(16);
            make.height.equalTo(@(kFileIconWidth));
            make.width.equalTo(self.mainImageView.mas_height);
        }];
        
        [self.topImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mainImageView).offset(-4);
            make.right.equalTo(self.mainImageView).offset(4);
            make.width.equalTo(self.mainImageView).multipliedBy(0.5);
            make.height.equalTo(self.mainImageView.mas_width);
        }];
        
        [self.bottomImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mainImageView).offset(4);
            make.right.equalTo(self.mainImageView).offset(4);
            make.width.equalTo(self.mainImageView).multipliedBy(0.5);
            make.height.equalTo(self.bottomImageView.mas_width);
        }];
        
        [self.mainTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(kMargin);
            make.left.equalTo(self.mainImageView.mas_right).offset(12);
            make.right.equalTo(self.contentView).offset(-8);
        }];
        
        [self.subTypeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mainTitleLabel.mas_bottom).offset(kMargin);
            make.width.equalTo(@2);
            make.left.equalTo(self.mainTitleLabel);
        }];
        
        [self.subSizeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.subTypeLabel);
            make.left.equalTo(self.subTypeLabel.mas_right).offset(kMargin);
            make.height.equalTo(self.subTypeLabel);
        }];
        
        [self.subDateLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.subTypeLabel);
            make.right.equalTo(self.mainTitleLabel);
            make.height.equalTo(self.subTypeLabel);
            
        }];
        [self.shareFromBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.subTypeLabel.mas_bottom).offset(kMargin/4);
            make.left.equalTo(self.contentView).offset(60);
            make.height.equalTo(@15);
            make.bottom.equalTo(self.contentView).offset(-kMargin);
        }];
        
        [self.fileStateImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.shareFromBtn.mas_bottom);
            make.left.and.right.equalTo(self.mainTitleLabel);
            make.height.equalTo(@(1));
        }];
        
        [self.fileStateTipsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.shareFromBtn.mas_bottom);
            make.left.and.right.equalTo(self.mainTitleLabel);
            make.height.equalTo(@(1));
        }];
    
}
- (void)updateUIForOfflineForShareFromBtn {
    [self.subTypeLabel setHidden:YES];
       [self.fileStateTipsLabel setHidden:NO];
       [self.fileStateImageView setHidden:NO];
       
       [self.mainImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
           make.centerY.equalTo(self.contentView);
           make.left.equalTo(self.contentView).offset(16);
           make.height.equalTo(@(kFileIconWidth));
           make.width.equalTo(self.mainImageView.mas_height);
       }];
       
       [self.topImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
           make.top.equalTo(self.mainImageView).offset(-4);
           make.right.equalTo(self.mainImageView).offset(4);
           make.width.equalTo(self.mainImageView).multipliedBy(0.5);
           make.height.equalTo(self.mainImageView.mas_width);
       }];
       
       [self.bottomImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
           make.bottom.equalTo(self.mainImageView).offset(4);
           make.right.equalTo(self.mainImageView).offset(4);
           make.width.equalTo(self.mainImageView).multipliedBy(0.5);
           make.height.equalTo(self.bottomImageView.mas_width);
       }];
       
       [self.mainTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
           make.top.equalTo(self.contentView).offset(kMargin);
           make.left.equalTo(self.mainImageView.mas_right).offset(12);
           make.right.equalTo(self.contentView).offset(-8);
       }];
       
       [self.subSizeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
           make.top.equalTo(self.mainTitleLabel.mas_bottom).offset(kMargin/4);
           make.left.equalTo(self.mainTitleLabel);
//           make.bottom.equalTo(self.fileStateImageView.mas_top);
       }];
       
       [self.subDateLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
           make.top.equalTo(self.subSizeLabel);
           make.right.equalTo(self.mainTitleLabel);
//           make.bottom.equalTo(self.fileStateImageView.mas_top);
       }];
       [self.shareFromBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
           make.top.equalTo(self.subSizeLabel.mas_bottom).offset(kMargin/4);
           make.left.equalTo(self.contentView).offset(60);
           make.height.equalTo(@15);
           make.right.equalTo(self.mainTitleLabel);
       }];
       [self.fileStateImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
           make.top.equalTo(self.shareFromBtn.mas_bottom).offset(kMargin/2);
           make.left.equalTo(self.mainTitleLabel);
           make.width.height.equalTo(@(9));
           make.bottom.equalTo(self.contentView).offset(-kMargin/2);
           
       }];
       
       [self.fileStateTipsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
           make.top.equalTo(self.shareFromBtn.mas_bottom).offset(kMargin/2);
           make.left.equalTo(self.fileStateImageView).offset(14);
           make.right.equalTo(self.mainTitleLabel);
           make.height.equalTo(@10);
           make.bottom.equalTo(self.contentView).offset(-kMargin);
       }];
    
}
- (void)setProjectModel:(NXProjectModel *)projectModel
{
    _projectModel = projectModel;
//    [self setSwipeButtons];
    
    if ([self.model isKindOfClass:[NXProjectFolder class]] && [projectModel isOwnedByMe] == NO) {
        [self.accessButton setHidden:YES];
    }
    else
    {
        [self.accessButton setHidden:NO];
    }
}


- (void)setSwipeButtons {
//    MGSwipeButton *deleteButton = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"trash"] backgroundColor:[UIColor lightGrayColor]];
    MGSwipeButton *logButton = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"UI_LOG", NULL) backgroundColor:RMC_SUB_COLOR];
    logButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
//    deleteButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    if (self.projectModel.isOwnedByMe) {
//        self.leftButtons = @[deleteButton];
        if ([self.model isKindOfClass:[NXProjectFile class]]) {
            self.rightButtons = @[logButton];
        }
    }
}

- (BOOL)swipeTableCell:(nonnull MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion {
    if (direction == MGSwipeDirectionRightToLeft) {
        if (self.swipeButtonBlock) {
            if (index == 0) {
                self.swipeButtonBlock(SwipeButtonTypeActiveLog);
            }
        }
    }
    return YES;
}

@end
