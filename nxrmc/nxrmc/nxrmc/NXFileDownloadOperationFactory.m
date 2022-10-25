//
//  NXFileDownloadBaseOperation.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 20/10/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXFileDownloadOperationFactory.h"
#import "NXDownloadRepoFileOperation.h"
#import "NXDownloadFileFromMyVaultFolderOperation.h"
#import "NXProjectDownloadFileOperation.h"
#import "NXSharedWithMeDownloadFileOperation.h"
#import "NXWorkSpaceDownloadFileOperation.h"
#import "NXWebFileDownloadDefaultOperation.h"
#import "NXSharedWithProjectFileDownloadOperation.h"
#import "NXCommonUtils.h"

@interface NXFileDownloadOperationFactory()
@end

@implementation NXFileDownloadOperationFactory

+ (id<NXWebFileDownloadOperation>)createWithFile:(NXFileBase *)file size:(NSUInteger)size downloadType:(NSInteger)downloadType
{
    id<NXWebFileDownloadOperation> downloadOperation = nil;
    
    switch (file.sorceType) {
        case NXFileBaseSorceTypeRepoFile:
        {   downloadOperation = [[NXDownloadRepoFileOperation alloc] initWithDestFile:file toSize:size repository:[[NXLoginUser sharedInstance].myRepoSystem getRepositoryModelByFileItem:file]];
        }
            break;
        case NXFileBaseSorceTypeSharedWorkspaceFile:
        {
            downloadOperation = [[NXDownloadRepoFileOperation alloc] initWithDestFile:file toSize:size repository:[[NXLoginUser sharedInstance].myRepoSystem getRepositoryModelByFileItem:file] downType:downloadType];
        }
            break;
        case NXFileBaseSorceTypeMyVaultFile:
        {
            downloadOperation = [[NXDownloadFileFromMyVaultFolderOperation alloc] initWithFile:(NXMyVaultFile*)file size:size downloadType:downloadType];
        }
            break;
        case NXFileBaseSorceTypeProject:
        {
            if ([file isKindOfClass:[NXOfflineFile class]]) {
                NXProjectFile *projectFile = [[NXOfflineFileManager sharedInstance] getProjectFilePartner:(NXOfflineFile *)file];
                file = projectFile;
                
            }
            downloadOperation = [[NXProjectDownloadFileOperation alloc] initWithProjectModel:[[NXLoginUser sharedInstance].myProject getProjectModelForFile:(NXProjectFile *)file] file:(NXProjectFile*)file start:0 length:size downloadType:downloadType];
        }
            break;
        case NXFileBaseSorceTypeShareWithMe:
        {
            NXSharedWithMeFile *sharedWithMeFile = nil;
            if ([file isKindOfClass:[NXOfflineFile class]]) {
                sharedWithMeFile = [[NXOfflineFileManager sharedInstance] getSharedWithMeFilePartner:(NXOfflineFile *)file];
            }else if([file isKindOfClass:[NXSharedWithMeFile class]]){
                sharedWithMeFile = (NXSharedWithMeFile *)file;
            }
            BOOL forViewer = NO;
            if (downloadType) {
                forViewer = YES;
            }
            downloadOperation = [[NXSharedWithMeDownloadFileOperation alloc] initWithSharedWithMeFile:sharedWithMeFile size:size forViewer:forViewer];
        }
            break;
        case NXFileBaseSorceTypeSharedWithProject:
        {
            downloadOperation = [[NXSharedWithProjectFileDownloadOperation alloc] initWithSharedWithProjectFile:(NXSharedWithProjectFile *)file size:size forViewer:YES];
        }
            break;
        case NXFileBaseSorceTypeWorkSpace:
            downloadOperation = [[NXWorkSpaceDownloadFileOperation alloc] initWithWorkSpaceFile:(NXWorkSpaceFile *)file start:0 length:size downloadType:downloadType];
            break;
        default:
            NSAssert(NO, @"Should add a download operation to support the sorceType file download");
            break;
    }
    if (downloadOperation==nil) {
        // There maybe lost necessary params to create download operation correctly
        // So use NXWebFileDownloadDefaultOperation instead. The NXWebFileDownloadDefaultOperation
        // will only finish the download when start, with download error
        downloadOperation = [[NXWebFileDownloadDefaultOperation alloc] init];
    }
    
    return downloadOperation;
}

@end
