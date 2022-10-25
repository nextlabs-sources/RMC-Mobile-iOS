//
//  NXPreviewFileView.h
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/3/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXRMCDef.h"
#import "NXFileBase.h"

#import "NXFileBase.h"
typedef void(^ClickFileImageViewBlock)(id sender);
@interface NXPreviewFileView : UIView

@property(nonatomic, copy) ClickActionBlock changePathClick;

@property(nonatomic, strong) NSString *promptMessage;
@property(nonatomic, strong) NSString *savedPath; // file path which will show.
@property(nonatomic, strong) NXFileBase *fileItem;
@property(nonatomic, assign) BOOL enableReselect;
@property(nonatomic, assign, getter=isEnabled) BOOL enabled;
@property(nonatomic,copy) ClickFileImageViewBlock showPreviewClick;
@property(nonatomic, weak) id delegate;
- (void)showSmallPreImageView;
@end
@protocol NXPreviewFileViewDelegate <NSObject>

- (void)previewFileViewDidloadFileContent;

@end
