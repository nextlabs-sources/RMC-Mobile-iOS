//
//  AppDelegate.h
//  nxrmc
//
//  Created by Kevin on 15/4/28.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DetailViewController.h"
#import "NXPrimaryNavigationController.h"

@class NXLProfile;
@protocol OIDAuthorizationFlowSession;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow * _Nullable window;
@property (strong, nonatomic) NXPrimaryNavigationController * _Nonnull primaryNavigationController;
@property(strong, nonatomic) NXFileBase* _Nullable pending3rdOpenFile;
@property(strong, nonatomic) NXFileBase* _Nullable pendingUniversalLinksShareWithMeFile;
@property(strong, nonatomic) NSString * _Nullable pendingUniversalLinksProjectId;
@property(nonatomic, assign) BOOL openThirdPartFileFirst;
@property(nonatomic, strong, nullable) id<OIDAuthorizationFlowSession> currentAuthorizationFlow;

- (void)showFileItem:(NXFileBase *_Nonnull)fileItem from:(UIViewController *_Nullable)vc withDelegate:(id<DetailViewControllerDelegate>_Nullable)delegate;
- (void)setupCoreDataStack:(NXLProfile *_Nonnull)userProfile;
- (void)cleanUpCoreDataStack;
@end

