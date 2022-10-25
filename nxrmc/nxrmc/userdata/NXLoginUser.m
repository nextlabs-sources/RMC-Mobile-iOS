//
//  LoginUser.m
//  nxrmc
//
//  Created by Kevin on 15/4/28.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import "NXLoginUser.h"
#import "NXLSDK.h"
#import "AppDelegate.h"
#import "NXCacheManager.h"
#import "NXCommonUtils.h"
#import "NXKeyChain.h"
#import "NXAddRepositoryAPI.h"
#import "NXRemoveRepositoryAPI.h"
#import "NXSyncRepoHelper.h"
#import "NXHeartbeatManager.h"
#import "NXUpdateRepositoryAPI.h"
#import "NXTimeServerManager.h"
#import "NXLogoutAPI.h"


static NXLoginUser* sharedObj = nil;
@interface NXLoginUser()
@property(readwrite, strong) NXLProfile* profile;
@end

@implementation NXLoginUser

+ (NXLoginUser *)sharedInstance {
    @synchronized(self) {
        if (sharedObj == nil) {
            sharedObj = [[super allocWithZone:nil] init];
        }
    }
    
    return sharedObj;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return nil;
}

#pragma mark 

- (NXLProfile *)profileWithUserinfo:(NSDictionary *)userInfo {
    
    NXLProfile *profile = [[NXLProfile alloc] init];
    
    if([NXLoginUser sharedInstance].profile.role){
        profile.role = [NXLoginUser sharedInstance].profile.role;
    }
    if ([NXLoginUser sharedInstance].profile.tenantPrefence) {
        profile.tenantPrefence = [NXLoginUser sharedInstance].profile.tenantPrefence;
    }
    NSString *tenantId = [userInfo objectForKey:@"tenantId"];
    profile.defaultTenantID = tenantId;
    NSMutableArray *memberships = [[NSMutableArray alloc]init];
    [[userInfo objectForKey:@"memberships"] enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NXLMembership *membership = [[NXLMembership alloc] init];
        membership.ID = [obj objectForKey:@"id"];
        membership.type = [obj objectForKey:@"type"];
        membership.tenantId = [obj objectForKey:@"tenantId"];
        membership.projectId = ((NSNumber *)[obj objectForKey:@"projectId"]);
        membership.tokenGroupName = [obj objectForKey:@"tokenGroupName"];
        if ([membership.tenantId isEqualToString:tenantId] && membership.type.integerValue == 0) {
            profile.individualMembership = membership;
        }
        if (membership.type.integerValue == 2) {
            profile.tenantMembership = membership;
        }
        [memberships addObject:membership];
    }];
    
    profile.rmserver = [NXCommonUtils currentRMSAddress];
    profile.memberships = memberships;
    NSNumber *userid = [userInfo objectForKey:@"userId"];
    profile.userId = [NSString stringWithFormat:@"%ld", userid.longValue];
    NSString *userName = [userInfo objectForKey:@"name"];
    profile.userName = [userName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    profile.ticket = [userInfo objectForKey:@"ticket"];
    profile.ttl = [userInfo objectForKey:@"ttl"];
    profile.email = [userInfo objectForKey:@"email"];
    profile.defaultTenant = [userInfo objectForKey:@"defaultTenant"];
    
    NSString *displayName = [userInfo objectForKey:@"displayName"];
    profile.displayName = [displayName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    profile.idpType = [userInfo objectForKey:@"idpType"];
    
    if ([userInfo objectForKey:@"preferences"]) {
        NSDictionary *preference = [userInfo objectForKey:@"preferences"];
        if ([preference objectForKey:@"profile_picture"]) {
            NSString *baseStrImage = [preference objectForKey:@"profile_picture"];
            NSInteger index = [baseStrImage rangeOfString:@"," options:NSBackwardsSearch].location;
            if (index == NSNotFound) {
                profile.avatar = nil;
            } else {
                profile.avatar = [baseStrImage substringFromIndex:index+1];
            }
        }
    }
    return profile;
}

- (void)loginWithUserinfo:(NSDictionary *)userInfo {
    [self loginWithUser:[self profileWithUserinfo:userInfo]];
}

- (void)updateUserinfo:(NSDictionary *)userInfo {
    if (![self isLogInState]) {
        return;
    }
    NXLProfile *profile = [self profileWithUserinfo:userInfo];
    self.profile.displayName = profile.displayName;
    self.profile.userName = profile.userName;
    self.profile.avatar = profile.avatar;
    if (profile.ticket) {
         self.profile.ticket = profile.ticket;
    }
    if (profile.ttl) {
        self.profile.ttl = profile.ttl;
    }
    
    [NXCommonUtils storeProfile:profile];
}

- (void)updateUserProfile:(NXLProfile *)profile
{
    if (![self isLogInState]) {
        return;
    }
    
    self.profile = profile;
    // update local store
    [NXCommonUtils storeProfile:profile];
    // update sdk
    [self.nxlOptManager updateProfile:profile];
}

- (void)loginWithUser:(NXLProfile *)profile {
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate setupCoreDataStack:profile];
    
    if (profile.defaultTenant) {
        [NXCommonUtils updateRMSTenant:profile.defaultTenant];
    }
    _myVault = [[NXMyVault alloc] initWithUserProfile:profile];
    _myProject = [[NXMyProjectManager alloc] initWithUserProfile:profile];
    _sharedFileManager = [[NXSharedFileManager alloc]initWithUserProfile:profile];
    _nxlOptManager = [[NXNXLOperationManager alloc] initWithNXProfile:profile];
    _workSpaceManager = [[NXWorkSpaceManager alloc]initWithUserProfile:profile];
    _profile = profile;
    [_myProject bootup];
    _favFileMarker = [[NXFileMarker alloc] init];
    _userPreferenceManager = [[NXUserPreferenceManager alloc] init];
    
    // save to key chain
    [NXCommonUtils storeProfile:profile];
    
    
    [self loadAllBoundServices];
    [_favFileMarker startSyncFavFromRMS];
    [_userPreferenceManager startSyncUserPreference];
    [[NXTimeServerManager sharedInstance] startSyncTimeWithTimeServer];
    
}
- (void)updateTenantPrefence:(NSDictionary *)dic {
    NXLTenantPrefence *tenantPrefence = [[NXLTenantPrefence alloc] initWithDictionaryFromRMS:dic];
    self.profile.tenantPrefence = tenantPrefence;
    [NXCommonUtils storeProfile:self.profile];
}

