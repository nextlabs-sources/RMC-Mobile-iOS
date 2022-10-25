//
//  NXShareViewController.m
//  nxrmc
//
//  Created by nextlabs on 11/11/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXShareViewController.h"

#import "Masonry.h"

#import "NXRMCUIDef.h"
#import "UIView+UIExt.h"
#import "NXFileInfoView.h"
#import "NXRightsSelectView.h"
#import "NXRightsDisplayView.h"
#import "NXMarkFavOrOffView.h"
#import "NXEmailView.h"
#import "NXCommentInputView.h"

#import "NXMessageViewManager.h"

#import "NXMBManager.h"
#import "UIImage+ColorToImage.h"
#import "NXSharedWithMeFile.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXWebFileManager.h"
#import "NXLogAPI.h"
#import "NXSyncHelper.h"
#import "NXCacheManager.h"
#import "NXLRights.h"
#import "NXLocalContactsVC.h"
#import "NXContactInfoTool.h"
#import "NXCommonUtils.h"
@interface NXShareViewController ()<UIGestureRecognizerDelegate, NXRightsSelectViewDelegate, NXEmailViewDelegate,NXLocalContactsVCDelegate>

@property(nonatomic, strong) NXRightsSelectView *rightsSelectView;
@property(nonatomic, strong) NXRightsDisplayView *rightsDisplayView;
@property(nonatomic, weak) NXEmailView *emailsView;
@property(nonatomic, strong) NXCommentInputView *commentInputView;
@property(nonatomic, weak) UIButton *shareButton;

@property(nonatomic, strong) NXMBProgressView *progressView;

@property(nonatomic, strong) NXLRights *selectedRights;
@property(nonatomic, assign) BOOL isNXL;
@property(nonatomic, assign) CGFloat mainContentHeightOffset;

@property(nonatomic, strong) NSString *downloadId;
@property(nonatomic, strong) NSString *shareOptId;
@property(nonatomic, strong) NSString *myRepoSysUploadOptIdentify;
@property(nonatomic, strong) NXLFileValidateDateModel *curFileValidateDateModel;
@property(nonatomic, strong) NSString *downloadOptIdentify;

@property(nonatomic, assign) BOOL isExternalFileAndBelongToMyProject;
@property(nonatomic, assign) NXExternalNXLFileSourceType type;
@property(nonatomic, assign) BOOL isEncryptedByCenterPolicy;
@property(nonatomic, copy)NSString *currentFileOrginalName;


@end

@implementation NXShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
    self.mainView.bounces = YES;
    _curFileValidateDateModel = nil;
    _isEncryptedByCenterPolicy = NO;
    _isExternalFileAndBelongToMyProject = NO;
    _type = NXExternalNXLFileSourceTypeOther;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name: UIKeyboardWillChangeFrameNotification object:nil];
    
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NXWebFileManager sharedInstance] cancelDownload:self.downloadId];
    DLog();
}

- (void)viewDidLayoutSubviews {
    CGFloat height = CGRectGetHeight(self.rightsSelectView.bounds) + CGRectGetHeight(self.rightsDisplayView.bounds) + CGRectGetHeight(self.emailsView.bounds) + CGRectGetHeight(self.commentInputView.bounds);

    CGFloat contentHeight = height + kMargin * 4 + self.mainContentHeightOffset;
    
    if (self.mainView.bounds.size.height > contentHeight) {
        self.mainView.contentSize = CGSizeMake(CGRectGetWidth(self.mainView.bounds), CGRectGetHeight(self.mainView.bounds) + 1);
    } else {
        self.mainView.contentSize = CGSizeMake(CGRectGetWidth(self.mainView.bounds), contentHeight);
    }
}

#pragma mark
- (void)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [[NXLoginUser sharedInstance].myRepoSystem cancelOperation:self.myRepoSysUploadOptIdentify];
    [[NXLoginUser sharedInstance].nxlOptManager cancelNXLOpt:self.shareOptId];
}

