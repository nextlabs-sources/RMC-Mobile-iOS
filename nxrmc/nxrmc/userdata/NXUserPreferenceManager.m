//
//  NXUserPreferenceManager.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 11/8/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXUserPreferenceManager.h"
#import "NXGetUserPreferenceAPI.h"
#import "NXUpdateUserPreferenceAPI.h"
#import "NSString+NXExt.h"
#import "NXUserPreferenceStorage.h"
#import "NXLFileValidateDateModel.h"
#define SYNC_INTERVAL 10
@interface NXUserPreferenceManager()
@property(nonatomic, assign) NSTimeInterval lastOperationTimestamp;
@property(atomic, strong) NXUserPreference *preference;

@property(nonatomic, strong) NSThread *workThread;
@property(nonatomic, assign) BOOL shouldExitWorkThread;
@property(nonatomic, assign) BOOL isStarted;
@property(nonatomic, strong) NSTimer *workTimer;
@property(nonatomic, assign) NSTimeInterval lastOperationTimeStamp;
@property(nonatomic, assign) BOOL isWorkTimerFirstStart;

@end

@implementation NXUserPreferenceManager
- (instancetype)init {
    if (self = [super init]) {
        _preference = [NXUserPreferenceStorage getUserPreference];
        if (_preference == nil) {
            _preference = [[NXUserPreference alloc] init];
            // set to default value
            NSString *defaultWatermarkString = @" $(User) $(Break) $(Date) $(Time)";
            _preference.preferenceWatermark = [defaultWatermarkString parseWatermarkWords];
            _preference.preferenceFileValidateDate = [[NXLFileValidateDateModel alloc] initWithNXFileValidateDateModelType:NXLFileValidateDateModelTypeNeverExpire withStartTime:nil endTIme:nil];
            _isWorkTimerFirstStart = YES;
        }
    }
    return self;
}


- (NXUserPreference *)userPreference {
    return [self.preference copy];
}
- (void)updateUserPreference:(NXUserPreference *)userPreference completion:(void(^)(NSError *error))completion {
    self.lastOperationTimestamp = [[NSDate date] timeIntervalSince1970];
    NXUpdateUserPreferenceRequest *updateUserPreferenceReq = [[NXUpdateUserPreferenceRequest alloc] init];
    WeakObj(self);
    NSMutableDictionary *updateModel = [NSMutableDictionary dictionary];
    if (userPreference.preferenceFileValidateDate) {
        [updateModel setObject:userPreference.preferenceFileValidateDate forKey:kUserPreferenceExpireKey];
    }
    if (userPreference.preferenceWatermark) {
        [updateModel setObject:userPreference.preferenceWatermark forKey:kUserPreferenceWatermark];
    }
    [updateUserPreferenceReq requestWithObject:updateModel Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (error) {
            completion(error);
        }else if(response.rmsStatuCode != NXRMS_ERROR_CODE_SUCCESS){
            NSError *retError = [[NSError alloc] initWithDomain:NX_ERROR_USER_PERFERENCE_DOMAIN code:NXRMC_ERROR_CODE_UPDATE_USER_PERFERENCE_FAILED userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_UPDATE_USER_PREFERENCE_FAILE", nil)}];
            completion(retError);
        }else {
            StrongObj(self);
            if (self) {
                if (userPreference.preferenceFileValidateDate) {
                    self.preference.preferenceFileValidateDate = userPreference.preferenceFileValidateDate;
                    [NXUserPreferenceStorage updateUserValidateFileDate:self.preference.preferenceFileValidateDate];
                }
                if (userPreference.preferenceWatermark) {
                    self.preference.preferenceWatermark = userPreference.preferenceWatermark;
                    [NXUserPreferenceStorage updateUserWatermark:self.preference.preferenceWatermark];
                }
            }
            completion(nil);
        }
    }];
}

