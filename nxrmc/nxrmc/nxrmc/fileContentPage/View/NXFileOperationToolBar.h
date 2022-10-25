//
//  NXFileOperationToolBar.h
//  CoreAnimationDemo
//
//  Created by EShi on 11/3/16.
//  Copyright © 2016 Eren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXFile.h"

typedef NS_ENUM(NSInteger, NXFileOperationToolBarItemType)
{
    NXFileOperationToolBarItemTypeFavorite = 1000,
    NXFileOperationToolBarItemTypeOffline,
    NXFileOperationToolBarItemTypeProtect,
    NXFileOperationToolBarItemTypeShare,
    NXFileOperationToolBarItemTypeShow,
};

typedef NS_ENUM(NSInteger, NXFileOperationToolBarType)
{
    NXFileOperationToolBarTypeFileContent = 1,
    NXFileOperationToolBarTypeFileItem = 2,
};



#define FILE_TOOL_BAR_HEIGHT 45
#define FILE_TOOL_BAR_WIDTH 290
#define FILE_TOOL_BAR_SHOW_WIDTH 60

@class NXFileOperationToolBar;
@protocol NXFileOperationToolBarDelegate <NSObject>
@required
- (void)fileOperationToolBar:(NXFileOperationToolBar *)toolBar didSelectItem:(NXFileOperationToolBarItemType) type;
@end

@interface NXFileOperationToolBar : UIView
@property(nonatomic, assign, getter=isToolBarVisible) BOOL toolBarVisible;
@property(nonatomic, weak) id<NXFileOperationToolBarDelegate> delegate;
@property(nonatomic, strong) NXFile *file;
- (void)disappearToolBar;
- (void)showToolBar;
@property(nonatomic, strong) UIButton *btnShow;
- (instancetype) initWithFrame:(CGRect)frame type:(NXFileOperationToolBarType)type;;
- (instancetype) initWithFrame:(CGRect)frame file:(NXFile *)file type:(NXFileOperationToolBarType)type;
-(void) disableBtn:(NXFileOperationToolBarItemType) btnType;
-(void) enableBtn:(NXFileOperationToolBarItemType) btnType;
@end
