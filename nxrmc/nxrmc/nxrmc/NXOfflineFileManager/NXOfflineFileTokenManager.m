//
//  NXOfflineFileTokenHelper.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2018/8/9.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import "NXOfflineFileTokenManager.h"
#import "NXFileBase.h"
#import "NXLClient.h"
#import "NXRMCDef.h"
#import "NXLMetaData.h"
#import "NXLSDKDef.h"
#import "NXLoginUser.h"
#import "NXKeyChain.h"
#import "NSString+AES256.h"
#import "NSString+Codec.h"
#import "NXCommonUtils.h"
#import "NXNetworkHelper.h"
#import "NXQueryFileTokenOperation.h"
@interface NXOfflineFileTokenManager ()
@property (nonatomic, strong)NSMutableDictionary *getTokenOptDict;
@end
@implementation NXOfflineFileTokenManager
- (NSMutableDictionary *)getTokenOptDict {
    if (!_getTokenOptDict) {
        _getTokenOptDict = [NSMutableDictionary dictionary];
    }
    return _getTokenOptDict;
}

- (NSString *)saveTokenForFile:(NXFileBase *)file completedBlock:(saveTokenCompletedBlock)completedBlock{
    NSString *opterationId = [[NSUUID UUID] UUIDString];
    NXQueryFileTokenOperation *getTokenOpt = [[NXQueryFileTokenOperation alloc]initWithFile:file];
    [self.getTokenOptDict setObject:getTokenOpt forKey:opterationId];
    getTokenOpt.operationCompleted = ^(NXFileBase *file, NSString *token, NSError *tokeError) {
        if (!tokeError) {
            NSString *fileKey = [NXCommonUtils fileKeyForFile:file];
            [NXKeyChain save:fileKey data:[token AES256ParmEncryptWithKey:[fileKey MD5]]];
            if (completedBlock) {
                completedBlock(file,nil);
            }
        }else{
            if (completedBlock) {
                completedBlock(file,tokeError);
            }
        }
        [self.getTokenOptDict removeObjectForKey:opterationId];
    };
    [getTokenOpt start];
    return opterationId;
}

- (NSString *)getTokenForFile:(NXFileBase *)file completedBlock:(getTokenCompletedBlock)completedBlock {
   NSString *fileKey = [NXCommonUtils fileKeyForFile:file];
    if (![[NXNetworkHelper sharedInstance] isNetworkAvailable]) {
        NSString *cacheToken = [NXKeyChain load:fileKey];
        if (cacheToken) {
            NSString *token = [cacheToken AES256ParmDecryptWithKey:[fileKey MD5]];
            if (completedBlock) {
                completedBlock(token,file,nil);
            }
        }else{
            NSError *error = [[NSError alloc]initWithDomain:NX_ERROR_NXOFFLINEFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_NO_TOKEN userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_GET_FILE_TOKEN_FAILLED", NULL)}];
            if (completedBlock) {
                completedBlock(nil,file,error);
            }
        }
    } else {
        NSString *opterationId = [[NSUUID UUID] UUIDString];
        NXQueryFileTokenOperation *getTokenOpt = [[NXQueryFileTokenOperation alloc]initWithFile:file];
        [self.getTokenOptDict setObject:getTokenOpt forKey:opterationId];
        getTokenOpt.operationCompleted = ^(NXFileBase *file, NSString *token, NSError *tokeError) {
            if (completedBlock) {
                completedBlock(token,file,tokeError);
            }
            if (!tokeError) {
                NSString *fileKey = [NXCommonUtils fileKeyForFile:file];
                [NXKeyChain save:fileKey data:[token AES256ParmEncryptWithKey:[fileKey MD5]]];
            }
            [self.getTokenOptDict removeObjectForKey:opterationId];
        };
        [getTokenOpt start];
        return opterationId;
    }
    return nil;
}
- (NSString *)refreshTokenForFile:(NXFileBase *)file completedBlock:(refreshTokenCompletedBlock)completedBlock {
    NSString *opterationId = [[NSUUID UUID] UUIDString];
    NXQueryFileTokenOperation *getTokenOpt = [[NXQueryFileTokenOperation alloc]initWithFile:file];
    [self.getTokenOptDict setObject:getTokenOpt forKey:opterationId];
    getTokenOpt.operationCompleted = ^(NXFileBase *file, NSString *token, NSError *tokeError) {
        if (!tokeError) {
            NSString *fileKey = [NXCommonUtils fileKeyForFile:file];
            [NXKeyChain save:fileKey data:[token AES256ParmEncryptWithKey:[fileKey MD5]]];
            if (completedBlock) {
                completedBlock(file,nil);
            }
        }else{
            if (completedBlock) {
                completedBlock(file,tokeError);
            }
        }
        [self.getTokenOptDict removeObjectForKey:opterationId];
    };
    [getTokenOpt start];
    return opterationId;
}
- (void)deleteTokenForFile:(NXFileBase *)file {
    NSString *fileKey = [NXCommonUtils fileKeyForFile:file];
    [NXKeyChain delete:fileKey];
}
- (void)cancel:(NSString *)opertationId {
    if (!opertationId) {
        return;
    }
    NSOperation *opt = self.getTokenOptDict[opertationId];
    if (opt) {
        [opt cancel];
    }
    [self.getTokenOptDict removeObjectForKey:opertationId];
    
}

@end
