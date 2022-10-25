//
//  NXProtectFileAfterSelectedLocationVC.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/5/27.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXProtectFileAfterSelectedLocationVC.h"
#import "NXCustomTitleView.h"
#import "NXPreviewFileView.h"
#import "Masonry.h"
#import "UIImage+ColorToImage.h"
#import "UIView+UIExt.h"
#import "NXMBManager.h"
#import "NXWebFileManager.h"
#import "NXRightsSelectView.h"
#import "NXClassificationSelectView.h"
#import "NXCommonUtils.h"
#import "NXCardStyleView.h"
#import "NXLeftImageButton.h"
#import "NXRepositoryModel.h"
#import "NXLoginUser.h"
#import "NXWorkSpaceUploadFileAPI.h"
#import "NXMBManager.h"
#import "NXMessageViewManager.h"
#import "NXTimeServerManager.h"
#import "NXOriginalFilesTransfer.h"
#import "NXRightsCellModel.h"
#import "NXRightsMoreOptionsVC.h"
#import "NXProtectRepoFileSelectLocationVC.h"
#import "NXProtectFileSelectLocationVC.h"
#import "NXFileChooseFlowViewController.h"
#import "NXProtectedFileListView.h"
#import "DetailViewController.h"
#import "NXProtectFileSelectedPolicyVC.h"
#import "NXProtectedResultVC.h"
#import "NXNetworkHelper.h"
#define PREVIEWFOLDHEIGHT 125
#define KBTNTAG 100

@interface NXSaveLocationInfoView ()
@property(nonatomic, strong)UILabel *savePathLabel;
@property(nonatomic, strong)UIButton *changeSaveLocationBtn;
@property(nonatomic, strong)UILabel *hintMessageLabel;
@property(nonatomic, strong)UIImageView *imageView;
@end
@implementation NXSaveLocationInfoView

- (instancetype)initWithSavePathText:(NSString *)text {
    if (self = [super init]) {
        [self commonInitUIWithText:text];
    }
    return  self;
}
- (void)commonInitUIWithText:(NSString *)text {
    UIImageView *infoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info-icon"]];
    [self addSubview:infoImageView];
    UILabel *savePathLabel = [[UILabel alloc] init];
    [self addSubview:savePathLabel];
    self.savePathLabel = savePathLabel;
    savePathLabel.numberOfLines = 0;
    self.savePathLabel.text = text;
    
    UIButton *changeLocationButton = [[UIButton alloc] init];
    [self addSubview:changeLocationButton];
    [changeLocationButton setTitle:@"Change save location" forState:UIControlStateNormal];
    [changeLocationButton setTitleColor:[UIColor colorWithRed:43/255.0 green:126/255.0 blue:246/255.0 alpha:1] forState:UIControlStateNormal];
    changeLocationButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [changeLocationButton addTarget:self action:@selector(changeSaveLocation:) forControlEvents:UIControlEventTouchUpInside];
    self.changeSaveLocationBtn = changeLocationButton;
   
    [infoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kMargin);
        make.left.equalTo(self).offset(kMargin/2);
        make.width.height.equalTo(@25);
    }];
    [savePathLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(infoImageView.mas_right).offset(kMargin/2);
        make.top.equalTo(self).offset(kMargin/2);
//        make.height.equalTo(@20);
        make.right.equalTo(self).offset(-kMargin *2);
    }];

    [changeLocationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(savePathLabel);
        make.top.equalTo(savePathLabel.mas_bottom);
        make.width.equalTo(@150);
        make.height.equalTo(@44);
        make.bottom.equalTo(self).offset(-kMargin/2);
    }];
}
- (void)setHintMessage:(NSString *)hintMessage andSavePath:(NSString *)savePath {
    self.savePathLabel.attributedText = [self createAttributeString:hintMessage subTitle1:savePath];
}
- (void)changeSaveLocation:(id)sender {
    if (self.changeSaveLocationCompletion) {
        self.changeSaveLocationCompletion();
    }
}
- (void)hideChangeSaveLocationButton {
    self.changeSaveLocationBtn.hidden = YES;
    [self.changeSaveLocationBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@0);
    }];
}
- (NSAttributedString *)createAttributeString:(NSString *)title subTitle1:(NSString *)subtitle1 {
    NSMutableAttributedString *myprojects = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName :[UIColor lightGrayColor],NSFontAttributeName:[UIFont systemFontOfSize:16]}];
    
    NSAttributedString *sub1 = [[NSMutableAttributedString alloc] initWithString:subtitle1 attributes:@{NSForegroundColorAttributeName :[UIColor blackColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:17]}];
    [myprojects appendAttributedString:sub1];

    return myprojects;
}
@end

