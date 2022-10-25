//
//  NXProtectFileSelectLocationVC2.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/6/2.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXProtectFileSelectLocationVC.h"
#import "NXCustomTitleView.h"
#import "UIImage+ColorToImage.h"
#import "UIView+UIExt.h"
#import "NXCardStyleView.h"
#import "Masonry.h"
#import "NXSelectLocationView.h"
#import "NXFileBase.h"
#import "NXRepositoryModel.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXSkyDRMItemsView.h"
#import "NXTargetPorjectsSelectVC.h"
#import "NXProtectFileAfterSelectedLocationVC.h"
#import "NXFileChooseFlowViewController.h"
#import "NXTwoIconsMenuView.h"
#define KBTNTAG 100
@interface NXProtectFileSelectLocationVC ()<NXFileChooseFlowViewControllerDelegate>
@property(nonatomic, strong)UIView *specifyView;
@property(nonatomic, strong)NSString *repoName;
@property(nonatomic, strong)UILabel *defaultSaveLabel;
@property(nonatomic, assign)BOOL isNeedSelect;
@property(nonatomic, strong)NSString *leftBtnTitle;
@property(nonatomic, strong)NSString *leftBtnIcon;
@property(nonatomic, strong)NSString *leftSelectBtnIcon;
//@property(nonatomic, strong)NXSelectLocationView *selectLocationView;
@property(nonatomic, strong)NXSkyDRMItemsView *skydrmView;
@property(nonatomic, assign)BOOL isMyDrive;
@property(nonatomic, strong)NXTwoIconsMenuView *repoMenuView;
@property(nonatomic, strong)NXTwoIconsMenuView *skydrmMenuView;
@property(nonatomic, strong)NSDictionary *repoIconDict;
@property(nonatomic, strong)NSDictionary *repoIconSelectDict;
@property(nonatomic, strong)UIButton *nextBtn;
@property(nonatomic, strong)NXProjectModel *selectedProject;
@property(nonatomic, strong)NSString *defaultPath;
@property(nonatomic, strong)UILabel *hintLabel;
@end

@implementation NXProtectFileSelectLocationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self initNavigationBar];
     NSString *defaultPath;
    defaultPath = @"Files:/";
    self.leftBtnTitle = @"Files";
    self.leftBtnIcon = @"FilesIcon";
    self.leftSelectBtnIcon = @"FilesIcon";
//    if (self.fileItem.sorceType == NXFileBaseSorceTypeLocalFiles || self.fileItem.sorceType == NXFileBaseSorceTypeLocal) {
//        defaultPath = @"Files:/";
//        self.leftBtnTitle = @"Files";
//        self.leftBtnIcon = @"FilesIcon";
//        self.leftSelectBtnIcon = @"FilesIcon";
//    }else{
//        NXRepositoryModel *model = [[NXLoginUser sharedInstance].myRepoSystem getRepositoryModelByRepoId:self.fileItem.repoId];
//        self.targetFolder = [[NXLoginUser sharedInstance].myRepoSystem parentForFileItem:self.fileItem];
//        defaultPath = [NSString stringWithFormat:@"%@:%@",model.service_alias,[self.fileItem.fullPath stringByReplacingOccurrencesOfString:self.fileItem.name withString:@""]];
//        self.repoName = model.service_alias;
//        self.leftBtnTitle = self.repoName;
//        self.isNeedSelect = YES;
//        self.leftBtnIcon = self.repoIconDict[model.service_type];
//        self.leftSelectBtnIcon = self.repoIconSelectDict[model.service_type];
//        if (model.service_type.integerValue == kServiceSkyDrmBox) {
//            self.isMyDrive = YES;
//            defaultPath = @"MySpace:/";
//            self.leftBtnTitle = @"MySpace";;
//        }
//    }
    UILabel *hintLabel = [[UILabel alloc] init];
    hintLabel.text = @"Select location to save the file";
    hintLabel.textColor = RMC_MAIN_COLOR;
    hintLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:hintLabel];
    
    self.defaultPath = defaultPath;
    self.specifyView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:self.specifyView];
    
