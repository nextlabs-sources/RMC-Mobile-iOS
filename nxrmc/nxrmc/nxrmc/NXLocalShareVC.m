//
//  NXLocalShareVC.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/5/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXLocalShareVC.h"

#import "NXChooseDriveView.h"
#import "NXPreviewFileView.h"
#import "NXRightsSelectView.h"
#import "NXRightsDisplayView.h"
#import "NXEmailView.h"
#import "NXCommentInputView.h"

#import "UIView+UIExt.h"
#import "UIImage+ColorToImage.h"
#import "NXRMCDef.h"
#import "NXMBManager.h"
#import "NXMessageViewManager.h"
#import "NXCustomTitleView.h"

#import "NXSharedWithMeFile.h"
#import "NXLRights.h"
#import "NXWebFileManager.h"
#import "NXLoginUser.h"
#import "NXLMetaData.h"
#import "NXCommonUtils.h"
#import "NXLogAPI.h"
#import "NXSyncHelper.h"
#import "NXCacheManager.h"
#import "Masonry.h"
#import "NXLocalContactsVC.h"
#import "NXContactInfoTool.h"
#import "NXCardStyleView.h"
#import "NXLeftImageButton.h"
#import "NXClassificationSelectView.h"
#import "NXProtectedFileListView.h"
#import "DetailViewController.h"
#define PREVIEWFOLDHEIGHT 20
#define KBTNTAG 1000
@interface NXLocalShareVC ()<NXRightsSelectViewDelegate, NXEmailViewDelegate, UIGestureRecognizerDelegate,NXLocalContactsVCDelegate>

@property(nonatomic, strong) NSString *name;

//@property(nonatomic, weak) NXPreviewFileView *preview;
@property(nonatomic, weak, readonly) NXRightsSelectView *rightsSelectView;
@property(nonatomic, weak, readonly) NXRightsDisplayView *rightsDisplayView;
@property(nonatomic, weak) NXEmailView *emailsView;
@property(nonatomic, strong) NXCommentInputView *commentInputView;
@property(nonatomic, strong) UIView *backgroundInfoView;
@property(nonatomic, weak, readonly) UIButton *shareButton;
@property(nonatomic, strong)NXProtectedFileListView *fileListView;
@property(nonatomic, strong) NXMBProgressView *progressView;
@property(nonatomic, assign) CGFloat mainContentHeightOffset; //used for keyboard show or hide event, we should change mainview contantsize when keyboard show or hide.

@property(nonatomic, assign) BOOL isNXL;

@property(nonatomic, strong) NXLRights *selectedRights;
@property(nonatomic, strong) NSString *shareOperationId;
@property(nonatomic, strong) NSString *downloadId;
@property(nonatomic,assign) BOOL isShowPreview;

@property(nonatomic, strong) UIView *specifyView;
@property(nonatomic, strong) UIButton *digitalBtn;
@property(nonatomic, strong) UIButton *classifyBtn;
@property(nonatomic, strong) NXClassificationSelectView *classificationView;
@property(nonatomic, copy)NSString *currentFileOrginalName;
@end

@implementation NXLocalShareVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
    [self initData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name: UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self.preview showSmallPreImageView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat height;
    if (self.currentType == NXShareSelectRightsTypeDigital) {
        height = (self.isShowPreview ? CGRectGetHeight(self.fileListView.bounds) : PREVIEWFOLDHEIGHT) + CGRectGetHeight(self.rightsSelectView.bounds) + CGRectGetHeight(self.emailsView.bounds)+CGRectGetHeight(self.rightsDisplayView.bounds) + CGRectGetHeight(self.commentInputView.bounds) + CGRectGetHeight(self.specifyView.bounds);
    }else {
         height = (self.isShowPreview ? CGRectGetHeight(self.fileListView.bounds) : PREVIEWFOLDHEIGHT) + CGRectGetHeight(self.classificationView.bounds) + CGRectGetHeight(self.emailsView.bounds)+CGRectGetHeight(self.rightsDisplayView.bounds) + CGRectGetHeight(self.commentInputView.bounds) + CGRectGetHeight(self.specifyView.bounds);
        
    }
    CGFloat contentHeight = height + kMargin * 4 + kMargin * 3 + self.mainContentHeightOffset;
    if (self.mainView.bounds.size.height > contentHeight) {
        self.mainView.contentSize = CGSizeMake(CGRectGetWidth(self.mainView.bounds), CGRectGetHeight(self.mainView.bounds) + 1);
    } else {
        self.mainView.contentSize = CGSizeMake(CGRectGetWidth(self.mainView.bounds), contentHeight + 1);
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NXWebFileManager sharedInstance] cancelDownload:self.downloadId];
    DLog();
}

