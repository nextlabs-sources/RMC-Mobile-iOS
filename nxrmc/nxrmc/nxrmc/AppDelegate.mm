//
//  AppDelegate.m
//  nxrmc
//
//  Created by Kevin on 15/4/28.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreData/CoreData.h>


#import "NXLoginNavigationController.h"
#import "NXMasterTabBarViewController.h"
#import "NXProjectTabBarController.h"
#import "NXLProfile.h"
#import "NXCommonUtils.h"
#import "NXLoginUser.h"
#import "NXFile.h"
#import "NXNetworkHelper.h"
#import "MobileApp.h"
#import "NXCacheManager.h"
#import "NXSyncHelper.h"
#import "NXCacheManager.h"
#import "NXKeyChain.h"
#import "NXVersionManager.h"
#import "AppAuth.h"
#import "ObjectiveDropboxOfficial.h"
#import "NXMBManager.h"
#import "MagicalRecord.h"
#import "NXTimeServerManager.h"
#import "NSURL+HTTPExt.h"
#import "NXGetTenantPreferenceAPI.h"
@interface AppDelegate ()
@property(nonatomic, assign) UIDeviceOrientation deviceOrientation;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [UINavigationBar appearance].tintColor = RMC_MAIN_COLOR;
    [UITabBar appearance].tintColor = RMC_MAIN_COLOR;
    [UITableView appearance].tintColor = RMC_MAIN_COLOR;
    if (@available(iOS 15.0, *)) {
        [UITableView appearance].sectionHeaderTopPadding = 0;
    }
    // Override point for customization after application launch.
    [[NXNetworkHelper sharedInstance] startNotifier];
    
    // listen to the net work statues change
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NetStatusChanged:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skyDRMLoginSuccess:) name:NOTIFICATION_SKYDRM_LOGIN_SUCCESS object:nil];
    
    // Locate ts3d.ttf font directory and pass to MobileApp
    NSString *ts3dFontPath = [[NSBundle mainBundle] pathForResource:@"ts3d" ofType:@"ttf"];
    NSString *fontDir = [ts3dFontPath stringByDeletingLastPathComponent];
    MobileApp::inst().setFontDirectory(fontDir.UTF8String);
    
    _deviceOrientation = [[UIDevice currentDevice] orientation];
    
    if ([NXCommonUtils isFirstTimeLaunching]) {
        // Clear up keychain if first init
        [NXKeyChain deleteAll];
    }
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    if (![NXLoginUser sharedInstance].isAutoLogin) {
        NXLoginNavigationController *nav = [[NXLoginNavigationController alloc] init];
        self.window.rootViewController = nav;
    } else {
        [[NXLoginUser sharedInstance] loadUserAccountData];
        NXPrimaryNavigationController *primaryNavigationController = [[NXPrimaryNavigationController alloc] init];
        self.window.rootViewController = primaryNavigationController;
        self.primaryNavigationController = primaryNavigationController;
    }
    [self.window makeKeyAndVisible];
    self.window.backgroundColor = RMC_MAIN_COLOR;
   //  Version compare
    [NXVersionManager hintUpdateNewVersion];
    
#ifdef DEBUG
//  get crash exception info
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);    