//    UILabel *defaultSaveLabel = [[UILabel alloc] init];
//    self.defaultSaveLabel = defaultSaveLabel;
//    defaultSaveLabel.attributedText = [self createAttributeString:@"File will be saved " subTitle:defaultPath];
//    defaultSaveLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
//    defaultSaveLabel.numberOfLines = 0;
//    [self.view addSubview:defaultSaveLabel];

    UIButton *nextButton = [[UIButton alloc] init];
    [self.view addSubview:nextButton];
    self.nextBtn = nextButton;
    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
    nextButton.accessibilityValue = @"NEXT_BTN";
    [nextButton addTarget:self action:@selector(nextBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextButton setBackgroundImage:[UIImage imageWithSize:CGSizeMake(200, 200) colors:@[RMC_GRADIENT_START_COLOR, RMC_GRADIENT_END_COLOR] gradientType:GradientTypeLeftToRight] forState:UIControlStateNormal];
    [nextButton cornerRadian:3];
    self.skydrmMenuView.isSelected = YES;
    self.skydrmView.hidden = NO;
//    if (self.selectType == NXSelectProtectMenuTypeRepo) {
//        self.repoMenuView.isSelected = YES;
//        self.selectLocationView.hidden = NO;
//    }else if (self.selectType == NXSelectProtectMenuTypeSkyDRM){
//        self.skydrmMenuView.isSelected = YES;
//        self.skydrmView.hidden = NO;
//        self.selectLocationView.hidden = YES;
//        if (self.isMyDrive) {
//            self.repoMenuView.backgroundColor = [UIColor groupTableViewBackgroundColor];
//            self.repoMenuView.userInteractionEnabled = NO;
//        }
//    }
    [hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(10);
        } else {
            make.top.equalTo(self.mas_topLayoutGuideBottom).offset(10);
        }
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-15);
        make.height.equalTo(@30);
    }];
    [self.specifyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(hintLabel.mas_bottom);
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
    }];
//    [defaultSaveLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.specifyView.mas_bottom).offset(20);
//        make.left.right.equalTo(self.specifyView);
//        make.height.lessThanOrEqualTo(@(50));
//    }];
    [nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(@300);
        make.bottom.equalTo(self.view.mas_bottom).offset(-130);
        make.height.lessThanOrEqualTo(@(40));
    }];
}
//- (NXSelectLocationView *)selectLocationView {
//    if (!_selectLocationView) {
//        _selectLocationView = [[NXSelectLocationView alloc] init];
//        [self.view addSubview:_selectLocationView];
//        _selectLocationView.currentFile = self.fileItem;
//        _selectLocationView.selectedFolder = self.targetFolder;
//        WeakObj(self);
//        _selectLocationView.selectedCompletion = ^(NXFileBase *fileBase,NSString *path) {
//            StrongObj(self);
//            NXFileChooseFlowViewController *chooseVC = [[NXFileChooseFlowViewController alloc] initWithAnchorFolder:fileBase fromPath:path type:NXFileChooseFlowViewControllerTypeChooseDestFolder];
//            chooseVC.fileChooseVCDelegate = self;
//            chooseVC.modalPresentationStyle = UIModalPresentationFullScreen;
//            [self.navigationController presentViewController:chooseVC animated:YES completion:nil];
//        };
//        [_selectLocationView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.specifyView.mas_bottom).offset(10);
//            make.left.right.equalTo(self.specifyView);
//            make.bottom.equalTo(self.defaultSaveLabel.mas_top).offset(-10);
//        }];
//    }
//    return _selectLocationView;
//}
- (NXSkyDRMItemsView *)skydrmView {
    if (!_skydrmView) {
        _skydrmView = [[NXSkyDRMItemsView alloc] init];
        _skydrmView.hidden = YES;
        [self.view addSubview:_skydrmView];
        WeakObj(self);
        _skydrmView.selectedCompletion = ^(NSString * _Nonnull path) {
            StrongObj(self);
            if ([path isEqualToString:@"project"]) {
                [self toSelectProjects:nil];
                
            }else if([path isEqualToString:@"workspace"]){
                [self toSelectWorkSpace:nil];
                
            }else if([path isEqualToString:@"myVault"]){
                [self toSelectMyVault:nil];
            }
        };
        _skydrmView.selectedItemModelCompletion = ^(id  _Nonnull itemModel) {
            StrongObj(self);
            if ([itemModel isKindOfClass:[NXProjectModel class]]) {
                self.selectedProject = itemModel;
                NXFileChooseFlowViewController *VC = [[NXFileChooseFlowViewController alloc] initWithProject:itemModel type:NXFileChooseFlowViewControllerTypeChooseDestFolder];
                VC.fileChooseVCDelegate = self;
                VC.modalPresentationStyle = UIModalPresentationFullScreen;
                [self.navigationController presentViewController:VC animated:YES completion:nil];
                
            }else if([itemModel isKindOfClass:[NXRepositoryModel class]]){
                NXFileChooseFlowViewController *VC = [[NXFileChooseFlowViewController alloc] initWithRepository:itemModel type:NXFileChooseFlowViewControllerTypeChooseDestFolder isSupportMultipleSelect:NO];
                VC.fileChooseVCDelegate = self;
                VC.modalPresentationStyle = UIModalPresentationFullScreen;
                [self.navigationController presentViewController:VC animated:YES completion:nil];
            }
            
        };
       
        [_skydrmView mas_makeConstraints:^(MASConstraintMaker *make) {
               make.top.equalTo(self.specifyView.mas_bottom).offset(10);
               make.left.right.equalTo(self.specifyView);
               make.bottom.equalTo(self.view).offset(-20);
           }];
        
    }
    return _skydrmView;
}
- (void)initNavigationBar {
    NXCustomTitleView *titleView = [[NXCustomTitleView alloc] init];
    titleView.text = NSLocalizedString(@"UI_SAVE_FILE_LOCATION", NULL);
    self.navigationItem.titleView = titleView;
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClicked:)];
    leftItem.accessibilityValue = @"UI_BOX_CANCEL";
    self.navigationItem.leftBarButtonItem = leftItem;
    self.automaticallyAdjustsScrollViewInsets = NO;
}
- (void)cancelButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}