#pragma mark
- (void)tap:(UIGestureRecognizer *)gestuer {
    [self.view endEditing:YES];
}

- (void)cancel:(UIBarButtonItem *)sender {
    [[NXLoginUser sharedInstance].nxlOptManager cancelNXLOpt:self.shareOperationId];
//    if (self.preview) {
//        [self.preview removeFromSuperview];
//        self.preview = nil;
//    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)share:(id)sender {
    //1 have cache or not
    //  //1 have cache or not
    
  if (!self.selectedRights.getVaildateDateModel) {
        [self.selectedRights setFileValidateDate:[NXLoginUser sharedInstance].userPreferenceManager.userPreference.preferenceFileValidateDate];
    }
    
    if (![self.fileItem isKindOfClass:[NXMyVaultFile class]] && ![self.fileItem isKindOfClass:[NXSharedWithMeFile class]] && self.fileItem.serviceType.integerValue != kServiceSkyDrmBox) {
        if (!self.fileItem.localPath || ![[NSFileManager defaultManager] fileExistsAtPath:self.fileItem.localPath]) {
            [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_FILE_NOT_EXISTED", NULL) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
            self.shareButton.enabled = YES;
            return;
        }
    }
    
    //2 check email
    if (self.emailsView.vaildEmails.count == 0) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_NO_VAILD_EMAIL_ADDRESS", NULL) hideAnimated:YES afterDelay:kDelay];
        return;
    }
    
    if ([self.emailsView isExistInvalidEmail]) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_HAVE_INVALID_EMAIL_ADDRESS", NULL) hideAnimated:YES afterDelay:kDelay];
        return;
        
    }
    
    if (![NXCommonUtils checkIsLegalFileValidityDate:[self.selectedRights getVaildateDateModel]]) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_FILE_EXPIRETIME_INVALID", NULL) hideAnimated:YES afterDelay:kDelay];
        return;
    }

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
                                [self shareFile];
                           } cancelActionHandle:^(UIAlertAction *action) {
                               self.shareButton.enabled = YES;
                               [NXMBManager hideHUDForView:self.view];
                               [self cancel:nil];
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
                        [self shareFile];
                    } cancelActionHandle:^(UIAlertAction *action) {
                        self.shareButton.enabled = YES;
                        [NXMBManager hideHUDForView:self.view];
                        [self cancel:nil];
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
                        
                        [self shareFile];
                    } inViewController:self position:self.view];
                    return;
                }));
                return;
            }
        }
    }
    
    //3 share.
    self.shareButton.enabled = NO;
    [self shareFile];
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

