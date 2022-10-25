//
//  NXVersionManager.m
//  nxrmc
//
//  Created by helpdesk on 5/1/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXVersionManager.h"
#import "NXFeasibleVersionAPI.h" 
#import "AppDelegate.h"
#include "NXNewestVersionAPI.h"
@implementation NXVersionManager

+ (void)hintUpdateNewVersion {
    NSDictionary *infoDic = [[NSBundle mainBundle]infoDictionary];
    NSString *currentVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
    NXNewestVersionAPIRequest *request = [[NXNewestVersionAPIRequest alloc]init];
    [request requestWithObject:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (!error) {
            NXNewestVersionAPIResponse *result = (NXNewestVersionAPIResponse *)response;
            NSString *latestVersion = result.version;
            if ([latestVersion compare:currentVersion] == NSOrderedDescending) {
                NSString *urlStr = nil;
                if (buildFromSkyDRMEnterpriseTarget) {
                    urlStr = @"https://apps.apple.com/cn/app/skydrm-pro/id1440353931";
                }else{
                    urlStr = @"https://apps.apple.com/cn/app/skydrm/id1148196131";
                }
                    dispatch_main_async_safe(^{
                        [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:NSLocalizedString(@"MSG_NEW_VERSION_DETECTED", nil) style: UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_UPDATE_NOW", nil) cancelActionTitle:NSLocalizedString(@"UI_UPDATE_NEXT_TIME", nil) OKActionHandle:^(UIAlertAction *action) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr] options:@{} completionHandler:^(BOOL success) {
                                
                            }];

                        } cancelActionHandle:^(UIAlertAction *action) {
                            
                        } inViewController:[UIApplication sharedApplication].delegate.window.rootViewController position:[UIApplication sharedApplication].delegate.window.rootViewController.view];
                    }
            )}
        }
    }];
}

@end
