//
//  NXOperationVCTitleView.h
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/17/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXRMCDef.h"

@class NXFileBase;
@interface NXOperationVCTitleView : UIView
- (instancetype)initWithFrame:(CGRect)frame supportSortAndSearch:(BOOL) supportSortAndSearch;

@property(nonatomic, strong) NXFileBase *model;
@property(nonatomic, strong) NSString *operationTitle;
@property(nonatomic, assign) BOOL supportSortAndSearch;
@property(nonatomic, strong) ClickActionBlock backClickAction;
@property(nonatomic, strong) ClickActionBlock sortClickAction;
@property(nonatomic, strong) ClickActionBlock searchClickAction;
@end
