//
//  NXRepoPageController.h
//  AlphaVC
//
//  Created by helpdesk on 7/11/16.
//  Copyright © 2016年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NXBoundService;
@interface NXRepoPageController : UIViewController
@property (nonatomic,assign) id delegate;
@end

@protocol NXRepoPageControllerDelegate <NSObject>

@required
- (void) serviceNXRepoPageVC:(NXRepoPageController*)viewCintroller didSelectServices:(NSArray*)servies;
- (void) serviceNXRepoPageVCDidSelectAddService:(NXRepoPageController*)tableView;
- (void) serviceNXRepoPageTableView:(NXRepoPageController*)viewController didSelectUnAuthedServer:(NXBoundService*)service;

@end