#endif
    return YES;
}
void UncaughtExceptionHandler(NSException *exception) {
    
    NSArray *symbols = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSString *exceptPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"Exception"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:exceptPath]) {
        
    } else {
        [fileManager createDirectoryAtPath:exceptPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *url = [NSString stringWithFormat:@"========exceptError info========\nname:%@\nreason:\n%@\ncallStackSymbols:\n%@",name,reason,[symbols componentsJoinedByString:@"\n"]];
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    NSString *dateTime = [formatter stringFromDate:nowDate];
    NSString *fileName = [NSString stringWithFormat:@"%@.txt",dateTime];
    NSString *path = [exceptPath stringByAppendingPathComponent:fileName];
    [url writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];

}
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler 
{
    _openThirdPartFileFirst = NO;
   
    NSString *currentRMSAddress = [NXCommonUtils currentRMSAddress];
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSURL *webUrl = userActivity.webpageURL;
        
        NSString *sharedWithMeUrlStr = [NSString stringWithFormat:@"/viewSharedFile"];
        NSString *invitationUrlStr = [NSString stringWithFormat:@"/invitation"];
        NSString *projectsUrlStr = [NSString stringWithFormat:@"/projects"];
        
        if ([webUrl.absoluteString containsString:currentRMSAddress]) {
            
            if ([webUrl.absoluteString containsString:sharedWithMeUrlStr]) {
                //open file
                NSString *transCode = [[NXCommonUtils getURLParameters:webUrl.absoluteString] objectForKey:@"c"];
                NSString *transId = [[NXCommonUtils getURLParameters:webUrl.absoluteString] objectForKey:@"d"];
                
                if (transId.length >0 && transCode.length > 0) {
                    [self openUniversalLinkSharedWithTransCode:transCode transId:transId];
                }
            }
            else if ([webUrl.absoluteString containsString:invitationUrlStr])
            {
                //open accept project page
                NSString *invitationId = [[NXCommonUtils getURLParameters:webUrl.absoluteString] objectForKey:@"id"];
                NSString *code = [[NXCommonUtils getURLParameters:webUrl.absoluteString] objectForKey:@"code"];
                
                if (invitationId.length >0 && code.length > 0 && [NXLoginUser sharedInstance].isLogInState) {
                    [self showProjectPendingInvitationWithInvitationId:invitationId code:code];
                }
            }
            else if ([webUrl.absoluteString containsString:projectsUrlStr])
            {
                //open project page
                NSArray *array1 = [webUrl.absoluteString componentsSeparatedByString:@"projects/"];
                NSArray *array2 = [array1.lastObject componentsSeparatedByString:@"/"];
                
                NSString *projectId = [array2 firstObject];
                
                if ([NXLoginUser sharedInstance].isLogInState) {
                    
                    if (projectId.length > 0) {
                        [NXMBManager showLoadingToView:self.window.rootViewController.view];
                        
                        [[NXLoginUser sharedInstance].myProject projectModelByProjectId:[NSNumber numberWithInt:projectId.intValue] withCompletion:^(NXProjectModel *projectModel, NSError *error) {
                            dispatch_main_async_safe(^{
                                [NXMBManager hideHUDForView:self.window.rootViewController.view];
                            });
                            
                            if (error == nil) {
                                dispatch_main_async_safe(^{
                                    [self openProjectPage:projectModel];});
                            }
                            else if(error.localizedDescription.length > 0)
                            {
                                dispatch_main_async_safe(^{
                                    [NXCommonUtils showAlertViewInViewController:self.window.rootViewController title:[NXCommonUtils currentBundleDisplayName] message:error.localizedDescription];
                                });
                            }
                        }];
                    }
                }
                else
                {
                    if (projectId.length > 0) {
                        self.pendingUniversalLinksProjectId = projectId;
                    }
                }
            }
            else
            {
                // safrai 打开
                [[UIApplication sharedApplication] openURL:webUrl options:@{} completionHandler:nil];
            }
        }
        else
        {
            // safrai 打开
            [[UIApplication sharedApplication] openURL:webUrl options:@{} completionHandler:nil];
        }
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url sourceApplication:(NSString *)source annotation:(id)annotation {
    
    if ([_currentAuthorizationFlow resumeAuthorizationFlowWithURL:url]) {
        _currentAuthorizationFlow = nil;
        return YES;
    }
    [self ipadToOpenThirdAppFile:url];
    
    // Add whatever other url handling code your app requires here
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    if ([url.scheme isEqualToString:RMS_CENTER_TOKEN_SCHEME]) {
        NSDictionary *params = [url parseURLParams];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REPO_AUTH_FINISHED object:nil userInfo:params];
        return YES;
    }
   
    [self ipadToOpenThirdAppFile:url];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    self.pendingUniversalLinksShareWithMeFile = nil;
    self.pendingUniversalLinksProjectId = nil;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [NXCommonUtils cleanTempFile];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if ([[NXLoginUser sharedInstance] isLogInState]) {
        [[NXTimeServerManager sharedInstance] startSyncTimeWithTimeServer];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (![[NXLoginUser sharedInstance] isAutoLogin]) {
        [[NXLoginUser sharedInstance] logOut];
        if (![self.window.rootViewController isKindOfClass:[NXLoginNavigationController class]]) {
            NXLoginNavigationController *nav = [[NXLoginNavigationController alloc] init];
            [UIApplication sharedApplication].keyWindow.rootViewController = nav;
        }
    }
    // update tenant preferences
    if ([[NXLoginUser sharedInstance] isLogInState]) {
        if (buildFromSkyDRMEnterpriseTarget && [NXCommonUtils isCompanyAccountLogin]) {
            NXGetTenantPreferenceAPIRequest *tenantPrefenceRequest = [[NXGetTenantPreferenceAPIRequest alloc]init];
            [tenantPrefenceRequest requestWithObject:[NXLoginUser sharedInstance].profile.defaultTenantID Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
                if (!error) {
                    NXGetTenantPreferenceAPIResponse *tenantResponse = (NXGetTenantPreferenceAPIResponse *)response;
                    if (tenantResponse.perenceDic) {
                        [[NXLoginUser sharedInstance] updateTenantPrefence:tenantResponse.perenceDic];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_WORKSPACE_STATE_UPDATE
                                                object:self];
                    });
                }
            }];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    // clean the tmp file
    [NXCommonUtils cleanTempFile];
    
    [[NXNetworkHelper sharedInstance] stopNotifier];
    
    // clean up magic record
    [MagicalRecord cleanUp];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - Split view
- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    if ([secondaryViewController isKindOfClass:[UINavigationController class]] && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[DetailViewController class]]) {
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
    } else {
        return NO;
    }
}

