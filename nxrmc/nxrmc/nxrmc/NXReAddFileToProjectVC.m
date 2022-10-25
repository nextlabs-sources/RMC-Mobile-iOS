//
//  NXReAddFileToProjectVC.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/3/18.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXReAddFileToProjectVC.h"
#import "NXMBManager.h"
#import "NXLoginUser.h"
#import "NXLProfile.h"
#import "NXWebFileManager.h"
#import "NXCommonUtils.h"
#import "NXRMCDef.h"
#import "UIImage+ColorToImage.h"
#import "UIView+UIExt.h"
#import "Masonry.h"
#import "NXPreviewFileView.h"
#import "NXFileChooseFlowViewController.h"
#import "NXCardStyleView.h"
#import "NXLeftImageButton.h"
#import "NXRightsSelectView.h"
#import "NXClassificationSelectView.h"
#import "NXProjectUploadVC.h"
#import "NSString+NXExt.h"
#import "NXAddToProjectLastVC.h"
#import "NXProtectedFileListView.h"
#define PREVIEWFOLDHEIGHT 98
@interface NXReAddFileToProjectVC ()<NXFileChooseFlowViewControllerDelegate,NXClassificationSelectViewDelegate>
@property (nonatomic, strong) UIScrollView *bgScrollView;
@property (nonatomic, strong) UIButton *protectBtn;
@property (nonatomic, assign) BOOL isShowPreview;
@property (nonatomic, assign) BOOL fileIsADHoc;
//@property (nonatomic, strong) NXPreviewFileView *preview;
@property (nonatomic, assign) BOOL isAdhocEnable;
@property(nonatomic, strong) UIView *specifyView;
@property(nonatomic, strong) UIButton *digitalBtn;
@property(nonatomic, strong) UIButton *classifyBtn;
@property (nonatomic, assign)NXSelectRightsType currentType;
@property(nonatomic, strong) NXRightsSelectView *digitalView;
@property(nonatomic, strong) NXClassificationSelectView *classificationView;
@property(nonatomic, strong) NSArray <NXClassificationCategory *>*classificationCategoryArray;
@property(nonatomic, strong) NSArray <NXClassificationCategory *>*fileOriginalCategoryArray;

@property(nonatomic, strong) NXLRights *selectedRights;
@property(nonatomic, strong) NXFileBase *decryptFile;
@property (nonatomic, strong) NXProtectedFileListView *fileListView;
@end

@implementation NXReAddFileToProjectVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self configurationNavigation];
    [self commonInit];
    [self updateUI:self.currentFile isADHoc:NO withRights:nil];