- (void)shareFile {
    [NXMBManager showLoading:NSLocalizedString(@"MSG_SHARING", NULL) toView:self.view];
        
        self.shareOperationId = [[NXLoginUser sharedInstance].nxlOptManager shareFile:self.fileItem recipients:self.emailsView.vaildEmails permissions:self.selectedRights comment:self.commentInputView.textView.text withCompletion:^(NSString *sharedFileName,NSString *duid, NSArray *alreadySharedArray, NSArray *newSharedArray, NSError *error) {
            dispatch_main_async_safe((^{
                [NXMBManager hideHUDForView:self.view];
                if (error) {
                    [NXMBManager showMessage:error.localizedDescription?[NSString stringWithFormat:@"%@,%@", NSLocalizedString(@"MSG_COM_FAILED", NULL),error.localizedDescription]:NSLocalizedString(@"MSG_SHARE_FILE_FAILED", NULL) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
                    self.shareButton.enabled = YES;
                    if (self.currentFileOrginalName) {
                        self.fileItem.name = self.currentFileOrginalName;
                    }
                } else {
                    if (DELEGATE_HAS_METHOD(self.delegate, @selector(viewcontroller:didfinishedOperationFile:toFile:))) {
                        [self.delegate viewcontroller:self didfinishedOperationFile:self.fileItem toFile:self.fileItem];
                    }
                    [self cancel:nil];
    //                NSString *email = [self.emailsView.vaildEmails componentsJoinedByString:@" "];
    //                [NXMessageViewManager showMessageViewWithTitle:self.fileItem.name details:NSLocalizedString(@"MSG_SUCCESS_SHARE", NULL) appendInfo:email appendInfo2:NSLocalizedString(@"MSG_COM_FILE_HAS_BEEN_SAVED_TO_MYVAULT", NULL) image:[UIImage imageNamed:@"Success - White tick"] dismissAfter:kDelay*2 type:NXMessageViewManagerTypeGreen];
                    
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
            }));
        }];
}

#pragma mark - private method
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
        self.downloadId = [[NXWebFileManager sharedInstance] downloadFile:(NXFileBase<NXWebFileDownloadItemProtocol>*)self.fileItem withProgress:progressBlock completed:^(NXFileBase *file, NSData *fileData, NSError *error) {
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

- (void)updateData:(NXFileBase *)localFile {
    if (localFile == NULL) {
        return;
    }
    BOOL ret = [[NXLoginUser sharedInstance].nxlOptManager isNXLFile:localFile];
    if (ret) {
        self.shareButton.enabled = NO;
        [NXMBManager showLoading:NSLocalizedString(@"MSG_COM_GETTING_RIGHTS", NULL) toView:self.mainView];
        [[NXLoginUser sharedInstance].nxlOptManager getNXLFileRights:localFile withWatermark:NO withCompletion:^(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray *watermark, NSString *owner, BOOL isOwner, NSError *error) {
            dispatch_main_async_safe(^{
                [NXMBManager hideHUDForView:self.mainView];
                [self updateUI:localFile nxl:YES rights:rights message:NSLocalizedString(@"MSG_COM_GET_RIGHTS_FAILED", NULL) isSteward:isOwner owner:owner];
            });
        }];
    } else {
        [self updateUI:self.fileItem nxl:NO rights:nil message:nil isSteward:NO owner:nil];
    }
}

- (void)updateUI:(NXFileBase *)fileItem nxl:(BOOL)isNXL rights:(NXLRights *)rights message:(NSString *)noRightsMessage isSteward:(BOOL)isSteward owner:(NSString *)owner {
    self.isShowPreview = NO;
    self.isNXL = isNXL;
//    NXPreviewFileView *previewFileView = [[NXPreviewFileView alloc] init];
//    [self.mainView addSubview:previewFileView];
//    [self.mainView sendSubviewToBack:previewFileView];
//
//    previewFileView.fileItem = self.fileItem;
//    previewFileView.enabled = NO;
//    previewFileView.promptMessage = NSLocalizedString(@"UI_SHARED_FILE_WILL_BE_SAVED_TO", NULL);
//
//    previewFileView.savedPath = NSLocalizedString(@"UI_MY_SPACE", NULL);
//
//    _preview = previewFileView;
//    previewFileView.showPreviewClick = ^(id sender) {
//        [self changePreviewSize];
//    };
    NXProtectedFileListView *fileListView = [[NXProtectedFileListView alloc] initWithFileList:@[fileItem]];
    [self.mainView addSubview:fileListView];
    self.fileListView = fileListView;
    fileListView.fileClickedCompletion = ^(NXFileBase * _Nonnull file) {
      // preview this file
        DetailViewController *detailVC = [[DetailViewController alloc] init];
        [detailVC openFileForPreview:file];
        [self.navigationController pushViewController:detailVC animated:YES];
    };
    [fileListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mainView);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
    }];
    
   
    if (isNXL) {
        [self.shareButton setTitle:@"Share file" forState:UIControlStateNormal];
        [[NXLoginUser sharedInstance].nxlOptManager canDoOperation:NXLRIGHTSHARING forFile:self.fileItem withCompletion:^(BOOL isAllowed, NSString *duid, NXLRights*rights, NSString *owner, BOOL isOwner, NSError *error) {
            dispatch_main_async_safe(^{
                if (isAllowed) {
                    self.shareButton.enabled = YES;
                }else{
                    [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_NO_SHARE_RIGHT", NULL) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
                    self.shareButton.enabled = NO;
                }
              
                UIView *infoView = [[UIView alloc] init];
                infoView.backgroundColor = [UIColor whiteColor];
                [self.mainView addSubview:infoView];
                NXRightsDisplayView *displayView = [[NXRightsDisplayView alloc] init];
                _rightsDisplayView = displayView;
                [infoView addSubview:displayView];
                self.backgroundInfoView = infoView;
                [infoView addSubview:self.emailsView];
                [infoView addSubview:self.commentInputView];
                [infoView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(fileListView.mas_bottom).offset(kMargin);
                    make.left.right.equalTo(self.fileListView);
                }];
                [displayView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.right.equalTo(infoView);
                    make.top.equalTo(infoView).offset(kMargin);
                }];
                [self.emailsView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(infoView).offset(kMargin * 1.3);
                    make.right.equalTo(displayView);
                    make.top.equalTo(displayView.mas_bottom).offset(kMargin * 2);
                }];
                [self.commentInputView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.emailsView.mas_bottom).offset(kMargin * 2);
                    make.left.and.right.equalTo(self.emailsView);
                    make.height.equalTo(@160);
                    make.bottom.equalTo(infoView).offset(-kMargin * 6);
                }];
                
                self.rightsDisplayView.rights = rights;
                [self.rightsDisplayView showSteward:isOwner];
                self.selectedRights = rights;
                self.rightsSelectView.noRightsMessage = noRightsMessage;
            });
        }];
    } else {
        self.specifyView.backgroundColor = [UIColor whiteColor];
        [self.mainView addSubview:self.specifyView];
        [self.mainView addSubview:self.emailsView];
        NXRightsSelectView *rightsView = [[NXRightsSelectView alloc] init];
        rightsView.fileValidityChagedBlock = ^(NXLFileValidateDateModel *model) {
            [self.selectedRights setFileValidateDate:model];
        };
        rightsView.delegate = self;
        _rightsSelectView = rightsView;
        [self.mainView addSubview:rightsView];
        [self.specifyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(fileListView.mas_bottom).offset(kMargin);
            make.left.equalTo(fileListView);
            make.right.equalTo(fileListView);
        }];
        [rightsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.specifyView);
            make.top.equalTo(self.specifyView.mas_bottom);
            make.height.greaterThanOrEqualTo(fileListView.mas_height);
        }];
        [self.emailsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(kMargin * 1.3);
            make.right.equalTo(rightsView);
            make.top.equalTo(rightsView.mas_bottom).offset(kMargin * 4);
        }];
        
        NXLRights *rights = [[NXLRights alloc] init];
        [rights setRight:NXLRIGHTVIEW value:YES];
        [rights setFileValidateDate:[NXLoginUser sharedInstance].userPreferenceManager.userPreference.preferenceFileValidateDate];
        self.selectedRights = rights;
        self.rightsSelectView.rights = rights;
        self.rightsSelectView.enabled = YES;
        self.shareButton.enabled = YES;
        [self.mainView addSubview:self.commentInputView];
        [self.commentInputView mas_makeConstraints:^(MASConstraintMaker *make) {
           make.top.equalTo(self.emailsView.mas_bottom).offset(kMargin * 3);
           make.left.and.right.equalTo(self.emailsView);
           make.height.equalTo(@160);
        }];
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

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UITextField class]] ||[touch.view isKindOfClass:[UITextView class]]) {
        return NO;
    } else {
        [self tap:nil];
        return NO;
    }
}

