//
//  NXMetaData.h
//  nxrmc
//
//  Created by Kevin on 15/5/29.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXLProfile.h"
#import "NXLRights.h"

@interface NXLMetaData : NSObject

+ (BOOL)isNxlFile:(NSString *)path;

+ (void)encrypt:(NSString *)srcPath destPath:(NSString *)destPath clientProfile:(NXLProfile *)clientProfile complete:(void(^)(NSError *error, id appendInfo))finishBlock;
+ (void)decrypt:(NSString *)srcPath destPath:(NSString *)destPath clientProfile:(NXLProfile *)clientProfile complete:(void(^)(NSError *error))finishBlock;

+ (void)getFileType:(NSString *)path clientProfile:(NXLProfile *) clientProfile complete:(void(^)(NSString *type, NSError *error))finishBlock;

+ (void)getPolicySection:(NSString *)nxlPath clientProfile:(NXLProfile *) clientProfile complete:(void(^)(NSDictionary *policySection, NSError *error))finishBlock;
+ (void)addAdHocSharingPolicy:(NSString *)nxlPath
                     issuer:(NSString*)issuer
                       rights:(NXLRights*)rights
                timeCondition:(NSString *)timeCondition
                clientProfile:(NXLProfile *) clientProfile
                     complete:(void(^)(NSError *error))finishBlock;
+ (void)getOwner:(NSString *)nxlPath complete:(void(^)(NSString *ownerId, NSError *error))finishBlock;


+ (NSDictionary *)getTags: (NSString *)path error:(NSError **)error;
+ (BOOL)setTags:(NSDictionary *)tags forFile:(NSString *)path;

+ (NSString *)hmacSha256Token:(NSString *) token content:(NSData *) content;

+ (BOOL)getFileToken:(NSString *)nxlFile tokenDict:(NSDictionary **)tokenDict clientProfile:(NXLProfile *) clientProfile error:(NSError**)err;

+ (BOOL) getNxlFile:(NSString *) nxlFile duid:(NSString **) duid publicAgrement:(NSData **) pubAgr owner:(NSString **) owner ml:(NSString **) ml error:(NSError **) error;
@end
