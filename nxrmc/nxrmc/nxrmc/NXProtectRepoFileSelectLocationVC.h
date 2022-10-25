//
//  NXProtectRepoFileSelectLocationVC.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/5/26.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class NXFileBase;
@interface NXProtectRepoFileSelectLocationVC : UIViewController
@property(nonatomic, strong)NXFileBase *fileItem;
@property(nonatomic, strong)NSArray *currentRepoFolderFiles;

@end

NS_ASSUME_NONNULL_END