@interface NXProtectFileAfterSelectedLocationVC ()<NXRightsSelectViewDelegate,NXFileChooseFlowViewControllerDelegate>
@property(nonatomic, strong)UIScrollView *mainView;
@property(nonatomic, strong)UIView *bottomView;
@property(nonatomic, strong)UIButton *protectButton;
@property(nonatomic, strong)UIButton *nextButton;
@property(nonatomic, strong)NSString *downloadId;
@property(nonatomic, strong)NSString *operationIdentifier;
@property(nonatomic, strong)NSString *uploadOperationIdentifier;
//@property(nonatomic, strong)NXPreviewFileView *preview;
@property(nonatomic, strong)NXProtectedFileListView *selectFileListView;
@property(nonatomic, strong)UIView *specifyView;
@property(nonatomic, strong)UIButton *digitalBtn;
@property(nonatomic, strong)UIButton *classifyBtn;
@property(nonatomic, strong)NXRightsSelectView *digitalView;
@property(nonatomic, strong)NXClassificationSelectView *classificationView;
@property(nonatomic, strong)NSArray <NXClassificationCategory *>*classificationCategoryArray;
@property(nonatomic, strong) NXLRights *selectedRights;
@property(nonatomic, assign)BOOL isAdhocEnable;
@property(nonatomic, assign)BOOL isClassificationEbable;
@property(nonatomic, assign)BOOL isShowPreview;
@property(nonatomic, strong)NSArray *currentRepoFolderFiles;
@property(nonatomic, copy) NSString *currentFileOriginalName;
@property(nonatomic, strong)UIBarButtonItem *cancelItem;
@property(nonatomic, strong)NSMutableArray *downloadedFIlesArray;
@property(nonatomic ,strong)NSMutableArray *exsitArray;
@property(nonatomic, strong)NSMutableArray *encryptArray;
@property(nonatomic, strong)NSMutableArray *failArray;
@property(nonatomic, strong)NSMutableArray *needProtectFiles;
@property(nonatomic, strong)NXSaveLocationInfoView *locationInfoView;
@end
static const CGFloat bottomviewHeight = 70.0;
@implementation NXProtectFileAfterSelectedLocationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.downloadedFIlesArray = [NSMutableArray array];
    self.encryptArray = [NSMutableArray array];
    [self initNavigationBar];
    [self initEnableProtectType];
    [self commonInitUI];
    [self initFileData];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.protectButton.enabled = YES;
    self.cancelItem.enabled = YES;
}
- (void)initNavigationBar {
    NXCustomNavTitleView *titleView = [[NXCustomNavTitleView alloc] init];
    titleView.mainTitle = NSLocalizedString(@"UI_CREATE_A_PROTECTED_FILE", NULL);
    if (self.filesArray.count>1) {
        titleView.subTitle = [NSString stringWithFormat:@"Selected files (%lu)",(unsigned long)self.filesArray.count];
        
    }else{
        titleView.subTitle = [NSString stringWithFormat:@"Selected file (%lu)",(unsigned long)self.filesArray.count];
    }
   
    self.navigationItem.titleView = titleView;
//    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClicked:)];
//    leftItem.accessibilityValue = @"UI_BOX_CANCEL";
    self.navigationItem.hidesBackButton = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    rightItem.accessibilityValue = @"UPLOAD_CANCEL";
    self.navigationItem.rightBarButtonItem = rightItem;
    self.cancelItem = rightItem;
}
- (void)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)cancel:(id)sender{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)initEnableProtectType {
    self.isAdhocEnable = YES;
    self.isClassificationEbable = YES;
    if (self.locationType == NXProtectSaveLoactionTypeMyVault) {
        self.isClassificationEbable = NO;
    }
    if (self.locationType == NXProtectSaveLoactionTypeProject || self.locationType == NXProtectSaveLoactionTypeWorkSpace || self.locationType == NXProjectSaveLocationTypeSharedWorkSpace || self.locationType == NXProtectSaveLoactionTypeLocalFiles || self.locationType == NXProtectSaveLoactionTypeFileRepo) {
        if ([NXLoginUser sharedInstance].profile.tenantPrefence) {
            self.isAdhocEnable = [NXLoginUser sharedInstance].profile.tenantPrefence.ADHOC_ENABLED;
        }
    }
}
- (void)commonInitUI {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    [self.view addSubview: scrollView];
    self.mainView = scrollView;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.backgroundColor = [UIColor whiteColor];
    UIView *bottomView = [[UIView alloc] init];
    [self.view addSubview:bottomView];
    self.bottomView = bottomView;
    bottomView.backgroundColor = [UIColor whiteColor];
    UIButton *protectButton = [[UIButton alloc] init];
    [self.bottomView addSubview:protectButton];
    protectButton.enabled = NO;
    [protectButton setTitle:NSLocalizedString(@"UI_CREATE_A_PROTECTED_FILE", NULL) forState:UIControlStateNormal];
    protectButton.accessibilityValue = @"PROTECT_BTN";
    [protectButton addTarget:self action:@selector(protect:) forControlEvents:UIControlEventTouchUpInside];
    [protectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [protectButton setBackgroundImage:[UIImage imageWithSize:CGSizeMake(200, 200) colors:@[RMC_GRADIENT_START_COLOR, RMC_GRADIENT_END_COLOR] gradientType:GradientTypeLeftToRight] forState:UIControlStateNormal];
    [protectButton cornerRadian:3];
    _protectButton = protectButton;
    
    UIButton *nextButton = [[UIButton alloc] init];
    [self.bottomView addSubview:nextButton];
    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
    nextButton.accessibilityValue = @"NEXT_BTN";
    [nextButton addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextButton setBackgroundImage:[UIImage imageWithSize:CGSizeMake(200, 200) colors:@[RMC_GRADIENT_START_COLOR, RMC_GRADIENT_END_COLOR] gradientType:GradientTypeLeftToRight] forState:UIControlStateNormal];
    [nextButton cornerRadian:3];
    _nextButton = nextButton;
    protectButton.hidden = YES;
    nextButton.hidden = YES;
    nextButton.enabled = NO;
    if (@available(iOS 11.0, *)) {
       
       [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
           make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
           make.left.and.right.equalTo(self.view);
           make.height.equalTo(@(bottomviewHeight));
       }];
       
       [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
           make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
           make.bottom.equalTo(bottomView.mas_top);
           make.width.equalTo(self.view);
           make.centerX.equalTo(self.view);
       }];
    }else{
        [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view);
            make.left.and.right.equalTo(self.view);
            make.height.equalTo(@(bottomviewHeight));
        }];
        
        [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottomLayoutGuideTop);
            make.bottom.equalTo(bottomView.mas_top);
            make.width.equalTo(self.view);
            make.centerX.equalTo(self.view);
        }];
    }
    [protectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.bottomView);
        make.width.equalTo(@300);
        make.height.lessThanOrEqualTo(self.bottomView).multipliedBy(0.7);
        make.height.lessThanOrEqualTo(@(40));
    }];
    [nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(protectButton);
    }];
}
- (void)initFileData {
    if (!self.filesArray) {
        return;
    }
    for (NXFileBase *fileItem in self.filesArray) {
        
        if (!fileItem.size || fileItem.size == 0) {
            [NXMBManager showMessage:@"You can not operate on 0KB file.Please select a different file." toView:self.mainView hideAnimated:YES afterDelay:kDelay * 2];
            return;
            
        }
        
        
        BOOL ret = [[NXLoginUser sharedInstance].nxlOptManager isNXLFile:fileItem];
        if (ret) {
            [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_NO_PROTECT_NXL_FILE", NULL) toView:self.mainView hideAnimated:YES afterDelay:kDelay * 2];
            return;
        }
        
    }
    [self showAllUIForThisPage];
  

}

- (void)showAllUIForThisPage{
//    [NXMBManager hideHUDForView:self.mainView];
//    self.preview.hidden = NO;
    NXProtectedFileListView *fileListView = [[NXProtectedFileListView alloc] initWithFileList:self.filesArray];
    self.selectFileListView = fileListView;
    [self.mainView addSubview:fileListView];
    fileListView.fileClickedCompletion = ^(NXFileBase * _Nonnull file) {
      // preview this file
        DetailViewController *detailVC = [[DetailViewController alloc] init];
        [detailVC openFileForPreview:file];
        [self.navigationController pushViewController:detailVC animated:YES];
    };

    NXSaveLocationInfoView *locationView = [[NXSaveLocationInfoView alloc] initWithSavePathText: [self getSaveLocationPath:self.fileItem]];
    [self.mainView addSubview:locationView];
    if (self.filesArray.count>1) {
        [locationView setHintMessage:NSLocalizedString(@"UI_FILES_WILL_BE_SAVED_TO1", NULL) andSavePath:[self getSaveLocationPath:self.saveFolder]];
    }else{
        [locationView setHintMessage:NSLocalizedString(@"UI_FILE_WILL_BE_SAVED_TO1", NULL) andSavePath:[self getSaveLocationPath:self.saveFolder]];
    }
   
    self.locationInfoView = locationView;
    [locationView addShadow:UIViewShadowPositionBottom color:[UIColor groupTableViewBackgroundColor]];
    locationView.changeSaveLocationCompletion = ^{
      // change save location
        [self changeSaveLocationion];
    };
    [fileListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mainView);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
    }];
    [locationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fileListView.mas_bottom).offset(kMargin/2);
        make.left.right.equalTo(fileListView);
    }];

    self.specifyView.backgroundColor = [UIColor whiteColor];
    
    // ***** suppot adhocEnable *****
   
    if (self.isClassificationEbable) {
        self.protectType = NXSelectProtectTypeClassification;
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
            self.protectType = NXSelectProtectTypeClassification;
            self.classificationView.hidden = NO;
            self.digitalView.hidden = YES;
        }
    }else{
        self.protectType = NXSelectProtectTypeDigital;
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
    if (self.protectType == NXSelectProtectTypeDigital) {
        self.protectButton.hidden = NO;
        self.protectButton.enabled = YES;
        self.nextButton.hidden = YES;
    }else if(self.protectType == NXSelectProtectTypeClassification){
        self.protectButton.hidden = YES;
        self.nextButton.hidden = NO;
    }
    if (self.isClassificationEbable) {
        [NXMBManager showLoading];
        if (self.locationType == NXProtectSaveLoactionTypeProject && self.targetProject) {
           
            [[NXLoginUser sharedInstance].myProject allClassificationsForProject:self.targetProject withCompletion:^(NXProjectModel *project, NSArray<NXClassificationCategory *> *classificaiton, NSError *error) {
               
                    self.classificationCategoryArray = [NSArray arrayWithArray:classificaiton];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [NXMBManager hideHUD];
                        if (!error) {
                            self.classificationView.classificationCategoryArray = self.classificationCategoryArray;
                            self.digitalView.hidden = YES;
                            self.nextButton.enabled = YES;
                        }else{
                            self.digitalView.hidden = NO;
                            [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:kDelay];
                        }
                    });
               
                        
            }];
            
        }else{
            self.operationIdentifier = [[NXLoginUser sharedInstance].workSpaceManager getWorkSpaceDefalutClassificationWithCompletion:^(NSArray *classifications, NSError *error) {
                self.classificationCategoryArray = [NSArray arrayWithArray:classifications];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NXMBManager hideHUD];
                    if (!error) {
                        self.classificationView.classificationCategoryArray = self.classificationCategoryArray;
                        self.digitalView.hidden = YES;
                        self.nextButton.enabled = YES;
                    }else{
                        self.digitalView.hidden = NO;
                        [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:kDelay];
                    }
                });
            }];
            
        }
       
    }
   
    self.selectedRights = self.digitalView.rights;
    [self.specifyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(locationView.mas_bottom).offset(kMargin/2);
        make.left.right.equalTo(self.selectFileListView);
    }];
    [self.digitalView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.specifyView.mas_bottom);
        make.left.right.equalTo(self.specifyView);
        make.height.greaterThanOrEqualTo(@100);
    }];
    [self.classificationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.specifyView.mas_bottom);
        make.left.right.equalTo(self.specifyView);
        make.height.greaterThanOrEqualTo(@100);
    }];
    
}
- (UIView *)specifyView {
    if (!_specifyView) {
        _specifyView = [[UIView alloc]init];
        [self.mainView addSubview:_specifyView];
        UILabel *specifyLabel =[[UILabel alloc]init];
        if (self.filesArray.count>1) {
            specifyLabel.text = NSLocalizedString(@"UI_SPECIFY_DIGITAL_OR_CLASSIFY_FILES", NULL);
        }else{
            specifyLabel.text = NSLocalizedString(@"UI_SPECIFY_DIGITAL_OR_CLASSIFY", NULL);
        }
       
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
        if (self.locationType == NXProtectSaveLoactionTypeProject) {
            _digitalView.currentWatermarks = [self.targetProject.watermark parseWatermarkWords];
            _digitalView.currentValidModel = self.targetProject.validateModel;
            [rights setFileValidateDate:self.targetProject.validateModel];

            [_digitalView setRights:rights withFileSorceType:NXFileBaseSorceTypeProject];
            _digitalView.isToProject = YES;
        }else if (self.locationType == NXProtectSaveLoactionTypeWorkSpace){

            [_digitalView setRights:rights withFileSorceType:NXFileBaseSorceTypeWorkSpace];
        }else{
            _digitalView.rights = rights;
        }
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
- (void)selectTypeBtnClick:(UIButton *)sender {
    
    NSInteger index = sender.tag - KBTNTAG;
    if (index == self.protectType) {
        return;
    }else {
        self.digitalBtn.selected = NO;
        self.digitalBtn.backgroundColor = [UIColor whiteColor];
        self.classifyBtn.selected = NO;
        self.classifyBtn.backgroundColor = [UIColor whiteColor];
        self.protectType = index;
        switch (index) {
            case NXSelectProtectTypeDigital:
            {
                self.classificationView.hidden = YES;
                self.digitalView.hidden = NO;
                
            }
                break;
            case NXSelectProtectTypeClassification:
            {
                self.classificationView.hidden = NO;
                self.digitalView.hidden = YES;
            }
                break;
        }
        sender.backgroundColor = RMC_MAIN_COLOR;
        sender.selected = YES;
        if (self.protectType == NXSelectProtectTypeDigital) {
            self.protectButton.hidden = NO;
            self.protectButton.enabled = YES;
            self.nextButton.hidden = YES;
        }else if(self.protectType == NXSelectProtectTypeClassification){
            self.protectButton.hidden = YES;
            self.nextButton.hidden = NO;
        }
        [self setScrollViewContentSize];
        
    }
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setScrollViewContentSize];
    });
   
}
- (void)setScrollViewContentSize {
    CGFloat height;
    switch (self.protectType) {
        case NXSelectProtectTypeDigital:
            height = CGRectGetHeight(self.selectFileListView.bounds) + CGRectGetHeight(self.locationInfoView.bounds) + CGRectGetHeight(self.digitalView.bounds)+CGRectGetHeight(_specifyView.bounds);
            break;
        case NXSelectProtectTypeClassification:
            height = CGRectGetHeight(self.selectFileListView.bounds) + CGRectGetHeight(self.locationInfoView.bounds) + CGRectGetHeight(self.classificationView.bounds)+CGRectGetHeight(_specifyView.bounds);
            break;
    }
    if (self.mainView.bounds.size.height - bottomviewHeight > height) {
        self.mainView.contentSize = CGSizeMake(CGRectGetWidth(self.mainView.bounds), CGRectGetHeight(self.mainView.bounds) + kMargin * 3);
    } else {
        self.mainView.contentSize = CGSizeMake(CGRectGetWidth(self.mainView.bounds), height + kMargin * 3);
    }
}
//- (void)changePreviewSize {
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
//        [self.mainView layoutIfNeeded];
//    } completion:^(BOOL finished) {
//        [self setScrollViewContentSize];
//    }];
//
//}

