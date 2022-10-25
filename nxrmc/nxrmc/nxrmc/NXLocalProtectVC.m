//
//  NXLocalProtectVC.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/5/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXLocalProtectVC.h"

#import "NXFileChooseFlowViewController.h"
#import "NXTimeServerManager.h"

#import "UIView+UIExt.h"
#import "HexColor.h"
#import "UIImage+ColorToImage.h"
#import "NXMessageViewManager.h"
#import "NXMBManager.h"
#import "Masonry.h"
#import "NXCustomTitleView.h"

#import "NXRMCDef.h"
#import "NXLRights.h"
#import "NXCommonUtils.h"
#import "NXWebFileManager.h"
#import "NXLoginUser.h"
#import "UIView+UIExt.h"
#import "NXCardStyleView.h"
#import "NXLeftImageButton.h"
#import "NXClassificationSelectView.h"
#import "NXOfflineFileManager.h"
#define KBTNTAG 1000
#define PREVIEWFOLDHEIGHT 98
 NSString * const kFinishedDownloadFile = @"finishedDownloadFile";
@interface NXLocalProtectVC ()<NXRightsSelectViewDelegate, NXFileChooseFlowViewControllerDelegate>

@property(nonatomic, strong) NXMBProgressView *progressView;

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NXLRights *selectedRights;

@property(nonatomic, strong) NSProgress *uploadProgerss;
@property(nonatomic, strong) NSString *downloadId;

@property(nonatomic, strong) NXFileBase *folder; //upload camera or library file to repository folder when do protect operation.

@property(nonatomic, strong) NSString *myVaultUploadOptIdentify;
@property(nonatomic, strong) NSString *myRepoSysUploadOptIdentify;
@property(nonatomic, strong) NSString *encryptFileOptIdentify;

@property(nonatomic,assign) BOOL isCancelButtonClicked;
@property(nonatomic,assign) BOOL isShowPreview;
@property(nonatomic, strong) UIView *specifyView;
@property(nonatomic, strong) UIButton *digitalBtn;
@property(nonatomic, strong) UIButton *classifyBtn;
@property(nonatomic, strong) NXClassificationSelectView *classificationView;
@property(nonatomic, copy)NSString *currentFileOrginalName;

@end

@implementation NXLocalProtectVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.uploadProgerss = [[NSProgress alloc] init];
    [self.uploadProgerss addObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted)) options:NSKeyValueObservingOptionNew context:NULL];
    
    [self commonInit];
    [self initData];
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
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self setScrollViewContentSize];
}

- (void)dealloc {
    [self.uploadProgerss removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
    [[NXWebFileManager sharedInstance] cancelDownload:self.downloadId];
}

#pragma mark
- (void)cancelButtonClicked:(id)sender {
    if (sender != nil) {
        _isCancelButtonClicked = YES;
        [[NXLoginUser sharedInstance].myVault cancelOperation:self.myVaultUploadOptIdentify];
        [[NXLoginUser sharedInstance].myRepoSystem cancelOperation:self.myRepoSysUploadOptIdentify];
        [[NXLoginUser sharedInstance].nxlOptManager cancelNXLOpt:self.encryptFileOptIdentify];
    }
    if (self.preview) {
        [self.preview removeFromSuperview];
        self.preview = nil;
    }
     [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)protect:(id)sender {
    self.protectButton.enabled = NO;
    
     if (!self.fileItem.localPath || ![[NSFileManager defaultManager] fileExistsAtPath:self.fileItem.localPath]) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_FILE_NOT_EXISTED", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
        self.protectButton.enabled = YES;
        return;
    }
    
    if (!self.selectedRights.getVaildateDateModel) {
            [self.selectedRights setFileValidateDate:[NXLoginUser sharedInstance].userPreferenceManager.userPreference.preferenceFileValidateDate];
    }
    
    if (![NXCommonUtils checkIsLegalFileValidityDate:[self.selectedRights getVaildateDateModel]]) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_FILE_EXPIRETIME_INVALID", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
        self.protectButton.enabled = YES;
        return;
    }
    
    NSArray *allMyvaltFileInDB = [[NXLoginUser sharedInstance].myVault getAllMyVaultFileInCoreData];
    if (allMyvaltFileInDB.count > 0) {
        for (NXMyVaultFile *myvaultFile in allMyvaltFileInDB) {
            if ([[myvaultFile.name stringByDeletingPathExtension] isEqualToString:self.fileItem.name]) {
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
                        [self protectNXLFile];
                    } cancelActionHandle:^(UIAlertAction *action) {
                        self.protectButton.enabled = YES;
                        [NXMBManager hideHUDForView:self.view];
                        [self cancelButtonClicked:nil];
                    } otherActionHandle:^(UIAlertAction *action) {
                        //no replace
                        NSMutableArray *currentFolderFilesNameArray = [[NSMutableArray alloc] init];
                        for (NXWorkSpaceFile *file in allMyvaltFileInDB) {
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
                        [self protectNXLFile];
                    } inViewController:self position:self.view];
                    return;
                }));
                return;
            }
        }
    }
    
    [self protectNXLFile];
}

