//
//  NXOfflineFileTokenManager.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2018/8/9.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NXFileBase;
typedef void(^saveTokenCompletedBlock)(NXFileBase *file,NSError *error);
typedef void(^getTokenCompletedBlock)(NSString *token,NXFileBase *file,NSError *error);
typedef void(^refreshTokenCompletedBlock)(NXFileBase *file,NSError *error);
@interface NXOfflineFileTokenManager : NSObject
- (NSString *)saveTokenForFile:(NXFileBase *)file completedBlock:(saveTokenCompletedBlock)completedBlock;
- (NSString *)getTokenForFile:(NXFileBase *)file completedBlock:(getTokenCompletedBlock)completedBlock;
- (NSString *)refreshTokenForFile:(NXFileBase *)file completedBlock:(refreshTokenCompletedBlock)completedBlock;
- (void)deleteTokenForFile:(NXFileBase *)file;
- (void)cancel:(NSString *)opertationId;
@end
