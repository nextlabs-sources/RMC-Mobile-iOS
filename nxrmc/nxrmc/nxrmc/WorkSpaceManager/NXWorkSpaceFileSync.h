//
//  NXWorkSpaceFileSync.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/9/12.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NXFileBase;
@class NXWorkSpaceFileSync;
NS_ASSUME_NONNULL_BEGIN
@protocol NXWorkSpaceFileSyncDelegate <NSObject>
- (void)updateFiles:(NSArray *)fileList parentFolder:(NXFileBase *)parentFolder error:(NSError *) error fromWorkSpaceFileSync:(NXWorkSpaceFileSync *)myVaultSync;
@end
@interface NXWorkSpaceFileSync : NSObject
@property(nonatomic, readonly, assign) BOOL exited;
@property(nonatomic, weak) id<NXWorkSpaceFileSyncDelegate> delegate;
- (void)startSyncFromWorkSpaceFolder:(NXFileBase *)myVaultFolder;
- (void)stopSync;
@end

NS_ASSUME_NONNULL_END
