//
//  NXTimeServiceManager.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 11/20/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXTimeServerManager.h"
#import "NXGetUserPreferenceAPI.h"
#import "NXNetworkHelper.h"

static NXTimeServerManager *timeServerManager = nil;
@interface NXTimeServerManager()
@property(nonatomic, assign) NSTimeInterval jetlag;
@property(nonatomic, weak) NXGetUserPreferenceRequest *preReq;
@end

@implementation NXTimeServerManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timeServerManager = [[NXTimeServerManager alloc] init];
    });
    return timeServerManager;
}

- (instancetype)init {
    if (self = [super init]) {
        _state = NXTimeServerManagerStateNotSyncTime;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userChangeClock:) name:UIApplicationSignificantTimeChangeNotification object:nil];
    }
    return self;
}
- (NSDate *)currentServerTime {
    if (![[NXNetworkHelper sharedInstance] isNetworkAvailable]) { // Just for offline mode use
        return [NSDate date];
    }
    
    if (self.state != NXTimeServerManagerStateSyncedTime) {
        [self startSyncTimeWithTimeServer];
        return [NSDate date];
    }
    NSDate *localSystemDate = [NSDate date];
    NSTimeInterval localSystemTime = [localSystemDate timeIntervalSince1970];
    localSystemTime += self.jetlag;
    NSDate *currentServerTime = [NSDate dateWithTimeIntervalSince1970:localSystemTime];
    return currentServerTime;
}

- (void)startSyncTimeWithTimeServer {
    if (_state != NXTimeServerManagerStateSyncingTime) {
        _state = NXTimeServerManagerStateSyncingTime;
        WeakObj(self);
        NXGetUserPreferenceRequest *getUserPreference = [[NXGetUserPreferenceRequest alloc] init];
        self.preReq = getUserPreference;
        NSTimeInterval requestTime = [[NSDate date] timeIntervalSince1970];
        [getUserPreference requestWithObject:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
            StrongObj(self);
            if (self && self.state != NXTimeServerManagerStateSyncCancelled) {
                if (!error) {
                    NXGetUserPreferenceResponse *userPreferenceResponse = (NXGetUserPreferenceResponse *)response;
                    if (userPreferenceResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) {
                        NSTimeInterval responseTime = [[NSDate date] timeIntervalSince1970];
                        NSTimeInterval transferTime =  (responseTime - requestTime)/2; // we need take the network transfer time into conside
                        NSTimeInterval currentServerTime = userPreferenceResponse.serverTime + transferTime;
                        NSDate *localSystemDate = [NSDate date];
                        NSTimeInterval localSystemTime = [localSystemDate timeIntervalSince1970];
                        NSTimeInterval lagTime = currentServerTime - localSystemTime;
                        self.jetlag = lagTime;
                        _state = NXTimeServerManagerStateSyncedTime;
                    }else {
                        _state = NXTimeServerManagerStateNotSyncTime;
                    }
                }else {
                    _state = NXTimeServerManagerStateNotSyncTime;
                }
            }
        }];
    }
}

#pragma mark - Response to time change
- (void)userChangeClock:(NSNotification *)notification {
    
    if (![[NXLoginUser sharedInstance] isAutoLogin]) {
        [NXCommonUtils forceUserLogout];
        return;
    }
    
    if([NXLoginUser sharedInstance].isLogInState) {
        self.state = NXTimeServerManagerStateSyncCancelled;
        [self.preReq cancelRequest];
        [self startSyncTimeWithTimeServer];
    }
}

@end
