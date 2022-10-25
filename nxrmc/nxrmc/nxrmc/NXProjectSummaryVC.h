//
//  NXProjectSummaryVC.h
//  Demo
//
//  Created by Bill (Guobin) Zhang on 5/8/17.
//  Copyright © 2017 Bill (Guobin) Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NXProjectBaseVC.h"
@interface NXProjectSummaryVC : NXProjectBaseVC
@property (nonatomic, strong) NXProjectModel *configurationModel;
- (void)configureNavigationBarButtons;
@end
