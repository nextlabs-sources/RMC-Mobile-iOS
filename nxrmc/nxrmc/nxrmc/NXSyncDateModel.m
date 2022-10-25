//
//  NXSyncDateModel.m
//  nxrmc
//
//  Created by nextlabs on 12/23/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXSyncDateModel.h"

#define kSyncDate @"kSyncDate"
#define kSyncFlag @"kSyncFlag"

@interface NXSyncDateModel ()

@end

@implementation NXSyncDateModel

- (instancetype)initWithDate:(NSDate *)date successed:(BOOL)syncSuccessed {
    if (self = [super init]) {
        self.syncDate = [date timeIntervalSince1970];
        self.syncSuccessed = syncSuccessed;
    }
    return self;
}

- (instancetype)initWithDaete:(NSTimeInterval)timeInterval successed:(BOOL)syncSuccessed {
    if (self = [super init]) {
        self.syncDate = timeInterval;
        self.syncSuccessed = syncSuccessed;
    }
    return self;
}

#pragma mark - NSCoding
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.syncDate = ((NSNumber *)[aDecoder decodeObjectForKey:kSyncDate]).doubleValue;
        self.syncSuccessed = ((NSNumber *)[aDecoder decodeObjectForKey:kSyncFlag]).boolValue;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSNumber numberWithDouble:self.syncDate] forKey:kSyncDate];
    [aCoder encodeObject:[NSNumber numberWithBool:self.isSyncSuccessed] forKey:kSyncFlag];
}

@end
