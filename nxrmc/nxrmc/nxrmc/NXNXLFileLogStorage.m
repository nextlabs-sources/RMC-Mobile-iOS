//
//  NXNXLFileStorage.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 10/10/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXNXLFileLogStorage.h"
#import "MagicalRecord.h"
#import "NXFileActivityLogAPI.h"
#import "NXNXLFileLog+CoreDataClass.h"
@implementation NXNXLFileLogModel
-(instancetype)initWithNXFileActivityLogModelDic:(NSDictionary*)dic {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}
- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[NXNXLFileLogModel class]]) {
        NXNXLFileLogModel *logModel = (NXNXLFileLogModel *)object;
        if ([logModel.deviceId isEqualToString:self.deviceId] && [logModel.accessTime isEqualToNumber:self.accessTime] && [logModel.operation isEqualToString:self.operation]) {
            return YES;
        }
        return NO;
    }
    return NO;
}

- (NSUInteger)hash {
    return [self.deviceId hash] ^ [self.accessTime hash] ^ [self.operation hash];
}
@end

@implementation NXNXLFileLogStorage
+ (NSArray *)searchFileLogs:(NSString *)duid sortBy:(NXSortOption)sortOpt searchString:(NSString *)searchString {
    NSMutableArray *retLogs = [[NSMutableArray alloc] init];
    if (duid) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"duid==%@ && (deviceId CONTAINS[cd] %@ || email CONTAINS[cd] %@ || operation CONTAINS[cd] %@)", duid, searchString, searchString, searchString];
        NSString *sortKey = @"accessTime";
        BOOL ascending = NO;
        switch (sortOpt) {
            case NXSortOptionNameAscending: {
                sortKey = @"email:YES,accessTime:NO";
                ascending = YES;
            }
                break;
            case NXSortOptionOperationAscending: {
                sortKey = @"operation:YES,accessTime:NO";
                ascending = YES;
            }
                break;
            case NXSortOptionDateDescending: {
                sortKey = @"accessTime";
                ascending = NO;
            }
                break;
            case NXSortOptionOperationResultAscending: {
                sortKey = @"accessResult:YES,accessTime:NO";
                ascending = YES;
            }
                break;
            default:
                break;
        }
        NSArray *logs = [NXNXLFileLog MR_findAllSortedBy:sortKey ascending:ascending withPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
        for (NXNXLFileLog *log in logs) {
            NXNXLFileLogModel *logModel = [[NXNXLFileLogModel alloc] init];
            logModel.duid = log.duid;
            logModel.email = log.email;
            logModel.accessResult = log.accessResult;
            logModel.accessTime = log.accessTime;
            logModel.deviceId = log.deviceId;
            logModel.deviceType = log.deviceType;
            logModel.name = log.name;
            logModel.operation = log.operation;
            logModel.activityData = log.activityData;

            NSNumber *time = (NSNumber *)logModel.accessTime;
            NSInteger minSecondsToSecond = 1000;
            long long publishLong = [time longLongValue]/minSecondsToSecond;
            NSDateFormatter *formatter =[[NSDateFormatter alloc]init];
            [formatter setDateStyle:NSDateFormatterMediumStyle];
            [formatter setDateStyle:NSDateFormatterShortStyle];
            //        [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
            [formatter setDateFormat:@"dd MMM yyyy, HH:mm"];
            NSDate *publishDate = [NSDate dateWithTimeIntervalSince1970:publishLong];
            logModel.accessTimeStr =[formatter stringFromDate:publishDate];
            
            NSString *agoTime = [NXCommonUtils timeAgoShortFromDate:publishDate];
            NSTimeInterval timeBetween = [publishDate timeIntervalSinceNow];
            NSTimeInterval oneDayAgo = -60*60*24;
            if (timeBetween>oneDayAgo) {
                logModel.accessTimeShortStr = agoTime;
            }else {
                NSDateFormatter *formatter =[[NSDateFormatter alloc]init];
                [formatter setDateStyle:NSDateFormatterMediumStyle];
                [formatter setDateStyle:NSDateFormatterShortStyle];
                //            [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                [formatter setDateFormat:@"dd MMM yyyy"];
                logModel.accessTimeShortStr =[formatter stringFromDate:publishDate];
            }
            [retLogs addObject:logModel];
        }
    }
    return retLogs;
}

+ (NSArray *)nxlFileLogs:(NSString *)duid sortBy:(NXSortOption)sortOpt {
    
    NSMutableArray *retLogs = [[NSMutableArray alloc] init];
    if (duid) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"duid==%@", duid];
        NSString *sortKey = @"accessTime";
        BOOL ascending = NO;