- (NSString *)getSaveLocationPath:(NXFileBase *)fileItem {
    NSString *savePath;
    switch (self.locationType) {
        case NXProtectSaveLoactionTypeWorkSpace:
            savePath = [NSString stringWithFormat:@"%@%@",@"SkyDRM://WorkSpace",self.saveFolder.fullPath];
            break;
        case NXProtectSaveLoactionTypeMyVault:
            savePath = @"SkyDRM://MySpace";
            break;
        case NXProjectSaveLocationTypeSharedWorkSpace:
        case NXProtectSaveLoactionTypeFileRepo:
        {
            NXRepositoryModel *model = [[NXLoginUser sharedInstance].myRepoSystem getRepositoryModelByRepoId:self.saveFolder.repoId];
            savePath = [NSString stringWithFormat:@"%@%@%@",@"SkyDRM://Repositories/",model.service_alias,self.saveFolder.fullPath];
            self.currentRepoFolderFiles = [[NXLoginUser sharedInstance].myRepoSystem childForFileItem:self.saveFolder];
        }
            break;
        case NXProtectSaveLoactionTypeLocalFiles:
            savePath = @"Device://Files";
            break;
        case NXProtectSaveLoactionTypeProject:
            savePath = [NSString stringWithFormat:@"%@%@%@",@"SkyDRM://Projects/",self.targetProject.name,self.saveFolder.fullPath];
            break;
    }
    return savePath;
}
- (void)protect:(id)sender {
    if (![[NXNetworkHelper sharedInstance] isNetworkAvailable]) {
        [NXMBManager showMessage:@"The internet connection appears to be offline" toView:self.view hideAnimated:YES afterDelay:kDelay];
        return;
    }
    self.protectButton.enabled = NO;
    self.cancelItem.enabled = NO;
    switch (self.locationType) {
        case NXProtectSaveLoactionTypeWorkSpace:
           [self proetctMultipleFilesToWorkspace:self.filesArray];
            break;
        case NXProtectSaveLoactionTypeMyVault:
            [self protectMultipleFilesToMyVault:self.filesArray];
            break;
        case NXProjectSaveLocationTypeSharedWorkSpace:
        case NXProtectSaveLoactionTypeFileRepo:
            [self uploadMultipleFilesToRepo:self.filesArray toFolder:self.saveFolder];
            break;
        case NXProtectSaveLoactionTypeLocalFiles:
            [self protectFilesToLocalFiles:self.filesArray];
            break;
        case NXProtectSaveLoactionTypeProject:
            [self protectMultipleFileToProject:self.filesArray];
            break;
    }

}
- (void)proetctMultipleFilesToWorkspace:(NSArray *)array{
    
    if (self.saveFolder == nil) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_SELECT_FOLDER", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
        self.protectButton.enabled = YES;
        self.cancelItem.enabled = YES;
        return;
    }
    if (!array.count) {
        return;
    }
       
    if (!self.selectedRights.getVaildateDateModel) {
       [self.selectedRights setFileValidateDate:[NXLoginUser sharedInstance].userPreferenceManager.userPreference.preferenceFileValidateDate];
       }
     
       
    if (![NXCommonUtils checkIsLegalFileValidityDate:[self.selectedRights getVaildateDateModel]]) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_FILE_EXPIRETIME_INVALID", NULL) hideAnimated:YES afterDelay:kDelay];
        self.protectButton.enabled = YES;
        self.cancelItem.enabled = YES;
        return;
    }
    [NXMBManager showLoading];
    
    NSMutableArray *existArray = [self checkExistFilesFromWrokspace:array];
    self.exsitArray = existArray;
    self.needProtectFiles = [NSMutableArray array];
    if (existArray.count > 0) {
        NSMutableArray *successArray = [NSMutableArray array];
        NSMutableArray *failArray = [NSMutableArray array];
        [[NXWebFileManager sharedInstance] downloadMultipleFiles:array completed:^(NSArray *downloadFileArray, NSError *error) {
            if (error) {
                for (NXFileBase *fileItem in array) {
                    fileItem.name = [NSString stringWithFormat:@"%@%@",fileItem.name,@".nxl"];
                    fileItem.localPath = error.localizedDescription;
                    [failArray addObject:fileItem];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NXMBManager hideHUD];
                    NXProtectedResultVC *VC = [[NXProtectedResultVC alloc] init];
                    VC.failFileArray = failArray;
                    VC.allFilesArray = array;
                    VC.savePath = [self getSaveLocationPath:self.saveFolder];
                    VC.successFileArray = successArray;
                    [self.navigationController pushViewController:VC animated:YES];
                    
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NXWorkSpaceFile *fileItem =  existArray.firstObject;
                    [self showMessageAboutWorkspaceFile:fileItem needProtectFileArray:downloadFileArray];
                   

                });
            }
           
        }];
       
    }else{
        [[NXLoginUser sharedInstance].nxlOptManager protectMultipleFilesToWorkspace:array membershipId:[NXLoginUser sharedInstance].profile.tenantMembership.ID  permissions:self.selectedRights classifications:nil intoFolder:(NXFolder *)self.saveFolder withCompletion:^(NSArray *successArray, NSArray *failArray, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [NXMBManager hideHUD];
                if (!error && failArray.count == 0) {
                    [self dismissSelf];
                }else{
                    NXProtectedResultVC *VC = [[NXProtectedResultVC alloc] init];
                    VC.failFileArray = failArray;
                    VC.allFilesArray = array;
                    VC.savePath = [self getSaveLocationPath:self.saveFolder];
                    VC.successFileArray = successArray;
                    [self.navigationController pushViewController:VC animated:YES];
                }

            });
        }];
        
    }
   
    
}
- (void)showMessageAboutWorkspaceFile:(NXFileBase *)fileItem needProtectFileArray:(NSArray *)downloadArray {
    if (self.exsitArray.count) {
        self.needProtectFiles = [NSMutableArray arrayWithArray:downloadArray];
        if (fileItem && [self.exsitArray containsObject:fileItem]) {
            [self.exsitArray removeObject:fileItem];
            dispatch_async(dispatch_get_main_queue(), ^{

                                for (NXFileBase *file in self.needProtectFiles) {
                
                                if ([fileItem.name.stringByDeletingPathExtension isEqualToString:file.name]) {
                                    if ([self isHaveOverwritePerssion:fileItem]) {
                                        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MSG_REPLACEANDKEEPBOTH_SELECT_MESSAGE", NULL), fileItem.name];
                                        [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_REPLACE", NULL) cancelActionTitle:NSLocalizedString(@"UI_BOX_SKIP", NULL) otherTitle:NSLocalizedString(@"UI_BOX_NO_REPLACE", NULL) OKActionHandle:^(UIAlertAction *action) {
                                            [self showMessageAboutWorkspaceFile:self.exsitArray.firstObject needProtectFileArray:self.needProtectFiles];
            
                                                               } cancelActionHandle:^(UIAlertAction *action) {
                                                                   [self.needProtectFiles removeObject:file];
                                                                   [self showMessageAboutWorkspaceFile:self.exsitArray.firstObject needProtectFileArray:self.needProtectFiles];
                                                                  
                                                               } otherActionHandle:^(UIAlertAction *action) {
                                                                   NSArray *currentFolderFiles = [[NXLoginUser sharedInstance].workSpaceManager getWorkSpaceFileListUnderFolderInCoreData:(NXWorkSpaceFolder *)self.saveFolder];
                                                                   NSMutableArray *currentFolderFilesNameArray = [[NSMutableArray alloc] init];
                                                                     for (NXWorkSpaceFile *tmpfile in currentFolderFiles) {
                                                                                             if (tmpfile.name.length > 0) {
                                                                                                 [currentFolderFilesNameArray addObject:tmpfile.name];
                                                                                             }
                                                                                         }
                                                                                         NSUInteger index = 2;
                                                                                         NSUInteger MaxIndex = [NXCommonUtils getMaxIndexForFile:file.name fileNameArray:currentFolderFilesNameArray];
                                                                                         NSString *newFileName = file.name;
                                                                                         if (MaxIndex == 0) {
                                                                                             newFileName = [NXCommonUtils addIndexForFile:index fileName:newFileName];
                                                                                         }else{
                                                                                             MaxIndex += 1;
                                                                                             newFileName = [NXCommonUtils addIndexForFile:MaxIndex fileName:newFileName];
                                                                                         }
                                  
                                                                                         file.name = newFileName;
                                                                   NXFileBase *newFile = [file copy];
                                                                   newFile.name = newFileName;
                                                                  
                                                                   [self.needProtectFiles removeObject:file];
                                                                   [self.needProtectFiles addObject:newFile];
                                                                   [self showMessageAboutWorkspaceFile:self.exsitArray.firstObject needProtectFileArray:self.needProtectFiles];
                                                                  
                                                               } inViewController:self position:self.view];
                                        
                                    }else{
                                        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MSG_KEEPBOTH_SELECT_MESSAGE", NULL), fileItem.name];
                                        [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message style:UIAlertControllerStyleAlert OKActionTitle:nil cancelActionTitle:NSLocalizedString(@"UI_BOX_SKIP", NULL) otherTitle:NSLocalizedString(@"UI_BOX_NO_REPLACE", NULL) OKActionHandle:^(UIAlertAction *action) {
    //                                        [self.needProtectFiles addObject:file];
    //                                        [self showMessageAboutFile:self.downloadedFIlesArray.firstObject needProtectFileArray:downloadArray];
    //
                                                               } cancelActionHandle:^(UIAlertAction *action) {
                                                                   [self.needProtectFiles removeObject:file];
                                                                   [self showMessageAboutWorkspaceFile:self.exsitArray.firstObject needProtectFileArray:self.needProtectFiles];
                                                                  
                                                               } otherActionHandle:^(UIAlertAction *action) {
                                                                   NSArray *currentFolderFiles = [[NXLoginUser sharedInstance].workSpaceManager getWorkSpaceFileListUnderFolderInCoreData:(NXWorkSpaceFolder *)self.saveFolder];
                                                                   NSMutableArray *currentFolderFilesNameArray = [[NSMutableArray alloc] init];
                                                                     for (NXWorkSpaceFile *tmpfile in currentFolderFiles) {
                                                                                             if (tmpfile.name.length > 0) {
                                                                                                 [currentFolderFilesNameArray addObject:tmpfile.name];
                                                                                             }
                                                                                         }
                                                                                         NSUInteger index = 2;
                                                                                         NSUInteger MaxIndex = [NXCommonUtils getMaxIndexForFile:file.name fileNameArray:currentFolderFilesNameArray];
                                                                                         NSString *newFileName = file.name;
                                                                                         if (MaxIndex == 0) {
                                                                                             newFileName = [NXCommonUtils addIndexForFile:index fileName:newFileName];
                                                                                         }else{
                                                                                             MaxIndex += 1;
                                                                                             newFileName = [NXCommonUtils addIndexForFile:MaxIndex fileName:newFileName];
                                                                                         }

                                                                   NXFileBase *newFile = [file copy];
                                                                   newFile.name = newFileName;

                                                                   [self.needProtectFiles removeObject:file];
                                                                   [self.needProtectFiles addObject:newFile];
                                                                   [self showMessageAboutWorkspaceFile:self.exsitArray.firstObject needProtectFileArray:self.needProtectFiles];
                                                                  
                                                               } inViewController:self position:self.view];
                                        
                                    }
                                  
                                }
                            }
                            
            });
           
        }
        
    }else{
        if (!self.needProtectFiles.count) {
            [NXMBManager hideHUD];
            self.cancelItem.enabled = YES;
            self.protectButton.enabled = YES;
            [self dismissSelf];
            return;
        }
        [[NXLoginUser sharedInstance].nxlOptManager protectMultipleAlreadyDownloadFilesToWorkspace:self.needProtectFiles  membershipLid:[NXLoginUser sharedInstance].profile.tenantMembership.ID permissions:self.selectedRights classifications:nil inFolder:(NXFolder *)self.saveFolder withCompletion:^(NSArray *successArray, NSArray *failArray, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [NXMBManager hideHUD];
                if (!error && failArray.count == 0) {
                    [self dismissSelf];
                }else{
                    NXProtectedResultVC *VC = [[NXProtectedResultVC alloc] init];
                    VC.failFileArray = failArray;
                    VC.allFilesArray = downloadArray;
                    VC.savePath = [self getSaveLocationPath:self.saveFolder];
                    VC.successFileArray = successArray;
                    [self.navigationController pushViewController:VC animated:YES];
                }
                
            });
        }];
    }
    
}
- (void)showMessageAboutMyVaultFile:(NXFileBase *)fileItem needProtectFileArray:(NSArray *)downloadArray {
    if (self.exsitArray.count) {
        self.needProtectFiles = [NSMutableArray arrayWithArray:downloadArray];
        if (fileItem && [self.exsitArray containsObject:fileItem]) {
            [self.exsitArray removeObject:fileItem];
            dispatch_async(dispatch_get_main_queue(), ^{

                                for (NXFileBase *file in self.needProtectFiles) {
                
                                if ([fileItem.name.stringByDeletingPathExtension isEqualToString:file.name]) {
//                                    if ([self isHaveOverwritePerssion:fileItem]) {
                                    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MSG_REPLACEANDKEEPBOTH_SELECT_MESSAGE", NULL), fileItem.name];
                                    [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_REPLACE", NULL) cancelActionTitle:NSLocalizedString(@"UI_BOX_SKIP", NULL) otherTitle:NSLocalizedString(@"UI_BOX_NO_REPLACE", NULL) OKActionHandle:^(UIAlertAction *action) {
                                        [self showMessageAboutMyVaultFile:self.exsitArray.firstObject needProtectFileArray:self.needProtectFiles];

                                                           } cancelActionHandle:^(UIAlertAction *action) {
                                                               [self.needProtectFiles removeObject:file];
                                                               [self showMessageAboutMyVaultFile:self.exsitArray.firstObject needProtectFileArray:self.needProtectFiles];
                                                              
                                                           } otherActionHandle:^(UIAlertAction *action) {
                                                               NSArray *currentFolderFiles = [[NXLoginUser sharedInstance].myVault getAllMyVaultFileInCoreData];
                                                               NSMutableArray *currentFolderFilesNameArray = [[NSMutableArray alloc] init];
                                                                 for (NXFileBase *tmpfile in currentFolderFiles) {
                                                                                         if (tmpfile.name.length > 0) {
                                                                                             [currentFolderFilesNameArray addObject:tmpfile.name];
                                                                                         }
                                                                                     }
                                                                                     NSUInteger index = 2;
                                                                                     NSUInteger MaxIndex = [NXCommonUtils getMaxIndexForFile:file.name fileNameArray:currentFolderFilesNameArray];
                                                                                     NSString *newFileName = file.name;
                                                                                     if (MaxIndex == 0) {
                                                                                         newFileName = [NXCommonUtils addIndexForFile:index fileName:newFileName];
                                                                                     }else{
                                                                                         MaxIndex += 1;
                                                                                         newFileName = [NXCommonUtils addIndexForFile:MaxIndex fileName:newFileName];
                                                                                     }
                              
                                                                                     file.name = newFileName;
                                                               NXFileBase *newFile = [file copy];
                                                               newFile.name = newFileName;
        //                                                                   newFile.localPath = file.localPath;
                                                               [self.needProtectFiles removeObject:file];
                                                               [self.needProtectFiles addObject:newFile];
                                                               [self showMessageAboutMyVaultFile:self.exsitArray.firstObject needProtectFileArray:self.needProtectFiles];
                                                              
                                                           } inViewController:self position:self.view];
                                        

                                }
                            }
                            
            });
           
        }
    }else{
        if (!self.needProtectFiles.count) {
            [NXMBManager hideHUD];
            self.cancelItem.enabled = YES;
            self.protectButton.enabled = YES;
            [self dismissSelf];
            return;
        }
        
        NSMutableArray *successArray = [NSMutableArray array];
        NSMutableArray *failArray = [NSMutableArray array];
        for (NXFileBase *fileItem in self.needProtectFiles) {
            NXFile *fakeFile = [fileItem copy];
            [[NXLoginUser sharedInstance].nxlOptManager protectToNXLFile:fakeFile toPath:[NXCommonUtils createNewNxlTempFile:fakeFile.name] permissions:self.selectedRights membershipId:nil createDate:[NXTimeServerManager sharedInstance].currentServerTime withCompletion:^(NSString *filePath, NSError *error) {
                if (!error) {
                    NXFileBase *file = [[NXFile alloc] init];
                    file.localPath = filePath;
                    file.name = [filePath lastPathComponent];
                    [successArray addObject:file];
                }else{
                    fileItem.name = [NSString stringWithFormat:@"%@%@",fileItem.name,@".nxl"];
                    fileItem.localPath = error.localizedDescription;
                    [failArray addObject:fileItem];
                }
                if (successArray.count + failArray.count == self.needProtectFiles.count) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [NXMBManager hideHUD];
                        if (!error && failArray.count == 0) {
                            [self dismissSelf];
                        }else{
                            NXProtectedResultVC *VC = [[NXProtectedResultVC alloc] init];
                            VC.failFileArray = failArray;
                            VC.allFilesArray = downloadArray;
                            VC.savePath = [self getSaveLocationPath:self.saveFolder];
                            VC.successFileArray = successArray;
                            [self.navigationController pushViewController:VC animated:YES];
                        }
                        
                    });
                   
                }
            }];
        }
    }
    
}
- (void)showMessageAboutProjectFile:(NXFileBase *)fileItem needProtectFileArray:(NSArray *)downloadArray {
    if (self.exsitArray.count) {
        self.needProtectFiles = [NSMutableArray arrayWithArray:downloadArray];
        if (fileItem && [self.exsitArray containsObject:fileItem]) {
            [self.exsitArray removeObject:fileItem];
            dispatch_async(dispatch_get_main_queue(), ^{

                                for (NXFileBase *file in self.needProtectFiles) {
                
                                if ([fileItem.name.stringByDeletingPathExtension isEqualToString:file.name]) {
                                    if ([self isHaveOverwritePerssion:fileItem]) {
                                        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MSG_REPLACEANDKEEPBOTH_SELECT_MESSAGE", NULL), fileItem.name];
                                        [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_REPLACE", NULL) cancelActionTitle:NSLocalizedString(@"UI_BOX_SKIP", NULL) otherTitle:NSLocalizedString(@"UI_BOX_NO_REPLACE", NULL) OKActionHandle:^(UIAlertAction *action) {
                                            [self showMessageAboutProjectFile:self.exsitArray.firstObject needProtectFileArray:self.needProtectFiles];
            
                                                               } cancelActionHandle:^(UIAlertAction *action) {
                                                                   [self.needProtectFiles removeObject:file];
                                                                   [self showMessageAboutProjectFile:self.exsitArray.firstObject needProtectFileArray:self.needProtectFiles];
                                                                  
                                                               } otherActionHandle:^(UIAlertAction *action) {
                                                                   NSArray *currentFolderFiles = [[NXLoginUser sharedInstance].myProject getFileListUnderParentFolderInCoreData:(NXProjectFolder *)self.saveFolder];
                                                                   NSMutableArray *currentFolderFilesNameArray = [[NSMutableArray alloc] init];
                                                                     for (NXFileBase *tmpfile in currentFolderFiles) {
                                                                                             if (tmpfile.name.length > 0) {
                                                                                                 [currentFolderFilesNameArray addObject:tmpfile.name];
                                                                                             }
                                                                                         }
                                                                                         NSUInteger index = 2;
                                                                                         NSUInteger MaxIndex = [NXCommonUtils getMaxIndexForFile:file.name fileNameArray:currentFolderFilesNameArray];
                                                                                         NSString *newFileName = file.name;
                                                                                         if (MaxIndex == 0) {
                                                                                             newFileName = [NXCommonUtils addIndexForFile:index fileName:newFileName];
                                                                                         }else{
                                                                                             MaxIndex += 1;
                                                                                             newFileName = [NXCommonUtils addIndexForFile:MaxIndex fileName:newFileName];
                                                                                         }
                                  
                                                                                         file.name = newFileName;
                                                                   NXFileBase *newFile = [file copy];
                                                                   newFile.name = newFileName;
//                                                                   newFile.localPath = file.localPath;
                                                                   [self.needProtectFiles removeObject:file];
                                                                   [self.needProtectFiles addObject:newFile];
                                                                   [self showMessageAboutProjectFile:self.exsitArray.firstObject needProtectFileArray:self.needProtectFiles];
                                                                  
                                                               } inViewController:self position:self.view];
                                        
                                    }else{
                                        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MSG_KEEPBOTH_SELECT_MESSAGE", NULL), fileItem.name];
                                        [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message style:UIAlertControllerStyleAlert OKActionTitle:nil cancelActionTitle:NSLocalizedString(@"UI_BOX_SKIP", NULL) otherTitle:NSLocalizedString(@"UI_BOX_NO_REPLACE", NULL) OKActionHandle:^(UIAlertAction *action) {
  
                                                               } cancelActionHandle:^(UIAlertAction *action) {
                                                                   [self.needProtectFiles removeObject:file];
                                                                   [self showMessageAboutProjectFile:self.exsitArray.firstObject needProtectFileArray:self.needProtectFiles];
                                                                  
                                                               } otherActionHandle:^(UIAlertAction *action) {
                                                                   NSArray *currentFolderFiles = [[NXLoginUser sharedInstance].myProject getFileListUnderParentFolderInCoreData:(NXProjectFolder *)self.saveFolder];
                                                                   NSMutableArray *currentFolderFilesNameArray = [[NSMutableArray alloc] init];
                                                                     for (NXFileBase *tmpfile in currentFolderFiles) {
                                                                                             if (tmpfile.name.length > 0) {
                                                                                                 [currentFolderFilesNameArray addObject:tmpfile.name];
                                                                                             }
                                                                                         }
                                                                                         NSUInteger index = 2;
                                                                                         NSUInteger MaxIndex = [NXCommonUtils getMaxIndexForFile:file.name fileNameArray:currentFolderFilesNameArray];
                                                                                         NSString *newFileName = file.name;
                                                                                         if (MaxIndex == 0) {
                                                                                             newFileName = [NXCommonUtils addIndexForFile:index fileName:newFileName];
                                                                                         }else{
                                                                                             MaxIndex += 1;
                                                                                             newFileName = [NXCommonUtils addIndexForFile:MaxIndex fileName:newFileName];
                                                                                         }
                                  
                                                                                         file.name = newFileName;
                                                                   NXFileBase *newFile = [file copy];
                                                                   newFile.name = newFileName;

                                                                   [self.needProtectFiles removeObject:file];
                                                                   [self.needProtectFiles addObject:newFile];
                                                                   [self showMessageAboutProjectFile:self.exsitArray.firstObject needProtectFileArray:self.needProtectFiles];
                                                                  
                                                               } inViewController:self position:self.view];
                                        
                                    }
                                  
                                }
                            }
                            
            });
           
        }
        
    }else{
        if (!self.needProtectFiles.count) {
            [NXMBManager hideHUD];
            self.cancelItem.enabled = YES;
            self.protectButton.enabled = YES;
            [self dismissSelf];
            return;
        }
        NSMutableArray *successArray = [NSMutableArray array];
        NSMutableArray *failArray = [NSMutableArray array];
        for (NXFileBase *fileItem in self.needProtectFiles) {
            
            [[NXLoginUser sharedInstance].nxlOptManager protectToNXLFile:fileItem toPath:[NXCommonUtils createNewNxlTempFile:fileItem.name] permissions:self.selectedRights membershipId:self.targetProject.membershipId inProject:self.targetProject.projectId intoFolder:(NXProjectFolder *)self.saveFolder createDate:[NXTimeServerManager sharedInstance].currentServerTime andIsOverwrite:YES withCompletion:^(NXProjectFolder *parentFolder, NXProjectFile *newProjectFile, NSError *error) {
            
                dispatch_async(dispatch_get_main_queue(), ^{
                   
                    if (!error) {
                        [successArray addObject:newProjectFile];
                    }else{
                        fileItem.name = [NSString stringWithFormat:@"%@%@",fileItem.name,@".nxl"];
                        fileItem.localPath = error.localizedDescription;
                        [failArray addObject:fileItem];
                    }
                    if (successArray.count + failArray.count == self.needProtectFiles.count) {
                        [NXMBManager hideHUD];
                        if (failArray.count >0) {
                           
                            NXProtectedResultVC *VC = [[NXProtectedResultVC alloc] init];
                            VC.failFileArray = failArray;
                            VC.allFilesArray = downloadArray;
                            VC.savePath = [self getSaveLocationPath:self.saveFolder];
                            VC.successFileArray = successArray;
                            [self.navigationController pushViewController:VC animated:YES];
                        }else{
                            [self dismissSelf];
                        }
                        
                    }
                });

            }];
        }
    }
    
}
- (void)showMessageRepoFile:(NXFileBase *)fileItem needProtectFileArray:(NSArray *)downloadArray {
    if (self.exsitArray.count) {
        self.needProtectFiles = [NSMutableArray arrayWithArray:downloadArray];
        if (fileItem && [self.exsitArray containsObject:fileItem]) {
            [self.exsitArray removeObject:fileItem];
            dispatch_async(dispatch_get_main_queue(), ^{

                                for (NXFileBase *file in  self.needProtectFiles) {
                
                                if ([fileItem.name.stringByDeletingPathExtension isEqualToString:file.name]) {
                                    if ([self isHaveOverwritePerssion:fileItem]) {
                                        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MSG_REPLACEANDKEEPBOTH_SELECT_MESSAGE", NULL), fileItem.name];
                                        [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_REPLACE", NULL) cancelActionTitle:NSLocalizedString(@"UI_BOX_SKIP", NULL) otherTitle:NSLocalizedString(@"UI_BOX_NO_REPLACE", NULL) OKActionHandle:^(UIAlertAction *action) {
                                            [self showMessageRepoFile:self.exsitArray.firstObject needProtectFileArray: self.needProtectFiles];
            
                                                               } cancelActionHandle:^(UIAlertAction *action) {
                                                                   [self.needProtectFiles removeObject:file];
                                                                   [self showMessageRepoFile:self.exsitArray.firstObject needProtectFileArray: self.needProtectFiles];
                                                                  
                                                               } otherActionHandle:^(UIAlertAction *action) {
                                                                   NSArray *currentFolderFiles = [[NXLoginUser sharedInstance].myRepoSystem childForFileItem:self.saveFolder];
                                                                   NSMutableArray *currentFolderFilesNameArray = [[NSMutableArray alloc] init];
                                                                     for (NXFile *tmpfile in currentFolderFiles) {
                                                                                             if (tmpfile.name.length > 0) {
                                                                                                 [currentFolderFilesNameArray addObject:tmpfile.name];
                                                                                             }
                                                                                         }
                                                                                         NSUInteger index = 2;
                                                                                         NSUInteger MaxIndex = [NXCommonUtils getMaxIndexForFile:file.name fileNameArray:currentFolderFilesNameArray];
                                                                                         NSString *newFileName = file.name;
                                                                                         if (MaxIndex == 0) {
                                                                                             newFileName = [NXCommonUtils addIndexForFile:index fileName:newFileName];
                                                                                         }else{
                                                                                             MaxIndex += 1;
                                                                                             newFileName = [NXCommonUtils addIndexForFile:MaxIndex fileName:newFileName];
                                                                                         }
                                  
                                                                                         file.name = newFileName;
                                                                   NXFileBase *newFile = [file copy];
                                                                   newFile.name = newFileName;
//                                                                   newFile.localPath = file.localPath;
                                                                   [self.needProtectFiles removeObject:file];
                                                                   [self.needProtectFiles addObject:newFile];
                                                                   [self showMessageRepoFile:self.exsitArray.firstObject needProtectFileArray: self.needProtectFiles];
                                                                  
                                                               } inViewController:self position:self.view];
                                        
                                    }else{
                                        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MSG_KEEPBOTH_SELECT_MESSAGE", NULL), fileItem.name];
                                        [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message style:UIAlertControllerStyleAlert OKActionTitle:nil cancelActionTitle:NSLocalizedString(@"UI_BOX_SKIP", NULL) otherTitle:NSLocalizedString(@"UI_BOX_NO_REPLACE", NULL) OKActionHandle:^(UIAlertAction *action) {
  
                                                               } cancelActionHandle:^(UIAlertAction *action) {
                                                                   [self.needProtectFiles removeObject:file];
                                                                   [self showMessageRepoFile:self.exsitArray.firstObject needProtectFileArray:self.needProtectFiles];
                                                                  
                                                               } otherActionHandle:^(UIAlertAction *action) {
                                                                   NSArray *currentFolderFiles = [[NXLoginUser sharedInstance].myRepoSystem childForFileItem:self.saveFolder];
                                                                   NSMutableArray *currentFolderFilesNameArray = [[NSMutableArray alloc] init];
                                                                     for (NXFile *tmpfile in currentFolderFiles) {
                                                                                             if (tmpfile.name.length > 0) {
                                                                                                 [currentFolderFilesNameArray addObject:tmpfile.name];
                                                                                             }
                                                                                         }
                                                                                         NSUInteger index = 2;
                                                                                         NSUInteger MaxIndex = [NXCommonUtils getMaxIndexForFile:file.name fileNameArray:currentFolderFilesNameArray];
                                                                                         NSString *newFileName = file.name;
                                                                                         if (MaxIndex == 0) {
                                                                                             newFileName = [NXCommonUtils addIndexForFile:index fileName:newFileName];
                                                                                         }else{
                                                                                             MaxIndex += 1;
                                                                                             newFileName = [NXCommonUtils addIndexForFile:MaxIndex fileName:newFileName];
                                                                                         }
                                  
                                                                                         file.name = newFileName;
                                                                   NXFileBase *newFile = [file copy];
                                                                   newFile.name = newFileName;

                                                                   [self.needProtectFiles removeObject:file];
                                                                   [self.needProtectFiles addObject:newFile];
                                                                   [self showMessageRepoFile:self.exsitArray.firstObject needProtectFileArray:self.needProtectFiles];
                                                                  
                                                               } inViewController:self position:self.view];
                                        
                                    }
                                  
                                }
                            }
                            
            });
           
        }
        
    }else{
        if (!self.needProtectFiles.count) {
            [NXMBManager hideHUD];
            self.cancelItem.enabled = YES;
            self.protectButton.enabled = YES;
            [self dismissSelf];
            return;
        }
        [[NXLoginUser sharedInstance].nxlOptManager encryptAndUploadMultipleFilesToRepo:self.needProtectFiles toPath:self.saveFolder permissions:self.selectedRights membershipId:[NXLoginUser sharedInstance].profile.tenantMembership.ID withComplection:^(NSArray *successArray, NSArray *failArray, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [NXMBManager hideHUD];
                if (!error && failArray.count == 0) {
                    [self dismissSelf];
                }else{
                    NXProtectedResultVC *VC = [[NXProtectedResultVC alloc] init];
                    VC.failFileArray = failArray;
                    VC.allFilesArray = downloadArray;
                    VC.savePath = [self getSaveLocationPath:self.saveFolder];
                    VC.successFileArray = successArray;
                    [self.navigationController pushViewController:VC animated:YES];
                }
                
            });
                        
        }];
    }
    
}
- (NSMutableArray *)checkExistFilesFromWrokspace:(NSArray *)filesArray {
    NSArray *currentFolderFiles = [[NXLoginUser sharedInstance].workSpaceManager getWorkSpaceFileListUnderFolderInCoreData:(NXWorkSpaceFolder *)self.saveFolder];
    NSMutableArray *exsitFileArray = [NSMutableArray array];
    if (currentFolderFiles.count) {
        for (NXWorkSpaceFile *fileItem in currentFolderFiles) {
            for (NXFileBase *fileModel in filesArray) {
                if ([fileItem.name.stringByDeletingPathExtension isEqualToString:fileModel.name]) {
                    [exsitFileArray addObject:fileItem];
                }
            }
        }
    }
    return exsitFileArray;
}
-(NSMutableArray *)checkExistFilesFromMyVault:(NSArray *)fileArray {
    NSArray *currentFolderFiles = [[NXLoginUser sharedInstance].myVault getAllMyVaultFileInCoreData];
    NSMutableArray *existArray = [NSMutableArray array];
    if (currentFolderFiles.count) {
        for (NXMyVaultFile *fileItem in currentFolderFiles) {
            for (NXFileBase *fileModel in fileArray) {
                if ([fileItem.name.stringByDeletingPathExtension isEqualToString:fileModel.name]) {
                    [existArray addObject:fileItem];
                }
            }
        }
    }
    return existArray;
}
- (NSMutableArray *)checkExistFilesFromProject:(NSArray *)fileArray {
    NSArray *currentFolderFiles = [[NXLoginUser sharedInstance].myProject getFileListUnderParentFolderInCoreData:(NXProjectFolder *)self.saveFolder];
    NSMutableArray *existArray = [NSMutableArray array];
    if (currentFolderFiles.count) {
        for (NXMyVaultFile *fileItem in currentFolderFiles) {
            for (NXFileBase *fileModel in fileArray) {
                if ([fileItem.name.stringByDeletingPathExtension isEqualToString:fileModel.name]) {
                    [existArray addObject:fileItem];
                }
            }
        }
    }
    return existArray;
}
- (NSMutableArray *)checkExistFilesFromRepo:(NSArray *)fileArray {
    NSArray *currentFolderFiles = [[NXLoginUser sharedInstance].myRepoSystem childForFileItem:self.saveFolder];
    NSMutableArray *existArray = [NSMutableArray array];
    if (currentFolderFiles.count) {
        for (NXMyVaultFile *fileItem in currentFolderFiles) {
            for (NXFileBase *fileModel in fileArray) {
                if ([fileItem.name.stringByDeletingPathExtension isEqualToString:fileModel.name]) {
                    [existArray addObject:fileItem];
                }
            }
        }
    }
    return existArray;
}

