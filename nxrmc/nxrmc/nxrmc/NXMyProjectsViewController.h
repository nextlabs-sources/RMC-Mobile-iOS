//
//  NXProjectsViewController.h
//  nxrmc
//
//  Created by nextlabs on 1/18/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NXProjectModel;
@interface NXMyProjectsViewController : UIViewController

@property(nonatomic, assign) BOOL showGoToSpace;//
- (instancetype)initWithExceptModel:(NXProjectModel *)projectModel;
@end
