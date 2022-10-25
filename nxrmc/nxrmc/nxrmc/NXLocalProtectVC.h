//
//  NXLocalProtectVC.h
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/5/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXFileOperationPageBaseVC.h"
#import "NXPreviewFileView.h"

#import "NXRightsSelectView.h"
#import "NXRightsDisplayView.h"
#import "NXCustomTitleView.h"
@class NXFileBase;
extern NSString * const kFinishedDownloadFile;

typedef NS_ENUM(NSInteger,NXSelectRightsType) {
    NXSelectRightsTypeDigital,
    NXSelectRightsTypeClassification
};

@interface NXLocalProtectVC : NXFileOperationPageBaseVC
@property (nonatomic, assign) NXSelectRightsType currentType;
@property(nonatomic, weak) NXPreviewFileView *preview;
@property(nonatomic, weak, readonly) NXRightsSelectView *rightsSelectView;
@property(nonatomic, weak, readonly) NXRightsDisplayView *rightsDisplayView;
@property(nonatomic,strong) NXCustomTitleView *navTittleView;
@property(nonatomic, weak, readonly) UIButton *protectButton;

@property(nonatomic, strong) NXFileBase *fileItem;

- (void)cancelButtonClicked:(id)sender;
- (void)protect:(id)sender;
@end
