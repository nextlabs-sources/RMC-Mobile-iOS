//
//  NXWorkSpaceUploadFileVC.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/9/27.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXWorkSpaceUploadFileVC.h"
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
#define KBTNTAG 1000
#define PREVIEWFOLDHEIGHT 98

@interface NXWorkSpaceUploadFileVC ()<NXFileChooseFlowViewControllerDelegate,NXRightsSelectViewDelegate>
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
@property(nonatomic, copy)NSArray<NXRightsCellModel*> *moreOptionsArray;
@property(nonatomic, copy)NSString *currentFileOrginalName;
@end

@implementation NXWorkSpaceUploadFileVC
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
        _digitalView.isShowMoreOptions = YES;
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
    self.navTittleView.text = @"Upload a file";
    [self.rightsSelectView removeFromSuperview];
    WeakObj(self);
    self.preview.savedPath = [NSString stringWithFormat:@"%@%@",@"WorkSpace", self.folder.fullPath?:@""];
    self.preview.changePathClick = ^(id sender) {
        StrongObj(self);
        NXFileChooseFlowViewController *vc = [[NXFileChooseFlowViewController alloc]initWithWorkSpaceType:NXFileChooseFlowViewControllerTypeChooseDestFolder];
        vc.type = NXFileChooseFlowViewControllerTypeChooseDestFolder;
        vc.fileChooseVCDelegate = self;
//        vc.projectModel = self.project;
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController presentViewController:vc animated:YES completion:nil];
    };
    self.preview.showPreviewClick = ^(id sender) {
        StrongObj(self);
        [self changePreviewSize];
    };
    self.specifyView.backgroundColor = [UIColor whiteColor];
    
    // ***** suppot adhocEnable *****
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
    self.operationIdentifier = [[NXLoginUser sharedInstance].workSpaceManager getWorkSpaceDefalutClassificationWithCompletion:^(NSArray *classifications, NSError *error) {
        if (!error) {
            self.classificationCategoryArray = [NSArray arrayWithArray:classifications];
            dispatch_async(dispatch_get_main_queue(), ^{
              self.classificationView.classificationCategoryArray = self.classificationCategoryArray;
            });
        }
    }];
    self.preview.enabled = YES;
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
    [self.protectButton setTitle:@"Upload file" forState:UIControlStateNormal];
    NXRightsCellModel *extractModel = [[NXRightsCellModel alloc] initWithTitle:@"Extract" value:NXLRIGHTDECRYPT modelType:MODELTYPERIGHTS actived:NO];
    self.moreOptionsArray = @[extractModel].mutableCopy;
    // ***** suppot adhocEnable *****
    self.isAdhocEnable = YES;
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
- (void)dealloc {
    DLog(@"%s", __FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFinishedDownloadFile object:nil];
}
- (void)cancelButtonClicked:(id)sender {
    [self dismissSelf];
    [[NXLoginUser sharedInstance].workSpaceManager cancelOperation:_operationIdentifier];
    [[NXLoginUser sharedInstance].workSpaceManager cancelOperation:_uploadOperationIdentifier];
}

#pragma mark
- (void)fileChooseFlowViewController:(NXFileChooseFlowViewController *)vc didChooseFile:(NSArray *)choosedFiles {
    if (choosedFiles.count) {
        self.folder = choosedFiles.lastObject;
        self.preview.savedPath = [NSString stringWithFormat:@"%@%@", @"WorkSpace", self.folder.fullPath];
    }
}