- (void)updateUserRole:(NSNumber *)role
{
    self.profile.role = role;
    [NXCommonUtils storeProfile:self.profile];
}

- (void)loadAllBoundServices {

    
    [[NXHeartbeatManager sharedInstance] start];
    _myRepoSystem = [[NXRepositorySysManager alloc] init];
    [_myRepoSystem bootupWithUserProfile:self.profile];
}

#pragma mark
- (void)logOut {
    NXLogoutRequest *logoutReq = [[NXLogoutRequest alloc] init];
    [logoutReq requestWithObject:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {

    }];
    
    [[NXHeartbeatManager sharedInstance] stop];
    
    [NXCommonUtils deleteProfile:self.profile];
    [self.myRepoSystem shutdown];
    [self.myProject shutDown];
    [self.favFileMarker stopSyncFavFromRMS];
    [self.userPreferenceManager stopSyncUserPreference];
    self.userPreferenceManager = nil;
    _profile = nil;
    [self.nxlOptManager signOut:nil];
    
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate cleanUpCoreDataStack];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NXRMC_LOG_OUT object:self];
}

- (BOOL)isLogInState {
    if (self.profile) {
        return YES;
    }
    return NO;
}

- (BOOL)isAutoLogin {
    
    NSArray *profiles = [NXCommonUtils getStoredProfiles];
    if (profiles.count == 0) {
        return  NO;
    }
    NXLProfile *profile = [profiles objectAtIndex:0];
    //is session time out.
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    if (profile.ttl.doubleValue - timeInterval * 1000  > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isProjectAdmin
{
    NSArray *profiles = [NXCommonUtils getStoredProfiles];
    assert(profiles.count > 0);
    _profile = [profiles objectAtIndex:0];
    
    if (!_profile.role) {
        return NO;
    }
    
    return (_profile.role.longLongValue & NXL_USER_ROLE_PROJECT_ADMIN) != 0 ? YES : NO;
}

- (BOOL)isTenantAdmin
{
    NSArray *profiles = [NXCommonUtils getStoredProfiles];
    assert(profiles.count > 0);
    _profile = [profiles objectAtIndex:0];
    
    if (!_profile.role) {
        return NO;
    }
    return (_profile.role.longLongValue & NXL_USER_ROLE_TENANT_ADMIN) != 0 ? YES : NO;
}

- (void) loadUserAccountData
{
    NSArray *profiles = [NXCommonUtils getStoredProfiles];
    assert(profiles.count > 0);
    _profile = [profiles objectAtIndex:0];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate setupCoreDataStack:_profile];
    
    _nxlOptManager = [[NXNXLOperationManager alloc] initWithNXProfile:_profile];
    _myVault = [[NXMyVault alloc] initWithUserProfile:_profile];
    _myProject = [[NXMyProjectManager alloc] initWithUserProfile:_profile];
    _sharedFileManager = [[NXSharedFileManager alloc]initWithUserProfile:_profile];
    _favFileMarker = [[NXFileMarker alloc] init];
    _userPreferenceManager = [[NXUserPreferenceManager alloc] init];
    _workSpaceManager = [[NXWorkSpaceManager alloc]init];
    
    [_myProject bootup];
    [self loadAllBoundServices];
    [_favFileMarker startSyncFavFromRMS];
    [_userPreferenceManager startSyncUserPreference];
    [[NXTimeServerManager sharedInstance] startSyncTimeWithTimeServer];
    
}

@end
