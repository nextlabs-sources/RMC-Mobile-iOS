//
//  NXFilePropertyVC.h
//  nxrmcUITest
//
//  Created by nextlabs on 11/9/16.
//  Copyright © 2016 zhuimengfuyun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NXFileOperationPageBaseVC.h"

#define kBottomCloseButtonHeight 40
@class NXFileBase;

@interface NXFilePropertyVC : NXFileOperationPageBaseVC

@property(nonatomic, strong) NXFileBase *fileItem;
@property(nonatomic, assign) BOOL shouldOpen;
@property(nonatomic, assign) BOOL isSteward;
@property(nonatomic, assign) BOOL isFromFavPage;

@end