- (void)protectNXLFile{
    NSString *fileName = self.fileItem.name;
       NSString *tmpPath = [NXCommonUtils createNewNxlTempFile:fileName];
       [NXMBManager showLoading:NSLocalizedString(@"MSG_COM_PROTECT_AND_UPLOADING", NULL) toView:self.view];
       NSDate *currentServerDate = [[NXTimeServerManager sharedInstance] currentServerTime];
       WeakObj(self);
    NXFile *fakeFile = [self.fileItem copy];
    fakeFile.fullPath = [NSString stringWithFormat:@"/%@",self.fileItem.name];
    fakeFile.fullServicePath = [NSString stringWithFormat:@"/%@",self.fileItem.name];
       self.encryptFileOptIdentify = [[NXLoginUser sharedInstance].nxlOptManager protectToNXLFile:fakeFile toPath:tmpPath permissions:self.selectedRights membershipId:nil createDate:currentServerDate  withCompletion:^(NSString *filePath, NSError *error) {
           dispatch_main_async_safe(^{
               StrongObj(self);
               if (error) {
                   [NXMBManager hideHUDForView:self.view];
                   [NXMBManager showMessage:error.localizedDescription?:NSLocalizedString(@"MSG_COM_ENCRYPT_FILE_FAILED", NULL) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
                   self.protectButton.enabled = YES;
                   if (self.currentFileOrginalName) {
                       self.fileItem.name = self.currentFileOrginalName;
                   }
               } else {
                   
                   if (DELEGATE_HAS_METHOD(self.delegate, @selector(viewcontroller:didfinishedOperationFile:toFile:))) {
                       [self.delegate viewcontroller:self didfinishedOperationFile:self.fileItem toFile:fakeFile];
                   }
                   [self cancelButtonClicked:nil];
                   if (_isCancelButtonClicked == YES) {
                       return;
                   }
                   [NXMessageViewManager showMessageViewWithTitle:self.fileItem.name details:NSLocalizedString(@"MSG_COM_SUCCESS_PROTECT", NULL) appendInfo:nil appendInfo2:NSLocalizedString(@"MSG_COM_FILE_HAS_BEEN_SAVED_TO_MYVAULT", NULL) image:[UIImage imageNamed:@"Success - White tick"] dismissAfter:kDelay*2 type:NXMessageViewManagerTypeGreen];
               }
           });
       }];
}

#pragma mark
- (void)initData {
    if (!self.fileItem) {
        return;
    }
    
    if (self.fileItem.localPath || [self.fileItem isKindOfClass:[NXMyVaultFile class]] || [self.fileItem isKindOfClass:[NXProjectFile class]]) {
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
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self) {
                    [NXMBManager hideHUDForView:self.mainView];
                    [self.progressView hide];
                    if (error) {
                       [NXMBManager showMessage:error.localizedDescription toView:self.mainView hideAnimated:YES afterDelay:kDelay];
                       self.protectButton.enabled = NO;
                       return;
                    }
                    file.parent = self.fileItem.parent;
                    self.fileItem = file;
                    [self updateData:self.fileItem];
                    [[NSNotificationCenter defaultCenter] postNotificationName: kFinishedDownloadFile object:nil];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                       [self.preview showSmallPreImageView];
                   });
                }
            });
        }];
    }
}

- (void)updateData:(NXFileBase *)fileItem {
//    NSString *fileExtension = fileItem.name.pathExtension;
//    if (!fileExtension || fileExtension.length == 0) {
//        fileExtension = fileItem.localPath.lastPathComponent;
//        self.tittleView.text = fileExtension;
//    }
//    else
//    {
//        self.tittleView.text = fileItem.name;
//    }
    self.navTittleView.accessibilityValue = @"UPLOAD_FILE_TITLE_LAB";

    BOOL ret = [[NXLoginUser sharedInstance].nxlOptManager isNXLFile:fileItem];
    if (ret) {
        self.protectButton.enabled = NO;
        [NXMBManager showLoading:NSLocalizedString(@"MSG_COM_GETTING_RIGHTS", NULL) toView:self.mainView];

        [[NXLoginUser sharedInstance].nxlOptManager getNXLFileRights:fileItem withWatermark:NO withCompletion:^(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray *watermark, NSString *owner, BOOL isOwner, NSError *error) {
            dispatch_main_async_safe(^{
                [NXMBManager hideHUDForView:self.mainView];
                [self updateUI:self.fileItem nxl:YES rights:rights message:NSLocalizedString(@"MSG_COM_GET_RIGHTS_FAILED", NULL) isStedWard:isOwner];
            });
        }];
      
    } else {
        [self updateUI:self.fileItem nxl:NO rights:nil message:nil isStedWard:NO];
    }
}