//    if (self.fileOperationType == NXFileOperationTypeProjectFileReclassify || self.fileOperationType == NXFileOperationTypeWorkSpaceFileReclassify) {
//        self.preview.enabled = NO;
//    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.toProject.membershipId) {
        [[NXLoginUser sharedInstance].myProject getMemberShipID:self.toProject withCompletion:^(NXProjectModel *projectModel, NSError *error) {
            if (!error) {
                self.toProject.membershipId = projectModel.membershipId;
            }
        }];
    }
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self setScrollViewContentSize];
}
- (void)configurationNavigation {
    if (self.fileOperationType == NXFileOperationTypeProjectFileReclassify || self.fileOperationType == NXFileOperationTypeWorkSpaceFileReclassify) {
        self.navigationItem.title = NSLocalizedString(@"UI_RECLASSIFY", NULL);
    }else {
        self.navigationItem.title = NSLocalizedString(@"UI_ADD_FILE_TO", NULL);
    }
   
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
}
- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (UIView *)specifyView {
    if (!_specifyView) {
        _specifyView = [[UIView alloc]init];
        [self.bgScrollView addSubview:_specifyView];
        UILabel *specifyLabel =[[UILabel alloc]init];
        if (self.fileOperationType == NXFileOperationTypeWorkSpaceFileReclassify || self.fileOperationType == NXFileOperationTypeAddProjectFileToWorkSpace) {
            specifyLabel.attributedText = [self createAttributeString:@"Choose company defined rights" subTitle1:@""];
        }else{
             specifyLabel.attributedText = [self createAttributeString:@"Choose company defined rights for the seclected project " subTitle1:self.toProject.displayName];
        }
       
        specifyLabel.font = [UIFont systemFontOfSize:17];
        specifyLabel.numberOfLines = 0;
        [_specifyView addSubview:specifyLabel];
        NXCardStyleView *digitalCardView = [[NXCardStyleView alloc]init];
        [_specifyView addSubview:digitalCardView];
        UIButton *digitalBtn = [self createSelectRightsTypeBtnWithTitle:NSLocalizedString(@"UI_DIGITAL_RIGHTS", NULL)];
        digitalBtn.selected = NO;
        digitalBtn.backgroundColor = [UIColor lightGrayColor];
        [_specifyView addSubview:digitalBtn];
        self.digitalBtn = digitalBtn;
        NXCardStyleView *classifyCardView = [[NXCardStyleView alloc]init];
        [_specifyView addSubview:classifyCardView];
        UIButton *classifyBtn = [self createSelectRightsTypeBtnWithTitle:NSLocalizedString(@"UI_DOCUMENT_CLASSIFICATION", NULL)];
        classifyBtn.backgroundColor = [UIColor lightGrayColor];
        classifyBtn.selected = NO;
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
        [self.bgScrollView addSubview:_digitalView];
        [self.bgScrollView bringSubviewToFront:_digitalView];
        if (self.selectedRights.getWatermarkString) {
            _digitalView.currentWatermarks = [self.selectedRights.getWatermarkString parseWatermarkWords];
        }

        _digitalView.currentValidModel = self.selectedRights.getVaildateDateModel;
        [_digitalView setIsToProject:YES];
        _digitalView.enabled = NO;
        _digitalView.rights = self.selectedRights;
        _digitalView.hidden = YES;
    }
    return _digitalView;
}
- (NXClassificationSelectView *)classificationView {
    if (!_classificationView) {
        _classificationView = [[NXClassificationSelectView alloc]init];
        _classificationView.delegate = self;
        [self.bgScrollView addSubview:_classificationView];
        _classificationView.hidden = YES;
    }
    return _classificationView;
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
    [button cornerRadian:20];
    return button;
}
- (void)commonInit{
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.isShowPreview = NO;
    UIScrollView *bgScrollView = [[UIScrollView alloc]init];
    bgScrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:bgScrollView];
    self.bgScrollView = bgScrollView;
    UIView *bottomView = [[UIView alloc]init];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    UIButton *protectButton = [[UIButton alloc] init];
    [bottomView addSubview:protectButton];
    protectButton.enabled = NO;
    [protectButton setTitle:@"Next" forState:UIControlStateNormal];
    [protectButton addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
    [protectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [protectButton setBackgroundImage:[UIImage imageWithSize:CGSizeMake(200, 200) colors:@[RMC_GRADIENT_START_COLOR, RMC_GRADIENT_END_COLOR] gradientType:GradientTypeLeftToRight] forState:UIControlStateNormal];
    [protectButton cornerRadian:3];
    self.protectBtn = protectButton;
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.view);
        make.height.equalTo(self.view).multipliedBy(0.12);
    }];
    
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [bgScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
                make.left.right.equalTo(self.view);
                make.bottom.equalTo(bottomView.mas_top);
            }];
        }
    }else{
        [bgScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuideBottom);
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(bottomView.mas_top);
        }];
    }
    
    [bgScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom);
    }];
    
    
    [protectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(bottomView);
        make.width.equalTo(@300);
        make.height.lessThanOrEqualTo(bottomView).multipliedBy(0.7);
        make.height.lessThanOrEqualTo(@(40));
    }];

}
- (void)updateUI:(NXFileBase *)file isADHoc:(BOOL)isADhoc withRights:(NXLRights *)right {
    self.protectBtn.enabled = YES;
//    NXPreviewFileView *previewFileView = [[NXPreviewFileView alloc] init];
//    [self.bgScrollView addSubview:previewFileView];
//    [self.bgScrollView sendSubviewToBack:previewFileView];
//    self.preview = previewFileView;
//    NXFile *previewFile = [[NXFile alloc]init];
//    previewFile.name = file.name;
//    if (self.fileOperationType == NXFileOperationTypeAddProjectFileToWorkSpace) {
//        previewFileView.savedPath = [NSString stringWithFormat:@"%@%@", @"WorkSpace",self.folder.fullPath?:@""];
//    }else{
//        previewFileView.savedPath = [NSString stringWithFormat:@"%@%@", self.toProject.displayName?:@"", self.folder.fullPath?:@""];
//    }
//    previewFileView.fileItem = previewFile;
//    previewFileView.showPreviewClick = ^(id sender) {
//        [self changePreviewSize];
//    };
    NXProtectedFileListView *fileListView = [[NXProtectedFileListView alloc] initWithFileList:@[self.currentFile]];
    [self.bgScrollView addSubview:fileListView];
    self.fileListView = fileListView;
    if (self.fileOperationType == NXFileOperationTypeProjectFileReclassify || self.fileOperationType == NXFileOperationTypeWorkSpaceFileReclassify) {
        self.protectBtn.enabled = NO;
//        NSString *parentPath = [self.currentFile.fullServicePath stringByDeletingLastPathComponent];
//        if (![parentPath isEqualToString:@"/"]) {
//           parentPath = [parentPath stringByAppendingString:@"/"];
//        }
//        self.preview.savedPath = parentPath;
    }else{
//        previewFileView.promptMessage = NSLocalizedString(@"UI_FILE_WILL_BE_SAVED_TO", NULL);
//
//        previewFileView.enabled = YES;
//        WeakObj(self);
//        previewFileView.changePathClick = ^(id sender) {
//            StrongObj(self);
//            NXFileChooseFlowViewController *vc = nil;
//            if (self.fileOperationType == NXFileOperationTypeAddProjectFileToWorkSpace) {
//                vc = [[NXFileChooseFlowViewController alloc]initWithWorkSpaceType:NXFileChooseFlowViewControllerTypeChooseDestFolder];
//            }else{
//                vc = [[NXFileChooseFlowViewController alloc]initWithProject:self.toProject type:NXFileChooseFlowViewControllerTypeChooseDestFolder];
//            }
//            vc.type = NXFileChooseFlowViewControllerTypeChooseDestFolder;
//            vc.fileChooseVCDelegate = self;
//            vc.projectModel = self.toProject;
//            vc.modalPresentationStyle = UIModalPresentationFullScreen;
//            [self.navigationController presentViewController:vc animated:YES completion:nil];
//       };
    }
   
    self.specifyView.backgroundColor = [UIColor whiteColor];
    if (isADhoc) {
        self.currentType = NXSelectRightsTypeDigital;
    }else{
        self.currentType = NXSelectRightsTypeClassification;
    }
    
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [fileListView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.bgScrollView);
                make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
            }];
        }
    }
    else
    {
        [fileListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bgScrollView);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
        }];
    }
    [self.specifyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fileListView.mas_bottom);
        make.left.equalTo(fileListView);
        make.right.equalTo(fileListView);
    }];
    [self.digitalView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.specifyView.mas_bottom);
        make.left.right.equalTo(self.specifyView);
        make.height.greaterThanOrEqualTo(@100);
    }];
    [self.classificationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.specifyView.mas_bottom);
        make.left.right.equalTo(self.specifyView);
        make.height.greaterThanOrEqualTo(self.digitalView.mas_height);
    }];
}
- (void)setCurrentType:(NXSelectRightsType)currentType {
    _currentType = currentType;
    if (currentType == NXSelectRightsTypeDigital) {
        self.digitalBtn.selected = YES;
        self.digitalBtn.backgroundColor = RMC_MAIN_COLOR;
        self.digitalView.hidden = NO;
        
    }else{
        self.classifyBtn.selected = YES;
        self.classifyBtn.backgroundColor = RMC_MAIN_COLOR;
        self.classificationView.hidden = NO;
        
        switch (self.fileOperationType) {
            case NXFileOperationTypeWorkSpaceFileReclassify:
            case NXFileOperationTypeAddProjectFileToWorkSpace:
            {
                [NXMBManager showLoading];
                [[NXLoginUser sharedInstance].workSpaceManager getWorkSpaceDefalutClassificationWithCompletion:^(NSArray *classifications, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [NXMBManager hideHUD];
                        if (!error) {
                            self.classificationCategoryArray = classifications;
                            [self.classificationCategoryArray enumerateObjectsUsingBlock:^(NXClassificationCategory * _Nonnull objCategory, NSUInteger idx, BOOL * _Nonnull stop) {
                                [objCategory.labs enumerateObjectsUsingBlock:^(NXClassificationLab * _Nonnull objLab, NSUInteger idx, BOOL * _Nonnull stop) {
                                    objLab.defaultLab = NO;
                                    for (NXClassificationCategory *selectCategory in self.currentClassifiations) {
                                        if ([selectCategory.name isEqualToString:objCategory.name]) {
                                            for (NXClassificationLab *selectLab in selectCategory.selectedLabs) {
                                                if ([selectLab.name isEqualToString:objLab.name]) {
                                                    objLab.defaultLab = YES;
                                                }
                                            }
                                        }
                                    }
                                }];
                            }];

                            self.classificationView.classificationCategoryArray = self.classificationCategoryArray;
                            self.fileOriginalCategoryArray = [[NSArray alloc]initWithArray:self.classificationCategoryArray copyItems:YES];
                        }else{
                            [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:kDelay];
                            self.protectBtn.enabled = NO;
                        }
                        
                    });
                    
                }];
            }
                break;
            case NXFileOperationTypeProjectFileReclassify:
            {
                [NXMBManager showLoading];
                [[NXLoginUser sharedInstance].myProject allClassificationsForProject:self.toProject withCompletion:^(NXProjectModel *project, NSArray<NXClassificationCategory *> *classificaiton, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [NXMBManager hideHUD];
                        if (!error) {
                            self.classificationCategoryArray = classificaiton;
                            [self.classificationCategoryArray enumerateObjectsUsingBlock:^(NXClassificationCategory * _Nonnull objCategory, NSUInteger idx, BOOL * _Nonnull stop) {
                                [objCategory.labs enumerateObjectsUsingBlock:^(NXClassificationLab * _Nonnull objLab, NSUInteger idx, BOOL * _Nonnull stop) {
                                    objLab.defaultLab = NO;
                                    for (NXClassificationCategory *selectCategory in self.currentClassifiations) {
                                        if ([selectCategory.name isEqualToString:objCategory.name]) {
                                            for (NXClassificationLab *selectLab in selectCategory.selectedLabs) {
                                                if ([selectLab.name isEqualToString:objLab.name]) {
                                                    objLab.defaultLab = YES;
                                                }
                                            }
                                        }
                                    }
                                }];
                            }];
                            self.classificationView.classificationCategoryArray = self.classificationCategoryArray;
                            self.fileOriginalCategoryArray = [[NSArray alloc]initWithArray:self.classificationCategoryArray copyItems:YES];
                        }else{
                            [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:kDelay];
                            self.protectBtn.enabled = NO;
                        }
                        
                    });
                }];
            }
                break;
                case NXFileOperationTypeAddProjectFileToProject:
                case NXFileOperationTypeAddWorkSpaceFileToProject:
            {
                [[NXLoginUser sharedInstance].myProject allClassificationsForProject:self.toProject withCompletion:^(NXProjectModel *project, NSArray<NXClassificationCategory *> *classificaiton, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!error) {
                            self.classificationCategoryArray = classificaiton;
                            [self.classificationCategoryArray enumerateObjectsUsingBlock:^(NXClassificationCategory * _Nonnull objCategory, NSUInteger idx, BOOL * _Nonnull stop) {
                                [objCategory.labs enumerateObjectsUsingBlock:^(NXClassificationLab * _Nonnull objLab, NSUInteger idx, BOOL * _Nonnull stop) {
                                    objLab.defaultLab = NO;
                                    for (NXClassificationCategory *selectCategory in self.currentClassifiations) {
                                        if ([selectCategory.name isEqualToString:objCategory.name]) {
                                            for (NXClassificationLab *selectLab in selectCategory.selectedLabs) {
                                                if ([selectLab.name isEqualToString:objLab.name]) {
                                                    objLab.defaultLab = YES;
                                                }
                                            }
                                        }
                                    }
                                }];
                            }];
                            self.classificationView.classificationCategoryArray = self.classificationCategoryArray;
                            self.fileOriginalCategoryArray = [[NSArray alloc]initWithArray:self.classificationCategoryArray copyItems:YES];
                        }else{
                            [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:kDelay];
                            self.protectBtn.enabled = NO;
                        }
                        
                    });
                }];
            }
                break;
            default:
                break;
        }
    }
}

