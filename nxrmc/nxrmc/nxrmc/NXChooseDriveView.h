//
//  NXChooseDriveView.h
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/5/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXRMCDef.h"
typedef void(^ClickFileImageViewBlock)(id sender);
@interface NXChooseDriveView : UIView

@property(nonatomic, strong) NSString *promptMessage;
@property(nonatomic, strong) NSString *model;
@property(nonatomic, strong) NSString *fileName;
@property(nonatomic, assign) BOOL isHiddenSmallPreview;
@property(nonatomic, assign) BOOL isForNewFolder;
@property(nonatomic, assign, getter=isEnabled) BOOL enabled;
@property(nonatomic, copy) ClickActionBlock clickActionBlock;
@property(nonatomic, strong) UIImageView *fileImageView;
@property(nonatomic, strong) ClickFileImageViewBlock clickImageViewBlock;
@end
