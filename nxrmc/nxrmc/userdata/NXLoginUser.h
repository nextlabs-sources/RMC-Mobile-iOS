//
//  LoginUser.h
//  nxrmc
//
//  Created by Kevin on 15/4/28.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NXRMCDef.h"
#import "NXRMCStruct.h"
#import "NXFileBase.h"
#import "NXBoundService+CoreDataClass.h"
#import "NXMyVault.h"
#import "NXNXLOperationManager.h"
#import "NXRepositorySysManager.h"
#import "NXMyProjectManager.h"
#import "NXSharedFileManager.h"
#import "NXFileMarker.h"
#import "NXUserPreferenceManager.h"
#import "NXOfflineFileManager.h"
#import "NXWorkSpaceManager.h"
#import "NXLProfile.h"

@interface NXLoginUser : NSObject
@property(readonly, strong) NXLProfile* profile;
@property(nonatomic, strong) NXMyProjectManager *myProject;
@property(nonatomic, strong) NXRepositorySysManager *myRepoSystem;
@property(nonatomic, strong) NXMyVault *myVault;
@property(nonatomic, strong) NXNXLOperationManager *nxlOptManager;
@property(nonatomic, strong) NXSharedFileManager *sharedFileManager;
@property(nonatomic, strong) NXUserPreferenceManager *userPreferenceManager;
@property(nonatomic, strong) NXFileMarker *favFileMarker;
@property(nonatomic, strong) NXOfflineFileManager *offlineFileManager;
@property(nonatomic, strong) NXWorkSpaceManager *workSpaceManager;
+ (NXLoginUser*)sharedInstance;

- (void)loginWithUserinfo:(NSDictionary *)userInfo;
- (void)updateUserinfo:(NSDictionary *)userInfo;
- (void)updateUserProfile:(NXLProfile *)profile;
- (void)updateTenantPrefence:(NSDictionary *)dic;
- (void)updateUserRole:(NSNumber *)role;
//- (void)loginWithUser:(NXLProfile *)profile;
- (NXLProfile *)profileWithUserinfo:(NSDictionary *)userInfo;

- (void)logOut;
- (BOOL)isLogInState;
- (BOOL)isAutoLogin;
- (void)loadUserAccountData;

- (BOOL)isProjectAdmin;
- (BOOL)isTenantAdmin;

@end