- (void)shareButtonClicked:(id)sender {
    
    // fix reshare bug ,if reshare,just read expire time from rights 2017/11/23
    if (self.curFileValidateDateModel) {
          [self.selectedRights setFileValidateDate:self.curFileValidateDateModel];
    }
    
    self.shareButton.enabled = NO;
    if ([self.fileItem isKindOfClass:[NXMyVaultFile class]]) {
        NXMyVaultFile *fileItem = (NXMyVaultFile *)(self.fileItem);
        if (fileItem.isRevoked) {
            [NXMBManager showMessage:NSLocalizedString(@"MSG_FILE_HAS_BEEN_REVOKED", NULL) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
            self.shareButton.enabled = YES;
            return;
        }
        
        //2 check expireTime / already exist files
        if ([NXCommonUtils checkNXLFileisExpired:self.selectedRights.getVaildateDateModel]) {
            [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_FILE_VALIDITY_EXPIRED", NULL) hideAnimated:YES afterDelay:kDelay];
            self.shareButton.enabled = YES;
            return;
        }
    }
    
    //1 have cache or not
    if (![self.fileItem isKindOfClass:[NXMyVaultFile class]] && ![self.fileItem isKindOfClass:[NXSharedWithMeFile class]] && self.fileItem.serviceType.integerValue != kServiceSkyDrmBox) {
        if ((!self.fileItem.localPath || ![[NSFileManager defaultManager] fileExistsAtPath:self.fileItem.localPath]) && ![self.fileItem isKindOfClass:[NXProjectFile class]]) {
            [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_FILE_NOT_EXISTED", NULL) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
            self.shareButton.enabled = YES;
            return;
        }
    }
    
    //2 check email
    if (self.emailsView.vaildEmails.count == 0) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_NO_VAILD_EMAIL_ADDRESS", NULL) hideAnimated:YES afterDelay:kDelay];
        self.shareButton.enabled = YES;
        return;
    }
    
    if ([self.emailsView isExistInvalidEmail]) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_HAVE_INVALID_EMAIL_ADDRESS", NULL) hideAnimated:YES afterDelay:kDelay];
        self.shareButton.enabled = YES;
        return;
    }
    
    if (!self.selectedRights.getVaildateDateModel) {
                   [self.selectedRights setFileValidateDate:[NXLoginUser sharedInstance].userPreferenceManager.userPreference.preferenceFileValidateDate];
    }
    
    
      //2 check expireTime
    if (![NXCommonUtils checkIsLegalFileValidityDate:[self.selectedRights getVaildateDateModel]] && _isEncryptedByCenterPolicy == NO) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_FILE_EXPIRETIME_INVALID", NULL) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
        self.shareButton.enabled = YES;
        return;
    }
    
    //3 upload repo
//    WeakObj(self);
//    if (self.fileItem.sorceType == NXFileBaseSorceTypeLocal) {
//        if (!self.folder) {
//            [NXMBManager showMessage:NSLocalizedString(@"MSG_SELECT_FOLDER", NULL) hideAnimated:YES afterDelay:kDelay];
//            return;
//        }
//
//        NSArray *children = [[NXLoginUser sharedInstance].myRepoSystem childForFileItem:self.folder];
//        for (NXFileBase *item in children) {
//            if ([self.fileItem.name caseInsensitiveCompare:item.name] == NSOrderedSame) {
//                [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_NAME_ALREADY_EXISTED", NULL) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
//                self.shareButton.enabled = YES;
//                return;
//            }
//        }
//
//        [NXMBManager showLoading:NSLocalizedString(@"MSG_UPLOADING", NULL) toView:self.mainView];
//        self.myRepoSysUploadOptIdentify = [[NXLoginUser sharedInstance].myRepoSystem uploadFile:self.fileItem.name toPath:self.folder fromPath:self.fileItem.localPath uploadType:NXRepositorySysManagerUploadTypeNormal overWriteFile:nil progress:nil completion:^(NXFileBase *fileItem, NXFileBase *parentFolder, NSError *error) {
//            StrongObj(self);
//            dispatch_main_sync_safe(^{
//                [NXMBManager hideHUDForView:self.mainView];
//                if (error) {
//                    [NXMBManager showMessage:error.localizedDescription?error.localizedDescription: NSLocalizedString(@"MSG_UPLOAD_FAILED", NULL) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
//                    self.shareButton.enabled = YES;
//                } else {
//                    [self shareAction];
//                }
//            });
//        }];
//    } else {
   //     [self shareAction];
//    }
    
    NSArray *allMyvaltFileInDB = [[NXLoginUser sharedInstance].myVault getAllMyVaultFileInCoreData];
    if (allMyvaltFileInDB.count > 0) {
        for (NXMyVaultFile *myvaultFile in allMyvaltFileInDB) {
            if ([[myvaultFile.name stringByDeletingPathExtension] isEqualToString:self.fileItem.name]) {
                
                if (self.fileItem.sorceType == NXFileBaseSorceTypeRepoFile) {
                      NSString *message = [NSString stringWithFormat:NSLocalizedString(@"ALERTVIEW_MESSAGE_OVERWRITE", NULL), myvaultFile.name];
                                         
                                         if (myvaultFile.sharedWith.count > 0) {
                                             NSString *member = @"";
                                             for (NSString *email in myvaultFile.sharedWith) {
                                                member = [member stringByAppendingFormat:@"%@,",email];
                                             }
                                             message = [NSString stringWithFormat:NSLocalizedString(@"ALERTVIEW_MESSAGE_OVERWRITE_SHARE_CASE", NULL),myvaultFile.name,member];
                                         }
                      dispatch_main_sync_safe(^{
                           [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_REPLACE", NULL) cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) OKActionHandle:^(UIAlertAction *action) {
                               //3 share.
                                self.shareButton.enabled = NO;
                                [self shareAction];
                           } cancelActionHandle:^(UIAlertAction *action) {
                               self.shareButton.enabled = YES;
                               [NXMBManager hideHUDForView:self.view];
                               [self backButtonClicked:nil];
                           } inViewController:self position:self.view];
                       })
                    return;
                }
                
                dispatch_main_sync_safe((^{
                    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"ALERTVIEW_MESSAGE_OVERWRITE", NULL), myvaultFile.name];
                    
                    if (myvaultFile.sharedWith.count > 0) {
                        NSString *member = @"";
                        for (NSString *email in myvaultFile.sharedWith) {
                           member = [member stringByAppendingFormat:@"%@,",email];
                        }
                        message = [NSString stringWithFormat:NSLocalizedString(@"ALERTVIEW_MESSAGE_OVERWRITE_SHARE_CASE", NULL),myvaultFile.name,member];
                    }
                    
                    [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_REPLACE", NULL) cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherTitle:NSLocalizedString(@"UI_BOX_NO_REPLACE", NULL) OKActionHandle:^(UIAlertAction *action) {
                        NXFileState state = [[NXOfflineFileManager sharedInstance] currentState:myvaultFile];
                        if (state != NXFileStateNormal)
                        {
                            [[NXOfflineFileManager sharedInstance] unmarkFileAsOffline:myvaultFile withCompletion:^(NXFileBase *fileItem, NSError *error) {
                            }];
                        }
                        [self shareAction];
                    } cancelActionHandle:^(UIAlertAction *action) {
                        self.shareButton.enabled = YES;
                        [self backButtonClicked:nil];
                        [NXMBManager hideHUDForView:self.view];
                    } otherActionHandle:^(UIAlertAction *action) {
                        //no replace
                        NSMutableArray *currentFolderFilesNameArray = [[NSMutableArray alloc] init];
                        for (NXMyVaultFile *file in allMyvaltFileInDB) {
                            if (file.name.length > 0) {
                                [currentFolderFilesNameArray addObject:file.name];
                            }
                        }
                        NSUInteger index = 2;
                        NSUInteger MaxIndex = [NXCommonUtils getMaxIndexForFile:self.fileItem.name fileNameArray:currentFolderFilesNameArray];
                        NSString *newFileName = self.fileItem.name;
                        if (MaxIndex == 0) {
                            newFileName = [NXCommonUtils addIndexForFile:index fileName:newFileName];
                        }else{
                            MaxIndex += 1;
                            newFileName = [NXCommonUtils addIndexForFile:MaxIndex fileName:newFileName];
                        }
                        self.currentFileOrginalName = self.fileItem.name;
                        self.fileItem.name = newFileName;
                        if(self.fileItem.localPath){
                            self.fileItem.localPath = [self renameWithFileName:newFileName];
                        }
                        
                        [self shareAction];
                    } inViewController:self position:self.view];
                    return;
                }));
                return;
            }
        }
    }
    
     [self shareAction];
}

