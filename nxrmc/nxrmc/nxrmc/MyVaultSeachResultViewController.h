//
//  MyVaultSeachResultViewController.h
//  nxrmc
//
//  Created by nextlabs on 1/4/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXSearchResultViewController.h"
#import "NXMyVaultFile.h"
#import "NXFileItemCell.h"

@class MyVaultSeachResultViewController;
@class NXOfflineFile;

@protocol NXMyVaultSearchResultDelegate <NSObject>

@required
- (void)myVaultFileListResultVC:(MyVaultSeachResultViewController *)resultVC didSelectItem:(NXMyVaultFile *)item;

@optional
- (void)swipeButtonClick:(SwipeButtonType)type fileItem:(NXFileBase *)fileItem;
- (void)accessButtonClickForFileItem:(NXFileBase *)fileItem;
- (void)offlineFileListResultVC:(MyVaultSeachResultViewController *)resultVC didSelectItem:(NXOfflineFile *)item;
@end

@protocol NXMyVaultResignActiveDelegate <NSObject>

- (void)searchVCShouldResignActive;

@end


@interface MyVaultSeachResultViewController : NXSearchResultViewController

@property (nonatomic,assign) id<NXMyVaultSearchResultDelegate> delegate;
@property (nonatomic,assign) BOOL isFromWorkSpace;
@end