//        NXNXLFileLogSortOptByName,
//        NXNXLFileLogSortOptByOperation,
//        NXNXLFileLogSortOptByOptTime,
//        NXNXLFileLogSortOptByResult,
        switch (sortOpt) {
            case NXSortOptionNameAscending: {
                sortKey = @"email:YES,accessTime:NO";
                ascending = YES;
            }
                break;
            case NXSortOptionOperationAscending: {
                sortKey = @"operation:YES,accessTime:NO";
                ascending = YES;
            }
                break;
            case NXSortOptionDateDescending: {
                sortKey = @"accessTime";
                ascending = NO;
            }
                break;
            case NXSortOptionOperationResultAscending: {
                sortKey = @"accessResult:YES,accessTime:NO";
                ascending = YES;
            }
                break;
            default:
                break;
        }
        NSArray *logs = [NXNXLFileLog MR_findAllSortedBy:sortKey ascending:ascending withPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
        for (NXNXLFileLog *log in logs) {
            NXNXLFileLogModel *logModel = [[NXNXLFileLogModel alloc] init];
            logModel.duid = log.duid;
            logModel.email = log.email;
            logModel.accessResult = log.accessResult;
            logModel.accessTime = log.accessTime;
            logModel.deviceId = log.deviceId;
            logModel.deviceType = log.deviceType;
            logModel.name = log.name;
            logModel.operation = log.operation;
            logModel.activityData = log.activityData;
            NSNumber *time = (NSNumber *)logModel.accessTime;
            NSInteger minSecondsToSecond = 1000;
            long long publishLong = [time longLongValue]/minSecondsToSecond;
            NSDateFormatter *formatter =[[NSDateFormatter alloc]init];
            [formatter setDateStyle:NSDateFormatterMediumStyle];
            [formatter setDateStyle:NSDateFormatterShortStyle];
            //        [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
            [formatter setDateFormat:@"dd MMM yyyy, HH:mm"];
            NSDate *publishDate = [NSDate dateWithTimeIntervalSince1970:publishLong];
            logModel.accessTimeStr =[formatter stringFromDate:publishDate];
            
            NSString *agoTime = [NXCommonUtils timeAgoShortFromDate:publishDate];
            NSTimeInterval timeBetween = [publishDate timeIntervalSinceNow];
            NSTimeInterval oneDayAgo = -60*60*24;
            if (timeBetween>oneDayAgo) {
                logModel.accessTimeShortStr = agoTime;
            }else {
                NSDateFormatter *formatter =[[NSDateFormatter alloc]init];
                [formatter setDateStyle:NSDateFormatterMediumStyle];
                [formatter setDateStyle:NSDateFormatterShortStyle];
                //            [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                [formatter setDateFormat:@"dd MMM yyyy"];
                logModel.accessTimeShortStr =[formatter stringFromDate:publishDate];
            }
            [retLogs addObject:logModel];
        }
    }
    
    return retLogs;
}

+ (void)storeNXLFileLogs:(NSArray *)fileLogs {
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        for (NXNXLFileLogModel *logModel in fileLogs) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"duid==%@ && accessTime==%@ && operation==%@", logModel.duid, logModel.accessTime, logModel.operation];
            NSUInteger count = [NXNXLFileLog MR_countOfEntitiesWithPredicate:predicate inContext:localContext];
            if (count == 0) {
                NXNXLFileLog *log = [NXNXLFileLog MR_createEntityInContext:localContext];
                log.duid = logModel.duid;
                log.email = logModel.email;
                log.accessResult = logModel.accessResult;
                log.accessTime = logModel.accessTime;
                log.deviceId = logModel.deviceId;
                log.deviceType = logModel.deviceType;
                log.name = logModel.name;
                log.operation = logModel.operation;
                log.activityData = logModel.activityData;
            }
        }
    }];
}
+ (void)insertNXLFileLog:(NXNXLFileLogModel *)logModel {
    
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NXNXLFileLog *log = [NXNXLFileLog MR_createEntityInContext:localContext];
        log.duid = logModel.duid;
        log.email = logModel.email;
        log.accessResult = logModel.accessResult;
        log.accessTime = logModel.accessTime;
        log.deviceId = logModel.deviceId;
        log.deviceType = logModel.deviceType;
        log.name = logModel.name;
        log.operation = logModel.operation;
        log.activityData = logModel.activityData;
    }];
}
@end
