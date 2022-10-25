//
//  NXProtectAndSaveFileFromFilesVC.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/4/15.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXProtectAndSaveFileFromFilesVC.h"
#import "NXFileChooseFlowViewController.h"
#import "UIView+UIExt.h"
#import "NXMBManager.h"
#import "Masonry.h"
#import "NXLoginUser.h"
#import "NXClassificationLab.h"
#import "NXClassificationCategory.h"
#import "NXRightsSelectView.h"
#import "NXClassificationSelectView.h"
#import "NXCommonUtils.h"
#import "NXCardStyleView.h"
#import "NXLRights.h"
#import "NXLeftImageButton.h"
#import "NXLProfile.h"
#import "NXWebFileManager.h"
#import "HexColor.h"
#import "NXRightsMoreOptionsVC.h"
#import "NXRightsCellModel.h"
#import "NXWorkSpaceItem.h"
#import "NXWorkSpaceUploadFileAPI.h"
#import "NXTimeServerManager.h"
#import "NXOriginalFilesTransfer.h"
#import "NXMessageViewManager.h"
#define KBTNTAG 1000
#define PREVIEWFOLDHEIGHT 98

@interface NXProtectAndSaveFileFromFilesVC ()<NXRightsSelectViewDelegate>
@property(nonatomic, strong) NXLRights *selectedRights;
@property(nonatomic, strong) NSString *operationIdentifier;
@property(nonatomic, strong) NSString *uploadOperationIdentifier;
@property(nonatomic, strong) NXRightsSelectView *digitalView;
@property(nonatomic, strong) NXClassificationSelectView *classificationView;
@property(nonatomic, strong)NSArray <NXClassificationCategory *>*classificationCategoryArray;
@property(nonatomic, strong)NSMutableArray *selectBtns;
@property(nonatomic, strong)UIView *specifyView;
@property(nonatomic, strong)UIButton *digitalBtn;
@property(nonatomic, strong)UIButton *classifyBtn;
@property(nonatomic, assign)BOOL isShowPreview;
@property(nonatomic, assign)BOOL isAdhocEnable;
@property(nonatomic, assign)BOOL isClassificationEbable;
@property(nonatomic, strong) NSString *myRepoSysUploadOptIdentify;
@property(nonatomic, copy)NSString *currentFileOrginalName;

@end

