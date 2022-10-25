//
//  NXWorkSpaceFileSearchResultVC.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/9/26.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXSearchResultViewController.h"

@class NXWorkSpaceFileSearchResultVC;
@class NXFileBase;
@protocol NXWorkSpaceFileListSearchResultDelegate <NSObject>

@required

- (void)fileListResultVC:(NXWorkSpaceFileSearchResultVC *)resultVC didSelectItem:(NXFileBase *)item;
- (void)fileListResultVC:(NXWorkSpaceFileSearchResultVC *)resultVC deleteItem:(NXFileBase *)item;
- (void)fileListResultVC:(NXWorkSpaceFileSearchResultVC *)resultVC infoForItem:(NXFileBase *)item;
- (void)fileListResultVC:(NXWorkSpaceFileSearchResultVC *)resultVC propertyForItem:(NXFileBase *)item;
- (void)fileListResultVC:(NXWorkSpaceFileSearchResultVC *)resultVC accessForItem:(NXFileBase *)item;
@end
@interface NXWorkSpaceFileSearchResultVC : NXSearchResultViewController
@property (nonatomic,assign) id<NXWorkSpaceFileListSearchResultDelegate> delegate;
@end


