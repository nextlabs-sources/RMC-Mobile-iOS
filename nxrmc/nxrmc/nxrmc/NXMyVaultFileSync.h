//
//  NXMyVaultSync.h
//  nxrmc
//
//  Created by EShi on 12/30/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMyVaultFile.h"
@class NXMyVaultFileSync;

@protocol NXMyVaultFileSyncDelegate <NSObject>
- (void)updateFiles:(NSArray *)fileList parentFolder:(NXFileBase *)parentFolder error:(NSError *) error fromMyVaultFileSync:(NXMyVaultFileSync *)myVaultSync;
@end


@interface NXMyVaultFileSync : NSObject
@property(nonatomic, readonly, assign) BOOL exited;
@property(nonatomic, weak) id<NXMyVaultFileSyncDelegate> delegate;
- (void)startSyncFromMyVaultFolder:(NXFileBase *)myVaultFolder;
- (void)stopSync;
@end
