//
//  NXProtectedFileListView.h
//  nxrmc
//
//  Created by Sznag on 2020/12/27.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NXFileBase;
NS_ASSUME_NONNULL_BEGIN
typedef void(^clickDetailFileCompletion)(NXFileBase *file);
@interface NXProtectedFileListView : UIView
@property(nonatomic, copy)clickDetailFileCompletion fileClickedCompletion;
- (instancetype)initWithFileList:(NSArray *)files;
@end

NS_ASSUME_NONNULL_END