#pragma mark - NXLRightsSelectViewDelegate
- (void)rightsSelectView:(NXRightsSelectView *)selectView didHeightChanged:(CGFloat)height {
    [self viewDidLayoutSubviews];
}

- (void)rightsSelectView:(NXRightsSelectView *)selectView didRightsSelected:(NXLRights *)rights {
     if (self.selectedRights.getVaildateDateModel) {
        [rights setFileValidateDate:self.selectedRights.getVaildateDateModel];
    }
    self.selectedRights = rights;
}

#pragma mark - NXEmailViewDelegate
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
#pragma mark ------> localContactVC deiegate
- (void)selectedEmail:(NSString *)emailStr {
    [self.emailsView addAEmail:emailStr];
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

#pragma mark
- (void)commonInit {
    NXCustomTitleView *titleView = [[NXCustomTitleView alloc] init];
    titleView.text = NSLocalizedString(@"UI_SHARE_A_PROTEDTED_FILE", NULL);
    self.navigationItem.titleView = titleView;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.automaticallyAdjustsScrollViewInsets = NO;
    

    [self.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom);
    }];
    
    [self.topView removeFromSuperview];
    
    UIButton *shareButton = [[UIButton alloc] init];
    [self.bottomView addSubview:shareButton];
    shareButton.enabled = NO;
    [shareButton setTitle:NSLocalizedString(@"UI_PROTECT_AND_SHARE_FILE", NULL) forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
    [shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [shareButton setBackgroundImage:[UIImage imageWithSize:CGSizeMake(200, 200) colors:@[RMC_GRADIENT_START_COLOR, RMC_GRADIENT_END_COLOR] gradientType:GradientTypeLeftToRight] forState:UIControlStateNormal];
    [shareButton cornerRadian:3];
    
    [shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.bottomView);
        make.width.equalTo(@300);
        make.height.lessThanOrEqualTo(self.bottomView).multipliedBy(0.7);
        make.height.lessThanOrEqualTo(@(40));
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [self.mainView addGestureRecognizer:tap];
    tap.delegate = self;
    [tap addTarget:self action:@selector(tap:)];
    
    _shareButton = shareButton;
//    _preview = previewFileView;
//    _rightsSelectView = rightsView;
    
#if 0
    self.mainView.backgroundColor = [UIColor magentaColor];
    previewFileView.backgroundColor = [UIColor redColor];
    emailsView.backgroundColor = [UIColor greenColor];
    _rightsSelectView.backgroundColor = [UIColor brownColor];
    self.bottomView.backgroundColor = [UIColor orangeColor];
#endif
}

- (UIButton *)createSelectRightsTypeBtnWithTitle:(NSString *)title {
    NXLeftImageButton *button = [[NXLeftImageButton alloc]init];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    button.titleLabel.textAlignment = NSTextAlignmentLeft;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [button setImage:[UIImage imageNamed:@"Group-Not-selected"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"Group-selected"] forState:UIControlStateSelected];
    
    [button addTarget:self action:@selector(selectTypeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [button cornerRadian:20];
    return button;
}

- (UIView *)specifyView {
    if (!_specifyView) {
        _specifyView = [[UIView alloc]init];
        [self.mainView addSubview:_specifyView];
        UILabel *specifyLabel =[[UILabel alloc]init];
        specifyLabel.text = NSLocalizedString(@"UI_SPECIFY_DIGITAL_OR_CLASSIFY", NULL);
        specifyLabel.font = [UIFont systemFontOfSize:17];
        specifyLabel.numberOfLines = 0;
        specifyLabel.textAlignment = NSTextAlignmentCenter;
        [_specifyView addSubview:specifyLabel];
        NXCardStyleView *digitalCardView = [[NXCardStyleView alloc]init];
        [_specifyView addSubview:digitalCardView];
        UIButton *digitalBtn = [self createSelectRightsTypeBtnWithTitle:NSLocalizedString(@"UI_DIGITAL_RIGHTS", NULL)];
        digitalBtn.tag = KBTNTAG;
        [digitalBtn addTarget:self action:@selector(selectTypeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_specifyView addSubview:digitalBtn];
        self.digitalBtn = digitalBtn;
        NXCardStyleView *classifyCardView = [[NXCardStyleView alloc]init];
        [_specifyView addSubview:classifyCardView];
        UIButton *classifyBtn = [self createSelectRightsTypeBtnWithTitle:NSLocalizedString(@"UI_DOCUMENT_CLASSIFICATION", NULL)];
        classifyBtn.tag = KBTNTAG + 1;
        [classifyBtn addTarget:self action:@selector(selectTypeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        classifyBtn.enabled = YES;
        classifyBtn.selected = YES;
        classifyBtn.backgroundColor = RMC_MAIN_COLOR;
        [_specifyView addSubview:classifyBtn];
        self.classifyBtn = classifyBtn;
        if (self.currentType == NXShareSelectRightsTypeDigital ) {
            digitalBtn.enabled = YES;
            digitalBtn.selected = YES;
            digitalBtn.backgroundColor = RMC_MAIN_COLOR;
            classifyBtn.enabled = NO;
            classifyBtn.backgroundColor = [HXColor colorWithHexString:@"#F1F1F1"];
            [classifyBtn setTitleColor:[HXColor colorWithHexString:@"#BABABA"] forState:UIControlStateNormal];
        }
        [specifyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_specifyView).offset(kMargin * 2.5);
            make.left.equalTo(_specifyView).offset(kMargin);
            make.right.equalTo(_specifyView).offset(-kMargin);
        }];
        
        [classifyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(specifyLabel.mas_bottom).offset(kMargin * 2.5);
            make.left.equalTo(specifyLabel);
            make.width.equalTo(specifyLabel).multipliedBy(0.5);
            make.height.equalTo(@44);
        }];
        [digitalCardView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(digitalBtn);
        }];
        [digitalBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.height.equalTo(classifyBtn);
            make.left.equalTo(classifyBtn.mas_right).offset(kMargin);
            make.right.equalTo(specifyLabel);
            make.bottom.equalTo(_specifyView).offset(-kMargin * 2.5);
        }];
        [classifyCardView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(classifyBtn);
        }];
    }
    return _specifyView;
}