- (void)protectMultipleFilesToMyVault:(NSArray *)fileArray {
    if (!self.selectedRights.getVaildateDateModel) {
        [self.selectedRights setFileValidateDate:[NXLoginUser sharedInstance].userPreferenceManager.userPreference.preferenceFileValidateDate];
       }
    
    if (![NXCommonUtils checkIsLegalFileValidityDate:[self.selectedRights getVaildateDateModel]]) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_FILE_EXPIRETIME_INVALID", NULL) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
        self.protectButton.enabled = YES;
        self.cancelItem.enabled = YES;
        return;
    }
    [NXMBManager showLoading];
    self.exsitArray = [self checkExistFilesFromMyVault:fileArray];
    if (self.exsitArray.count) {
        NSMutableArray *successArray = [NSMutableArray array];
        NSMutableArray *failArray = [NSMutableArray array];
        [[NXWebFileManager sharedInstance] downloadMultipleFiles:fileArray completed:^(NSArray *downloadFileArray, NSError *error) {
            if (error) {
                for (NXFileBase *fileItem in fileArray) {
                    fileItem.name = [NSString stringWithFormat:@"%@%@",fileItem.name,@".nxl"];
                    fileItem.localPath = error.localizedDescription;
                    [failArray addObject:fileItem];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NXMBManager hideHUD];
                    NXProtectedResultVC *VC = [[NXProtectedResultVC alloc] init];
                    VC.failFileArray = failArray;
                    VC.allFilesArray = fileArray;
                    VC.savePath = [self getSaveLocationPath:self.saveFolder];
                    VC.successFileArray = successArray;
                    [self.navigationController pushViewController:VC animated:YES];
                    
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NXMyVaultFile *fileItem =  self.exsitArray.firstObject;
                    [self showMessageAboutMyVaultFile:fileItem needProtectFileArray:downloadFileArray];
                   

                });
            }
           
        }];
        
    }else{
        [[NXLoginUser sharedInstance].nxlOptManager protectAndUploadMultipleFilesToMyVault:fileArray permissions:self.selectedRights membershipId:nil withCompletion:^(NSArray *successArray, NSArray *failArray, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [NXMBManager hideHUD];
                if (failArray.count == 0) {
                    [self dismissSelf];
                }else{
                    NXProtectedResultVC *VC = [[NXProtectedResultVC alloc] init];
                    VC.failFileArray = failArray;
                    VC.allFilesArray = fileArray;
                    VC.savePath = [self getSaveLocationPath:self.saveFolder];
                    VC.successFileArray = successArray;
                    [self.navigationController pushViewController:VC animated:YES];
                }
                
            });
           
                
        }];
    }
    
}
- (void)protectMultipleFileToProject:(NSArray *)fileArray{
    if (!self.targetProject.membershipId) {
        return;
    }
    if (self.saveFolder == nil) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_SELECT_FOLDER", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
        self.protectButton.enabled = YES;
        self.cancelItem.enabled = YES;
        return;
    }
    
    if (!self.selectedRights.getVaildateDateModel) {
        if (!self.targetProject.validateModel) {
            [NXMBManager showLoading];
            [[NXLoginUser sharedInstance].myProject project:self.targetProject MetadataWithCompletion:^(NXProjectModel *projectModel, NSError *error) {
                if (!error) {
                    self.targetProject.validateModel = projectModel.validateModel;
                }
                [self.selectedRights setFileValidateDate:self.targetProject.validateModel];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (![NXCommonUtils checkIsLegalFileValidityDate:[self.selectedRights getVaildateDateModel]]) {
                        [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_FILE_EXPIRETIME_INVALID", NULL) hideAnimated:YES afterDelay:kDelay];
                        self.protectButton.enabled = YES;
                        self.cancelItem.enabled = YES;
                        [NXMBManager hideHUD];
                        return;
                    }
                   
                    self.exsitArray = [self checkExistFilesFromProject:fileArray];
                    if (self.exsitArray.count) {
                        NSMutableArray *successArray = [NSMutableArray array];
                        NSMutableArray *failArray = [NSMutableArray array];
                        [[NXWebFileManager sharedInstance] downloadMultipleFiles:fileArray completed:^(NSArray *downloadFileArray, NSError *error) {
                            if (error) {
                                for (NXFileBase *fileItem in fileArray) {
                                    fileItem.name = [NSString stringWithFormat:@"%@%@",fileItem.name,@".nxl"];
                                    fileItem.localPath = error.localizedDescription;
                                    [failArray addObject:fileItem];
                                }
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [NXMBManager hideHUD];
                                    NXProtectedResultVC *VC = [[NXProtectedResultVC alloc] init];
                                    VC.failFileArray = failArray;
                                    VC.allFilesArray = fileArray;
                                    VC.successFileArray = successArray;
                                    VC.savePath = [self getSaveLocationPath:self.saveFolder];
                                   
                                    [self.navigationController pushViewController:VC animated:YES];
                                    
                                });
                            }else{
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NXProjectFile *fileItem =  self.exsitArray.firstObject;
                                    [self showMessageAboutProjectFile:fileItem needProtectFileArray:downloadFileArray];
                                   

                                });
                            }
                           
                        }];
                        
                    }else{
                        [[NXLoginUser sharedInstance].nxlOptManager protectMultipleFilesToProject:fileArray permissions:self.selectedRights membershipId:self.targetProject.membershipId inProject:self.targetProject.projectId intoFolder:(NXProjectFolder *)self.saveFolder andIsOverwrite:NO withCompletion:^(NSArray *successArray, NSArray *failArray, NSError *error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [NXMBManager hideHUD];
                                if (failArray.count == 0) {
                                    [self dismissSelf];
                                }else{
                                    NXProtectedResultVC *VC = [[NXProtectedResultVC alloc] init];
                                    VC.failFileArray = failArray;
                                    VC.allFilesArray = fileArray;
                                    VC.successFileArray = successArray;
                                    VC.savePath = [self getSaveLocationPath:self.saveFolder];
                                    [self.navigationController pushViewController:VC animated:YES];
                                }
                            });
                        }];
                        
                    }
                    
                });
            }];
            return;
        }else{
            [self.selectedRights setFileValidateDate:self.targetProject.validateModel];
        }
        
    }
    
    if (![NXCommonUtils checkIsLegalFileValidityDate:[self.selectedRights getVaildateDateModel]]) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_FILE_EXPIRETIME_INVALID", NULL) hideAnimated:YES afterDelay:kDelay];
        self.protectButton.enabled = YES;
        self.cancelItem.enabled = YES;
        return;
    }
    [NXMBManager showLoading];
    self.exsitArray = [self checkExistFilesFromProject:fileArray];
    if (self.exsitArray.count) {
        NSMutableArray *successArray = [NSMutableArray array];
        NSMutableArray *failArray = [NSMutableArray array];
        [[NXWebFileManager sharedInstance] downloadMultipleFiles:fileArray completed:^(NSArray *downloadFileArray, NSError *error) {
            if (error) {
                for (NXFileBase *fileItem in fileArray) {
                    fileItem.name = [NSString stringWithFormat:@"%@%@",fileItem.name,@".nxl"];
                    fileItem.localPath = error.localizedDescription;
                    [failArray addObject:fileItem];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NXMBManager hideHUD];
                    NXProtectedResultVC *VC = [[NXProtectedResultVC alloc] init];
                    VC.failFileArray = failArray;
                    VC.allFilesArray = fileArray;
                    VC.successFileArray = successArray;
                    VC.savePath = [self getSaveLocationPath:self.saveFolder];
                   
                    [self.navigationController pushViewController:VC animated:YES];
                    
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NXProjectFile *fileItem =  self.exsitArray.firstObject;
                    [self showMessageAboutProjectFile:fileItem needProtectFileArray:downloadFileArray];
                   

                });
            }
           
        }];
        
    }else{
        [[NXLoginUser sharedInstance].nxlOptManager protectMultipleFilesToProject:fileArray permissions:self.selectedRights membershipId:self.targetProject.membershipId inProject:self.targetProject.projectId intoFolder:(NXProjectFolder *)self.saveFolder andIsOverwrite:NO withCompletion:^(NSArray *successArray, NSArray *failArray, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [NXMBManager hideHUD];
                if (failArray.count == 0) {
                    [self dismissSelf];
                }else{
                    NXProtectedResultVC *VC = [[NXProtectedResultVC alloc] init];
                    VC.failFileArray = failArray;
                    VC.allFilesArray = fileArray;
                    VC.successFileArray = successArray;
                    VC.savePath = [self getSaveLocationPath:self.saveFolder];
                    [self.navigationController pushViewController:VC animated:YES];
                }
            });
        }];
        
    }
    
}

