//
//  NXFileOperationPageBaseVC.h
//  nxrmc
//
//  Created by nextlabs on 11/18/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NXOperationVCTitleView.h"

@class NXFileBase;
@class NXFileOperationPageBaseVC;

@protocol NXOperationVCDelegate <NSObject>
@optional
- (void)viewcontroller:(NXFileOperationPageBaseVC *)vc didfinishedOperationFile:(NXFileBase *)file toFile:(NXFileBase *)resultFile;
- (void)viewcontroller:(NXFileOperationPageBaseVC *)vc didCancelOperationFile:(NXFileBase *)file;
- (void)viewcontrollerWillDisappear:(NXFileOperationPageBaseVC *)vc;
@end

@interface NXFileOperationPageBaseVC : UIViewController
- (instancetype)initWithSupportSortSearch:(BOOL)supportSortSearch sortClickCallBack:(ClickActionBlock)sortCallBack searchClickCallBack:(ClickActionBlock)searchCallBack;

@property(nonatomic, weak, readonly) UIScrollView *mainView;
@property(nonatomic, weak, readonly) UIView *bottomView;
@property(nonatomic, weak, readonly) NXOperationVCTitleView *topView;
@property(nonatomic, assign) BOOL showSortSearch;
@property(nonatomic, copy) ClickActionBlock sortCallBack;
@property(nonatomic, copy) ClickActionBlock searchCallBack;
@property(nonatomic, weak) id<NXOperationVCDelegate> delegate;

- (void)showTopView;
- (void)hideTopView;
@end
