//
//  NXOfflineFileRightsManager.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2018/8/9.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXFileBase.h"
#import "NXWatermarkWord.h"
#import "NXClassificationCategory.h"

@class NXLRights;

typedef void(^queryNXLFileRightsCompletedBlock)(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray<NXWatermarkWord *> *waterMarkWords, NSString *owner, BOOL isOwner, NSError *error);

@interface NXOfflineFileRightsManager : NSObject
- (NSString *)queryRightsForFile:(NXFileBase *)file completed:(queryNXLFileRightsCompletedBlock) completed;
- (NSString *)refreshRightsForFile:(NXFileBase *)file completed:(queryNXLFileRightsCompletedBlock) completed;
- (void)clearCachedRightsForFile:(NXFileBase *)file;
- (void)clearAllCachedRights;
- (void)cancelOperation:(NSString *)optID;
@end