- (void)changeSaveLocationion {
    NXProtectFileSelectLocationVC *VC = [[NXProtectFileSelectLocationVC alloc] init];
    VC.selectFilesArray = self.filesArray;
    VC.targetFolder = self.saveFolder;
    VC.selectType = NXSelectProtectMenuTypeSkyDRM;
    [self.navigationController pushViewController:VC animated:YES];
   
//    if (self.locationType == NXProtectSaveLoactionTypeFileRepo || self.locationType == NXProjectSaveLocationTypeSharedWorkSpace) {
//        NXProtectFileSelectLocationVC *VC = [[NXProtectFileSelectLocationVC alloc] init];
//        VC.fileItem = self.fileItem;
//        VC.targetFolder = self.saveFolder;
//        VC.selectType = NXSelectProtectMenuTypeRepo;
//        [self.navigationController pushViewController:VC animated:YES];
//    }else if(self.locationType == NXProtectSaveLoactionTypeProject){
//        NXFileChooseFlowViewController *chooseVC = [[NXFileChooseFlowViewController alloc] initWithProject:self.targetProject type:NXFileChooseFlowViewControllerTypeChooseDestFolder];
//        chooseVC.fileChooseVCDelegate = self;
//        chooseVC.modalPresentationStyle = UIModalPresentationFullScreen;
//        [self.navigationController presentViewController:chooseVC animated:YES completion:nil];
//    }else if (self.locationType == NXProtectSaveLoactionTypeWorkSpace){
//        NXFileChooseFlowViewController *chooseVC = [[NXFileChooseFlowViewController alloc] initWithWorkSpaceType:NXFileChooseFlowViewControllerTypeChooseDestFolder];
//        chooseVC.fileChooseVCDelegate = self;
//        chooseVC.modalPresentationStyle = UIModalPresentationFullScreen;
//        [self.navigationController presentViewController:chooseVC animated:YES completion:nil];
//    }else if (self.locationType == NXProtectSaveLoactionTypeLocalFiles || self.locationType == NXProtectSaveLoactionTypeMyVault){
//        NXProtectFileSelectLocationVC *VC = [[NXProtectFileSelectLocationVC alloc] init];
//        VC.fileItem = self.fileItem;
//        VC.targetFolder = self.saveFolder;
//        VC.selectType = NXSelectProtectMenuTypeSkyDRM;
//        [self.navigationController pushViewController:VC animated:YES];                                                       
//    }
    
}
- (void)uploadFilesToLocalFiles:(NSArray *)filesArray wilthFailFiles:(NSArray *)failArray{
    [[NXOriginalFilesTransfer sharedIInstance] exportMultipleFiles:filesArray toOriginalFilesFromVC:self];
        
    [NXOriginalFilesTransfer sharedIInstance].exprotMultipleFilesCompletion = ^(UIViewController *currentVC, NSArray *fileUrls, NSError *error) {
        [NXMBManager hideHUD];
        if ([currentVC isMemberOfClass:[self class]]) {
            if (!error && failArray.count == 0) {
                [self dismissSelf];
            }else{
                NXProtectedResultVC *VC = [[NXProtectedResultVC alloc] init];
                VC.failFileArray = failArray;
                VC.allFilesArray = filesArray;
                VC.savePath = [self getSaveLocationPath:self.saveFolder];
                VC.successFileArray = @[];
                [self.navigationController pushViewController:VC animated:YES];
            }
        }
    };
       
}

