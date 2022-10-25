//
//  NXMyVaultCell.h
//  nxrmc
//
//  Created by nextlabs on 12/29/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MGSwipeTableCell.h"

#import "NXMyVaultFile.h"
#import "NXFileItemCellDelegate.h"
#import "NXFileItemCell.h"

@protocol NXMyVaultCellDelegate <NSObject>

- (void)onClickMoreButton:(NXMyVaultFile *)myVauleFile;

@end

typedef void(^ButtonClickBlock)(id sender);
//typedef void(^SwipeButtonBlock)(MyVaultCellSwipeButtonClickType type);

@interface NXMyVaultCell : MGSwipeTableCell

@property(nonatomic, weak, readonly) UIImageView *mainImageView;
@property(nonatomic, weak, readonly) UIImageView *fileStateImageView;
@property(nonatomic, weak) UIImageView *topImageView;
@property(nonatomic, weak) UIImageView *bottomImageView;

@property(nonatomic, weak, readonly) UILabel *mainTitleLabel;

@property(nonatomic, weak, readonly) UILabel *subSizeLabel;
@property(nonatomic, weak, readonly) UILabel *subDateLabel;

@property(nonatomic, weak, readonly) UILabel *subSharedOnLabel;
@property(nonatomic, weak, readonly) UILabel *subDrivePathLabel;

@property (nonatomic,weak, readonly) UIButton *moreButton;

@property(nonatomic, weak, readonly) UILabel *fileStateTipsLabel;

@property(nonatomic, strong) NXFileBase *model;

@property(nonatomic, copy) ButtonClickBlock accessBlock;
@property(nonatomic, copy) SwipeButtonBlock swipeButtonBlock;

@property(nonatomic, weak) id<NXFileItemCellDelegate> swipeDelegate;
@property(nonatomic, weak) id<NXMyVaultCellDelegate> myVaultCellDelegate;

- (void)updateCurrentLayoutForNormal;
- (void)updateCurrentLayoutForOffline;

@end