#pragma mark -------------core data------------------
-(void) setupCoreDataStack:(NXLProfile *)userProfile
{
    NSURL* storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"DB"];
    storeURL = [storeURL URLByAppendingPathComponent:userProfile.defaultTenant];
    storeURL = [storeURL URLByAppendingPathComponent:userProfile.userId];
    storeURL = [storeURL URLByAppendingPathComponent:@"rmc.sqlite"];
    NSLog(@"Sqlite store %@", storeURL);
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelOff];
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreAtURL:storeURL];
}

- (void)cleanUpCoreDataStack
{
    [MagicalRecord cleanUp];
}



- (NSURL*) applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark others

- (void) ipadToOpenThirdAppFile:(NSURL *) fileUrl
{
    NSURL *destUrl = [NXCacheManager getCacheUrlForOpenedInFile:fileUrl];
    NSError *error;
    NSData *fileData = [NSData dataWithContentsOfURL:fileUrl];
    if (fileData) {
        BOOL res = [fileData writeToURL:destUrl atomically:YES];
        if (!res) {
            NSLog(@"Copy inbox file out fail! scrUrl = %@ destUrl = %@, error is %@", fileUrl, destUrl, error);
            return;
        }
        
        NSError *err = nil;
        [[NSFileManager defaultManager] removeItemAtURL:fileUrl error:&err];
        if (err) {
                NSLog(@"Delete inbox file fail! scrUrl = %@ destUrl = %@, error is %@", fileUrl, destUrl, err);
        }
        
        NXFileBase *file = [NXCommonUtils fetchFileInfofromThirdParty:destUrl];
        if([NXLoginUser sharedInstance].isLogInState)
        {
            if (![self canOpenThirdPartyFile]) {
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NXCommonUtils currentBundleDisplayName] message:NSLocalizedString(@"MSG_OPEN_THIRD_FILE_DENY", NULL) preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"UI_BOX_OK", NULL) style:UIAlertActionStyleCancel handler:nil];
                [alertController addAction:cancelAction];
                
                return;
            }
            
            [self showFileItem:file from:nil withDelegate:nil];
            
        }else
        {
            // the user did not login, so store the url, we fileContentVC appear, it will check thirdAppFileURL
            self.pending3rdOpenFile = file;
            _openThirdPartFileFirst = YES;
        }
    }else{
        [NXMBManager showMessage:@"Fail to import file,please try again." hideAnimated:YES afterDelay:2.0];
    }
}