- (UIView *)specifyView {
    if (!_specifyView) {
        _specifyView = [[UIView alloc]init];
        NXTwoIconsMenuView *repoMenuView = [[NXTwoIconsMenuView alloc] initWithFirstNormalIconName:@"Group-Not-selected" firstSelectIconName:@"Group-selected" secondNormalIconName:self.leftBtnIcon secondSelectIconName:self.leftSelectBtnIcon title:self.leftBtnTitle];
        [_specifyView addSubview:repoMenuView];
        self.repoMenuView = repoMenuView;
        WeakObj(self);
        repoMenuView.selectedCompletion = ^{
            StrongObj(self);
            self.selectType = NXSelectProtectMenuTypeRepo;
            self.skydrmMenuView.isSelected = NO;
            self.skydrmView.hidden = YES;
//            self.selectLocationView.hidden = NO;
            self.defaultSaveLabel.hidden = NO;
            self.nextBtn.hidden = NO;
//            self.selectLocationView.hidden = YES;
//            if (self.fileItem.sorceType == NXFileBaseSorceTypeLocalFiles || self.fileItem.sorceType == NXFileBaseSorceTypeLocal || self.isMyDrive) {
//                 self.selectLocationView.hidden = YES;
//            }
        };
        NXTwoIconsMenuView *skrdrmMenuView = [[NXTwoIconsMenuView alloc] initWithFirstNormalIconName:@"Group-Not-selected" firstSelectIconName:@"Group-selected" secondNormalIconName:@"SkyDRM-black" secondSelectIconName:@"SkyDRM-white" title:@"SkyDRM"];
        [_specifyView addSubview:skrdrmMenuView];
        self.skydrmMenuView = skrdrmMenuView;
        skrdrmMenuView.selectedCompletion = ^{
            StrongObj(self);
            self.selectType = NXSelectProtectMenuTypeSkyDRM;
            self.repoMenuView.isSelected = NO;
//            self.selectLocationView.hidden = YES;
            self.skydrmView.hidden = NO;
            self.defaultSaveLabel.hidden = YES;
            self.nextBtn.hidden = YES;
        };
       
        [repoMenuView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_specifyView).offset(kMargin * 2.5);
            make.left.equalTo(_specifyView);
            make.width.equalTo(_specifyView).multipliedBy(0.5);
            make.height.equalTo(@44);
        }];
        [skrdrmMenuView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.height.equalTo(repoMenuView);
            make.left.equalTo(repoMenuView.mas_right).offset(kMargin);
            make.right.equalTo(_specifyView);
            make.bottom.equalTo(_specifyView).offset(-kMargin * 2.5);
        }];
    }
    return _specifyView;
}
- (void)nextBtnClick:(id)sneder {
    NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
    VC.filesArray = self.selectFilesArray;
    VC.locationType = NXProtectSaveLoactionTypeLocalFiles;
//    if (self.fileItem.sorceType == NXFileBaseSorceTypeLocalFiles || self.fileItem.sorceType == NXFileBaseSorceTypeLocal) {
//        VC.locationType = NXProtectSaveLoactionTypeLocalFiles;
//    }else if (self.fileItem.sorceType == NXFileBaseSorceTypeRepoFile) {
//        if (self.isMyDrive) {
//            VC.locationType = NXProtectSaveLoactionTypeMyVault;
//        }else{
//            VC.locationType = NXProtectSaveLoactionTypeFileRepo;
//        }
//    }
    VC.saveFolder = self.targetFolder;
    [self.navigationController pushViewController:VC animated:YES];
}
- (NSAttributedString *)createAttributeString:(NSString *)title subTitle:(NSString *)subtitle {
    NSMutableAttributedString *myprojects = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName :[UIColor darkTextColor],NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    
    NSAttributedString *sub1 = [[NSMutableAttributedString alloc] initWithString:subtitle attributes:@{NSForegroundColorAttributeName :[UIColor blackColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:14]}];
    [myprojects appendAttributedString:sub1];
    return myprojects;
}
- (void)toSelectProjects:(id)sender {
    NXTargetPorjectsSelectVC *targetVC = [[NXTargetPorjectsSelectVC alloc] init];
    targetVC.fileArray = self.selectFilesArray;
    targetVC.isForProtect = YES;
    [self.navigationController pushViewController:targetVC animated:YES];
}
- (void)toSelectMyVault:(id)sender {
    NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
    VC.filesArray = self.selectFilesArray;
    VC.locationType = NXProtectSaveLoactionTypeMyVault;
    [self.navigationController pushViewController:VC animated:YES];
}
- (void)toSelectWorkSpace:(id)sender {
    NXFileChooseFlowViewController *VC = [[NXFileChooseFlowViewController alloc] initWithWorkSpaceType:NXFileChooseFlowViewControllerTypeChooseDestFolder];
    VC.fileChooseVCDelegate = self;
    VC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:VC animated:YES completion:nil];
}
- (NSDictionary *)repoIconDict {
    if (!_repoIconDict) {
        _repoIconDict = @{[NSNumber numberWithInteger:kServiceDropbox]:@"dropbox - black",
                          [NSNumber numberWithInteger:kServiceSharepointOnline]:@"sharepoint - black",
                          [NSNumber numberWithInteger:kServiceSharepoint]:@"sharepoint - black",
                          [NSNumber numberWithInteger:kServiceOneDrive]:@"onedrive - black",
                          [NSNumber numberWithInteger:kServiceGoogleDrive]:@"google-drive-color",
                          [NSNumber numberWithInteger:kServiceBOX]:@"box - black",
                          [NSNumber numberWithInteger:kServiceSkyDrmBox]:@"MySpace-nav-bar-icon",
                          [NSNumber numberWithInteger:kServiceOneDriveApplication]:@"onedrive - black",
                          [NSNumber numberWithInteger:KServiceSharepointOnlineApplication]:@"sharepoint - black",
        };
    }
    return _repoIconDict;
}
- (NSDictionary *)repoIconSelectDict {
    if (!_repoIconSelectDict) {
       _repoIconSelectDict = @{[NSNumber numberWithInteger:kServiceDropbox]:@"dropbox - gray",
                               [NSNumber numberWithInteger:kServiceSharepointOnline]:@"sharepoint - gray",
                               [NSNumber numberWithInteger:kServiceSharepoint]:@"sharepoint - gray",
                               [NSNumber numberWithInteger:kServiceOneDrive]:@"onedrive - gray",
                               [NSNumber numberWithInteger:kServiceGoogleDrive]:@"google-drive-notSelected",
                               [NSNumber numberWithInteger:kServiceBOX]:@"box - gray",
                               [NSNumber numberWithInteger:kServiceSkyDrmBox]:@"MySpace-nav-bar-icon",
                               [NSNumber numberWithInteger:kServiceOneDriveApplication]:@"onedrive - gray",
                               [NSNumber numberWithInteger:KServiceSharepointOnlineApplication]:@"sharepoint - gray",
       };
    }
    return _repoIconSelectDict;
    
}
#pragma mark ------> fileChooseDelegate
- (void)fileChooseFlowViewController:(NXFileChooseFlowViewController *)vc didChooseFile:(NSArray *)choosedFiles {
    if (choosedFiles.count) {
        self.targetFolder = choosedFiles.lastObject;
    }
    NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
    VC.filesArray = self.selectFilesArray;
    VC.saveFolder = self.targetFolder;
    if ([self.targetFolder isKindOfClass:[NXProjectFolder class]]) {
        VC.targetProject = self.selectedProject;
        VC.locationType = NXProtectSaveLoactionTypeProject;
    }else if ([self.targetFolder isKindOfClass:[NXWorkSpaceFolder class]]){
        VC.locationType = NXProtectSaveLoactionTypeWorkSpace;
    }else {
      NXRepositoryModel *repoModel = [[NXLoginUser sharedInstance].myRepoSystem getRepositoryModelByRepoId:self.targetFolder.repoId];
        if ([repoModel.service_type intValue] == kServiceOneDriveApplication) {
            VC.locationType = NXProjectSaveLocationTypeSharedWorkSpace;
        }else{
            VC.locationType = NXProtectSaveLoactionTypeFileRepo;
        }
    }
    
    [self.navigationController pushViewController:VC animated:NO];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)fileChooseFlowViewControllerDidCancelled:(NXFileChooseFlowViewController *)vc {
   self.defaultSaveLabel.attributedText = [self createAttributeString:@"File will be saved " subTitle:self.defaultPath];
    
}
@end
