//
//  NXFileParser.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 7/12/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXFileParser.h"
#import "NXCommonUtils.h"
#import "NXWebFileManager.h"


// all supported file parse responder
#import "NXNormalFileParseResponder.h"
#import "NXMediaParseResponder.h"
#import "NXPDFParserResponder.h"
#import "NXSAPParserResponder.h"
#import "NXHoopsParseResponder.h"
#import "NXHeavyRemoteViewParserResponder.h"
#import "NXSimpleRemoteViewParseResponder.h"
#import "NX3DConvertParseResponder.h"
#import "NXOfflineFileManager.h"
#import "NXNetworkHelper.h"
#import "NXLRights.h"

@interface NXFileParser()
@property(nonatomic, strong) NSString *downloadOptIdentify;
@property(nonatomic, strong) NSString *tempNXLFilePath;
@property(nonatomic, strong) NXFileBase *fakeFile;  // This file base is stand for decrypt nxl file
@property(nonatomic, strong) NXFileParseResponder *fileParseResponder;
@property(nonatomic, strong) NXFileParseResponder *curFileParse;
@end


@implementation NXFileParser
- (void)setCurFileParse:(NXFileParseResponder *)curFileParse
{
    _curFileParse = curFileParse;
    if (curFileParse != nil) {
        self.fileContentType = _curFileParse.contentType;
    }
}