- (void)openUniversalLinkSharedWithTransCode:(NSString *)transCode transId:(NSString *)transId
{
    NXFileBase *file = [NXCommonUtils fetchFileInfofromUniversalLinksWithTransactionCode:transCode transactionId:transId];
    if([NXLoginUser sharedInstance].isLogInState)
    {
        if (![self canOpenThirdPartyFile]) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NXCommonUtils currentBundleDisplayName] message:NSLocalizedString(@"MSG_OPEN_THIRD_FILE_DENY", NULL) preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"UI_BOX_OK", NULL) style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:cancelAction];
            
            return;
        }
        
        [self showFileItem:file from:nil withDelegate:nil];
    }else
    {
       //the user did not login, so store the url, when fileContentVC appear, it will check universalLinksSharedWithMeFile
        self.pendingUniversalLinksShareWithMeFile = file;
    }
}

- (void)showProjectPendingInvitationWithInvitationId:(NSString *)InvitationId code:(NSString *)code
{
    if([NXLoginUser sharedInstance].isLogInState)
    {
        NXPendingProjectInvitationModel *model = [[NXPendingProjectInvitationModel alloc] init];
        model.invitationId = [NSNumber numberWithInteger:InvitationId.integerValue];
        model.code = code;
        
        WeakObj(self)
        [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:NSLocalizedString(@"MSG_PROJECT_INVATATION", nil)  style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"MSG_PROJECT_INVATATION_ACCEPT", nil) cancelActionTitle:NSLocalizedString(@"MSG_PROJECT_INVATATION_DECLINE", nil) OKActionHandle:^(UIAlertAction *action) {
            StrongObj(self)
            [NXMBManager showLoadingToView:self.window.rootViewController.view];
            [[NXLoginUser sharedInstance].myProject acceptProjectInvitation:model withCompletion:^(NXProjectModel *project, NSTimeInterval serverTime, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [NXMBManager hideHUDForView:self.window.rootViewController.view];
                    if (!error) {
                        [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_ACCEPT_INVITATION_SUCCESS", nil) toView:self.window.rootViewController.view hideAnimated:YES afterDelay:kDelay];
                        [[NSNotificationCenter defaultCenter] postNotificationName:NXPrjectInvitationNotifiy object:self userInfo:@{NXProjectInvitationsKey:model}];
                        
                    } else {
                        if (error.code == NXRMC_ERROR_CODE_PROJECT_INVITATION_MISMATCH) {
                            [NXCommonUtils showAlertViewInViewController:self.window.rootViewController title:[NXCommonUtils currentBundleDisplayName] message:error.localizedDescription?:NSLocalizedString(@"MSG_COM_INVITATION_MISMATCH", nil)];
                        }
                        else
                        {
                            NSString *errorMsg = NSLocalizedString(@"MSG_COM_FAILED", nil);
                            if (error.localizedDescription.length > 0) {
                                errorMsg = error.localizedDescription;
                            }
                            [NXMBManager showMessage:errorMsg toView:self.window.rootViewController.view hideAnimated:YES afterDelay:kDelay];
                        }
                    }
                });
            }];
            
        } cancelActionHandle:^(UIAlertAction *action) {
            StrongObj(self)
            [NXMBManager showLoadingToView:self.window.rootViewController.view];
            [[NXLoginUser sharedInstance].myProject declineProjectInvitation:model forReason:nil withCompletion:^(NXPendingProjectInvitationModel *pendingInvitation, NSTimeInterval serverTime, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [NXMBManager hideHUDForView:self.window.rootViewController.view];
                    if (!error) {
                        [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_DECLINE_INVITATION_SUCCESS", nil) toView:self.window.rootViewController.view hideAnimated:YES afterDelay:kDelay];
                        [[NSNotificationCenter defaultCenter] postNotificationName:NXPrjectInvitationNotifiy object:self userInfo:@{NXProjectInvitationsKey:model}];
                        
                    } else {
                        if (error.code == NXRMC_ERROR_CODE_PROJECT_INVITATION_MISMATCH) {
                            [NXCommonUtils showAlertViewInViewController:self.window.rootViewController title:[NXCommonUtils currentBundleDisplayName] message:error.localizedDescription];
                        }
                        else
                        {
                            NSString *errorMsg = NSLocalizedString(@"MSG_COM_DECLINE_INVITATION_FAILED", nil);
                            if (error.localizedDescription.length > 0) {
                                errorMsg = error.localizedDescription;
                            }
                            
                            [NXMBManager showMessage:errorMsg toView:self.window.rootViewController.view hideAnimated:YES afterDelay:kDelay];
                        }
                    }
                });
            }];
        }
        inViewController:self.window.rootViewController position:self.window.rootViewController.view];
    }
}

