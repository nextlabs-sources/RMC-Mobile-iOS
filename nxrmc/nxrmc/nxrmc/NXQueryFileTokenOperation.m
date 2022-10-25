//
//  NXQueryFileTokenOperation.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2018/8/14.
//  Copyright © 2018年 nextlabs. All rights reserved.
//

#import "NXQueryFileTokenOperation.h"
#import "NXLoginUser.h"
#import "NXWebFileManager.h"
#import "NXOpenSSL.h"
#import "NXLMetaData.h"
#import "NXLClient.h"
#import "NXLTenant.h"


@interface NXQueryFileTokenOperation ()
@property(nonatomic, strong) NXFileBase *file;
@property(nonatomic, strong) NSString *fileToken;
@property(nonatomic, strong) NSString *operationId;
@end
@implementation NXQueryFileTokenOperation
- (instancetype)initWithFile:(NXFileBase *)file {
    self = [super init];
    if (self) {
        _file = file;
    }
    return self;
}
#pragma mark - Overwrite NXOperationBase
- (void)executeTask:(NSError *__autoreleasing *)error {
    _operationId = [((NXFile *)self.file) getNXLHeader:^(NXFileBase *file, NSData *fileData, NSError *error) {
        if (!error) {
            NSError *err = nil;
            NSDictionary *tokenInfoDict = nil;
            NSDictionary *sharedInfoDict = nil;
            if ([self.file isKindOfClass:[NXSharedWithProjectFile class]]) {
                sharedInfoDict = @{
                    @"sharedSpaceType": @1,
                    @"sharedSpaceId": ((NXSharedWithProjectFile *)file).sharedProject.projectId,
                    @"sharedSpaceUserMembership": ((NXSharedWithProjectFile *)file).sharedProject.membershipId
                };
            }
            [NXLMetaData getFileToken:file.localPath sharedInfo:sharedInfoDict tokenDict:&tokenInfoDict clientProfile:[NXLoginUser sharedInstance].profile error:&err];
            if (err) {
                [self finish:err];
            }else {
                if (tokenInfoDict && tokenInfoDict.count) {
                    NSString *token = tokenInfoDict.allValues.firstObject;
                    self.fileToken = token;
                    [self finish:nil];
                }else {
                    NSError *retError = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_DECRYPT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_GET_FILE_TOKEN_FAILLED", nil)}];
                    [self finish:retError];
                }
            }
        } else {
            [self finish:error];
        }
    }];
}
- (void)cancelWork:(NSError *)cancelError {
    [[NXWebFileManager sharedInstance] cancelDownload:self.operationId];
}
- (void)workFinished:(NSError *)error {
    if (self.operationCompleted) {
        self.operationCompleted(self.file, self.fileToken, error);
    }
}
@end
