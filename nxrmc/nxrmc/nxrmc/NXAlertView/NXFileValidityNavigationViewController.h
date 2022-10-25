//
//  NXFileValidityNavigationViewController.h
//  Calender
//
//  Created by Stepanoval (Xinxin) Huang on 07/11/2017.
//  Copyright © 2017 NextLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXFileValidityDateChooseViewController.h"

@interface NXFileValidityNavigationViewController : UINavigationController

@property (nonatomic, strong) NXFileValidityWindow *fileValidityWindow;
@property (nonatomic, assign) CGFloat viewHeight;

@end
