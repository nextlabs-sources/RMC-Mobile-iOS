//
//  NXNXLFileStorage.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 10/10/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXFileBase.h"
#import "NXFileSort.h"


typedef NS_ENUM(NSUInteger, NXNXLFileLogSortOpt) {
    NXNXLFileLogSortOptByName,
    NXNXLFileLogSortOptByOperation,
    NXNXLFileLogSortOptByOptTime,
    NXNXLFileLogSortOptByResult,
};

@interface NXNXLFileLogModel : NSObject
@property(nonatomic, strong) NSString *duid;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSNumber *accessTime;
@property(nonatomic, strong) NSString *email;
@property(nonatomic, strong) NSString *operation;
@property(nonatomic, strong) NSString *deviceType;
@property(nonatomic, strong) NSString *deviceId;
@property(nonatomic, strong) NSString *accessTimeStr;
@property(nonatomic, strong) NSString *accessResult;
@property(nonatomic, strong) NSString *activityData;
@property(nonatomic, strong) NSString *accessTimeShortStr;
-(instancetype)initWithNXFileActivityLogModelDic:(NSDictionary*)dic;
@end

@interface NXNXLFileLogStorage : NSObject
+ (NSArray *)nxlFileLogs:(NSString *)duid sortBy:(NXSortOption)sortOpt;
+ (NSArray *)searchFileLogs:(NSString *)duid sortBy:(NXSortOption)sortOpt searchString:(NSString *)searchString;
+ (void)storeNXLFileLogs:(NSArray *)fileLogs;
+ (void)insertNXLFileLog:(NXNXLFileLogModel *)logModel;
@end