- (NSString *)renameWithFileName:(NSString *)newName
{
    //通过移动该文件对文件重命名
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = self.fileItem.localPath;
    NSString *newPathWithoutExtension = [self.fileItem.localPath stringByDeletingLastPathComponent];
    NSString *newPath = [newPathWithoutExtension stringByAppendingPathComponent:newName];

    BOOL isSuccess = [fileManager moveItemAtPath:filePath toPath:newPath error:nil];
    if (isSuccess) {
        NSLog(@"rename success");
    }else{
        NSLog(@"rename fail");
    }
    return newPath;
}

- (void)shareAction {
    
    NXFile *fakeFile = [self.fileItem copy];
    
    // for 3rd file share (source type is MyVault,should construct fullServicePath "/nxl_myvault_nxl")
    if (_type == NXExternalNXLFileSourceTypeMyVault) {
        fakeFile.sorceType = NXFileBaseSorceTypeMyVaultFile;
        NSString *fullpath = [NXCommonUtils getMyVaultFilePathBy3rdOpenInFileLocalPath:self.fileItem.localPath];
        fakeFile.fullPath = fullpath;
        fakeFile.name = [fullpath componentsSeparatedByString:@"/"].lastObject;
        fakeFile.fullServicePath = [[NSString stringWithFormat:@"/nxl_myvault_nxl%@",fullpath] lowercaseString];
    }
    [NXMBManager showLoading:NSLocalizedString(@"MSG_SHARING", NULL) toView:self.mainView];
    // property ‘_isExternalFileAndBelongToMyProject’ means this file is open from external and is belong to my project
    if ([self.fileItem isKindOfClass:[NXProjectFile class]] || _isExternalFileAndBelongToMyProject==YES) {
        WeakObj(self);
        self.downloadOptIdentify = [[NXLoginUser sharedInstance].nxlOptManager downloadNXLFileAndDecrypted:fakeFile completion:^(NXFileBase *file,NXLRights *originalNXLFileRights,NSString *duid,NSString *ownerID,NSError *error) {
            StrongObj(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    [NXMBManager showMessage:error.localizedDescription?:NSLocalizedString(@"MSG_SHARE_FILE_FAILED", NULL) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
                    self.shareButton.enabled = YES;
                    if (self.currentFileOrginalName) {
                        self.fileItem.name = self.currentFileOrginalName;
                        }
                    return ;
                }
                self.shareOptId = [[NXLoginUser sharedInstance].nxlOptManager shareProjectFile:file recipients:self.emailsView.vaildEmails permissions:self.selectedRights comment:self.commentInputView.textView.text originalFile:(NXFile *)self.fileItem originalFileOwnnerID:ownerID originalFileDuid:duid withCompletion:^(NSString *sharedFileName,NSString *duid, NSArray *alreadySharedArray, NSArray *newSharedArray, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [NXMBManager hideHUDForView:self.mainView];
                        if (error) {
                            [NXMBManager showMessage:error.localizedDescription?:NSLocalizedString(@"MSG_SHARE_FILE_FAILED", NULL) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
                            self.shareButton.enabled = YES;
                            if (self.currentFileOrginalName) {
                              self.fileItem.name = self.currentFileOrginalName;
                            }
                        } else {
                            if (DELEGATE_HAS_METHOD(self.delegate, @selector(viewcontroller:didfinishedOperationFile:toFile:))) {
                                [self.delegate viewcontroller:self didfinishedOperationFile:self.fileItem toFile:self.fileItem];
                            }
                            [self backButtonClicked:nil];
                            if (self.fileItem.sorceType == NXFileBaseSorceTypeLocal) {
                                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                            } else {
                                [self.navigationController popViewControllerAnimated:YES];
                            }
                            
                            if (self.isNXL) {
                                NSMutableString *alreadyMessage = [[NSMutableString alloc] init];
                                if (alreadySharedArray.count) {
                                    NSString *alreadyShared = [NSString stringWithFormat:NSLocalizedString(@"MSG_SUCCESS_ALREADY_SHARE", NULL), [alreadySharedArray componentsJoinedByString:@" "]];
                                    [alreadyMessage appendString:alreadyShared];
                                }
                                NSString *emails = [newSharedArray componentsJoinedByString:@" "];
                                [NXMessageViewManager showMessageViewWithTitle:sharedFileName?sharedFileName:self.fileItem.name details:emails.length?NSLocalizedString(@"MSG_SUCCESS_SHARE", NULL):nil appendInfo:emails.length?emails:nil appendInfo2:alreadyMessage image:[UIImage imageNamed:@"Success - White tick"] dismissAfter:kDelay*2 type:NXMessageViewManagerTypeGreen];
                                
                            } else {
                                NSString *email = [self.emailsView.vaildEmails componentsJoinedByString:@" "];
                                [NXMessageViewManager showMessageViewWithTitle:self.fileItem.name details:NSLocalizedString(@"MSG_SUCCESS_SHARE", NULL) appendInfo:email appendInfo2:NSLocalizedString(@"MSG_COM_FILE_HAS_BEEN_SAVED_TO_MYVAULT", NULL) image:[UIImage imageNamed:@"Success - White tick"] dismissAfter:kDelay*2 type:NXMessageViewManagerTypeGreen];
                            }
                        }
                    });
                }];
            });
        }];
        return;
    }
    
 
    
    self.shareOptId = [[NXLoginUser sharedInstance].nxlOptManager shareFile:fakeFile recipients:self.emailsView.vaildEmails permissions:self.selectedRights comment:self.commentInputView.textView.text withCompletion:^(NSString *sharedFileName,NSString *duid, NSArray *alreadySharedArray, NSArray *newSharedArray, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NXMBManager hideHUDForView:self.mainView];
            if (error) {
                [NXMBManager showMessage:error.localizedDescription?:NSLocalizedString(@"MSG_SHARE_FILE_FAILED", NULL) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
                self.shareButton.enabled = YES;
                if (self.currentFileOrginalName) {
                    self.fileItem.name = self.currentFileOrginalName;
                  }
            } else {
                if (DELEGATE_HAS_METHOD(self.delegate, @selector(viewcontroller:didfinishedOperationFile:toFile:))) {
                    [self.delegate viewcontroller:self didfinishedOperationFile:self.fileItem toFile:self.fileItem];
                }
                [self backButtonClicked:nil];
                if (self.fileItem.sorceType == NXFileBaseSorceTypeLocal) {
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                } else {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                
                if (self.isNXL) {
                    NSMutableString *alreadyMessage = [[NSMutableString alloc] init];
                    if (alreadySharedArray.count) {
                        NSString *alreadyShared = [NSString stringWithFormat:NSLocalizedString(@"MSG_SUCCESS_ALREADY_SHARE", NULL), [alreadySharedArray componentsJoinedByString:@" "]];
                        [alreadyMessage appendString:alreadyShared];
                    }
                    NSString *emails = [newSharedArray componentsJoinedByString:@" "];
                    [NXMessageViewManager showMessageViewWithTitle:self.fileItem.name details:emails.length?NSLocalizedString(@"MSG_SUCCESS_SHARE", NULL):nil appendInfo:emails.length?emails:nil appendInfo2:alreadyMessage image:[UIImage imageNamed:@"Success - White tick"] dismissAfter:kDelay*2 type:NXMessageViewManagerTypeGreen];
                    
                } else {
                    NSString *email = [self.emailsView.vaildEmails componentsJoinedByString:@" "];
                    [NXMessageViewManager showMessageViewWithTitle:self.fileItem.name details:NSLocalizedString(@"MSG_SUCCESS_SHARE", NULL) appendInfo:email appendInfo2:NSLocalizedString(@"MSG_COM_FILE_HAS_BEEN_SAVED_TO_MYVAULT", NULL) image:[UIImage imageNamed:@"Success - White tick"] dismissAfter:kDelay*2 type:NXMessageViewManagerTypeGreen];
                }
            }
        });
    }];
}

