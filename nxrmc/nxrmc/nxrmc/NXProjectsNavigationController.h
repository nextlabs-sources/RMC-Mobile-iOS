//
//  NXProtectsNavigationController.h
//  nxrmc
//
//  Created by nextlabs on 1/18/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NXProjectModel;
@interface NXProjectsNavigationController : UINavigationController

@property(nonatomic, strong) NXProjectModel *projectModel;

- (void)configureTitleView:(UIViewController *)vc;

@end
