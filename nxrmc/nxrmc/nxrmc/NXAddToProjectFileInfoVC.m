//
//  NXAddToProjectFileInfoVC.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/4/2.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXAddToProjectFileInfoVC.h"
#import "NXProjectModel.h"
#import "NXPreviewFileView.h"
#import "NXMBManager.h"
#import "NXWebFileManager.h"
#import "NXLoginUser.h"
#import "NXFileBase.h"
#import "NXCommonUtils.h"
#import "NXRightsDisplayView.h"
#import "NXDocumentClassificationView.h"
#import "NXReAddFileToProjectVC.h"
#import "NXAddToProjectLastVC.h"
#import "Masonry.h"

#define OTHER_HEIGHT 140
@interface NXAddToProjectFileInfoVC ()
@property(nonatomic, strong) NXFileBase *decryptFile;
@property(nonatomic, strong) NXDocumentClassificationView *classificationView;
@property(nonatomic, strong) NXRightsDisplayView *rightsDisplayView;
@property(nonatomic, strong) NSArray<NXClassificationCategory *> *fileClassifications;

@end

@implementation NXAddToProjectFileInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.specifyView.backgroundColor = [UIColor whiteColor];
    [self commonInitUI];
    if (self.fileOperationType == NXFileOperationTypeWorkSpaceFileReclassify || self.fileOperationType == NXFileOperationTypeProjectFileReclassify) {
        self.navigationItem.title = NSLocalizedString(@"UI_RECLASSIFY", NULL);
//        self.preview.enabled = NO;
//        NSString *parentPath = [self.currentFile.fullServicePath stringByDeletingLastPathComponent];
//        if (![parentPath isEqualToString:@"/"]) {
//           parentPath = [parentPath stringByAppendingString:@"/"];
//        }
//        self.preview.savedPath = parentPath;
        [self getFileRightsAndDisplay];
    }else{
        if (self.fileOperationType == NXFileOperationTypeAddProjectFileToWorkSpace) {
            self.navigationItem.title = NSLocalizedString(@"UI_ADD_FILE_TO", NULL);
        }
       [self handleFile];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self setScrollViewContentSize];
}
- (void)back:(id)sender {
    if (self.navigationController.childViewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
   
}
- (void)commonInitUI {
    self.folder = [NXMyProjectManager rootFolderForProject:self.toProject];
//    if (self.fileOperationType == NXFileOperationTypeAddProjectFileToWorkSpace) {
//        self.preview.savedPath = @"WorkSpace:/";
//    }else{
//        self.preview.savedPath = [NSString stringWithFormat:@"%@:%@", self.toProject.displayName?:@"", self.folder.fullPath?:@""];
//    }
    
    [self.bottomBtn setTitle:@"Next" forState:UIControlStateNormal];
}
- (void)getFileRightsAndDisplay {
    [NXMBManager showLoadingToView:self.view];
    [[NXLoginUser sharedInstance].nxlOptManager getNXLFileRights:self.currentFile withWatermark:NO withCompletion:^(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray<NXWatermarkWord *> *waterMarkWords, NSString *owner, BOOL isOwner, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NXMBManager hideHUDForView:self.view];
            if (classifications) {
//                NXFile *previewFile = [[NXFile alloc] init];
//                previewFile.name = self.currentFile.name;
//                self.preview.enabled = NO;
//                self.preview.fileItem = previewFile;
                self.bottomBtn.enabled = YES;
                [self updateUIWith:classifications withRights:rights];
                self.fileClassifications = classifications;
            }else{
                NSString *errorMessage =error?error.localizedDescription:NSLocalizedString(@"MSG_USER_DEFINED_FILE_CAN_NOT_MODIFY_RIGHTS", NULL);
                [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:errorMessage  style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_OK", NULL) cancelActionTitle:nil OKActionHandle:^(UIAlertAction *action) {
                    [self back:nil];
                } cancelActionHandle:nil inViewController:self position:self.view];
            }
        });
    }];
}
- (void)handleFile {
    [NXMBManager showLoading];
    [[NXWebFileManager sharedInstance] downloadFile:(NXFileBase<NXWebFileDownloadItemProtocol>*)self.currentFile withProgress:nil completed:^(NXFileBase *file, NSData *fileData, NSError *error) {
        if (!error) {
            NSError *err = nil;
            NSString *tempPath = [self getTempFilePathWithForFile:file error:&err];
            [[NXLoginUser sharedInstance].nxlOptManager decryptNXLFile:file toPath:tempPath shouldSendLog:NO withCompletion:^(NSString *filePath, NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSString *owner, BOOL isOwner, NSError *error1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NXMBManager hideHUD];
                    if (!error1 && !err) {
//                        NXFile *previewFile = [[NXFile alloc] init];
//                        previewFile.name = tempPath.lastPathComponent;
//                        self.preview.fileItem = previewFile;
                        NXFile *decryptFile = [[NXFile alloc]init];
                        decryptFile.name = tempPath.lastPathComponent;
                        decryptFile.size = file.size;
                        decryptFile.localPath = tempPath;
                        decryptFile.sorceType = NXFileBaseSorceTypeLocal;
                        self.decryptFile = decryptFile;
                        self.currentFile = decryptFile;
                        self.originalFileOwnerId = owner;
                        self.originalFileDUID = duid;
                        self.bottomBtn.enabled = YES;
                        [self updateUIWith:classifications withRights:rights];
                    }else{
                        [NXMBManager showMessage:error1 ? error1.localizedDescription : err.localizedDescription hideAnimated:YES afterDelay:kDelay];
                    }
                    
                });
            }];
        }else{
            [NXMBManager hideHUD];
            [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:kDelay];
        }
        
    }];
}