#pragma mark
- (void)tap:(UIGestureRecognizer *)gestuer {
    [self.view endEditing:YES];
}

#pragma mark
- (void)initData {
    if (!self.fileItem) {
        return;
    }
    if (self.fileItem.localPath || [self.fileItem isKindOfClass:[NXMyVaultFile class]] || [self.fileItem isKindOfClass:[NXProjectFile class]] || [self.fileItem isKindOfClass:[NXSharedWithMeFile class]] || self.fileItem.serviceType.integerValue == kServiceSkyDrmBox) {
        [self updateData:self.fileItem];
    } else {
        self.progressView = [NXMBManager showLoading:NSLocalizedString(@"MSG_COM_DOWNLOADING", NULL) progress:0 mode:NXMBProgressModeDeterminateHorizontalBar toView:self.mainView];
        WeakObj(self);
        NXWebFileDownloaderProgressBlock progressBlock = ^(int64_t receivedSize, int64_t totalCount, double fractionCompleted){
            StrongObj(self);
            self.progressView.progress = fractionCompleted;
        };
        BOOL isOffline = NO;
        if ([[NXOfflineFileManager sharedInstance] currentState:self.fileItem] == NXFileStateOfflined) {
            isOffline = YES;
        }
        self.downloadId = [[NXWebFileManager sharedInstance] downloadFile:(NXFileBase<NXWebFileDownloadItemProtocol>*)self.fileItem   withProgress:progressBlock isOffline:isOffline forOffline:NO completed:^(NXFileBase *file, NSData *fileData, NSError *error) {
            StrongObj(self);
            if (self) {
                dispatch_async(dispatch_get_main_queue(), ^{
                [NXMBManager hideHUDForView:self.mainView];
                [self.progressView hide];
                if (error) {
                    [NXMBManager showMessage:error.localizedDescription toView:self.mainView hideAnimated:YES afterDelay:kDelay];
                    self.shareButton.enabled = NO;
                    return;
                }
                self.fileItem = file;
                [self updateData:self.fileItem];
                });
            };
        }];
    }
}

