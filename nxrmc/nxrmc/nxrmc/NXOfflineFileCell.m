//
//  NXOfflineFileCell.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2018/8/13.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import "NXOfflineFileCell.h"
#import "NXSharedWithMeFile.h"
#import "NXMyVaultFile.h"

#import "NXRMCDef.h"
#import "NXCommonUtils.h"
#import "NXOfflineFile.h"

@implementation NXOfflineFileCell

- (void)setModel:(NXOfflineFile *)model {
    
    if(!model){
        return;
    }
    
    [super setModel:model];
    
    NSString *imageName = [NXCommonUtils getImagebyExtension:model.name];
    self.mainImageView.image = [UIImage imageNamed:imageName];
    
    NSString *strSize = [NSByteCountFormatter stringFromByteCount:model.size countStyle:NSByteCountFormatterCountStyleBinary];
    NSDictionary *attribtues = @{NSForegroundColorAttributeName:[UIColor blackColor]};
    self.mainTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:model.name attributes:attribtues];
    
    NSDate *lastModifiedDate = model.lastModifiedDate;
    NSDateFormatter* dateFormtter = [[NSDateFormatter alloc] init];
    [dateFormtter setDateFormat:@"dd MMM yyyy, HH:mm"];
    NSString *lastModifiedStr = [dateFormtter stringFromDate:lastModifiedDate];
    
    self.subSizeLabel.text = model.size ? strSize :@"N/A";
    if (!model.markAsOfflineDate) {
        self.subDateLabel.text = @"N/A";
    }else{
        self.subDateLabel.text = lastModifiedStr;
    }
    if (model.sorceType == NXFileBaseSorceTypeMyVaultFile || model.sorceType == NXFileBaseSorceTypeShareWithMe){
         self.subDrivePathLabel.text = model.sourcePath;
    }
   
    self.topImageView.image = model.isFavorite ? [UIImage imageNamed:@"faved file"] : nil;
    //self.bottomImageView.image = model.isOffline ? [UIImage imageNamed:@"offline file"] : nil;
    
    NXFileState state = [[NXOfflineFileManager sharedInstance] currentState:model];
    switch (state) {
        case NXFileStateNormal:
            
            [self updateCurrentLayoutForNormal];
            [self.fileStateTipsLabel setHidden:YES];
            [self.fileStateImageView setHidden:YES];
            self.bottomImageView.image = nil;
            break;
        case NXFileStateOfflined:
        {
            [self updateCurrentLayoutForNormal];
            [self.fileStateTipsLabel setHidden:YES];
            [self.fileStateImageView setHidden:YES];
            self.bottomImageView.image = [UIImage imageNamed:@"offline file"];
        }
            break;
        case NXFileStateConvertingOffline:
        {
            [self updateCurrentLayoutForOffline];
            [self.fileStateTipsLabel setHidden:NO];
            [self.fileStateTipsLabel setText:@"Updating..."];
            [self.fileStateTipsLabel setTextColor:[UIColor colorWithRed:112.0/255.0 green:112.0/255.0 blue:113.0/255.0 alpha:1.0]];
            [self.fileStateImageView setHidden:NO];
            [self.fileStateImageView setImage:[UIImage imageNamed:@"Updating..."]];
            [self.bottomImageView setImage:[UIImage imageNamed:@"FileUpdating"]];
        }
            break;
        case NXFileStateOfflineFailed:
        {
            [self updateCurrentLayoutForOffline];
            [self.fileStateTipsLabel setHidden:NO];
            [self.fileStateTipsLabel setText:@"Error in downloading file"];
            [self.fileStateTipsLabel setTextColor:[UIColor colorWithRed:255.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0]];
            [self.fileStateImageView setHidden:NO];
            [self.fileStateImageView setImage:[UIImage imageNamed:@"fa-exclamation-triangle"]];
            [self.bottomImageView setImage:[UIImage imageNamed:@"FileUpdating"]];
        }
            break;
        default:
            break;
    }
    
    self.subSharedOnLabel.text = @"";
    [self setSwipeButtons];
}

- (void)setSwipeButtons {
    WeakObj(self);
    MGSwipeButton *logButton = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"UI_LOG",NULL) backgroundColor:RMC_SUB_COLOR callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
        StrongObj(self);
        self.swipeButtonBlock(SwipeButtonTypeActiveLog);
        return YES;
    }];
    logButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [logButton setButtonWidth:80.0];
    MGSwipeButton *manageButton = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"UI_MANAGE", NULL) backgroundColor:RMC_MAIN_COLOR callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
        StrongObj(self);
        self.swipeButtonBlock(SwipeButtonTypeManage);
        return YES;
    }];
    manageButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [manageButton setButtonWidth:80.0];
    
    NSString *extension = [self.model.name pathExtension];
    NSString *markExtension = [NSString stringWithFormat:@".%@", extension];
    MGSwipeButton *shareButton = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"UI_COM_SHARE", NULL) icon:nil backgroundColor:RMC_MAIN_COLOR callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
        StrongObj(self);
        self.swipeButtonBlock(SwipeButtonTypeShare);
        return YES;
    }];
    shareButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    
    BOOL isNXL = [markExtension compare:NXLFILEEXTENSION options:NSCaseInsensitiveSearch] == NSOrderedSame;
    BOOL isMyDrive = self.model.serviceType.integerValue == kServiceSkyDrmBox;
    if (isNXL && isMyDrive) {
        self.rightButtons = @[logButton, shareButton];
    } else if (isNXL && !isMyDrive) {
        if ([self.model isKindOfClass:[NXMyVaultFile class]]) {
            NXMyVaultFile *item = (NXMyVaultFile *)self.model;
            if (item.isShared == YES || item.isRevoked == YES) {
                self.rightButtons = @[logButton, manageButton];
            }else{
                self.rightButtons = @[logButton,shareButton];
            }
        } else if ([self.model isKindOfClass:[NXOfflineFile class]] ){
            self.rightButtons = @[];
        }
        else{
            self.rightButtons = @[logButton,shareButton];
        }
    } else {
        MGSwipeButton *protectButton = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"UI_COM_PROTECT", NULL) icon:nil backgroundColor:RMC_SUB_COLOR callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
            self.swipeButtonBlock(SwipeButtonTypeProtect);
            return YES;
        }];
        protectButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        self.rightButtons = @[protectButton, shareButton];
    }
}

@end