@implementation NXProtectAndSaveFileFromFilesVC
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
- (NSMutableArray *)selectBtns {
    if (!_selectBtns) {
        _selectBtns = [NSMutableArray array];
    }
    return _selectBtns;
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
- (NXRightsSelectView *)digitalView {
    if (!_digitalView) {
        _digitalView = [[NXRightsSelectView alloc]init];
        [self.mainView addSubview:_digitalView];
        [self.mainView bringSubviewToFront:_digitalView];
        NXLRights *rights = [[NXLRights alloc] init];
        [rights setRight:NXLRIGHTVIEW value:YES];
        _digitalView.currentWatermarks = [NXLoginUser sharedInstance].userPreferenceManager.userPreference.preferenceWatermark;
        _digitalView.currentValidModel = [NXLoginUser sharedInstance].userPreferenceManager.userPreference.preferenceFileValidateDate;
        [rights setFileValidateDate:[NXLoginUser sharedInstance].userPreferenceManager.userPreference.preferenceFileValidateDate];
        _digitalView.rights = rights;
        _digitalView.enabled = YES;
        _digitalView.delegate = self;
        WeakObj(self);
        _digitalView.fileValidityChagedBlock = ^(NXLFileValidateDateModel *model) {
            StrongObj(self);
            [self.selectedRights setFileValidateDate:model];
        };
    }
    return _digitalView;
}
- (NXClassificationSelectView *)classificationView {
    if (!_classificationView) {
        _classificationView = [[NXClassificationSelectView alloc]init];
        [self.mainView addSubview:_classificationView];
    }
    return _classificationView;
}
- (void)commonInitUI {
    self.navTittleView.text = self.fileItem.name;
    [self.rightsSelectView removeFromSuperview];
    WeakObj(self);
    self.preview.savedPath = @"";
    self.preview.enabled = NO;
    self.preview.promptMessage = @"";
    self.preview.showPreviewClick = ^(id sender) {
        StrongObj(self);
        [self changePreviewSize];
    };
    self.specifyView.backgroundColor = [UIColor whiteColor];
    
    // ***** suppot adhocEnable *****
   
    if (self.isClassificationEbable) {
         self.currentType = NXSelectRightsTypeClassification;
        if (self.isAdhocEnable) {
            self.digitalBtn.enabled = YES;
            self.digitalBtn.backgroundColor = [UIColor whiteColor];
        }else{
            self.digitalBtn.selected = NO;
            self.digitalBtn.enabled = NO;
            self.digitalBtn.backgroundColor = [HXColor colorWithHexString:@"#F1F1F1"];
            [self.digitalBtn setTitleColor:[HXColor colorWithHexString:@"#BABABA"] forState:UIControlStateNormal];
            self.classifyBtn.enabled = YES;
            self.classifyBtn.selected = YES;
            self.classifyBtn.backgroundColor = RMC_MAIN_COLOR;
            self.currentType = NXSelectRightsTypeClassification;
            self.classificationView.hidden = NO;
            self.digitalView.hidden = YES;
        }
    }else{
        self.currentType = NXSelectRightsTypeDigital;
        self.classifyBtn.enabled = NO;
        self.classifyBtn.selected = NO;
        self.classifyBtn.backgroundColor = [HXColor colorWithHexString:@"#F1F1F1"];
        [self.classifyBtn setTitleColor:[HXColor colorWithHexString:@"#BABABA"] forState:UIControlStateNormal];
        self.digitalBtn.enabled = YES;
        self.digitalBtn.selected = YES;
        self.digitalBtn.backgroundColor = RMC_MAIN_COLOR;
        self.classificationView.hidden = YES;
        self.digitalView.hidden = NO;
        
    }
    
    if (self.isClassificationEbable) {
        self.operationIdentifier = [[NXLoginUser sharedInstance].workSpaceManager getWorkSpaceDefalutClassificationWithCompletion:^(NSArray *classifications, NSError *error) {
           if (!error) {
               self.classificationCategoryArray = [NSArray arrayWithArray:classifications];
               dispatch_async(dispatch_get_main_queue(), ^{
                 self.classificationView.classificationCategoryArray = self.classificationCategoryArray;
               });
           }
        }];
    }
   
    self.isShowPreview = NO;
    self.selectedRights = self.digitalView.rights;
    [self.specifyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.preview).offset(PREVIEWFOLDHEIGHT);
        make.left.equalTo(self.preview);
        make.right.equalTo(self.preview);
    }];
    [self.digitalView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.specifyView.mas_bottom);
        make.left.right.equalTo(self.specifyView);
        make.height.greaterThanOrEqualTo(self.preview.mas_height);
    }];
    [self.classificationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.specifyView.mas_bottom);
        make.left.right.equalTo(self.specifyView);
        make.height.greaterThanOrEqualTo(self.digitalView.mas_height);
    }];
    self.protectButton.enabled = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.protectButton setTitle:NSLocalizedString(@"UI_CREATE_A_PROTECTED_FILE", NULL) forState:UIControlStateNormal];
    // ***** suppot adhocEnable *****
    self.isAdhocEnable = YES;
    self.isClassificationEbable = YES;
    if ([NXLoginUser sharedInstance].profile.tenantPrefence) {
        self.isAdhocEnable = [NXLoginUser sharedInstance].profile.tenantPrefence.ADHOC_ENABLED;
    }
    
    if (self.preview) {
        [self commonInitUI];
    }
    [[NSNotificationCenter defaultCenter] addObserverForName:kFinishedDownloadFile object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        if (self.preview) {
            [self commonInitUI];
        }
    }];
}
- (void)setScrollViewContentSize {
    CGFloat height;
    switch (self.currentType) {
        case NXSelectRightsTypeDigital:
            height = (self.isShowPreview ? CGRectGetHeight(self.preview.bounds) : PREVIEWFOLDHEIGHT)+ CGRectGetHeight(self.digitalView.bounds)+CGRectGetHeight(_specifyView.bounds)+CGRectGetHeight(self.rightsDisplayView.bounds);
            break;
        case NXSelectRightsTypeClassification:
            height = (self.isShowPreview ? CGRectGetHeight(self.preview.bounds) : PREVIEWFOLDHEIGHT) + CGRectGetHeight(self.classificationView.bounds)+CGRectGetHeight(_specifyView.bounds)+CGRectGetHeight(self.rightsDisplayView.bounds);
            break;
    }
    if (self.mainView.bounds.size.height > height) {
        self.mainView.contentSize = CGSizeMake(CGRectGetWidth(self.mainView.bounds), CGRectGetHeight(self.mainView.bounds) + 1);
    } else {
        self.mainView.contentSize = CGSizeMake(CGRectGetWidth(self.mainView.bounds), height + kMargin * 3);
    }
}
- (void)selectTypeBtnClick:(UIButton *)sender {
    
    NSInteger index = sender.tag - KBTNTAG;
    if (index == self.currentType) {
        return;
    }else {
        self.digitalBtn.selected = NO;
        self.digitalBtn.backgroundColor = [UIColor whiteColor];
        self.classifyBtn.selected = NO;
        self.classifyBtn.backgroundColor = [UIColor whiteColor];
        self.currentType = index;
        switch (index) {
            case NXSelectRightsTypeDigital:
            {
                self.classificationView.hidden = YES;
                self.digitalView.hidden = NO;
                
            }
                break;
            case NXSelectRightsTypeClassification:
            {
                self.classificationView.hidden = NO;
                self.digitalView.hidden = YES;
            }
                break;
        }
        sender.backgroundColor = RMC_MAIN_COLOR;
        sender.selected = YES;
        [self setScrollViewContentSize];
        
    }
}
- (void)handleSegmentControlAction:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == self.currentType) {
        return;
    }else {
    self.currentType = sender.selectedSegmentIndex;
    switch (sender.selectedSegmentIndex) {
        case NXSelectRightsTypeDigital:
        {
            self.classificationView.hidden = YES;
            self.digitalView.hidden = NO;
        }
            break;
        case NXSelectRightsTypeClassification:
        {
            self.classificationView.hidden = NO;
            self.digitalView.hidden = YES;
        }
            break;
    }
    [self setScrollViewContentSize];
    }
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self setScrollViewContentSize];
}

