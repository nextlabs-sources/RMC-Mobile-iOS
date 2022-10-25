//
//  NXSyncDateModel.h
//  nxrmc
//
//  Created by nextlabs on 12/23/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NXSyncDateModel : NSObject<NSCoding>

@property(nonatomic, assign) NSTimeInterval syncDate;
@property(nonatomic, assign, getter=isSyncSuccessed, setter=syncSuccessed:) BOOL syncSuccessed;

- (instancetype)initWithDate:(NSDate *)date successed:(BOOL)syncSuccessed;
- (instancetype)initWithDaete:(NSTimeInterval)timeInterval successed:(BOOL)syncSuccessed;

@end