- (void)openProjectPage:(NXProjectModel *)projectModel {
    if (![NXLoginUser sharedInstance].isLogInState) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NXCommonUtils currentBundleDisplayName] message:NSLocalizedString(@"MSG_SIGN_IN_FIRST", NULL) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"UI_BOX_OK", NULL) style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        
        return;
    }
        if (![self canOpenThirdPartyFile]) {
        DLog();
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NXCommonUtils currentBundleDisplayName] message:NSLocalizedString(@"MSG_OPEN_THIRD_FILE_DENY", NULL) preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"UI_BOX_OK", NULL) style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:cancelAction];
            

        return;
    }
    
    if ([[UIApplication sharedApplication].keyWindow.rootViewController isKindOfClass:[NXPrimaryNavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        NXProjectTabBarController *tab = [[NXProjectTabBarController alloc] initWithProject:projectModel];
        tab.preTabBarController = nav.viewControllers.firstObject;
        tab.selectedIndex = 1;
        [nav pushViewController:tab animated:YES];
    }
}

// this function used to dismiss presentedViewcontroller when open third party file.
- (BOOL)canOpenThirdPartyFile {
    AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UIViewController *vc = app.window.rootViewController;
    if ([vc isKindOfClass:[NXPrimaryNavigationController class]]) {
        NXPrimaryNavigationController* nav = (NXPrimaryNavigationController *)vc;
        if ([[nav.viewControllers objectAtIndex:0] isKindOfClass:[NXMasterTabBarViewController class]]) {
            NXMasterTabBarViewController *masterTabViewController = [nav.viewControllers objectAtIndex:0];
            UIViewController *vc = masterTabViewController.selectedViewController;
            UINavigationController *nav;
            if ([vc isKindOfClass:[UINavigationController class]]) {
                nav = (UINavigationController*)vc;
                UIViewController *v = nav.topViewController.presentedViewController;
                if ([v isKindOfClass:[UINavigationController class]]) {
                    NSArray *array = ((UINavigationController *)v).viewControllers;//LiveAuthDialog6
                    if (array.count) {
                        if ([[array objectAtIndex:0] isKindOfClass:NSClassFromString(@"LiveAuthDialog")]) {
                                return NO;
                        }
                    }
                }
                [nav.topViewController.presentedViewController dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
    return YES;
}



- (void)showFileItem:(NXFileBase *)fileItem from:(UIViewController *)vc withDelegate:(id<DetailViewControllerDelegate>)delegate
{
    DetailViewController *detailVC = [[DetailViewController alloc] init];
    detailVC.delegate = delegate;
    [self.primaryNavigationController pushViewController:detailVC animated:YES];
    [detailVC openFile:fileItem];
}

- (NSUInteger) application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (![NXCommonUtils isiPad]) {
          return UIInterfaceOrientationMaskPortrait;
    }
    UIDeviceOrientation curOrientation = [[UIDevice currentDevice] orientation];
    if (_deviceOrientation != curOrientation) {
        _deviceOrientation = curOrientation;
    }
        
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - Observer
- (void) NetStatusChanged:(NSNotification *) notification
{
    if ([[NXNetworkHelper sharedInstance]  isNetworkAvailable] && [NXLoginUser sharedInstance].isLogInState) {
        [[NXSyncHelper sharedInstance] uploadPreviousFailedRESTRequestWithCachedURL:[NXCacheManager getSharingRESTCacheURL] mustAllSuccess:NO Complection:^(id object, NSError *error) {
            
        }];
        [[NXSyncHelper sharedInstance] uploadPreviousFailedRESTRequestWithCachedURL:[NXCacheManager getLogCacheURL] mustAllSuccess:NO Complection:^(id object, NSError *error) {
            ;
        }];
    }
}

- (void)skyDRMLoginSuccess:(NSNotification *) notification
{
    if (![[NXLoginUser sharedInstance] isAutoLogin]) {
        [NXCommonUtils forceUserLogout];
        return;
    }
    
    if (_openThirdPartFileFirst == YES) {
          [self showFileItem:self.pending3rdOpenFile from:nil withDelegate:nil];
        self.pending3rdOpenFile = nil;
        _openThirdPartFileFirst = NO;
        return;
    }
    
    if (self.pendingUniversalLinksShareWithMeFile) {
        
            WeakObj(self);
            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0/*延迟执行时间*/ * NSEC_PER_SEC));
            
            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
              
                StrongObj(self);
                
                if (![self canOpenThirdPartyFile]) {
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NXCommonUtils currentBundleDisplayName] message:NSLocalizedString(@"MSG_OPEN_THIRD_FILE_DENY", NULL) preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"UI_BOX_OK", NULL) style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:cancelAction];
                    
                    return;
                }
                
                [self showFileItem:self.pendingUniversalLinksShareWithMeFile from:nil withDelegate:nil];
                
                self.pendingUniversalLinksShareWithMeFile = nil;
            });
    }
    else if (self.pendingUniversalLinksProjectId) {
        if (self.pendingUniversalLinksProjectId.length > 0) {
            [NXMBManager showLoadingToView:self.window.rootViewController.view];
            
            [[NXLoginUser sharedInstance].myProject projectModelByProjectId:[NSNumber numberWithInt:self.pendingUniversalLinksProjectId.intValue] withCompletion:^(NXProjectModel *projectModel, NSError *error) {
                dispatch_main_async_safe(^{
                    [NXMBManager hideHUDForView:self.window.rootViewController.view];
                });
                
                if (error == nil) {
                    dispatch_main_async_safe(^{
                        [self openProjectPage:projectModel];});
                }
                else if(error.localizedDescription.length > 0)
                {
                    dispatch_main_async_safe(^{
                        [NXCommonUtils showAlertViewInViewController:self.window.rootViewController title:[NXCommonUtils currentBundleDisplayName] message:error.localizedDescription];
                    });
                }
            }];
        }
        self.pendingUniversalLinksProjectId = nil;
    }
}

- (void)redirectNSLogToDocumentFolder
{
    //如果已经连接Xcode调试则不输出到文件
    if(isatty(STDOUT_FILENO)) {
        return;
    }
    UIDevice *device = [UIDevice currentDevice];
    if([[device model] hasSuffix:@"Simulator"]){ //在模拟器不保存到文件中
        return;
    }
    //将NSlog打印信息保存到Document目录下的Log文件夹下
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Log"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:logDirectory];
    if (!fileExists) {
        [fileManager createDirectoryAtPath:logDirectory  withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; //每次启动后都保存一个新的日志文件中
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    NSString *logFilePath = [logDirectory stringByAppendingFormat:@"/%@.log",dateStr];
    // 将log输入到文件
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
    //未捕获的Objective-C异常日志
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
}


@end
@implementation NSURLRequest(DataController)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
    if (host) {
        return YES;
    }
    return NO;
}
@end
