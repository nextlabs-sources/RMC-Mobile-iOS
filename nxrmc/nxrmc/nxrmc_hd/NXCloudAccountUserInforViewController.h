//
//  NXCloudAccountUserInforViewController.h
//  nxrmc
//
//  Created by ShiTeng on 15/5/29.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXRMCDef.h"
@class NXRepositoryModel;
@class NXCloudAccountUserInforViewController;
@protocol NXCloudAccountUserInforViewControllerDelegate <NSObject>
-(void) cloudAccountUserInfoVCDidPressCancelBtn:(NXCloudAccountUserInforViewController *)cloudAccountInfoVC;
-(void) cloudAccountUserInfoDidAuthSuccess:(NSDictionary *) authInfo;
@end

@interface NXCloudAccountUserInforViewController : UIViewController

@property (nonatomic) ServiceType serviceBindType;
@property (nonatomic, copy) void (^dismissBlock)(BOOL);
@property (nonatomic, copy) void (^addRepoAccountFinishBlock)(NXRepositoryModel *repoModel,NSError *error);
@property (nonatomic, copy) void (^siteUrlEnterFinishedBlock)(NSString *);
@property (nonatomic, copy) NSString *repoName;
@property (nonatomic, copy) NSString *accountName;
@property (nonatomic, copy) NSString *repoId;
@property (nonatomic, assign) BOOL isReAuth;
@property(nonatomic, weak) id<NXCloudAccountUserInforViewControllerDelegate> delegate;

@end