- (void)updateData:(NXFileBase *)fileItem {
    self.topView.model = fileItem;
    BOOL ret = [[NXLoginUser sharedInstance].nxlOptManager isNXLFile:fileItem];
    if (ret) {
        self.shareButton.enabled = NO;
        [NXMBManager showLoading:NSLocalizedString(@"MSG_COM_GETTING_RIGHTS", NULL) toView:self.mainView];
        [[NXLoginUser sharedInstance].nxlOptManager getNXLFileRights:fileItem withWatermark:NO withCompletion:^(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray *watermark, NSString *owner, BOOL isOwner, NSError *error) {
            dispatch_main_async_safe(^{
                 [NXMBManager hideHUDForView:self.mainView];
                if (classifications) {
                    _isEncryptedByCenterPolicy = YES;
                }
                 // if a NXL file in project is encrypted by center-policy, it can not share to person
                if ([self.fileItem isKindOfClass:[NXProjectFile class]] && classifications.count >0) {
                    [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:NSLocalizedString(@"MSG_COM_PROJECT_FILE_SHARE_FORBIDDEN", nil)  style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_OK", NULL) cancelActionTitle:nil OKActionHandle:^(UIAlertAction *action) {
                        [self.navigationController popViewControllerAnimated:YES];
                    } cancelActionHandle:nil inViewController:self position:self.view];
                    return;
                }
                
                NXExternalNXLFileSourceType type = [NXCommonUtils getExternalNXLFileTypeByFileOwnerID:owner];
                if (self.fileItem.sorceType == NXFileBaseSorceType3rdOpenIn && owner) {
                    if ( type== NXExternalNXLFileSourceTypeProject) {
                        _isExternalFileAndBelongToMyProject = YES;
                    }else if(type == NXExternalNXLFileSourceTypeMyVault){
                        _isExternalFileAndBelongToMyProject = NO;
                        _type = NXExternalNXLFileSourceTypeMyVault;
                    }
                }
                
                [self updateUI:self.fileItem nxl:YES rights:rights message:NSLocalizedString(@"MSG_COM_GET_RIGHTS_FAILED", NULL) isSteward:isOwner owner:owner];
            });
        }];
    } else {
        [self updateUI:self.fileItem nxl:NO rights:nil message:nil isSteward:NO owner:nil];
    }
}

