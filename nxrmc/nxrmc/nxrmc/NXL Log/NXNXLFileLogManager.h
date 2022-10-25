//
//  NXNXLFileLogManager.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 10/11/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXNXLFileLogStorage.h"
#import "NXLogAPI.h"

@class NXNXLFileLogManager;
@protocol NXNXLFileLogManagerDelegate
- (void)nxNXLFileLogManager:(NXNXLFileLogManager *)nxFileLogManger duid:(NSString *)duid didUpdateLog:(NSArray *)activityLogs;
@end
typedef void(^NXNXLFileLogManagerGetNXLLogsCompletion)(NSArray *activityLogs, NSString *duid, NSError *error);

@interface NXNXLFileLogManager : NSObject
@property(nonatomic, weak) id<NXNXLFileLogManagerDelegate> delegate;
- (void)activityLogForFile:(NSString *)duid sortBy:(NXSortOption)sortType onlyLocalData:(BOOL)onlyLocalData withCompletion:(NXNXLFileLogManagerGetNXLLogsCompletion)completion;
- (void)insertNXLFileActivity:(NXLogAPIRequestModel *)logModel;
- (NSArray *)searchActivityLogForFile:(NSString *)duid sortBy:(NXSortOption)sortType searchString:(NSString *)searchString;
@end
