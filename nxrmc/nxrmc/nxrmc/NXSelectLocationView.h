//
//  NXSelectLocationView.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/6/2.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class NXFileBase;
typedef void(^afterSelectFolderCompletion)(NXFileBase *fileBase,NSString *path);
@interface NXSelectLocationView : UIView
@property(nonatomic, copy)afterSelectFolderCompletion selectedCompletion;
@property(nonatomic, strong)NXFileBase *currentFile;
@property(nonatomic, strong)NXFileBase *selectedFolder;
@end

NS_ASSUME_NONNULL_END
