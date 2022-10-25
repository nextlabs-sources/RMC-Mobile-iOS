//
//  NXMarkFileAsOfflineCombinedOperation.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2018/8/10.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import "NXMarkFileAsOfflineCombinedOperation.h"
#import "NXOfflineFileManager.h"
#import "NXOfflineFile.h"
#import "NXOfflineFileStorage.h"
#import "NXCommonUtils.h"
#import "NXTimeServerManager.h"
#import "NXSharedWithMeFile.h"
#import "NXLFileValidateDateModel.h"
#import "NXLRights.h"
#import "NXWorkSpaceItem.h"
#import "NXSharedWithProjectFile.h"
@interface NXMarkFileAsOfflineCombinedOperation()

@property(nonatomic,strong) NXFileBase *file;
@property(nonatomic,strong) NSString *downloadOptIdentify;
@property(nonatomic,strong) NSString *queryRightsOptIdentify;
@property(nonatomic,assign) NXFileBaseSorceType sourceType;
@property(nonatomic,copy) NSString *sourcePath;

@end

@implementation NXMarkFileAsOfflineCombinedOperation

#pragma -mark -init method

-(instancetype)initWithFile:(NXFileBase *)file
{
    self = [super init];
    if (self) {
        _file = file;
        if ([file isKindOfClass:[NXMyVaultFile class]]) {
            _sourceType = NXFileBaseSorceTypeMyVaultFile;
            _sourcePath = [NSString stringWithFormat:@"MyVault:%@",file.fullPath];
        }
        if ([file isKindOfClass:[NXProjectFile class]]) {
            _sourceType = NXFileBaseSorceTypeProject;
            _sourcePath = [NSString stringWithFormat:@"Project:%@",file.fullPath];
        }
        
        if ([file isKindOfClass:[NXSharedWithMeFile class]]) {
            _sourceType = NXFileBaseSorceTypeShareWithMe;
            _sourcePath = [NSString stringWithFormat:@"sharedWithMe:/%@",file.name];
        }
        
        if ([file isKindOfClass:[NXWorkSpaceFile class]]) {
           _sourceType = NXFileBaseSorceTypeWorkSpace;
           _sourcePath = [NSString stringWithFormat:@"WorkSpace:/%@",file.name];
        }
        
        if ([file isKindOfClass:[NXSharedWithProjectFile class]]) {
            _sourceType = NXFileBaseSorceTypeSharedWithProject;
            _sourcePath = [NSString stringWithFormat:@"Project:%@",file.name];
        }
        
        if ([file isKindOfClass:[NXOfflineFile class]]) {
            NXOfflineFile *offlineFile = (NXOfflineFile *)file;
            _sourceType = offlineFile.sorceType;
            _sourcePath = offlineFile.sourcePath;
        }
    }
    return self;
}

#pragma  -mark -override method

