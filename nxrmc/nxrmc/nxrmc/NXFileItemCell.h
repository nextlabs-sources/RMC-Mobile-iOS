//
//  NXFileItemCell.h
//  nxrmcUITest
//
//  Created by nextlabs on 11/7/16.
//  Copyright © 2016 zhuimengfuyun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MGSwipeTableCell.h"
#import "NXFileItemCellDelegate.h"

typedef NS_ENUM(NSInteger, SwipeButtonType) {
    SwipeButtonTypeShare = 0,
    SwipeButtonTypeFavorite,
    SwipeButtonTypeOffline,
    SwipeButtonTypeProtect,
    SwipeButtonTypeDelete,
    SwipeButtonTypeActiveLog,
    SwipeButtonTypeInfo,
    SwipeButtonTypeManage
};

typedef void(^ButtonClickBlock)(id sender);
typedef void(^SwipeButtonBlock)(SwipeButtonType type);

@class NXFileBase;
@class NXFileItemCell;

@interface NXFileItemCell : MGSwipeTableCell

@property(nonatomic, weak, readonly) UIImageView *mainImageView;
@property(nonatomic, weak) UIImageView *topImageView;
@property(nonatomic, weak) UIImageView *bottomImageView;
@property(nonatomic, weak, readonly) UIImageView *fileStateImageView;

@property(nonatomic, weak, readonly) UILabel *mainTitleLabel;
@property(nonatomic, weak, readonly) UILabel *subTypeLabel;
@property(nonatomic, weak, readonly) UILabel *subSizeLabel;
@property(nonatomic, weak, readonly) UILabel *subDateLabel;
@property(nonatomic, weak, readonly) UILabel *fileStateTipsLabel;

@property(nonatomic, strong) NXFileBase *model;

@property(nonatomic, copy) ButtonClickBlock accessBlock;

@property(nonatomic, strong) UIButton *accessButton;

@property(nonatomic, copy) SwipeButtonBlock swipeButtonBlock;

@property(nonatomic, weak) id<NXFileItemCellDelegate> swipeDelegate;

@property(nonatomic, assign) BOOL shouldShowSwipe;


-(void)updateUIForNormal;
-(void)updateUIForOffline;

@end