- (void)protectFilesToLocalFiles:(NSArray *)filesArray {
    if (!self.selectedRights.getVaildateDateModel) {
        [self.selectedRights setFileValidateDate:[NXLoginUser sharedInstance].userPreferenceManager.userPreference.preferenceFileValidateDate];
       }
    
    if (![NXCommonUtils checkIsLegalFileValidityDate:[self.selectedRights getVaildateDateModel]]) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_FILE_EXPIRETIME_INVALID", NULL) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
        self.protectButton.enabled = YES;
        self.cancelItem.enabled = YES;
        return;
    }
    [NXMBManager showLoading];
    [[NXLoginUser sharedInstance].nxlOptManager downloadAndEncryptMultipleFile:filesArray permissions:self.selectedRights membershipId:[NXLoginUser sharedInstance].profile.tenantMembership.ID  withComplection:^(NSArray *successArray, NSArray *failArray, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NXMBManager hideHUD];
            self.protectButton.enabled = YES;
            self.cancelItem.enabled = YES;
            [self uploadFilesToLocalFiles:successArray wilthFailFiles:failArray];
        });
    }];

}
- (void)protectFileToRepoOrLocalFiles:(NXFileBase *)fileBase andIsOverwrite:(BOOL)isOverwrite{
    NSString *tmpPath = [NXCommonUtils createNewNxlTempFile:self.fileItem.name];
    [NXMBManager showLoading:NSLocalizedString(@"MSG_COM_PROTECT_AND_UPLOADING", NULL) toView:self.view];
    NSDate *currentServerDate = [[NXTimeServerManager sharedInstance] currentServerTime];
    if (self.protectType == NXSelectProtectTypeClassification) {
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
                                      
                   if (self.locationType == NXProtectSaveLoactionTypeLocalFiles) {
                       [self uploadToLocalFilesWithFile:file];
                                          
                   }else if (self.locationType == NXProtectSaveLoactionTypeFileRepo || self.locationType == NXProjectSaveLocationTypeSharedWorkSpace){
                      
                       [self uploadToRepoWithFile:file toFolder:self.saveFolder isOverwrite:isOverwrite];
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
    }else if(self.protectType == NXSelectProtectTypeDigital){
           
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
                   
                  if (self.locationType == NXProtectSaveLoactionTypeLocalFiles) {
                       [self uploadToLocalFilesWithFile:file];
                                          
                   }else if (self.locationType == NXProtectSaveLoactionTypeFileRepo || self.locationType == NXProjectSaveLocationTypeSharedWorkSpace){
                      
                       [self uploadToRepoWithFile:file toFolder:self.saveFolder isOverwrite:isOverwrite];
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

- (void)checkforRepoExistDuplicatefile:(NXFileBase *)file {

    if (self.currentRepoFolderFiles.count > 0) {
          for (NXFile *tmpfile in self.currentRepoFolderFiles) {
              if ([[tmpfile.name stringByDeletingPathExtension] isEqualToString:file.name]) {
                  WeakObj(self);
                  
                  dispatch_main_sync_safe((^{
                      if (self.saveFolder.serviceType.integerValue == kServiceGoogleDrive || self.saveFolder.serviceType.integerValue == kServiceBOX ) {
                          NSString *message = [NSString stringWithFormat:NSLocalizedString(@"ALERTVIEW_MESSAGE_OVERWRITE_ONLY_RENAME", NULL), tmpfile.name];
                          [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_RENAME", NULL) cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) OKActionHandle:^(UIAlertAction *action) {
                              //no replace
                              NSMutableArray *currentFolderFilesNameArray = [[NSMutableArray alloc] init];
                              for (NXFileBase *tmpfile in self.currentRepoFolderFiles) {
                                  if (tmpfile.name.length > 0) {
                                      [currentFolderFilesNameArray addObject:tmpfile.name];
                                  }
                              }
                              
                              NSString *fileName = file.localPath.lastPathComponent;
                              NSUInteger index = 2;
                              NSUInteger MaxIndex = [NXCommonUtils getMaxIndexForFile:fileName fileNameArray:currentFolderFilesNameArray];
                              NSString *newFileName = fileName;
                              if (MaxIndex == 0) {
                                  newFileName = [NXCommonUtils addIndexForFile:index fileName:newFileName];
                              }else{
                                  MaxIndex += 1;
                                  newFileName = [NXCommonUtils addIndexForFile:MaxIndex fileName:newFileName];
                              }
                              self.currentFileOriginalName = self.fileItem.name;
                              file.name = newFileName;
                              [self protectFileToRepoOrLocalFiles:file andIsOverwrite:NO];
                          } cancelActionHandle:^(UIAlertAction *action) {
                              self.protectButton.enabled = YES;
                              [NXMBManager hideHUDForView:self.view];
                          } inViewController:self position:self.view];
                          return;
                      }
                  }));
                  
                  dispatch_main_sync_safe((^{
                      NSString *message = [NSString stringWithFormat:NSLocalizedString(@"ALERTVIEW_MESSAGE_OVERWRITE", NULL), tmpfile.name];
                      [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_REPLACE", NULL) cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherTitle:NSLocalizedString(@"UI_BOX_NO_REPLACE", NULL) OKActionHandle:^(UIAlertAction *action) {
                          StrongObj(self);
                          
                          [self protectFileToRepoOrLocalFiles:file andIsOverwrite:YES];
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
                          
                          NSString *fileName = file.localPath.lastPathComponent;
                          NSUInteger index = 2;
                          NSUInteger MaxIndex = [NXCommonUtils getMaxIndexForFile:fileName fileNameArray:currentFolderFilesNameArray];
                          NSString *newFileName = fileName;
                          switch (MaxIndex) {
                              case 0:
                              newFileName = [NXCommonUtils addIndexForFile:index fileName:newFileName];
                                  break;
                              default:
                              MaxIndex += 1;
                              newFileName = [NXCommonUtils addIndexForFile:MaxIndex fileName:newFileName];
                                  break;
                          }
                          self.currentFileOriginalName = self.fileItem.name;
                          file.name = newFileName;
                          
                          [self protectFileToRepoOrLocalFiles:file andIsOverwrite:NO];
                      } inViewController:self position:self.view];
                      
                      return;
                  }));
                  return;
              }
          }
    }
    [self protectFileToRepoOrLocalFiles:file andIsOverwrite:NO];
}
- (void)uploadToLocalFilesWithFile:(NXFileBase *)file {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NXMBManager hideHUDForView:self.view];
        [[NXOriginalFilesTransfer sharedIInstance] exportFile:file toOriginalFilesFromVC:self];
        [NXOriginalFilesTransfer sharedIInstance].exprotFileCompletion = ^(UIViewController *currentVC,NSURL *fileUrl, NSError *error) {
        [NXMBManager hideHUDForView:self.view];
            if ([currentVC isMemberOfClass:[self class]]) {
                if (!error && fileUrl) {
                    [self dismissSelf];
                    [NXMessageViewManager showMessageViewWithTitle:file.name details:NSLocalizedString(@"MSG_COM_SUCCESS_PROTECT", NULL) appendInfo:nil appendInfo2:NSLocalizedString(@"MSG_COM_FILES_HAS_BEEN_SAVED_TO_FILES", NULL) image:[UIImage imageNamed:@"Success - White tick"] dismissAfter:kDelay*2 type:NXMessageViewManagerTypeGreen];
                          
                }else{
                    [NXMBManager showMessage:error.localizedDescription?:@"Failed to save to Files" toView:self.mainView hideAnimated:YES afterDelay:kDelay];
                        self.protectButton.enabled = YES;
                        if (self.currentFileOriginalName) {
                            self.fileItem.name = self.currentFileOriginalName;
                        }
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
- (void)uploadFileToworkSpaceAndIsOverwrite:(BOOL)isOverwrite{
    if (self.protectType == NXSelectProtectTypeClassification) {
        if (self.classificationView.isMandatoryEmpty) {
            [NXMBManager showMessage:NSLocalizedString(@"MSG_MANDATORY_NOT_EMPTY", NULL) toView:self.view hideAnimated:YES afterDelay:1.5 * kDelay];
            self.protectButton.enabled = YES;
            self.cancelItem.enabled = YES;
            return;
        }
        [NXMBManager showLoadingToView:self.view];
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
        self.uploadOperationIdentifier = [[NXLoginUser sharedInstance].nxlOptManager protectFileToWorkSpace:self.fileItem toPath:[NXCommonUtils createNewNxlTempFile:self.fileItem.name] membershipId:[NXLoginUser sharedInstance].profile.tenantMembership.ID permissions:nil classifications:classificaitonDict intoFolder:(NXFolder *)self.saveFolder createDate:[NXTimeServerManager sharedInstance].currentServerTime andIsOverwrite:isOverwrite  withCompletion:^(NXFolder *folder, NXFileBase *newFile, NSError *error) {
                WeakObj(self);
                dispatch_main_async_safe(^{
                    [NXMBManager hideHUDForView:self.view];
                    if (error) {
                        [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_PROTECT_FILE_FAILED", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
                        self.protectButton.enabled = YES;
                        self.cancelItem.enabled = YES;
                        if (self.currentFileOriginalName) {
                            self.fileItem.name = self.currentFileOriginalName;
                        }
                    }else{
                        StrongObj(self);
                        [self dismissSelf];
                        [NXMessageViewManager showMessageViewWithTitle:self.fileItem.name details:NSLocalizedString(@"MSG_COM_SUCCESS_PROTECT", NULL) appendInfo:nil appendInfo2:NSLocalizedString(@"MSG_COM_FILE_HAS_BEEN_SAVED_TO_WORKSAPCE", NULL) image:[UIImage imageNamed:@"Success - White tick"] dismissAfter:kDelay*2 type:NXMessageViewManagerTypeGreen];
                    }
                 
                });
        }];
        return;
    }else if(self.protectType == NXSelectProtectTypeDigital){
           
           
        if (!self.selectedRights.getVaildateDateModel) {
           [self.selectedRights setFileValidateDate:[NXLoginUser sharedInstance].userPreferenceManager.userPreference.preferenceFileValidateDate];
           }
         
           
        if (![NXCommonUtils checkIsLegalFileValidityDate:[self.selectedRights getVaildateDateModel]]) {
            [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_FILE_EXPIRETIME_INVALID", NULL) hideAnimated:YES afterDelay:kDelay];
            self.protectButton.enabled = YES;
            self.cancelItem.enabled = YES;
            return;
        }
        [NXMBManager showLoadingToView:self.view];
        self.uploadOperationIdentifier = [[NXLoginUser sharedInstance].nxlOptManager protectFileToWorkSpace:self.fileItem toPath:[NXCommonUtils createNewNxlTempFile:self.fileItem.name] membershipId:[NXLoginUser sharedInstance].profile.tenantMembership.ID permissions:self.selectedRights classifications:nil intoFolder:(NXFolder *)self.saveFolder createDate:[NXTimeServerManager sharedInstance].currentServerTime andIsOverwrite:isOverwrite withCompletion:^(NXFolder *folder, NXFileBase *newFile, NSError *error) {
                WeakObj(self);
                dispatch_main_async_safe(^{
                    [NXMBManager hideHUDForView:self.view];
                    if (error) {
                        [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_UPLOAD_FILE_FAILED", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
                        self.protectButton.enabled = YES;
                        self.cancelItem.enabled = YES;
                    }else{
                        StrongObj(self);
                        [self dismissSelf];
                        [NXMessageViewManager showMessageViewWithTitle:self.fileItem.name details:NSLocalizedString(@"MSG_COM_SUCCESS_PROTECT", NULL) appendInfo:nil appendInfo2:NSLocalizedString(@"MSG_COM_FILE_HAS_BEEN_SAVED_TO_WORKSAPCE", NULL) image:[UIImage imageNamed:@"Success - White tick"] dismissAfter:kDelay*2 type:NXMessageViewManagerTypeGreen];
                    }
                   
                });
            }];
           return;
       }else {
           NSAssert(NO, @"Proect type is not correctly");
       }
}
- (void)uploadNXLFileToProjectAndIsOverwriteFile:(BOOL)isOverwrite{
    if (self.protectType == NXSelectProtectTypeClassification) {
            if (self.classificationView.isMandatoryEmpty) {
                [NXMBManager showMessage:NSLocalizedString(@"MSG_MANDATORY_NOT_EMPTY", NULL) toView:self.view hideAnimated:YES afterDelay:1.5 * kDelay];
                self.protectButton.enabled = YES;
                return;
            }
            // if no tag can not protect
    //        if (self.classificationView.isNotSelected) {
    //            [NXMBManager showMessage:NSLocalizedString(@"MSG_CLASSIFICATION_NOT_SELECTED", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
    //            self.protectButton.enabled = YES;
    //            return;
    //        }
            [NXMBManager showLoadingToView:self.view];
        self.uploadOperationIdentifier = [[NXLoginUser sharedInstance].nxlOptManager protectToNXLFile:self.fileItem toPath:[NXCommonUtils createNewNxlTempFile:self.fileItem.name] classifications:self.classificationView.classificationCategoryArray membershipId:self.targetProject.membershipId inProject:self.targetProject.projectId intoFolder:(NXProjectFolder *)self.saveFolder createDate:[NXTimeServerManager sharedInstance].currentServerTime andIsOverwrite:isOverwrite withCompletion:^(NXProjectFolder *projectFolder, NXProjectFile *newProjectFile, NSError *error) {
                WeakObj(self);
                dispatch_main_async_safe((^{
                    [NXMBManager hideHUDForView:self.view];
                    if (error) {
                        [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_UPLOAD_FILE_FAILED", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
                        self.protectButton.enabled = YES;
                        if (self.currentFileOriginalName) {
                            self.fileItem.name = self.currentFileOriginalName;
                        }
                    }else{
                        StrongObj(self);
                        [self dismissSelf];
                        [NXMessageViewManager showMessageViewWithTitle:self.fileItem.name details:NSLocalizedString(@"MSG_COM_SUCCESS_PROTECT", NULL) appendInfo:nil appendInfo2:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"MSG_COM_FILE_HAS_BEEN_SAVED_TO_PROJECT", NULL),self.targetProject.name] image:[UIImage imageNamed:@"Success - White tick"] dismissAfter:kDelay*2 type:NXMessageViewManagerTypeGreen];
                    }
                    
                }));
            }];
            return;
    }else if(self.protectType == NXSelectProtectTypeDigital){
            
            if (!self.selectedRights.getVaildateDateModel) {
                [self.selectedRights setFileValidateDate:self.targetProject.validateModel];
            }
            
            if (![NXCommonUtils checkIsLegalFileValidityDate:[self.selectedRights getVaildateDateModel]]) {
                [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_FILE_EXPIRETIME_INVALID", NULL) hideAnimated:YES afterDelay:kDelay];
                self.protectButton.enabled = YES;
                return;
            }
            
            [NXMBManager showLoadingToView:self.view];
            self.uploadOperationIdentifier  = [[NXLoginUser sharedInstance].nxlOptManager protectToNXLFile:self.fileItem toPath:[NXCommonUtils createNewNxlTempFile:self.fileItem.name] permissions:self.selectedRights membershipId:self.targetProject.membershipId inProject:self.targetProject.projectId intoFolder:(NXProjectFolder *)self.saveFolder createDate:[NXTimeServerManager sharedInstance].currentServerTime andIsOverwrite:isOverwrite withCompletion:^(NXProjectFolder *parentFolder, NXProjectFile *newProjectFile, NSError *error) {
                    WeakObj(self);
                    dispatch_main_async_safe((^{
                        [NXMBManager hideHUDForView:self.view];
                        if (error) {
                            [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_UPLOAD_FILE_FAILED", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
                            self.protectButton.enabled = YES;
                            if (self.currentFileOriginalName) {
                                self.fileItem.name = self.currentFileOriginalName;
                            }
                        }else{
                            StrongObj(self);
                            [self dismissSelf];
                            [NXMessageViewManager showMessageViewWithTitle:self.fileItem.name details:NSLocalizedString(@"MSG_COM_SUCCESS_PROTECT", NULL) appendInfo:nil appendInfo2:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"MSG_COM_FILE_HAS_BEEN_SAVED_TO_PROJECT", NULL),self.targetProject.name] image:[UIImage imageNamed:@"Success - White tick"] dismissAfter:kDelay*2 type:NXMessageViewManagerTypeGreen];
                        }
                        
                    }));
            }];
            return;
        }else {
            NSAssert(NO, @"Proect type is not correctly");
        }
}

- (void)uploadFileToMyVault{
    WeakObj(self);
    
    NXFile *fakeFile = [self.fileItem copy];
    fakeFile.fullServicePath = [NSString stringWithFormat:@"/%@",self.fileItem.name];
    fakeFile.fullPath = [NSString stringWithFormat:@"/%@",self.fileItem.name];
    self.uploadOperationIdentifier = [[NXLoginUser sharedInstance].nxlOptManager protectToNXLFile:fakeFile toPath:[NXCommonUtils createNewNxlTempFile:self.fileItem.name] permissions:self.selectedRights membershipId:nil createDate:[NXTimeServerManager sharedInstance].currentServerTime withCompletion:^(NSString *filePath, NSError *error) {
          dispatch_main_async_safe(^{
              StrongObj(self);
              [NXMBManager hideHUDForView:self.view];
              if (error) {
                  [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_ENCRYPT_FILE_FAILED", NULL) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
                  self.protectButton.enabled = YES;
                  if (self.currentFileOriginalName) {
                    self.fileItem.name = self.currentFileOriginalName;
                  }
              } else{
                    [self dismissSelf];
                    [NXMessageViewManager showMessageViewWithTitle:self.fileItem.name details:NSLocalizedString(@"MSG_COM_SUCCESS_PROTECT", NULL) appendInfo:nil appendInfo2:NSLocalizedString(@"MSG_COM_FILE_HAS_BEEN_SAVED_TO_MYVAULT", NULL) image:[UIImage imageNamed:@"Success - White tick"] dismissAfter:kDelay*2 type:NXMessageViewManagerTypeGreen];
              }
          });
      }];
}
- (void)uploadMultipleFilesToRepo:(NSArray *)fileArray toFolder:(NXFileBase *)targetFolder {
    
    if (targetFolder == nil) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_SELECT_FOLDER", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
        self.protectButton.enabled = YES;
        self.cancelItem.enabled = YES;
        return;
    }
    if (!self.selectedRights.getVaildateDateModel) {
        [self.selectedRights setFileValidateDate:[NXLoginUser sharedInstance].userPreferenceManager.userPreference.preferenceFileValidateDate];
       }
    
    if (![NXCommonUtils checkIsLegalFileValidityDate:[self.selectedRights getVaildateDateModel]]) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_FILE_EXPIRETIME_INVALID", NULL) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
        self.protectButton.enabled = YES;
        self.cancelItem.enabled = YES;
        return;
    }
    [NXMBManager showLoading];
    self.exsitArray = [self checkExistFilesFromRepo:fileArray];
    if (self.exsitArray.count) {
        NSMutableArray *successArray = [NSMutableArray array];
        NSMutableArray *failArray = [NSMutableArray array];
        [[NXWebFileManager sharedInstance] downloadMultipleFiles:fileArray completed:^(NSArray *downloadFileArray, NSError *error) {
            if (error) {
                for (NXFileBase *fileItem in fileArray) {
                    fileItem.name = [NSString stringWithFormat:@"%@%@",fileItem.name,@".nxl"];
                    fileItem.localPath = error.localizedDescription;
                    [failArray addObject:fileItem];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NXMBManager hideHUD];
                    NXProtectedResultVC *VC = [[NXProtectedResultVC alloc] init];
                    VC.failFileArray = failArray;
                    VC.allFilesArray = fileArray;
                    VC.savePath = [self getSaveLocationPath:self.saveFolder];
                    VC.successFileArray = successArray;
                    [self.navigationController pushViewController:VC animated:YES];
                    
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NXFileBase *fileItem = self.exsitArray.firstObject;
                    [self showMessageRepoFile:fileItem needProtectFileArray:downloadFileArray];
                   
                });
            }
           
        }];
        
    }else{
        [[NXLoginUser sharedInstance].nxlOptManager downloadAndEncryptMultipleFile:fileArray permissions:self.selectedRights membershipId:[NXLoginUser sharedInstance].profile.tenantMembership.ID withComplection:^(NSArray *successArray, NSArray *failArray, NSError *error) {
            if (failArray.count && failArray.count == fileArray.count) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NXMBManager hideHUD];
                    NXProtectedResultVC *VC = [[NXProtectedResultVC alloc] init];
                    VC.failFileArray = failArray;
                    VC.allFilesArray = fileArray;
                    VC.savePath = [self getSaveLocationPath:self.saveFolder];
                    VC.successFileArray = successArray;
                    [self.navigationController pushViewController:VC animated:YES];
                });
                return;
            }
            NSMutableArray *failuploadArray = [NSMutableArray arrayWithArray:failArray];
            NSMutableArray *successUploadArray = [NSMutableArray array];
            for (NXFileBase *file in successArray) {
                NXRepositorySysManagerUploadType uploadType = NXRepositorySysManagerUploadTypeNormal;
                [[NXLoginUser sharedInstance].myRepoSystem uploadFile:file.name toPath:targetFolder fromPath:file.localPath uploadType:uploadType overWriteFile:nil progress:nil completion:^(NXFileBase *fileItem, NXFileBase *parentFolder, NSError *error1) {
                    if (!error1) {
                        [successUploadArray addObject:fileItem];
                    }else{
                        file.localPath = error1.localizedDescription;
                        [failuploadArray addObject:file];
                    }
                    if (successUploadArray.count + failuploadArray.count == fileArray.count) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [NXMBManager hideHUD];
                            if (failuploadArray.count == 0) {
                                [self dismissSelf];
                            }else{
                                NXProtectedResultVC *VC = [[NXProtectedResultVC alloc] init];
                                VC.failFileArray = failuploadArray;
                                VC.allFilesArray = fileArray;
                                VC.savePath = [self getSaveLocationPath:self.saveFolder];
                                VC.successFileArray = successUploadArray;
                                [self.navigationController pushViewController:VC animated:YES];
                            }

                        });
                        
                    }
                   
                }];
                
            }
        }];
        
    }
   
}
- (void)uploadToRepoWithFile:(NXFileBase *)file toFolder:(NXFileBase *)targetFolder isOverwrite:(BOOL)isOverwrite
{
       WeakObj(self);
    NXRepositorySysManagerUploadType uploadType = NXRepositorySysManagerUploadTypeNormal;
    if (isOverwrite) {
        uploadType = NXRepositorySysManagerUploadTypeOverWrite;
    }
    self.uploadOperationIdentifier = [[NXLoginUser sharedInstance].myRepoSystem uploadFile:file.name toPath:targetFolder fromPath:file.localPath uploadType:uploadType overWriteFile:nil progress:nil completion:^(NXFileBase *fileItem, NXFileBase *parentFolder, NSError *error) {
          StrongObj(self);
               dispatch_main_async_safe(^{
                   [NXMBManager hideHUDForView:self.view];
                   if (!error) {
                       [self dismissSelf];
                       [NXMessageViewManager showMessageViewWithTitle:file.name details:NSLocalizedString(@"MSG_COM_SUCCESS_PROTECT", NULL) appendInfo:nil appendInfo2:NSLocalizedString(@"MSG_COM_FILE_HAS_BEEN_SAVED_TO_REPO", NULL) image:[UIImage imageNamed:@"Success - White tick"] dismissAfter:kDelay*2 type:NXMessageViewManagerTypeGreen];
                   }else{
                       [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_UPLOAD_FILE_FAILED", NULL) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
                       self.protectButton.enabled = YES;
                       if (self.currentFileOriginalName) {
                           self.fileItem.name = self.currentFileOriginalName;
                       }
                   }
              });
          }];
}

- (void)next:(id)sender{
    if (![[NXNetworkHelper sharedInstance] isNetworkAvailable]) {
        [NXMBManager showMessage:@"The internet connection appears to be offline" toView:self.view hideAnimated:YES afterDelay:kDelay];
        return;
    }
    if (!self.classificationView.classificationCategoryArray) {
        [self initFileData];
    }
    if (self.classificationView.isMandatoryEmpty) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_MANDATORY_NOT_EMPTY", NULL) toView:self.view hideAnimated:YES afterDelay:1.5 * kDelay];
        self.protectButton.enabled = YES;
        return;
    }
    
    NXProtectFileSelectedPolicyVC *VC = [[NXProtectFileSelectedPolicyVC alloc] init];
    VC.selectedFileArray = self.filesArray;
    VC.selectedClassifiations = self.classificationView.classificationCategoryArray;
    VC.targetProject = self.targetProject;
    VC.locationType = self.locationType;
    VC.saveFolder = (NXFolder *)self.saveFolder;
    VC.savePath = [self getSaveLocationPath:self.fileItem];
    [self.navigationController pushViewController:VC animated:YES];
    
}
- (BOOL)isHaveOverwritePerssion:(NXFileBase *)file {
//  __block  BOOL isCanOverwrite = NO;
    if (self.saveFolder.serviceType && (self.saveFolder.serviceType == [NSNumber numberWithInteger:kServiceBOX] || self.saveFolder.serviceType == [NSNumber numberWithInteger:kServiceGoogleDrive])) {
        return  NO;
    }
    return YES;
//    if ([[NXLoginUser sharedInstance] isTenantAdmin]) {
//        isCanOverwrite = YES;
//    }else{
//        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//        [[NXLoginUser sharedInstance].nxlOptManager getNXLFileRights:file withWatermark:NO withCompletion:^(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray<NXWatermarkWord *> *waterMarkWords, NSString *owner, BOOL isOwner, NSError *error) {
//            if (!error) {
//                if ([rights EditRight]) {
//                    isCanOverwrite = YES;
//                }else{
//                    isCanOverwrite = NO;
//                }
//            }else{
//                isCanOverwrite = NO;
//            }
//            dispatch_semaphore_signal(semaphore);
//        }];
//        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//    }
//
//    return isCanOverwrite;
}
- (void)dismissSelf {

    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
#pragma mark ------> fileChooseDelegate
- (void)fileChooseFlowViewController:(NXFileChooseFlowViewController *)vc didChooseFile:(NSArray *)choosedFiles {
    if (choosedFiles.count) {
        self.saveFolder = choosedFiles.lastObject;
        if (self.filesArray.count>1) {
            [self.locationInfoView setHintMessage:NSLocalizedString(@"UI_FILES_WILL_BE_SAVED_TO1", NULL) andSavePath:[self getSaveLocationPath:self.saveFolder]];
        }else{
            [self.locationInfoView setHintMessage:NSLocalizedString(@"UI_FILE_WILL_BE_SAVED_TO1", NULL) andSavePath:[self getSaveLocationPath:self.saveFolder]];
        }
    }
}
- (void)fileChooseFlowViewControllerDidCancelled:(NXFileChooseFlowViewController *)vc {
    
}
//#pragma mark ------>NXPreviewFileViewDelegate
//- (void)previewFileViewDidloadFileContent {
//    [self showAllUIForThisPage];
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