- (void)updateUI:(NXFileBase *)fileItem nxl:(BOOL)isNXL rights:(NXLRights *)rights1 message:(NSString *)noRightsMessage isSteward:(BOOL)isSteward owner:(NSString *)owner {
    
      [self.rightsDisplayView setIsOwner:YES];
    
    _isNXL = isNXL;
    if (isNXL) {
        //file owner.
        [self.shareButton setTitle:NSLocalizedString(@"UI_SHARE_THE_PROTECTED_FILE", NULL) forState:UIControlStateNormal];
        [[NXLoginUser sharedInstance].nxlOptManager canDoOperation:NXLRIGHTSHARING forFile:self.fileItem withCompletion:^(BOOL isAllowed, NSString *duid, NXLRights*rights, NSString *owner, BOOL isOwner, NSError *error) {
            dispatch_main_async_safe(^{
                if (isAllowed) {
                    self.shareButton.enabled = YES;
                }else{
                    self.shareButton.enabled = NO;
                }
                self.rightsDisplayView.rights = rights1;
                self.selectedRights = rights1;
                [self.rightsDisplayView showSteward:isOwner];
                self.rightsDisplayView.noRightsMessage = noRightsMessage;
                
                [self.mainView addSubview:self.rightsDisplayView];
                [self.rightsDisplayView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.mainView).offset(kMargin);
                    make.left.equalTo(self.view).offset(kMargin);
                    make.right.equalTo(self.view).offset(-kMargin);
                }];
                
                [self.emailsView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.rightsDisplayView.mas_bottom).offset(kMargin);
                    make.left.equalTo(self.view).offset(kMargin);
                    make.right.equalTo(self.view).offset(-kMargin);
                }];
                [self updateSubViews];
            });
        }];
    } else {
        NXLRights *rights = [[NXLRights alloc] init];
        [rights setRight:NXLRIGHTVIEW value:YES];
        [rights setFileValidateDate:[NXLoginUser sharedInstance].userPreferenceManager.userPreference.preferenceFileValidateDate];
        self.selectedRights = rights;
        self.rightsSelectView.rights = rights;
        self.rightsSelectView.enabled = YES;
        self.shareButton.enabled = YES;
        self.rightsSelectView.noRightsMessage = noRightsMessage;
        
        [self.mainView addSubview:self.rightsSelectView];
        [self.rightsSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mainView).offset(kMargin);
            make.left.equalTo(self.view).offset(kMargin);
            make.right.equalTo(self.view).offset(-kMargin);
        }];
        
        [self.emailsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.rightsSelectView.mas_bottom).offset(kMargin);
            make.left.equalTo(self.view).offset(kMargin);
            make.right.equalTo(self.view).offset(-kMargin);
        }];
    }
    [self.mainView addSubview:self.commentInputView];
    [self.commentInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.emailsView.mas_bottom).offset(kMargin);
        make.left.and.right.equalTo(self.emailsView);
        make.height.equalTo(@150);
    }];
    
