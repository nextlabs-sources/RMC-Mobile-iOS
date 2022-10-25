//
//  NXFileActivityLogViewController.h
//  nxrmc
//
//  Created by helpdesk on 7/4/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXFileOperationPageBaseVC.h"

@class NXFileBase;
@interface NXFileActivityLogViewController : NXFileOperationPageBaseVC

@property(nonatomic, strong) NXFileBase *fileItem;

@end