- (void)updateUI:(NXFileBase *)fileItem nxl:(BOOL)isNXL rights:(NXLRights *)rights message:(NSString *)noRightsMessage isStedWard:(BOOL)isSteward {
    NXPreviewFileView *previewFileView = [[NXPreviewFileView alloc] init];
    [self.mainView addSubview:previewFileView];
    [self.mainView sendSubviewToBack:previewFileView];
    previewFileView.fileItem = self.fileItem;
    previewFileView.showPreviewClick = ^(id sender) {
        [self changePreviewSize];
    };
    self.preview = previewFileView;
    if ([fileItem isKindOfClass:[NXProjectFile class]]) {
        previewFileView.promptMessage = NSLocalizedString(@"UI_FILE_WILL_BE_SAVED_TO", NULL);
        previewFileView.savedPath = self.folder.fullPath;
        previewFileView.enabled = YES;
    } else {
        previewFileView.promptMessage = NSLocalizedString(@"UI_PROTECTED_FILE_WILL_SAVED_TO", NULL);
        previewFileView.savedPath = NSLocalizedString(@"UI_MY_SPACE", NULL);
        previewFileView.enabled = NO;
    }
    
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [previewFileView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.mainView);
                make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
                make.height.equalTo(self.view.mas_safeAreaLayoutGuideHeight).multipliedBy(0.6);
            }];
        }
    }
    else
    {
        [previewFileView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mainView);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.height.equalTo(self.view).multipliedBy(0.6);
        }];
    }
    
    if (isNXL) {
        [self.preview removeFromSuperview];
        self.preview = nil;
//        NXRightsDisplayView *displayView = [[NXRightsDisplayView alloc]init];
//        [self.mainView addSubview:displayView];
//
//        _rightsDisplayView = displayView;
//        [displayView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.and.right.equalTo(previewFileView);
//            make.top.equalTo(previewFileView.mas_bottom).offset(kMargin/2);
//        }];
//        displayView.noRightsMessage = noRightsMessage;
//
//        [self.rightsDisplayView showSteward:isSteward];
//        self.rightsDisplayView.rights = rights;
//        self.selectedRights = rights;
        [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_NO_PROTECT_NXL_FILE", NULL) toView:self.mainView hideAnimated:YES afterDelay:kDelay * 2];
        self.protectButton.enabled = NO;
    } else {
        NXRightsSelectView *rightsView = [[NXRightsSelectView alloc] init];
        WeakObj(self);
        rightsView.fileValidityChagedBlock = ^(NXLFileValidateDateModel *model) {
            StrongObj(self);
            [self.selectedRights setFileValidateDate:model];
        };
        [self.mainView addSubview:rightsView];
        
        rightsView.delegate = self;
        _rightsSelectView = rightsView;
        self.specifyView.backgroundColor = [UIColor whiteColor];
        [self.specifyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.preview).offset(PREVIEWFOLDHEIGHT);
            make.left.equalTo(self.preview);
            make.right.equalTo(self.preview);
        }];
        [rightsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.specifyView);
            make.top.equalTo(self.specifyView.mas_bottom);
            make.height.greaterThanOrEqualTo(self.preview.mas_height);
        }];
        rightsView.noRightsMessage = noRightsMessage;
        
        NXLRights *rights = [[NXLRights alloc] init];
        [rights setRight:NXLRIGHTVIEW value:YES];
        [rights setFileValidateDate:[NXLoginUser sharedInstance].userPreferenceManager.userPreference.preferenceFileValidateDate];
        self.rightsSelectView.rights = rights;
        self.rightsSelectView.enabled = YES;
        self.selectedRights = rights;
        self.protectButton.enabled = YES;
         [self viewDidLayoutSubviews];
    }
}

- (void)chooseRepo:(NXRepositoryModel *)repoModel {
    NXFileChooseFlowViewController *vc = [[NXFileChooseFlowViewController alloc]initWithRepository:repoModel type:NXFileChooseFlowViewControllerTypeChooseDestFolder isSupportMultipleSelect:NO];
    vc.fileChooseVCDelegate = self;
    vc.repoModel = repoModel;
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}

#pragma mark - NXFileChooseFlowViewControllerDelegate

