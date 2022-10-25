//
//  NXProtectViewController.h
//  nxrmcUITest
//
//  Created by nextlabs on 11/10/16.
//  Copyright © 2016 zhuimengfuyun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NXFileOperationPageBaseVC.h"

@interface NXProtectViewController : NXFileOperationPageBaseVC

@property(nonatomic, strong) NXFileBase *fileItem;
@property(nonatomic, strong) NXFileBase *folder; // upload camera and library file into Repository folder when do protect operation.

@end