- (void)parseFile:(NXFileBase *)file
{
    if ([file isKindOfClass:[NXOfflineFile class]]) {
        NXOfflineFile *offlineFile = (NXOfflineFile *)file;
        if ([[NXOfflineFileManager sharedInstance] checkIsExpire:offlineFile]) {
            [self refreshOfflineFileMarkAsOfflineDateAndOpen:offlineFile];
            return;
        }else{
            self.curFile = file;
            [self processOfflineFile:offlineFile];
            return;
        }
    }
    
    NXFileState state = [[NXOfflineFileManager sharedInstance] currentState:file];
    if (state == NXFileStateOfflined) {
        NXOfflineFile *offlineFile = [[NXOfflineFileManager sharedInstance] getOfflineFilePartner:file];
        
        if (!offlineFile.name) {
            if(DELEGATE_HAS_METHOD(self.delegate, @selector(NXFileParser:didFinishedParseFile:resultView:error:))){
                              NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXOFFLINEFILE_DOMAIN code:NXRMC_ERROR_CODE_OFFLINE_FILE_EXPIRED_ERROR userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_OFFLINE_FILE_EXPIRED", nil)}];
                            [self.delegate NXFileParser:self didFinishedParseFile:file resultView:nil error:error];
                        }
                 
            return;
        }
        
     
        if (offlineFile) {
            if ([[NXOfflineFileManager sharedInstance] checkIsExpire:offlineFile]) {
                [self refreshOfflineFileMarkAsOfflineDateAndOpen:offlineFile];
                return;
            }
            self.curFile = offlineFile;
            [self processOfflineFile:offlineFile];
        }
        return;
    }
    
    NSString *fileExtension = [NXCommonUtils getFileExtensionByFileName:file];
    if([NXCommonUtils isTheSupportedFormat:fileExtension] || (file.serviceType == [NSNumber numberWithInteger:kServiceGoogleDrive] && [fileExtension isEqualToString:@""]) || file.sorceType == NXFileBaseSorceTypeShareWithMe || file.sorceType == NXFileBaseSorceTypeLocalFiles){
         // '(file.serviceType == [NSNumber numberWithInteger:kServiceGoogleDrive]' to support google file type without extension
        // share with me file has no extension 
        self.curFile = file;
        if((file.serviceType.integerValue == kServiceSkyDrmBox || [file isKindOfClass:[NXMyVaultFile class]]) && [NXCommonUtils isRemoteViewSupportFormat:fileExtension]){
            WeakObj(self);
            self.fileParseResponder = [[NXSimpleRemoteViewParseResponder alloc] init];
            [self.fileParseResponder parseFile:file withCompleteBlock:^(NXFileParseResponder *fileParseResponder, NXFileBase *file, UIView *renderView, NSError *error) {
                StrongObj(self);
                if (self && [self.curFile isEqual:file]) {
                    self.curFileParse = fileParseResponder;
                    NSString *extension = file.name.lastPathComponent;
                    BOOL isNXL = NO;
                    if ([extension compare:@"nxl" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                        isNXL = YES;
                    }
                    if (error) {
                        if (DELEGATE_HAS_METHOD(self.delegate, @selector(NXFileParser:didFinishedParseFile:resultView:error:))) {
                            if (isNXL) {
                                [self.delegate NXFileParser:self didFinishedParseNXLFile:self.curFile resultView:nil rights:nil isSteward:NO stewardID:nil error:error];
                            }else{
                                [self.delegate NXFileParser:self didFinishedParseFile:self.curFile resultView:nil error:error];
                            }
                        }
                    }else{
                        if (isNXL) {
                            [[NXLoginUser sharedInstance].nxlOptManager getNXLFileRights:self.curFile withWatermark:NO withCompletion:^(NSString *duid, NXLRights *rights,NSArray<NXClassificationCategory *> *classifications, NSArray *watermark, NSString *owner, BOOL isOwner, NSError *error) {
                                if (DELEGATE_HAS_METHOD(self.delegate, @selector(NXFileParser:didFinishedParseNXLFile:resultView:rights:isSteward:stewardID:error:))) {
                                    [self.delegate NXFileParser:self didFinishedParseNXLFile:self.curFile resultView:renderView rights:rights isSteward:isOwner stewardID:owner error:nil];
                                }
                            }];
                        }else{
                            if (DELEGATE_HAS_METHOD(self.delegate, @selector(NXFileParser:didFinishedParseFile:resultView:error:))) {
                                [self.delegate NXFileParser:self didFinishedParseFile:self.curFile resultView:renderView error:nil];
                            }
                        }
                    }
                }
            }];
            
        }else{  ///////////// from here, we need download first
            WeakObj(self);
            NXWebFileDownloaderProgressBlock progressBlock = ^(int64_t receivedSize, int64_t totalCount, double fractionCompleted){
                DLog(@"Downloading %lf", fractionCompleted);
            };
            self.downloadOptIdentify = [[NXWebFileManager sharedInstance] downloadFile:(NXFileBase<NXWebFileDownloadItemProtocol>*)self.curFile withProgress:progressBlock completed:^(NXFileBase *file, NSData *fileData, NSError *error) {
                StrongObj(self);
                if (self && [self.curFile isEqual:file]) {
                    if (error) {
                        if(DELEGATE_HAS_METHOD(self.delegate, @selector(NXFileParser:didFinishedParseFile:resultView:error:))){
                            [self.delegate NXFileParser:self didFinishedParseFile:file resultView:nil error:error];
                        }
                    }else{
                        self.curFile.localPath = file.localPath;
                        [self processDownloadedFile:file];
                    }
                }
            }];
        }
    }else{
        if(DELEGATE_HAS_METHOD(self.delegate, @selector(NXFileParser:didFinishedParseFile:resultView:error:))){
            NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_REPO_FILE_SYSTEM_DOMAIN code:NXRMC_ERROR_CODE_RENDER_FILE_NOT_SUPPORT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_HINT_USER_MESSAGE", nil)}];
            [self.delegate NXFileParser:self didFinishedParseFile:file resultView:nil error:error];
        }
    }
}

- (void)processOfflineFile:(NXOfflineFile *)file
{
    NSError *error = nil;
    self.isNXLFile = YES;
    NSString *destTempPath = [self getTempFilePathWithForFile:file error:&error];
     WeakObj(self);
    [[NXOfflineFileManager sharedInstance] decryptOfflineFile:file toPath:destTempPath withCompletion:^(NSString *filePath, NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSString *owner, BOOL isOwner, NSError *error) {
        StrongObj(self);
        if (self && [self.curFile isEqual:file]) {
            if (error) {
                if (file.sorceType == NXFileBaseSorceTypeShareWithMe && !file.name && file.localPath.length > 0) {
                    file.name = file.localPath.lastPathComponent;
                }
                
                if (DELEGATE_HAS_METHOD(self.delegate, @selector(NXFileParser:didFinishedParseFile:resultView:error:))) {
                    [self.delegate NXFileParser:self didFinishedParseNXLFile:file resultView:nil rights:nil isSteward:NO stewardID:nil error:error];
                }
            }else{
                self.fakeFile = [self.curFile copy];
                self.fakeFile.localPath = filePath;
                self.fakeFile.name = self.curFile.name;
                self.stewardID = owner;
                self.fileRights = rights;
                self.isSteward = isOwner;
                [self openNoEncryptedFile:self.fakeFile];
            }
        }
    }];
}

- (void)processDownloadedFile:(NXFileBase *)file
{
    // STEP1. check if is nxl, if nxl, decrypt
    if([[NXLoginUser sharedInstance].nxlOptManager isNXLFile:file]){
        self.isNXLFile = YES;
        NSError *error = nil;
        NSString *destTempPath = [self getTempFilePathWithForFile:file error:&error];
        WeakObj(self);
        [[NXLoginUser sharedInstance].nxlOptManager decryptNXLFile:file toPath:destTempPath withCompletion:^(NSString *filePath, NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSString *stewardID, BOOL isSteward, NSError *error) {
            StrongObj(self);
            if (self && [self.curFile isEqual:file]) {
                if (error) {
                    if (file.sorceType == NXFileBaseSorceTypeShareWithMe && !file.name && file.localPath.length > 0) {
                        file.name = file.localPath.lastPathComponent;
                    }
                    
                    if (DELEGATE_HAS_METHOD(self.delegate, @selector(NXFileParser:didFinishedParseFile:resultView:error:))) {
                        [self.delegate NXFileParser:self didFinishedParseNXLFile:file resultView:nil rights:nil isSteward:NO stewardID:nil error:error];
                    }
                }else{
                    self.fakeFile = [self.curFile copy];
                    self.fakeFile.localPath = filePath;
                    self.fakeFile.name = filePath.lastPathComponent;
                    self.stewardID = stewardID;
                    self.fileRights = rights;
                    self.isSteward = isSteward;
                    [self openNoEncryptedFile:self.fakeFile];
                }
            }
        }];
    }else{
        [self openNoEncryptedFile:file];
    }
}

- (void)openNoEncryptedFile:(NXFileBase *)normalFile{
    WeakObj(self);
    dispatch_main_async_safe(^{ // There back to main thread for we may operation on UI in the file parsse responder
        [self.fileParseResponder parseFile:normalFile withCompleteBlock:^(NXFileParseResponder *fileParseResponder, NXFileBase *file, UIView *renderView, NSError *error) {
            StrongObj(self);
            if (self && ([self.curFile isEqual:file] || [self.fakeFile isEqual:file])) {
                self.curFileParse = fileParseResponder;
                if (normalFile.sorceType == NXFileBaseSorceTypeShareWithMe && normalFile.localPath.lastPathComponent.length > 0) {
                    self.curFile.name = normalFile.localPath.lastPathComponent;
                }
                if (error) {
                    if (self.isNXLFile) {
                        if (DELEGATE_HAS_METHOD(self.delegate, @selector(NXFileParser:didFinishedParseNXLFile:resultView:rights:isSteward:stewardID:error:))) {
                            [self.delegate NXFileParser:self didFinishedParseNXLFile:self.curFile resultView:nil rights:self.fileRights isSteward:self.isSteward stewardID:self.stewardID error:error];
                        }
                    }else if (DELEGATE_HAS_METHOD(self.delegate, @selector(NXFileParser:didFinishedParseFile:resultView:error:))){
                        [self.delegate NXFileParser:self didFinishedParseFile:self.curFile resultView:nil error:error];
                    }
                }else{
                    if (self.isNXLFile) {
                        if (DELEGATE_HAS_METHOD(self.delegate, @selector(NXFileParser:didFinishedParseNXLFile:resultView:rights:isSteward:stewardID:error:))) {
                            [self.delegate NXFileParser:self didFinishedParseNXLFile:self.curFile resultView:renderView rights:self.fileRights isSteward:self.isSteward stewardID:self.stewardID error:nil];
                        }
                    }else if (DELEGATE_HAS_METHOD(self.delegate, @selector(NXFileParser:didFinishedParseFile:resultView:error:))){
                        [self.delegate NXFileParser:self didFinishedParseFile:self.curFile resultView:renderView error:nil];
                    }
                }
            }
        }];
    });
}

- (NSString *)getTempFilePathWithForFile:(NXFileBase *)file error:(NSError **)Error
{
    NSString *tmpPath = [NXCommonUtils getConvertFileTempPath];
    
    if (file.name && file.name.length > 0) {
         tmpPath = [tmpPath stringByAppendingPathComponent:[file.name lastPathComponent]];
    }
    else
    {
        if (file.localPath.lastPathComponent.length > 0) {
            file.name = file.localPath.lastPathComponent;
        }
       tmpPath = [tmpPath stringByAppendingPathComponent:[file.name lastPathComponent]];
    }
  
    // there get file token from RMS, may failed for no right or network error
    NSString *fileExtension = [self getFileExtensionByFileName:file];
    tmpPath = [tmpPath stringByAppendingPathExtension:fileExtension];
    return tmpPath;
}

- (NSString *)getFileExtensionByFileName:(NXFileBase *)file
{
    NSString *fileExtension = file.name.pathExtension;
    if ([fileExtension compare:NXL options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        fileExtension = [file.name stringByDeletingPathExtension].pathExtension;
    }
    return fileExtension;
}



- (void)addOverlayer:(UIView *)overlay toFile:(NXFileBase *)file
{
    [self.curFileParse addOverlay:overlay];
}

- (void)snapShot:(NXFileBase *)file compBlock:(getSnapShotCompBlock)block
{
    [self.curFileParse snapShot:^(id image) {
        block(image);
    }];
}

- (void)closeFile:(NXFileBase *)file
{
    // cancel download file
    [[NXWebFileManager sharedInstance] cancelDownload:self.downloadOptIdentify];
    // TODO cancle decrypt
    //
    
    // reset fileparseResponder
    [self.curFileParse closeFile];
    
    // delete temp file
    if (self.fakeFile) {
        [[NSFileManager defaultManager] removeItemAtPath:self.fakeFile.localPath error:nil];

    }
    
    // reset property
    self.curFileParse = nil;
    self.downloadOptIdentify = nil;
    self.tempNXLFilePath = nil;
    self.fakeFile = nil;
    self.curFile = nil;
}

- (void)pauseMediaFile:(NXFileBase *)file
{
    [self.curFileParse pauseMediaFile];
}

- (void)refreshOfflineFileMarkAsOfflineDateAndOpen:(NXOfflineFile *)offlineFile
{
    if ([[NXNetworkHelper sharedInstance] isNetworkAvailable]) {
        dispatch_main_async_safe(^{
            [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:NSLocalizedString(@"MSG_OFFLINE_FILE_LOCAL_EXPIRED_ALERT", nil) style: UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_OK", nil) cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", nil) OKActionHandle:^(UIAlertAction *action) {
                if (offlineFile.isCenterPolicyEncrypted) {
                    [[NXOfflineFileManager sharedInstance] refreshTokenForFile:offlineFile withCompletion:^(NXFileBase *file, NSError *error) {
                        if (!error) {
                            [[NXOfflineFileManager sharedInstance] refreshRightsForFile:offlineFile withCompletion:^(NXFileBase *file, NSError *error) {
                                if (!error) {
                                    [[NXOfflineFileManager sharedInstance] updateOfflineFileMarkAsOfflineDate:offlineFile];
                                    NXOfflineFile *fileOff = [offlineFile copy];
                                    fileOff.markAsOfflineDate = [NSDate date];
                                    self.curFile = fileOff;
                                    [self processOfflineFile:fileOff];
                                }else{
                                    if (DELEGATE_HAS_METHOD(self.delegate, @selector(NXFileParser:didFinishedParseFile:resultView:error:))) {
                                        [self.delegate NXFileParser:self didFinishedParseNXLFile:self.curFile resultView:nil rights:nil isSteward:NO stewardID:nil error:error];
                                    }
                                }
                            }];
                        }else{
                            if (DELEGATE_HAS_METHOD(self.delegate, @selector(NXFileParser:didFinishedParseFile:resultView:error:))) {
                                [self.delegate NXFileParser:self didFinishedParseNXLFile:self.curFile resultView:nil rights:nil isSteward:NO stewardID:nil error:error];
                            }
                        }
                    }];
                }else{
                    // means current file is encrypted by adhoc
                    [[NXOfflineFileManager sharedInstance] refreshTokenForFile:offlineFile withCompletion:^(NXFileBase *file, NSError *error) {
                        if (!error) {
                            [[NXOfflineFileManager sharedInstance] updateOfflineFileMarkAsOfflineDate:offlineFile];
                            NXOfflineFile *fileOff = [offlineFile copy];
                            fileOff.markAsOfflineDate = [NSDate date];
                            self.curFile = fileOff;
                            [self processOfflineFile:fileOff];
                        }else{
                            if (DELEGATE_HAS_METHOD(self.delegate, @selector(NXFileParser:didFinishedParseFile:resultView:error:))) {
                                [self.delegate NXFileParser:self didFinishedParseNXLFile:self.curFile resultView:nil rights:nil isSteward:NO stewardID:nil error:error];
                            }
                        }
                    }];
                }
            } cancelActionHandle:^(UIAlertAction *action) {
                NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXOFFLINEFILE_DOMAIN code:NXRMC_ERROR_CODE_OFFLINE_FILE_EXPIRED_ERROR userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_OFFLINE_FILE_EXPIRED", nil)}];
                if (DELEGATE_HAS_METHOD(self.delegate, @selector(NXFileParser:didFinishedParseFile:resultView:error:))) {
                    [self.delegate NXFileParser:self didFinishedParseNXLFile:self.curFile resultView:nil rights:nil isSteward:NO stewardID:nil error:error];
                }
            } inViewController:[UIApplication sharedApplication].delegate.window.rootViewController position:[UIApplication sharedApplication].delegate.window.rootViewController.view];
        });
        return;
    }else{
        NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXOFFLINEFILE_DOMAIN code:NXRMC_ERROR_CODE_OFFLINE_FILE_EXPIRED_ERROR userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_OFFLINE_FILE_EXPIRED", nil)}];
        if (DELEGATE_HAS_METHOD(self.delegate, @selector(NXFileParser:didFinishedParseFile:resultView:error:))) {
            [self.delegate NXFileParser:self didFinishedParseNXLFile:self.curFile resultView:nil rights:nil isSteward:NO stewardID:nil error:error];
        }
    }
}

#pragma mark - Getter/Setter
- (NXFileParseResponder *)fileParseResponder{
    if (_fileParseResponder == nil) {
        _fileParseResponder = [[NXNormalFileParseResponder alloc] init];
        NXPDFParserResponder *pdfParse = [[NXPDFParserResponder alloc] init];
        NXMediaParseResponder *mediaParse = [[NXMediaParseResponder alloc] init];
        NXSAPParserResponder *sapParse = [[NXSAPParserResponder alloc] init];
        NXHoopsParseResponder *hoopsParse = [[NXHoopsParseResponder alloc] init];
        NXHeavyRemoteViewParserResponder *heavyRemoteViewParse = [[NXHeavyRemoteViewParserResponder alloc] init];
        NXSimpleRemoteViewParseResponder *simpleRemoteViewParse = [[NXSimpleRemoteViewParseResponder alloc] init];
        NX3DConvertParseResponder *needConvert3DFileParse = [[NX3DConvertParseResponder alloc] init];
        
        _fileParseResponder.nextResponder = pdfParse;
        pdfParse.nextResponder = mediaParse;
        mediaParse.nextResponder = sapParse;
        sapParse.nextResponder = hoopsParse;
        hoopsParse.nextResponder = needConvert3DFileParse;
        needConvert3DFileParse.nextResponder = simpleRemoteViewParse;
        simpleRemoteViewParse.nextResponder = heavyRemoteViewParse;
    }
    return _fileParseResponder;
}
@end