- (void)fileChooseFlowViewController:(NXFileChooseFlowViewController *)vc didChooseFile:(NSArray *)choosedFiles {
    if (choosedFiles.count) {
        self.folder = choosedFiles.lastObject;
        _preview.savedPath = [NSString stringWithFormat:@"%@%@", _folder.serviceAlias, _folder.fullPath];
    }
}

- (void)fileChooseFlowViewControllerDidCancelled:(NXFileChooseFlowViewController *)vc {
    
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
        if (self.currentType == NXSelectRightsTypeDigital ) {
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
#pragma mark
- (void)commonInit {
    self.isShowPreview = NO;
    NXCustomTitleView *titleView = [[NXCustomTitleView alloc] init];
    titleView.text = NSLocalizedString(@"UI_CREATE_A_PROTECTED_FILE", NULL);
    self.navigationItem.titleView = titleView;
    self.navTittleView = titleView;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClicked:)];
    rightItem.accessibilityValue = @"UI_BOX_CANCEL";
    self.navigationItem.rightBarButtonItem = rightItem;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom);
    }];
    
    [self.topView removeFromSuperview];
    
    UIButton *protectButton = [[UIButton alloc] init];
    [self.bottomView addSubview:protectButton];
    protectButton.enabled = NO;
    [protectButton setTitle:NSLocalizedString(@"UI_CREATE_A_PROTECTED_FILE", NULL) forState:UIControlStateNormal];
    protectButton.accessibilityValue = @"PROTECT_BTN";
    [protectButton addTarget:self action:@selector(protect:) forControlEvents:UIControlEventTouchUpInside];
    [protectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [protectButton setBackgroundImage:[UIImage imageWithSize:CGSizeMake(200, 200) colors:@[RMC_GRADIENT_START_COLOR, RMC_GRADIENT_END_COLOR] gradientType:GradientTypeLeftToRight] forState:UIControlStateNormal];
    [protectButton cornerRadian:3];

    [protectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.bottomView);
        make.width.equalTo(@300);
        make.height.lessThanOrEqualTo(self.bottomView).multipliedBy(0.7);
        make.height.lessThanOrEqualTo(@(40));
    }];
    _protectButton = protectButton;
    
#if 0
    self.mainView.backgroundColor = [UIColor colorWithHexString:@"#00ff00"];
#endif
}

- (void)changePreviewSize {
    if (self.isShowPreview) {
        [self.specifyView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.preview).offset(PREVIEWFOLDHEIGHT);
            make.left.equalTo(self.preview);
            make.right.equalTo(self.preview);
        }];
    }else{
        [self.specifyView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.preview.mas_bottom).offset(kMargin);
            make.left.equalTo(self.preview);
            make.right.equalTo(self.preview);
        }];
        
    }
    self.isShowPreview = !self.isShowPreview;
    [UIView animateWithDuration:0.7 animations:^{
        [self.mainView layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self setScrollViewContentSize];
    }];
    
}
- (void)setScrollViewContentSize {
    CGFloat height;
    switch (self.currentType) {
        case NXSelectRightsTypeDigital:
            height = (self.isShowPreview ? CGRectGetHeight(self.preview.bounds) : PREVIEWFOLDHEIGHT)+ CGRectGetHeight(self.rightsSelectView.bounds)+CGRectGetHeight(self.specifyView.bounds)+CGRectGetHeight(self.rightsDisplayView.bounds);
            break;
        case NXSelectRightsTypeClassification:
            height = (self.isShowPreview ? CGRectGetHeight(self.preview.bounds) : PREVIEWFOLDHEIGHT) + CGRectGetHeight(self.classificationView.bounds)+CGRectGetHeight(self.specifyView.bounds)+CGRectGetHeight(self.rightsDisplayView.bounds);
            break;
    }
    if (self.mainView.bounds.size.height > height) {
        self.mainView.contentSize = CGSizeMake(CGRectGetWidth(self.mainView.bounds), CGRectGetHeight(self.mainView.bounds) + 10);
    } else {
        self.mainView.contentSize = CGSizeMake(CGRectGetWidth(self.mainView.bounds), height + kMargin * 3);
    }
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
//            case NXSelectRightsTypeDigital:
//            {
//                self.classificationView.hidden = YES;
//                self.rightsSelectView.hidden = NO;
//                
//            }
//                break;
//            case NXSelectRightsTypeClassification:
//            {
//                self.classificationView.hidden = NO;
//                self.rightsSelectView.hidden = YES;
//            }
//                break;
//        }
//        sender.backgroundColor = RMC_MAIN_COLOR;
//        sender.selected = YES;
//        [self setScrollViewContentSize];
//        
//    }
}
@end