//- (void)changePreviewSize {
//    if (self.isNXL) {
//        if (self.isShowPreview) {
//
//            [self.rightsDisplayView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.top.equalTo(self.preview).offset(PREVIEWFOLDHEIGHT);
//                make.left.equalTo(self.preview);
//                make.right.equalTo(self.preview);
//                make.height.equalTo(self.preview).multipliedBy(0.85);
//            }];
//        }else{
//            [self.rightsDisplayView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.top.equalTo(self.preview.mas_bottom).offset(kMargin);
//                make.left.equalTo(self.preview);
//                make.right.equalTo(self.preview);
//                make.height.equalTo(self.preview).multipliedBy(0.85);
//            }];
//        }
//    }else{
//        if (self.isShowPreview) {
//
//            [self.rightsSelectView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.top.equalTo(self.preview).offset(PREVIEWFOLDHEIGHT);
//                make.left.equalTo(self.preview);
//                make.right.equalTo(self.preview);
//                make.height.greaterThanOrEqualTo(self.preview.mas_height);
//            }];
//        }else{
//            [self.rightsSelectView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.top.equalTo(self.preview.mas_bottom).offset(kMargin);
//                make.left.equalTo(self.preview);
//                make.right.equalTo(self.preview);
//                make.height.greaterThanOrEqualTo(self.preview.mas_height);
//            }];
//        }
//    }
//
//    self.isShowPreview = !self.isShowPreview;
//    [UIView animateWithDuration:0.7 animations:^{
//        [self.mainView layoutIfNeeded];
//    } completion:^(BOOL finished) {
//        [self viewDidLayoutSubviews];
//    }];
//}
//- (void)changePreviewSize {
//    if (self.isNXL) {
//        if (self.isShowPreview) {
//            [self.backgroundInfoView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.top.equalTo(self.preview).offset(PREVIEWFOLDHEIGHT);
//                make.left.equalTo(self.preview);
//                make.right.equalTo(self.preview);
////                make.height.equalTo(self.preview).multipliedBy(0.85);
//            }];
//        }else{
//            [self.backgroundInfoView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.top.equalTo(self.preview.mas_bottom).offset(kMargin);
//                make.left.equalTo(self.preview);
//                make.right.equalTo(self.preview);
////                make.height.equalTo(self.preview).multipliedBy(0.85);
//            }];
//        }
//    }else{
//        if (self.isShowPreview) {
//            [self.specifyView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.top.equalTo(self.preview).offset(PREVIEWFOLDHEIGHT);
//                make.left.equalTo(self.preview);
//                make.right.equalTo(self.preview);
//            }];
//        }else{
//            [self.specifyView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.top.equalTo(self.preview.mas_bottom).offset(kMargin);
//                make.left.equalTo(self.preview);
//                make.right.equalTo(self.preview);
//            }];
//
//        }
//
//    }
//
//    self.isShowPreview = !self.isShowPreview;
//    [UIView animateWithDuration:0.7 animations:^{
//        [self.mainView layoutIfNeeded];
//    } completion:^(BOOL finished) {
//        [self viewDidLayoutSubviews];
//    }];
//
//}
- (NXCommentInputView *)commentInputView {
    if (!_commentInputView) {
        NXCommentInputView *commentInputView = [[NXCommentInputView alloc] init];
        _commentInputView = commentInputView;
    }
    return _commentInputView;
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
//                    [self.navigationController pushViewController:contactVC animated:YES];
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
- (void)selectTypeBtnClick:(UIButton *)sender {
    return;
    
//    NSInteger index = sender.tag - KBTNTAG;
//    if (index == self.currentType) {
//        return;
//    }else {
//        self.digitalBtn.selected = NO;
//        self.digitalBtn.backgroundColor = [UIColor whiteColor];
//        self.classifyBtn.selected = NO;
//        self.classifyBtn.backgroundColor = [UIColor whiteColor];
//        self.currentType = index;
//        switch (index) {
//            case NXShareSelectRightsTypeDigital:
//            {
//                self.classificationView.hidden = YES;
//                self.rightsSelectView.hidden = NO;
//
//            }
//                break;
//            case NXShareSelectRightsTypeClassification:
//            {
//                self.classificationView.hidden = NO;
//                self.rightsSelectView.hidden = YES;
//            }
//                break;
//        }
//        sender.backgroundColor = RMC_MAIN_COLOR;
//        sender.selected = YES;
//        [self viewDidLayoutSubviews];
        
//    }
}

@end
