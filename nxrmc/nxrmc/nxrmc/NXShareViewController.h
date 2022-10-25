//
//  NXShareViewController.h
//  nxrmc
//
//  Created by nextlabs on 11/11/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NXFileOperationPageBaseVC.h"

@class NXFileBase;

@interface NXShareViewController : NXFileOperationPageBaseVC

@property(nonatomic, strong) NXFileBase *fileItem;
@property(nonatomic, strong) NXFileBase *folder;

@end
