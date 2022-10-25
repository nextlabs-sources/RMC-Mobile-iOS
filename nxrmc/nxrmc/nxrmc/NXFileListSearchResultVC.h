//
//  NXFileListSearchResultVC.h
//  nxrmc
//
//  Created by nextlabs on 1/10/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXSearchResultViewController.h"
#import "NXFileBase.h"
#import "NXFileItemCell.h"

@class NXFileListSearchResultVC;

@protocol NXFileListSearchResultDelegate <NSObject>


@required
- (void)fileListResultVC:(NXFileListSearchResultVC *)resultVC didSelectItem:(id)item;
@optional
- (void)swipeButtonClick:(SwipeButtonType)type fileItem:(NXFileBase *)fileItem;
- (void)accessButtonClickForFileItem:(NXFileBase *)fileItem;
@end

@interface NXFileListSearchResultVC : NXSearchResultViewController

@property (nonatomic,assign) id<NXFileListSearchResultDelegate> delegate;

@end