- (void)setScrollViewContentSize {
    CGFloat height;
    switch (self.currentType) {
        case NXSelectRightsTypeDigital:
            height = (self.isShowPreview ? CGRectGetHeight(self.fileListView .bounds) : PREVIEWFOLDHEIGHT)+ CGRectGetHeight(self.digitalView.bounds)+CGRectGetHeight(_specifyView.bounds);
            break;
        case NXSelectRightsTypeClassification:
            height = (self.isShowPreview ? CGRectGetHeight(self.fileListView .bounds) : PREVIEWFOLDHEIGHT) + CGRectGetHeight(self.classificationView.bounds)+CGRectGetHeight(_specifyView.bounds);
            break;
    }
    if (self.bgScrollView.bounds.size.height > height) {
        self.bgScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bgScrollView.bounds), CGRectGetHeight(self.bgScrollView.bounds));
    } else {
        self.bgScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bgScrollView.bounds), height + 10);
    }
}

- (void)changePreviewSize {
//    if (self.isShowPreview) {
//        [self.specifyView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.preview).offset(PREVIEWFOLDHEIGHT);
//            make.left.equalTo(self.preview);
//            make.right.equalTo(self.preview);
//        }];
//    }else{
//        [self.specifyView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.preview.mas_bottom).offset(kMargin);
//            make.left.equalTo(self.preview);
//            make.right.equalTo(self.preview);
//        }];
//
//    }
//    self.isShowPreview = !self.isShowPreview;
//    [UIView animateWithDuration:0.7 animations:^{
//        [self.bgScrollView layoutIfNeeded];
//    } completion:^(BOOL finished) {
//        [self setScrollViewContentSize];
//    }];
    
    
}
#pragma mark ------> next
- (void)next:(id)sender {
    if (self.classificationView.isMandatoryEmpty) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_MANDATORY_NOT_EMPTY", NULL) toView:self.view hideAnimated:YES afterDelay:1.5 * kDelay];
        self.protectBtn.enabled = YES;
        return;
    }
    // if file has multiple tag to single project or WorkSpace,should show this message(fix bug 58762)
    NSArray *notShouldMultipleArray = [self.classificationView isNotShouldMultipleCategory];
       if (notShouldMultipleArray.count>0) {
           NSString *categoryName = [notShouldMultipleArray componentsJoinedByString:@","];
           [NXMBManager showMessage:[NSString stringWithFormat:NSLocalizedString(@"MSG_REQUIRE_ONLY_ONE_CLASSIFICATION_LABEL", NULL),categoryName] toView:self.view hideAnimated:YES afterDelay:1.5 * kDelay];
           self.protectBtn.enabled = YES;
           return;
       }
    NSMutableArray *allClassifications = [NSMutableArray array];
    NSMutableArray *realInheritClassifications = [NSMutableArray array];
    NSMutableArray *inheritClassifications = [NSMutableArray array];
    for (NXClassificationCategory *currentCatgory in self.currentClassifiations) {
       __block BOOL isExist = NO;
        [self.classificationCategoryArray enumerateObjectsUsingBlock:^(NXClassificationCategory * _Nonnull obj, NSUInteger idx, BOOL * stop) {
            if ([obj.name isEqualToString:currentCatgory.name]) {
                isExist = YES;
                *stop = YES;
            }
        }];
        if (!isExist) {
            [inheritClassifications addObject:currentCatgory];
        }
    }
    [allClassifications addObjectsFromArray:inheritClassifications];
    [allClassifications addObjectsFromArray:self.classificationView.classificationCategoryArray];
    for (NXClassificationCategory *newCategory in allClassifications) {
        if (newCategory.selectedLabs.count) {
            [realInheritClassifications addObject:newCategory];
        }
    }
    NXAddToProjectLastVC *addToFileVC = [[NXAddToProjectLastVC alloc]init];
    addToFileVC.toProject = self.toProject;
    addToFileVC.currentFile = self.currentFile;
    addToFileVC.folder = self.folder;
    addToFileVC.originalFileDUID = self.originalFileDUID;
    addToFileVC.originalFileOwnerId = self.originalFileOwnerId;
    addToFileVC.currentClassifiations = realInheritClassifications;
    addToFileVC.fileOperationType = self.fileOperationType;
    if (self.fileOperationType == NXFileOperationTypeWorkSpaceFileReclassify || self.fileOperationType == NXFileOperationTypeProjectFileReclassify) {
        addToFileVC.currentClassifiations = self.classificationView.classificationCategoryArray;
    }
    [self.navigationController pushViewController:addToFileVC animated:YES];
}