#if 0
    self.emailsView.backgroundColor = [UIColor orangeColor];
    self.rightsSelectView.backgroundColor = [UIColor greenColor];
#endif
}

#pragma - NXEmailViewDelegate

- (void)emailViewDidBeginEditing:(NXEmailView *)emailView {
    
}

- (void)emailViewDidEndingEditing:(NXEmailView *)emailView {
    
}

- (void)emailView:(NXEmailView *)emailView didChangeHeightTo:(CGFloat)height {
    [self viewDidLayoutSubviews];
    [self scrollMainView];
}

- (void)emailView:(NXEmailView *)emailView didInputEmail:(NSString *)email {
    //
}

- (void)emailViewDidReturn:(NXEmailView *)emailView {
    //for return textview will have one "\n" character, can not fixed yet.
//    if (self.commentInputView.bounds.size.height) {
//        [self.commentInputView.textView becomeFirstResponder];
//    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UITextField class]] || [touch.view isKindOfClass:[UITextView class]]) {
        return NO;
    } else {
        [self tap:nil];
        return NO;
    }
}

#pragma mark - NSNotification
- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat keyboardHeight = [UIScreen mainScreen].bounds.size.height - keyboardEndFrame.origin.y;
    CGFloat bottomHeight = self.bottomView.bounds.size.height + kMargin;
    if (keyboardHeight - bottomHeight > 0) {
        self.mainContentHeightOffset = keyboardEndFrame.size.height - bottomHeight;
    } else {
        self.mainContentHeightOffset = 0;
    }
    [self viewDidLayoutSubviews];
    [self scrollMainView];
}

#pragma mark - NXRightsSelectViewDelegate
- (void)rightsSelectView:(NXRightsSelectView *)selectView didRightsSelected:(NXLRights *)rights {
    if (self.selectedRights.getVaildateDateModel) {
        [rights setFileValidateDate:self.selectedRights.getVaildateDateModel];
    }
    self.selectedRights = rights;
}

- (void)rightsSelectView:(NXRightsSelectView *)selectView didHeightChanged:(CGFloat)height {
    [self viewDidLayoutSubviews];
}

#pragma mark
- (void)scrollMainView {
    if (self.mainContentHeightOffset) {
        CGFloat y = self.mainView.contentSize.height - self.mainView.bounds.size.height;
        if ([self.emailsView.textField isFirstResponder]) {
            y = y - self.commentInputView.bounds.size.height;
        }
        [self.mainView setContentOffset:CGPointMake(0, y>0?y:0) animated:YES];
    }
}