- (void)updateUIWith:(NSArray *)classifications withRights:(NXLRights *)rights {
    UILabel *messageLabel = [[UILabel alloc]init];
    messageLabel.numberOfLines = 0;
    [self.specifyView addSubview:messageLabel];
    messageLabel.text = @"Permissions granted for current file";
    NXDocumentClassificationView *classificationView = [[NXDocumentClassificationView alloc]init];
    classificationView.documentClassicationsArray = classifications;
    [self.bgScrollView addSubview:classificationView];
    self.classificationView = classificationView;
    NXRightsDisplayView *rightsDisplayView = [[NXRightsDisplayView alloc]init];
    rightsDisplayView.rights = rights;
//    rightsDisplayView.isNeedTitle = NO;
    [self.bgScrollView addSubview:rightsDisplayView];
    self.rightsDisplayView = rightsDisplayView;
     [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
           make.top.equalTo(self.specifyView).offset(kMargin);
           make.left.equalTo(self.specifyView).offset(10);
           make.right.equalTo(self.specifyView).offset(-kMargin);
       }];
       
       [classificationView mas_makeConstraints:^(MASConstraintMaker *make) {
           make.top.equalTo(messageLabel.mas_bottom).offset(kMargin);
           make.left.right.equalTo(messageLabel);
           make.height.greaterThanOrEqualTo(@60);
       }];
       [rightsDisplayView mas_makeConstraints:^(MASConstraintMaker *make) {
           make.top.equalTo(classificationView.mas_bottom);
           make.left.right.equalTo(classificationView);
           make.height.greaterThanOrEqualTo(@200);
       }];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}


- (void)setScrollViewContentSize {
    
    CGFloat height;
    height = OTHER_HEIGHT+CGRectGetHeight(self.classificationView.bounds) + CGRectGetHeight(self.rightsDisplayView.bounds);
    if (self.bgScrollView.bounds.size.height > height) {
        self.bgScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bgScrollView.bounds), CGRectGetHeight(self.bgScrollView.bounds));
    } else {
        self.bgScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bgScrollView.bounds), height + 10);
    }
}
#pragma mark ------> get temp file path
- (NSString *)getTempFilePathWithForFile:(NXFileBase *)file error:(NSError **)Error
{
    NSString *tmpPath = [NXCommonUtils getConvertFileTempPath];
    file.name = [NXCommonUtils getNXLFileOriginalName:file.name];
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
    
    return tmpPath;
}
- (void)nextOperation:(id)sender {
    if ((self.fileOperationType == NXFileOperationTypeWorkSpaceFileReclassify || self.fileOperationType == NXFileOperationTypeProjectFileReclassify)) {
        NXReAddFileToProjectVC *addToFileVC  = [[NXReAddFileToProjectVC alloc]init];
        addToFileVC.toProject = self.toProject;
        addToFileVC.currentFile = self.currentFile;
        addToFileVC.folder = (NXFolder *)self.folder;
        addToFileVC.originalFileDUID = self.originalFileDUID;
        addToFileVC.originalFileOwnerId = self.originalFileOwnerId;
        addToFileVC.currentClassifiations = self.currentClassifiations;
        addToFileVC.fileOperationType = self.fileOperationType;
        if (self.fileOperationType == NXFileOperationTypeWorkSpaceFileReclassify || self.fileOperationType == NXFileOperationTypeProjectFileReclassify) {
            addToFileVC.currentClassifiations = self.fileClassifications;
        }
        [self.navigationController pushViewController:addToFileVC animated:YES];
        return;
    }
   
   
    if (self.folder == nil) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_SELECT_FOLDER", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
        self.bottomBtn.enabled = YES;
        return;
    }
           
   if (!self.currentFile.localPath || ![[NSFileManager defaultManager] fileExistsAtPath:self.currentFile.localPath]) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_FILE_NOT_EXISTED", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
        self.bottomBtn.enabled = YES;
        return;
   }
    NXAddToProjectLastVC *addToFileVC = [[NXAddToProjectLastVC alloc]init];
    addToFileVC.toProject = self.toProject;
    addToFileVC.currentFile = self.currentFile;
    addToFileVC.folder = self.folder;
    addToFileVC.originalFileDUID = self.originalFileDUID;
    addToFileVC.originalFileOwnerId = self.originalFileOwnerId;
    addToFileVC.currentClassifiations = self.currentClassifiations;
    addToFileVC.fileOperationType = self.fileOperationType;
    [self.navigationController pushViewController:addToFileVC animated:YES];
}
@end
