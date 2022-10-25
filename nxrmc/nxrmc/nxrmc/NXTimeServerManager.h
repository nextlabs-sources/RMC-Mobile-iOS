//
//  NXTimeServiceManager.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 11/20/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, NXTimeServerManagerState){
    NXTimeServerManagerStateNotSyncTime = 0,
    NXTimeServerManagerStateSyncingTime,
    NXTimeServerManagerStateSyncedTime,
    NXTimeServerManagerStateSyncCancelled,
};

@interface NXTimeServerManager : NSObject
+ (instancetype)sharedInstance;
- (NSDate *)currentServerTime;
- (void)startSyncTimeWithTimeServer;

@property(nonatomic, assign) NXTimeServerManagerState state;
@end
