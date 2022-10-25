//
//  NXSharedFileCell.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 8/1/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXSharedFileCell.h"

#import "NXSharedWithMeFile.h"
#import "NXMyVaultFile.h"

#import "NXRMCDef.h"
#import "NXCommonUtils.h"

@implementation NXSharedFileCell

- (void)setModel:(NXFileBase *)model {
    [super setModel: model];
    
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
    
    if ([model isKindOfClass:[NXSharedWithMeFile class]]) {
        [self setSharedWithMe:(NXSharedWithMeFile *)model];
    }
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
    
    if ([self.model isKindOfClass:[NXSharedWithMeFile class]]) {
        self.rightButtons = @[];
    } else {
        self.rightButtons = @[logButton, manageButton];
    }
}

#pragma mark
- (void)setSharedWithMe:(NXSharedWithMeFile *)fileItem {
    NSString *imageName = [NXCommonUtils getImagebyExtension:fileItem.name];
    self.mainImageView.image = [UIImage imageNamed:imageName];
    
    NSDateFormatter* dateFormtter = [[NSDateFormatter alloc] init];
    [dateFormtter setDateFormat:@"dd MMM yyyy, HH:mm"];
    NSString* sharedDateString = [dateFormtter stringFromDate:[NSDate dateWithTimeIntervalSince1970:fileItem.sharedDate]];
    
    NSString *strSize = [NSByteCountFormatter stringFromByteCount:fileItem.size countStyle:NSByteCountFormatterCountStyleBinary];
    
    NSDictionary *attribtues = @{NSForegroundColorAttributeName:[UIColor blackColor]};
    self.mainTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:fileItem.name attributes:attribtues];
    
    self.subSizeLabel.text = fileItem.size ? strSize :@"";
    self.subDateLabel.text = sharedDateString;
    
    self.subSharedOnLabel.text = fileItem.sharedBy;
    
    [self setSwipeButtons];
}

@end
