//
//  NXFavoriteFileCell.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 22/08/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXFavoriteFileCell.h"
#import "NXSharedWithMeFile.h"
#import "NXMyVaultFile.h"

#import "NXRMCDef.h"
#import "NXCommonUtils.h"

@implementation NXFavoriteFileCell

- (void)setModel:(NXFileBase *)model {
    
    [super setModel:model];
    
    NSString *imageName = [NXCommonUtils getImagebyExtension:model.fullPath];
    self.mainImageView.image = [UIImage imageNamed:imageName];
    
    NSString *strSize = [NSByteCountFormatter stringFromByteCount:model.size countStyle:NSByteCountFormatterCountStyleBinary];
    NSDictionary *attribtues = @{NSForegroundColorAttributeName:[UIColor blackColor]};
    self.mainTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:model.name attributes:attribtues];
    
    NSDate *lastModifiedDate = [NSDate dateWithTimeIntervalSince1970:model.lastModifiedTime.longLongValue];
    NSDateFormatter* dateFormtter = [[NSDateFormatter alloc] init];
    [dateFormtter setDateFormat:@"dd MMM yyyy, HH:mm"];
    NSString *lastModifiedStr = [dateFormtter stringFromDate:lastModifiedDate];
    
    self.subSizeLabel.text = model.size ? strSize :@"N/A";
    if (self.model.lastModifiedTime.longLongValue == 0) {
         self.subDateLabel.text = @"N/A";
    }
    else
    {
        self.subDateLabel.text = lastModifiedStr;
    }
   
    self.subDrivePathLabel.text = [NSString stringWithFormat:@"%@:%@", model.serviceAlias, model.fullPath];
    self.topImageView.image = model.isFavorite ? [UIImage imageNamed:@"faved file"] : nil;
    [self.topImageView setHidden:NO];

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
            }
            else
            {
                 self.rightButtons = @[logButton,shareButton];
            }
        }
        else
        {
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