- (void)updateUserWatermark:(NSArray<NXWatermarkWord *> *)watermark completion:(void(^)(NSError *error))completion {
    NXUserPreference *updatePreference = [[NXUserPreference alloc] init];
    updatePreference.preferenceWatermark = watermark;
    [self updateUserPreference:updatePreference completion:^(NSError *error) {
        completion(error);
    }];
}

- (void)updateFileValidateDate:(NXLFileValidateDateModel *)validateDate completion:(void(^)(NSError *error))completion {
    NXUserPreference *updatePreference = [[NXUserPreference alloc] init];
    updatePreference.preferenceFileValidateDate = validateDate;
    [self updateUserPreference:updatePreference completion:^(NSError *error) {
        completion(error);
    }];
}


- (NSThread *)workThread {
    if (_workThread == nil) {
        _workThread = [[NSThread alloc] initWithTarget:self selector:@selector(workThreadEnterPoint:) object:nil];
        [_workThread start];
    }
    return _workThread;
}

- (void)workThreadEnterPoint:(id)__unused object {
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    do{
        @autoreleasepool {
            [runLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow: 1.0]];
            if (self.shouldExitWorkThread) {
                break;
            }
            [NSThread sleepForTimeInterval:2.0];
        }
    }while (true);
}

#pragma mark - Sync
- (void)startSyncUserPreference {
    if (!self.isStarted) {
        [self startTimer];
        self.isStarted = YES;
    }
}

- (void)stopSyncUserPreference {
    self.shouldExitWorkThread = YES;
    self.isStarted = NO;
    self.workThread = nil;
    [self.workTimer invalidate];
    self.lastOperationTimeStamp = 0;
}

- (void)startTimer
{
    [self performSelector:@selector(scheduleSyncTimer) onThread:self.workThread withObject:nil waitUntilDone:NO];
}

- (void)scheduleSyncTimer
{
//    NSLog(@"NXUserPreferenceManager start sync ++++++++++");
//    
    [self.workTimer invalidate];
    if (!self.shouldExitWorkThread) {
        self.workTimer = [NSTimer scheduledTimerWithTimeInterval:SYNC_INTERVAL target:self selector:@selector(syncUserPreferenceFromRMS:) userInfo:nil repeats:NO];
        if (_isWorkTimerFirstStart) {
            [self.workTimer fire];
            _isWorkTimerFirstStart = NO;
        }
    }
}

- (void)syncUserPreferenceFromRMS:(NSTimer *)timer {
    NSTimeInterval syncTimeStamp = [[NSDate date] timeIntervalSince1970];
    NXGetUserPreferenceRequest *userPreferenceReq = [[NXGetUserPreferenceRequest alloc] init];
    WeakObj(self);
    [userPreferenceReq requestWithObject:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        if (self) {
            if (syncTimeStamp < self.lastOperationTimestamp) {
                [self startTimer];
                return;
            }
            
            if (error) {
                [self startTimer];
                return;
            }
            NXGetUserPreferenceResponse *userPreferenceResponse = (NXGetUserPreferenceResponse *)response;
            if (userPreferenceResponse.rmsStatuCode != NXRMS_ERROR_CODE_SUCCESS) {
                [self startTimer];
            }else {
                NSString *localWatermarkString = [self.preference.preferenceWatermark translateIntoPolicyString];
                NSString *rmsWatermarkString = [userPreferenceResponse.watermarkPreference translateIntoPolicyString];
                
                if (![localWatermarkString isEqualToString:rmsWatermarkString]) { // update local
                    self.preference.preferenceWatermark = [rmsWatermarkString parseWatermarkWords];
                    // update local database
                    [NXUserPreferenceStorage updateUserWatermark:self.preference.preferenceWatermark];
                }
                
                if (![self.preference.preferenceFileValidateDate isEqual:userPreferenceResponse.validateDatePreference]) {
                    self.preference.preferenceFileValidateDate = userPreferenceResponse.validateDatePreference;
                    // update local database
                    [NXUserPreferenceStorage updateUserValidateFileDate:self.preference.preferenceFileValidateDate];
                }
                [self startTimer];
            }
        }
    }];
}
@end