#pragma mark -
- (void)commonInit {
    self.topView.model = self.fileItem;
    self.topView.operationTitle = NSLocalizedString(@"UI_SHARE_A_PROTEDTED_FILE", NULL);
    WeakObj(self);
    self.topView.backClickAction = ^(id sender) {
        StrongObj(self);
        [self backButtonClicked:nil];
    };
    
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.bottomView);
        make.width.equalTo(@300);
        make.height.lessThanOrEqualTo(self.bottomView).multipliedBy(0.7);
        make.height.lessThanOrEqualTo(@(40));
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [self.mainView addGestureRecognizer:tap];
    tap.delegate = self;
    [tap addTarget:self action:@selector(tap:)];
}

- (NXRightsSelectView *)rightsSelectView {
    if (!_rightsSelectView) {
        NXRightsSelectView *rightsSelectView = [[NXRightsSelectView alloc] init];
        rightsSelectView.backgroundColor = [UIColor colorWithHexString:@"#f2f2f2"];
        rightsSelectView.delegate = self;
        
        WeakObj(self);
        rightsSelectView.fileValidityChagedBlock = ^(NXLFileValidateDateModel *model) {
            StrongObj(self);
            self.curFileValidateDateModel = model;
        };
        
        _rightsSelectView = rightsSelectView;
    }
    return _rightsSelectView;
}

- (NXRightsDisplayView *)rightsDisplayView {
    if (!_rightsDisplayView) {
        NXRightsDisplayView *displayView = [[NXRightsDisplayView alloc] init];
        _rightsDisplayView = displayView;
    }
    return _rightsDisplayView;
}

- (NXEmailView *)emailsView {
    if (!_emailsView) {
        NXEmailView *emailView = [[NXEmailView alloc] init];
        [self.mainView addSubview:emailView];
        emailView.delegate = self;
        _emailsView = emailView;
        _emailsView.rightBtnClicked = ^{
            NXLocalContactsVC *contactVC = [[NXLocalContactsVC alloc]init];
            contactVC.delegate = self;
            switch ([NXContactInfoTool checkAuthorizationStatus]) {
                case NXContactAuthStatusAlreadyDenied:{
                    NSString *appName = (NSString*)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
                    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MSG_SETTING_ACCESS_ADDRESS_BOOK", NULL),appName];
                    [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message  style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_OK", NULL) cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) OKActionHandle:^(UIAlertAction *action) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]) {
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                            }
                        });
                       
                    } cancelActionHandle:nil inViewController:self position:self.view];
                }
                    break;
                case NXContactAuthStatusAlreadyAuthorized:{
                    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:contactVC];
                    nav.modalPresentationStyle = UIModalPresentationFullScreen;
                    [self.navigationController presentViewController:nav animated:YES completion:nil];
                }
                     break;
                 case NXContactAuthStatusNotDetermined:
                    [NXContactInfoTool requestAccessEntityWithCompletion:^(BOOL granted, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (granted) {
                                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:contactVC];
                                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                                [self.navigationController presentViewController:nav animated:YES completion:nil];
                            }else{
                                
                            }
                        });
                    }];
                    break;
            }
        };
    }
    return _emailsView;
}

- (NXCommentInputView *)commentInputView {
    if (!_commentInputView) {
        NXCommentInputView *commentInputView = [[NXCommentInputView alloc] init];
        _commentInputView = commentInputView;
    }
    return _commentInputView;
}

- (UIButton *)shareButton {
    if (!_shareButton) {
        UIButton *shareButton = [[UIButton alloc] init];
        [self.bottomView addSubview:shareButton];
        shareButton.enabled = NO;
        [shareButton setTitle:NSLocalizedString(@"UI_SHARE_A_PROTEDTED_FILE", NULL) forState:UIControlStateNormal];
        [shareButton addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        //    [shareButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
        [shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [shareButton setBackgroundImage:[UIImage imageWithSize:CGSizeMake(200, 200) colors:@[RMC_GRADIENT_START_COLOR, RMC_GRADIENT_END_COLOR] gradientType:GradientTypeLeftToRight] forState:UIControlStateNormal];
        [shareButton cornerRadian:3];
        _shareButton = shareButton;
        _shareButton.accessibilityValue = @"SHARE_FILE_BTN";
    }
    return _shareButton;
}
- (void)updateSubViews {
    [self.view layoutIfNeeded];
    [self viewDidLayoutSubviews];
}
- (void)selectedEmail:(NSString *)emailStr {
    [self.emailsView addAEmail:emailStr];
}
@end