- (void)executeTask:(NSError **)error
{
   self.queryRightsOptIdentify = [[NXOfflineFileManager sharedInstance].offlineFileRightsManager queryRightsForFile:_file completed:^(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray<NXWatermarkWord *> *waterMarkWords, NSString *owner, BOOL isOwner, NSError *error) {
        
        if (self.isCancelled) {
            return;
        }
       BOOL isEncryptedByCenterPolicy = NO;
       if (classifications.count >= 1) {
           isEncryptedByCenterPolicy = YES;
       }
        //error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_ACCESS_DENY userInfo:nil];
        if (error) {
            // store a failed offline file into coredata  >>>>>>>>>>>>>>>>>>>>>>>>>>>>@_@
            NSString *fileKey = [NXCommonUtils fileKeyForFile:self.file];
            
            
            NXOfflineFile *newOfflineFile = [[NXOfflineFile alloc] init];
            newOfflineFile.duid = duid;
            newOfflineFile.markAsOfflineDate = [NSDate date];
            newOfflineFile.isCenterPolicyEncrypted = isEncryptedByCenterPolicy;
            newOfflineFile.fileKey = fileKey;
            newOfflineFile.state = NXFileStateOfflineFailed;
            newOfflineFile.sourcePath = self.sourcePath;
            newOfflineFile.sorceType = self.sourceType;
            
            [NXOfflineFileStorage insertNewOfflineFileItem:newOfflineFile];
            
            [self finish:error];
        }else {
            
            // step0. check file expire time >>>>>>>>>>>>>>>>>>>>>>>>>>>>@_@
            if (!isOwner) {
                NXLFileValidateDateModel *fileValidateDate = [rights getVaildateDateModel];
                if(fileValidateDate.type != NXLFileValidateDateModelTypeNeverExpire) {
                    NSDate *nowDate = [[NXTimeServerManager sharedInstance] currentServerTime];
                    if (nowDate == nil) {
                        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_DECRYPT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_NO_TIME_SERVER", nil)}];
                       [self finish:error];
                       return;
                    }
                    BOOL isValidateDate = [fileValidateDate checkInValidateDateRange:nowDate];
                    if (!isValidateDate) {
                        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_DECRYPT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_NO_ACCESS_RIGHT", nil)}];
                        [self finish:error];
                        return;
                    }
                }
            }
            
            // step1. check view right   >>>>>>>>>>>>>>>>>>>>>>>>>>>>@_@
            if (![rights ViewRight]) {
                  NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_DECRYPT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_NO_ACCESS_RIGHT", nil)}];
                    NSString *fileKey = [NXCommonUtils fileKeyForFile:self.file];
                    NXOfflineFile *newOfflineFile = [[NXOfflineFile alloc] init];
                    newOfflineFile.duid = duid;
                    newOfflineFile.markAsOfflineDate = [NSDate date];
                    newOfflineFile.isCenterPolicyEncrypted = isEncryptedByCenterPolicy;
                    newOfflineFile.fileKey = fileKey;
                    newOfflineFile.state = NXFileStateOfflineFailed;
                    newOfflineFile.sourcePath = self.sourcePath;
                    newOfflineFile.sorceType = self.sourceType;
                
                [NXOfflineFileStorage insertNewOfflineFileItem:newOfflineFile];
                [self finish:error];
                return;
            }
            
            // @Fix Bug 64428: Update last modify date every time.
            [[NXOfflineFileManager sharedInstance] updateLastModifyDate:self.file];
            
            // step2. download file   >>>>>>>>>>>>>>>>>>>>>>>>>>>>@_@
            WeakObj(self);
            NXWebFileDownloaderProgressBlock progressBlock = ^(int64_t receivedSize, int64_t totalCount, double fractionCompleted){
                DLog(@"mark as offline->Downloading: %lf", fractionCompleted);
            };
            self.downloadOptIdentify = [[NXOfflineFileManager sharedInstance].webFileManager downloadFile:(NXFileBase<NXWebFileDownloadItemProtocol>*)self.file withProgress:progressBlock isOffline:YES forOffline:YES completed:^(NXFileBase *file, NSData *fileData, NSError *error) {
                StrongObj(self);
                if (self && [self.file isEqual:file]) {
                    if (error) {
                        // store a failed offline file into coredata  >>>>>>>>>>>>>>>>>>>>>>>>>>>>@_@
                        NSString *fileKey = [NXCommonUtils fileKeyForFile:self.file];
                        BOOL isEncryptedByCenterPolicy = NO;
                        if (classifications.count >= 1) {
                            isEncryptedByCenterPolicy = YES;
                            NSLog(@"NXOfflineFileManager: cur file is encrypted by center policy");
                        }
                        
                        NXOfflineFile *newOfflineFile = [[NXOfflineFile alloc] init];
                        newOfflineFile.duid = duid;
                        newOfflineFile.markAsOfflineDate = [NSDate date];
                        newOfflineFile.isCenterPolicyEncrypted = isEncryptedByCenterPolicy;
                        newOfflineFile.fileKey = fileKey;
                        newOfflineFile.state = NXFileStateOfflineFailed;
                        newOfflineFile.sourcePath = self.sourcePath;
                        newOfflineFile.sorceType = self.sourceType;
                        
                        [NXOfflineFileStorage insertNewOfflineFileItem:newOfflineFile];
                        
                        [self finish:error];
                    }else{
                        self.file.localPath = file.localPath;
                        // step3. save token >>>>>>>>>>>>>>>>>>>>>>>>>>>>@_@
                        
                        [[NXOfflineFileManager sharedInstance].offlineFileTokenManager saveTokenForFile:self.file completedBlock:^(NXFileBase *file, NSError *error) {
                            
                            if (error) {
                                
                                // store a failed offline file into coredata  >>>>>>>>>>>>>>>>>>>>>>>>>>>>@_@
                                NSString *fileKey = [NXCommonUtils fileKeyForFile:self.file];
                                BOOL isEncryptedByCenterPolicy = NO;
                                if (classifications.count >= 1) {
                                    isEncryptedByCenterPolicy = YES;
                                    NSLog(@"NXOfflineFileManager: cur file is encrypted by center policy");
                                }
                                
                                NXOfflineFile *newOfflineFile = [[NXOfflineFile alloc] init];
                                newOfflineFile.duid = duid;
                                newOfflineFile.markAsOfflineDate = [NSDate date];
                                newOfflineFile.isCenterPolicyEncrypted = isEncryptedByCenterPolicy;
                                newOfflineFile.fileKey = fileKey;
                                newOfflineFile.state = NXFileStateOfflineFailed;
                                newOfflineFile.sourcePath = self.sourcePath;
                                newOfflineFile.sorceType = self.sourceType;
                                
                                [NXOfflineFileStorage insertNewOfflineFileItem:newOfflineFile];
                                
                                [self finish:error];
                            }else{
                                // step4. store new offline file into coredata  >>>>>>>>>>>>>>>>>>>>>>>>>>>>@_@
                                NSString *fileKey = [NXCommonUtils fileKeyForFile:self.file];
                                BOOL isEncryptedByCenterPolicy = NO;
                                if (classifications.count >= 1) {
                                    isEncryptedByCenterPolicy = YES;
                                    NSLog(@"NXOfflineFileManager: cur file is encrypted by center policy");
                                }
                                
                                NXOfflineFile *newOfflineFile = [[NXOfflineFile alloc] init];
                                newOfflineFile.duid = duid;
                                newOfflineFile.markAsOfflineDate = [NSDate date];
                                newOfflineFile.isCenterPolicyEncrypted = isEncryptedByCenterPolicy;
                                newOfflineFile.fileKey = fileKey;
                                newOfflineFile.state = NXFileStateOfflined;
                                newOfflineFile.sourcePath = self.sourcePath;
                                newOfflineFile.sorceType = self.sourceType;
                                
                                [NXOfflineFileStorage insertNewOfflineFileItem:newOfflineFile];
                                [self finish:nil];
                                NSLog(@"NXOfflineFileManager: %@ mark as offline success!!!!",self.file.name);
                            }
                        }];
                    }
                }
            }];
        }
    }];
}

- (void)workFinished:(NSError *)error
{
    if (self.markFileAsOfflineCompletedBlock) {
        self.markFileAsOfflineCompletedBlock(self.file, error);
    }
}

- (void)cancelWork:(NSError *)cancelError
{
    [[NXOfflineFileManager sharedInstance].offlineFileRightsManager cancelOperation:self.queryRightsOptIdentify];
    [[NXOfflineFileManager sharedInstance].webFileManager cancelDownload:self.downloadOptIdentify];
    
    if (self.markFileAsOfflineCompletedBlock){
        self.markFileAsOfflineCompletedBlock(self.file,cancelError);
    }
}

@end