- (void)fileChooseFlowViewControllerDidCancelled:(NXFileChooseFlowViewController *)vc {
    //
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

- (void)moreOperationsClicledFromRightsSelectView:(NXRightsSelectView *)selectView {
    NXRightsMoreOptionsVC *optionsVC = [[NXRightsMoreOptionsVC alloc]init];
    optionsVC.dataArray = [self.moreOptionsArray mutableCopy];
    optionsVC.finishedOptionBlock = ^(NSArray<NXRightsCellModel *> *modelArray) {
        self.moreOptionsArray = [modelArray mutableCopy];
    };
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:optionsVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}
#pragma mark
- (void)dismissSelf {
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
    NSLog(@"%s", __FUNCTION__);
    self.protectButton.enabled = NO;
    
    if (self.folder == nil) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_SELECT_FOLDER", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
        self.protectButton.enabled = YES;
        return;
    }
    
    if (!self.fileItem.localPath || ![[NSFileManager defaultManager] fileExistsAtPath:self.fileItem.localPath]) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_FILE_NOT_EXISTED", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
        self.protectButton.enabled = YES;
        return;
    }
    
    NSArray *currentFolderFiles = [[NXLoginUser sharedInstance].workSpaceManager getWorkSpaceFileListUnderFolderInCoreData:self.folder];
    if (currentFolderFiles.count > 0) {
        for (NXWorkSpaceFile *file in currentFolderFiles) {
            if ([file.name.stringByDeletingPathExtension isEqualToString:self.fileItem.name]) {
                dispatch_main_sync_safe((^{
                    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"ALERTVIEW_MESSAGE_OVERWRITE", NULL), file.name];
                    [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_REPLACE", NULL) cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherTitle:NSLocalizedString(@"UI_BOX_NO_REPLACE", NULL) OKActionHandle:^(UIAlertAction *action) {
                        NXFileState state = [[NXOfflineFileManager sharedInstance] currentState:file];
                        if (state != NXFileStateNormal)
                        {
                            [[NXOfflineFileManager sharedInstance] unmarkFileAsOffline:file withCompletion:^(NXFileBase *fileItem, NSError *error) {
                            }];
                        }
                        [self uploadFileToServer];
                    } cancelActionHandle:^(UIAlertAction *action) {
                        self.protectButton.enabled = YES;
                        [NXMBManager hideHUDForView:self.view];
                    } otherActionHandle:^(UIAlertAction *action) {
                        //no replace
                        NSMutableArray *currentFolderFilesNameArray = [[NSMutableArray alloc] init];
                        for (NXWorkSpaceFile *file in currentFolderFiles) {
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
                        
                        [self uploadFileToServer];
                    } inViewController:self position:self.view];
                    return;
                }));
                return;
             }
          }
    }
    [self uploadFileToServer];
}