- (void)cancelButtonClicked:(id)sender {
    [self dismissSelf];
}

#pragma mark
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
- (void)dismissSelf {
    [[NXOriginalFilesTransfer sharedIInstance] deleteTheLocalFilesPath];
    if (self.preview) {
        [self.preview removeFromSuperview];
        self.preview = nil;
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
- (void)protect:(id)sender {
    self.protectButton.enabled = NO;
    
    if (!self.fileItem.localPath || ![[NSFileManager defaultManager] fileExistsAtPath:self.fileItem.localPath]) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_FILE_NOT_EXISTED", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
        self.protectButton.enabled = YES;
        return;
    }
    NSString *tmpPath = [NXCommonUtils createNewNxlTempFile:self.fileItem.name];
    [NXMBManager showLoading:NSLocalizedString(@"MSG_COM_PROTECT_AND_UPLOADING", NULL) toView:self.view];
    NSDate *currentServerDate = [[NXTimeServerManager sharedInstance] currentServerTime];
    if (self.currentType == NXSelectRightsTypeClassification) {
        if (self.classificationView.isMandatoryEmpty) {
            [NXMBManager showMessage:NSLocalizedString(@"MSG_MANDATORY_NOT_EMPTY", NULL) toView:self.view hideAnimated:YES afterDelay:1.5 * kDelay];
            self.protectButton.enabled = YES;
            return;
        }
        WeakObj(self);
        [NXMBManager showLoadingToView:self.view];
        [[NXLoginUser sharedInstance].nxlOptManager onlyEncryptToNXLFile:self.fileItem toPath:tmpPath classifications:self.classificationView.classificationCategoryArray membershipId:[NXLoginUser sharedInstance].profile.tenantMembership.ID createDate:currentServerDate withCompletion:^(NSString *filePath, NSError *error) {
            StrongObj(self);
            if (!error) {
                NXFileBase *file = [[NXFile alloc] init];
                file.localPath = filePath;
                file.name = [filePath lastPathComponent];
                                   
                if (self.fileItem.sorceType == NXFileBaseSorceTypeLocalFiles) {
                    [self uploadToLocalFilesWithFile:file];
                                       
                }else if (self.fileItem.sorceType == NXFileBaseSorceTypeRepoFile){
                    NXFileBase *parentFolder = [[NXLoginUser sharedInstance].myRepoSystem parentForFileItem:self.fileItem];
                    [self uploadToRepoWithFile:file toFolder:parentFolder];
                }
                
            }else{
                  
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NXMBManager hideHUDForView:self.view];
                    [NXMBManager showMessage:error.localizedDescription?:NSLocalizedString(@"MSG_COM_ENCRYPT_FILE_FAILED", NULL) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
                self.protectButton.enabled = YES;
                });
            }
        }];
        return;
    }else if(self.currentType == NXSelectRightsTypeDigital){
        
        if (!self.selectedRights.getVaildateDateModel) {
            [self.selectedRights setFileValidateDate:[NXLoginUser sharedInstance].userPreferenceManager.userPreference.preferenceFileValidateDate];
        }
      
        
        if (![NXCommonUtils checkIsLegalFileValidityDate:[self.selectedRights getVaildateDateModel]]) {
            [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_FILE_EXPIRETIME_INVALID", NULL) hideAnimated:YES afterDelay:kDelay];
            self.protectButton.enabled = YES;
            [NXMBManager hideHUDForView:self.view];
            return;
        }
        [NXMBManager showLoadingToView:self.view];
        NXWorkSpaceUploadFileModel *model = [[NXWorkSpaceUploadFileModel alloc]init];
        model.file = self.fileItem;
        WeakObj(self);
        model.digitalRight = self.selectedRights;
        [[NXLoginUser sharedInstance].nxlOptManager onlyEncryptToNXLFile:self.fileItem toPath:tmpPath permissions:self.selectedRights membershipId:[NXLoginUser sharedInstance].profile.tenantMembership.ID createDate:currentServerDate withCompletion:^(NSString *filePath, NSError *error) {
            StrongObj(self);
            if (!error) {
                NXFileBase *file = [[NXFile alloc] init];
                file.localPath = filePath;
                file.name = [filePath lastPathComponent];
                
                if (self.fileItem.sorceType == NXFileBaseSorceTypeLocalFiles) {
                    [self uploadToLocalFilesWithFile:file];
                                       
                }else if (self.fileItem.sorceType == NXFileBaseSorceTypeRepoFile){
                    NXFileBase *parentFolder = [[NXLoginUser sharedInstance].myRepoSystem parentForFileItem:self.fileItem];
                    [self uploadToRepoWithFile:file toFolder:parentFolder];
                }
                
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                       [NXMBManager hideHUDForView:self.view];
                    [NXMBManager showMessage:error.localizedDescription?:NSLocalizedString(@"MSG_COM_ENCRYPT_FILE_FAILED", NULL) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
                self.protectButton.enabled = YES;
                });
            }
        }];
        return;
    }else {
        NSAssert(NO, @"Proect type is not correctly");
    }
    
}
- (void)uploadToLocalFilesWithFile:(NXFileBase *)file {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NXMBManager hideHUDForView:self.view];
        [[NXOriginalFilesTransfer sharedIInstance] exportFile:file toOriginalFilesFromVC:self];
        self.protectButton.enabled = YES;
        [NXOriginalFilesTransfer sharedIInstance].exprotFileCompletion = ^(UIViewController *currentVC,NSURL *fileUrl, NSError *error) {
               [NXMBManager hideHUDForView:self.view];
            if ([currentVC isMemberOfClass:[self class]]) {
                if (!error && fileUrl) {
                    [NXMessageViewManager showMessageViewWithTitle:file.name details:NSLocalizedString(@"MSG_COM_SUCCESS_PROTECT", NULL) appendInfo:nil appendInfo2:NSLocalizedString(@"MSG_COM_FILES_HAS_BEEN_SAVED_TO_FILES", NULL) image:[UIImage imageNamed:@"Success - White tick"] dismissAfter:kDelay*2 type:NXMessageViewManagerTypeGreen];
                    [self dismissSelf];
                }else{
                    [NXMBManager showMessage:error.localizedDescription?:@"Failed to save to Files" toView:self.mainView hideAnimated:YES afterDelay:kDelay];
                }
            }
        };
        [NXOriginalFilesTransfer sharedIInstance].cancelCompletion = ^(UIViewController *currentVC) {
            if ([currentVC isMemberOfClass:[self class]]) {
                [self dismissSelf];
            }
        };
    });
}
- (void)uploadToRepoWithFile:(NXFileBase *)file toFolder:(NXFileBase *)targetFolder {
    
    if (self.currentRepoFolderFiles.count > 0) {
          for (NXFile *tmpfile in self.currentRepoFolderFiles) {
              if ([[tmpfile.name stringByDeletingPathExtension] isEqualToString:self.fileItem.name]) {
                  WeakObj(self);
                  dispatch_main_sync_safe((^{
                      NSString *message = [NSString stringWithFormat:NSLocalizedString(@"ALERTVIEW_MESSAGE_OVERWRITE", NULL), tmpfile.name];
                      [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_REPLACE", NULL) cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherTitle:NSLocalizedString(@"UI_BOX_NO_REPLACE", NULL) OKActionHandle:^(UIAlertAction *action) {
                          StrongObj(self);
                          
                          [self uploadOperationToRepoWithFile:file toFolder:targetFolder];
                      } cancelActionHandle:^(UIAlertAction *action) {
                          self.protectButton.enabled = YES;
                          [NXMBManager hideHUDForView:self.view];
                      } otherActionHandle:^(UIAlertAction *action) {
                          //no replace
                          NSMutableArray *currentFolderFilesNameArray = [[NSMutableArray alloc] init];
                          for (NXFileBase *tmpfile in self.currentRepoFolderFiles) {
                              if (tmpfile.name.length > 0) {
                                  [currentFolderFilesNameArray addObject:tmpfile.name];
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
                          file.name = newFileName;
                          [self uploadOperationToRepoWithFile:file toFolder:targetFolder];
                      } inViewController:self position:self.view];
                  }));
                   
                  return;
              }
          }
    }
    [self uploadOperationToRepoWithFile:file toFolder:targetFolder];
}

- (void)uploadOperationToRepoWithFile:(NXFileBase *)file toFolder:(NXFileBase *)targetFolder
{
    self.myRepoSysUploadOptIdentify = [[NXLoginUser sharedInstance].myRepoSystem uploadFile:file.name toPath:targetFolder fromPath:file.localPath uploadType:NXRepositorySysManagerUploadTypeNormal overWriteFile:nil progress:nil completion:^(NXFileBase *fileItem, NXFileBase *parentFolder, NSError *error) {
               dispatch_main_async_safe(^{
                   [NXMBManager hideHUDForView:self.view];
                   if (!error) {
                       if (DELEGATE_HAS_METHOD(self.delegate, @selector(viewcontroller:didfinishedOperationFile:toFile:))) {
                           [self.delegate viewcontroller:self didfinishedOperationFile:self.fileItem toFile:self.fileItem];
                       }
                       [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                       [NXMessageViewManager showMessageViewWithTitle:self.fileItem.name details:NSLocalizedString(@"MSG_COM_SUCCESS_PROTECT", NULL) appendInfo:nil appendInfo2:NSLocalizedString(@"MSG_COM_FILE_HAS_BEEN_SAVED_TO_REPO", NULL) image:[UIImage imageNamed:@"Success - White tick"] dismissAfter:kDelay*2 type:NXMessageViewManagerTypeGreen];
                  
                   }else{
                       [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_UPLOAD_FILE_FAILED", NULL) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
                       self.protectButton.enabled = YES;
                       if (self.currentFileOrginalName) {
                           self.fileItem.name = self.currentFileOrginalName;
                       }
                  
                   }
              });
          }];
}
    
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
