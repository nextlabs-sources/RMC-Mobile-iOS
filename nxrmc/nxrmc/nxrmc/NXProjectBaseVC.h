//
//  NXProjectBaseVC.h
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/8/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NXProjectModel;
@interface NXProjectBaseVC : UIViewController

@property(nonatomic, strong) NXProjectModel *projectModel;

- (void)responseProjectModelUpdated:(NSNotification *)notification;
@end
