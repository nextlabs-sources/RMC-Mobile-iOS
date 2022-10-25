//
//  NXMyDriveViewController.h
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/9/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NXMyDriveFilesNavigatonVC.h"

@interface NXMyDriveViewController : UIViewController

@property(nonatomic, strong) NXMyDriveFilesNavigatonVC *fileListNav;
@property(nonatomic, assign, readonly) NSInteger currentPageIndex;

@end