#pragma mark ------> fileChooseDelegate
- (void)fileChooseFlowViewController:(NXFileChooseFlowViewController *)vc didChooseFile:(NSArray *)choosedFiles {
    if (choosedFiles.count) {
        self.folder = choosedFiles.lastObject;
//        if (self.fileOperationType == NXFileOperationTypeAddProjectFileToWorkSpace) {
//            self.preview.savedPath = [NSString stringWithFormat:@"%@%@",@"WorkSpace",self.folder.fullPath];
//        }else{
//            self.preview.savedPath = [NSString stringWithFormat:@"%@%@", vc.projectModel.displayName, self.folder.fullPath];
//        }
    }
}
- (void)fileChooseFlowViewControllerDidCancelled:(NXFileChooseFlowViewController *)vc {
    //
}
#pragma mark ----->ClassificationSelectViewDelegate
- (void)afterChangeCurrentSelectClassifationSelectView:(NXClassificationSelectView *)selectView{
    if (self.fileOperationType == NXFileOperationTypeWorkSpaceFileReclassify || self.fileOperationType == NXFileOperationTypeProjectFileReclassify) {
        if (![self fileSelectTabs:self.fileOriginalCategoryArray isEqualToCurrentSelectTabs:selectView.classificationCategoryArray]) {
            self.protectBtn.enabled = YES;
        }else{
            self.protectBtn.enabled = NO;
        }
    }else{
        self.protectBtn.enabled = YES;
    }
}
- (BOOL)fileSelectTabs:(NSArray *)array1 isEqualToCurrentSelectTabs:(NSArray *)array2{
    for (int i = 0; i<array1.count; i++) {
        __block BOOL isSame = YES;
        NSMutableArray *slectLabs = [NSMutableArray array];
        NXClassificationCategory *category1 = array1[i];
        for (NXClassificationCategory *fileCategory in self.currentClassifiations) {
            if ([fileCategory.name isEqualToString:category1.name]) {
                category1 = fileCategory;
            }
        }
        NXClassificationCategory *category2 = array2[i];
        if (category1.selectedLabs.count != category2.selectedLabs.count) {
            return NO;
        }
        for (NXClassificationLab *lab in category1.selectedLabs) {
            [slectLabs addObject:lab.name];
        }
        
        [category2.selectedLabs enumerateObjectsUsingBlock:^(NXClassificationLab * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![slectLabs containsObject:obj.name]) {
                isSame = NO;
                *stop = YES;
                
            }
        }];
        if (!isSame) {
            return NO;
        }
    }
    return YES;
}
#pragma mark   ----》NSAttributedString
- (NSAttributedString *)createAttributeString:(NSString *)title subTitle1:(NSString *)subtitle1 {
    NSMutableAttributedString *myprojects = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    
    NSAttributedString *sub1 = [[NSMutableAttributedString alloc] initWithString:subtitle1 attributes:@{NSForegroundColorAttributeName :[UIColor blackColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:16]}];
    
    [myprojects appendAttributedString:sub1];
    
    return myprojects;
}

@end