- (void)uploadFileToServer{
    if (self.currentType == NXSelectRightsTypeClassification) {
        if (self.classificationView.isMandatoryEmpty) {
            [NXMBManager showMessage:NSLocalizedString(@"MSG_MANDATORY_NOT_EMPTY", NULL) toView:self.view hideAnimated:YES afterDelay:1.5 * kDelay];
            self.protectButton.enabled = YES;
            return;
        }
        
        [NXMBManager showLoading:NSLocalizedString(@"MSG_UPLOADING", NULL) toView:self.view];
          
        NSMutableDictionary *classificaitonDict = [[NSMutableDictionary alloc] init];
        for (NXClassificationCategory *classificationCategory in self.classificationView.classificationCategoryArray) {
            if (classificationCategory.selectedLabs.count > 0) {
                NSMutableArray *labs = [[NSMutableArray alloc] init];
                for (NXClassificationLab *classificationLab in classificationCategory.selectedLabs) {
                    NSString *labName = classificationLab.name;
                    [labs addObject:labName];
                }
                [classificaitonDict setObject:labs forKey:classificationCategory.name];
            }
        }
        NXWorkSpaceUploadFileModel *model = [[NXWorkSpaceUploadFileModel alloc]init];
        model.file = self.fileItem;
        model.parentFolder = self.folder;
        model.tags = classificaitonDict;
        self.uploadOperationIdentifier = [[NXLoginUser sharedInstance].nxlOptManager protectFileToWorkSpace:self.fileItem toPath:[NXCommonUtils createNewNxlTempFile:self.fileItem.name] membershipId:[NXLoginUser sharedInstance].profile.tenantMembership.ID permissions:nil classifications:classificaitonDict intoFolder:self.folder createDate:[NXTimeServerManager sharedInstance].currentServerTime andIsOverwrite:NO withCompletion:^(NXFolder *folder, NXFileBase *newFile, NSError *error) {
            WeakObj(self);
            dispatch_main_async_safe(^{
                if (error) {
                    [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_UPLOAD_FILE_FAILED", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
                    self.protectButton.enabled = YES;
                    if (self.currentFileOrginalName) {
                        self.fileItem.name = self.currentFileOrginalName;
                    }
                }else{
                    StrongObj(self);
                    [NXMBManager showMessage:NSLocalizedString(@"MSG_UPLOAD_SUCCESS", NULL)toView:self.view hideAnimated:YES afterDelay:kDelay];
                    if ([self.delegate respondsToSelector:@selector(viewcontroller:didfinishedOperationFile:toFile:)]) {
                        [self.delegate viewcontroller:self didfinishedOperationFile:nil toFile:newFile];
                    }
                    [self performSelector:@selector(dismissSelf) withObject:nil afterDelay:kDelay + 0.5];
                }
                
            });
        }];
           return;
        }else if(self.currentType == NXSelectRightsTypeDigital){
           
            [self.moreOptionsArray enumerateObjectsUsingBlock:^(NXRightsCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
               [self.selectedRights setRight:obj.value value:obj.active];
            }];
           
            if (!self.selectedRights.getVaildateDateModel) {
                [self.selectedRights setFileValidateDate:[NXLoginUser sharedInstance].userPreferenceManager.userPreference.preferenceFileValidateDate];
            }
         
           
           if (![NXCommonUtils checkIsLegalFileValidityDate:[self.selectedRights getVaildateDateModel]]) {
               [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_FILE_EXPIRETIME_INVALID", NULL) hideAnimated:YES afterDelay:kDelay];
               self.protectButton.enabled = YES;
               return;
           }
           [NXMBManager showLoading:NSLocalizedString(@"MSG_UPLOADING", NULL) toView:self.view];
           NXWorkSpaceUploadFileModel *model = [[NXWorkSpaceUploadFileModel alloc]init];
           model.file = self.fileItem;
           model.parentFolder = self.folder;
           model.digitalRight = self.selectedRights;
        
          self.uploadOperationIdentifier = [[NXLoginUser sharedInstance].nxlOptManager protectFileToWorkSpace:self.fileItem toPath:[NXCommonUtils createNewNxlTempFile:self.fileItem.name] membershipId:[NXLoginUser sharedInstance].profile.tenantMembership.ID permissions:self.selectedRights classifications:nil intoFolder:self.folder createDate:[NXTimeServerManager sharedInstance].currentServerTime andIsOverwrite:NO withCompletion:^(NXFolder *folder, NXFileBase *newFile, NSError *error) {
              WeakObj(self);
              dispatch_main_async_safe(^{
                  if (error) {
                      [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_UPLOAD_FILE_FAILED", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
                      self.protectButton.enabled = YES;
                      if (self.currentFileOrginalName) {
                          self.fileItem.name = self.currentFileOrginalName;
                      }
                  }else{
                      StrongObj(self);
                      [NXMBManager showMessage:NSLocalizedString(@"MSG_UPLOAD_SUCCESS", NULL)toView:self.view hideAnimated:YES afterDelay:kDelay];
                      if ([self.delegate respondsToSelector:@selector(viewcontroller:didfinishedOperationFile:toFile:)]) {
                          [self.delegate viewcontroller:self didfinishedOperationFile:nil toFile:newFile];
                      }
                      [self performSelector:@selector(dismissSelf) withObject:nil afterDelay:kDelay + 0.5];
                  }
                  
              });
          }];
           return;
       }else {
           NSAssert(NO, @"Proect type is not correctly");
       }
}


@end
