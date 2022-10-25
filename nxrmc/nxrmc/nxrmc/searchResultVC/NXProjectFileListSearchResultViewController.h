//
//  NXProjectFileListSearchResultViewController.h
//  nxrmc
//
//  Created by xx-huang on 17/02/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXSearchResultViewController.h"
#import "NXProjectModel.h"

@class NXProjectFileListSearchResultViewController;

@protocol NXProjectFileListSearchResultDelegate <NSObject>

@required

- (void)fileListResultVC:(NXProjectFileListSearchResultViewController *)resultVC didSelectItem:(NXFileBase *)item;
- (void)fileListResultVC:(NXProjectFileListSearchResultViewController *)resultVC deleteItem:(NXFileBase *)item;
- (void)fileListResultVC:(NXProjectFileListSearchResultViewController *)resultVC infoForItem:(NXFileBase *)item;
- (void)fileListResultVC:(NXProjectFileListSearchResultViewController *)resultVC propertyForItem:(NXFileBase *)item;
- (void)fileListResultVC:(NXProjectFileListSearchResultViewController *)resultVC accessForItem:(NXFileBase *)item;
@end


@interface NXProjectFileListSearchResultViewController : NXSearchResultViewController
@property(nonatomic, strong) NXProjectModel *searchProjet;
@property (nonatomic,assign) id<NXProjectFileListSearchResultDelegate> delegate;

@end
