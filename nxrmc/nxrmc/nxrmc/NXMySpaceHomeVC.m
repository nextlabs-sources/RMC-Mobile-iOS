
//
//  NXMySpaceHomeVC.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 27/4/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//
#import "AppDelegate.h"
#import "NXMySpaceHomeVC.h"
#import "NXProjectTabBarController.h"
#import "NXProjectGuideViewController.h"
#import "NXPresentNavigationController.h"
#import "NXFilesNavigationVC.h"
#import "NXMySpaceHomeInfoView.h"
#import "Masonry.h"
#import "NXLoginUser.h"
#import "NXGetProfileAPI.h"
#import "NXMyDriveGetUsageAPI.h"
#import "NXMBManager.h"
#import "NXHomeMySpaceStateView.h"
#import "NXHomeRepositoriesView.h"
#import "NXHomeProjectView.h"
#import "NXHomeUpgradesView.h"
#import "NXProjectCollectionFlowLayout.h"
#import "NXMyProjectItemCell.h"
#import "NXProjectPendingInvitationCell.h"
#import "NXFileChooseFlowViewController.h"
#import "NXRepositoryInfoViewController.h"
#import "NXAddRepositoryViewController.h"
#import "NXRepositoryViewController.h"
#import "NXNewProjectVC.h"
#import "NXCustomAlertView.h"
#import "NXProfileViewController.h"
//#import "NXProjectInviteMemberView.h"
#import "NXAlertView.h"
#import "NXActionSheetItem.h"
#import "NXCustomActionSheetViewController.h"
#import "NXProjectDeclineMsgView.h"
#import "NXExceptInfoViewController.h"
#import "NXCustomHomeTittleView.h"

#import "UIView+UIExt.h"
#import "NXAllProjectsViewController.h"
#import "NXGetAuthURLAPI.h"
#import "NXOneDriveTestVC.h"
#import "NXLProfile.h"
#import "UIView+UIExt.h"
#import "NXSlideBarModel.h"
#import "NXWorkSpaceManager.h"
#import "NXWorkSpaceItem.h"
#import "NXWorkSpaceTabBarViewController.h"
#import "NXMyVaultListParModel.h"
#import "NXRepositoriesVC.h"
#import "NXProjectFilesVC.h"
#import "NXHomeNavigationVC.h"
#import "NXSharedWithMeFileListParameterModel.h"

static const CGFloat kCellHeight = 130;
#define kMyProjectsCollectionViewIdentifier     1231231
#define kotherProjectsCollectionViewIdentifier  1231232341
#define KSCOLLECTIONVIEWHIGHT 180
#define KSHEADINFOVIEWHEIGHT  120
#define KSSTATEVIEWHEIGHT     120
#define KSREPOVIEWHEIGHT      160
//#if NXRMC_ENTERPRISE_FLAG == 1
//#define KSTOPPARTVIEWHEIGHT KSHEADINFOVIEWHEIGHT + KSSTATEVIEWHEIGHT
//#else
//#define KSTOPPARTVIEWHEIGHT KSHEADINFOVIEWHEIGHT + KSSTATEVIEWHEIGHT + KSREPOVIEWHEIGHT
//#endif
@interface NXMySpaceHomeVC ()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,NXRepoSystemFileInfoDelegate>
@property(nonatomic, strong) UIScrollView *homeScrollView;
@property(nonatomic, strong) NXMySpaceHomeInfoView *headInfoView;
@property(nonatomic, strong) NXHomeMySpaceStateView *stateView;
@property(nonatomic, strong) NXHomeRepositoriesView *repoView;
@property(nonatomic, strong)NSMutableArray *byMeProjectArray;
@property(nonatomic, strong)UICollectionView *byMeCollectionView;
@property(nonatomic, strong)NSMutableArray *byOtherProjectArray;
@property(nonatomic, strong)UICollectionView *byOtherConllectionView;
@property(nonatomic, strong)NXHomeProjectView *byMeProjectsView;
@property(nonatomic, strong)NXHomeProjectView *byOtherProjectsView;
@property(nonatomic, strong)NXCustomAlertView *addFriendAlertView;
@property(nonatomic, assign)CGFloat scrollContentY;
@property(nonatomic, strong)UIView *waitingView;
@property(nonatomic, strong)UIButton *createProjectBtn;
@property(nonatomic, strong)UIView *bgGradientView;
@property(nonatomic, strong)UIImageView *gradientLineView;
@property(nonatomic, assign)CGFloat topPartViewGeight;
@property(nonatomic, assign)NSUInteger myVaultFilesTotalCount;
@property(nonatomic, assign)NSUInteger  sharedWithMeCount;
@end

@implementation NXMySpaceHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor cyanColor];
//    if (buildFromSkyDRMEnterpriseTarget && [NXCommonUtils isCompanyAccountLogin]) {
//        self.topPartViewGeight = KSHEADINFOVIEWHEIGHT + KSSTATEVIEWHEIGHT;
//    }else{
        self.topPartViewGeight = KSHEADINFOVIEWHEIGHT + KSSTATEVIEWHEIGHT + KSREPOVIEWHEIGHT;
//    }
    [self commonInitNavgationBar];
    [self commonInitUI];
//    [NXMBManager showLoadingToView:self.waitingView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseToProjectInvitationChanged:) name:NXPrjectInvitationNotifiy object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseToProjectListChanged:) name:NOTIFICATION_PROJECT_LIST_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseToRepositoryListChanged:) name: NOTIFICATION_REPO_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSupportWorkspaceState:) name:NOTIFICATION_WORKSPACE_STATE_UPDATE object:nil];
    [[NXLoginUser sharedInstance].myRepoSystem syncRepositoryWithCompletion:^(NSArray *repoArray, NSTimeInterval syncTime, NSError *error) {
        NXSyncDateModel *dataModel = [[NXSyncDateModel alloc] initWithDate:[NSDate date] successed:error?NO:YES];
        [NXCommonUtils storeSyncDateModel:dataModel];
    }];
#ifdef DEBUG
    //  show exception info
    [self showCrashExceptInfo];
#endif
    
    // check App signature
    [NXSlideBarModel loadSlideData];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self checkProfileInfo];
    [self checkMySpaceState];
    NSArray *array = [[NXLoginUser sharedInstance].myRepoSystem allAuthReposiories];
    [self.repoView upDateNewInfoWith:array];
    [self getNewDataFromAPIandReload];
    
    [[NXLoginUser sharedInstance].myProject startSyncProjectInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MASTER_TABBAR_ADDBUTTON_NEED_DISPLAY object:nil];
}

- (NXHomeProjectView *)byMeProjectsView {
    if (!_byMeProjectsView) {
        _byMeProjectsView = [[NXHomeProjectView alloc]init];
        _byMeProjectsView.accessibilityValue = @"HOME_PAGE_PROJECT_BY_ME_VIEW";
        _byMeProjectsView.projectTypeLabel.accessibilityValue = @"HOME_PAGE_PROJECT_BY_ME_LAB";
        [self.homeScrollView addSubview:_byMeProjectsView];
        NXProjectCollectionFlowLayout *layout = [[NXProjectCollectionFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(0, 25, 0, 25);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(kCellHeight * 1.2 + kMargin * 8, kCellHeight);
        self.byMeCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_byMeProjectsView.projectContentView addSubview:self.byMeCollectionView];
        _byMeCollectionView.tag = kMyProjectsCollectionViewIdentifier;
        _byMeCollectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _byMeCollectionView.delegate = self;
        _byMeCollectionView.dataSource = self;
        [_byMeCollectionView registerClass:[NXMyProjectItemCell class] forCellWithReuseIdentifier:@"myProjectCell"];
        [_byMeCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_byMeProjectsView.projectContentView);
            make.left.equalTo(_byMeProjectsView.projectContentView);
            make.right.equalTo(_byMeProjectsView.projectContentView);
            make.height.equalTo(@(kCellHeight));
        }];
    }
    NSString *meStr = NSLocalizedString(@"UI_HOMEVC_PROJECT_BY_ME", NULL);
    _byMeProjectsView.projectTypeLabel.attributedText = [self createAttributeString:NSLocalizedString(@"UI_HOMEVC_PROJECT_CREATED", NULL) subTitle1:[NSString stringWithFormat:@" %@",meStr] subTitle2:[NSString stringWithFormat:@" (%ld)",self.byMeProjectArray.count]];
    return _byMeProjectsView;
}
- (NXHomeProjectView *)byOtherProjectsView {
    if (!_byOtherProjectsView ) {
        _byOtherProjectsView  = [[NXHomeProjectView alloc]init];
        _byOtherProjectsView.accessibilityValue = @"HOME_PAGE_PROJECT_BY_OTHER_LAB";
        [self.homeScrollView addSubview:_byOtherProjectsView];
        NXProjectCollectionFlowLayout *layout = [[NXProjectCollectionFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(0, 25, 0, 25);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//        layout.itemSize = CGSizeMake(kCellHeight + kMargin * 8, kCellHeight);
        layout.itemSize = CGSizeMake(kCellHeight * 1.2 + kMargin * 8, kCellHeight);
    
        self.byOtherConllectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [self.homeScrollView addSubview:_byOtherConllectionView];
        _byOtherConllectionView.tag = kotherProjectsCollectionViewIdentifier;
        _byOtherConllectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _byOtherConllectionView.delegate = self;
        _byOtherConllectionView.dataSource = self;
        _byOtherConllectionView.showsHorizontalScrollIndicator = YES;
        [_byOtherConllectionView registerClass:[NXMyProjectItemCell class] forCellWithReuseIdentifier:@"myProjectCell"];
        [_byOtherConllectionView registerClass:[NXProjectPendingInvitationCell class] forCellWithReuseIdentifier:@"projectPendingInvitationCell"];
        [_byOtherConllectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_byOtherProjectsView.projectContentView);
            make.left.equalTo(_byOtherProjectsView.projectContentView);
            make.right.equalTo(_byOtherProjectsView.projectContentView);
            make.height.equalTo(@(kCellHeight));
        }];
    }
    
    NSString *otherStr = NSLocalizedString(@"UI_HOMEVC_PROJECT_BY_OTHER", NULL);
    _byOtherProjectsView.projectTypeLabel.attributedText = [self createAttributeString:NSLocalizedString(@"UI_HOMEVC_PROJECT_INVITED", NULL) subTitle1:[NSString stringWithFormat:@" %@",otherStr] subTitle2:[NSString stringWithFormat:@" (%ld)",self.byOtherProjectArray.count]];
    return  _byOtherProjectsView;
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.homeScrollView.contentSize = CGSizeMake(0,self.scrollContentY);
}

- (void)commonInitNavgationBar {
    
    UIImage *launchImage;
    if (buildFromSkyDRMEnterpriseTarget) {
        launchImage = [UIImage imageNamed:@"launch-screen-enterprise-icon"];
    }else{
        launchImage = [UIImage imageNamed:@"launchScreenImg"];
    }
    
    UIImageView *titleView = [[UIImageView alloc] initWithImage:launchImage];
    titleView.contentMode = UIViewContentModeScaleAspectFill;
    titleView.frame = CGRectMake(-10, 0, 100, 25);
    
    NXCustomHomeTittleView *customeTittleView = [[NXCustomHomeTittleView alloc] initWithFrame:CGRectMake(0, 0, 100, 25)];
    [customeTittleView addSubview:titleView];
    self.navigationItem.titleView = customeTittleView;
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UIBarButtonItem *setBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Settings Filled-20"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemClcik:)];
    setBarButton.accessibilityValue = @"HOME_PAGE_SET_BTN";
    self.navigationItem.leftBarButtonItems = @[setBarButton];
    // add rightButton just for titleView is center.
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    rightButton.enabled = NO;
    self.navigationItem.rightBarButtonItems = @[rightButton];
    
}

- (void)commonInitUI {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UIScrollView *homeScrollView = [[UIScrollView alloc]init];
    [self.view addSubview:homeScrollView];
    self.homeScrollView = homeScrollView;
    
    homeScrollView.backgroundColor = [UIColor clearColor];
    homeScrollView.showsVerticalScrollIndicator = NO;
    homeScrollView.bounces = YES;
    homeScrollView.delegate = self;

    UIView *bgGradientView = [UIView az_gradientViewWithColors:@[RMC_GRADIENT_START_COLOR,RMC_GRADIENT_END_COLOR,[UIColor colorWithRed:227/255.0f green:236/255.0 blue:228/255.0 alpha:1.0]] locations:@[@(0.1),@(0.5),@(0.85)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(0, 1)];
    [homeScrollView addSubview:bgGradientView];
    self.bgGradientView = bgGradientView;
    
    UIImageView *gradientLineView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg.png"]];
    [homeScrollView addSubview:gradientLineView];
    self.gradientLineView = gradientLineView;
    
    NXMySpaceHomeInfoView *headInfoView = [[NXMySpaceHomeInfoView alloc]init];
    [bgGradientView addSubview:headInfoView];
    self.headInfoView = headInfoView;
    WeakObj(self);
    headInfoView.goToPorFilePageBlock =^(id sender) {
        StrongObj(self);
        [self goToProfilePage];
    };
    [headInfoView updateUserNameAndHeadImage];
    
    NXHomeMySpaceStateView *stateView = [[NXHomeMySpaceStateView alloc]init];
    [bgGradientView addSubview:stateView];
    
    [stateView makeUIBaseWithItemInfo:nil];
    self.stateView = stateView;
    
    stateView.clickSpaceItemFinishedBlock = ^(NSInteger index){
        StrongObj(self);
        [self clickItemToOtherSpacePage:index];
    };
    NXHomeRepositoriesView *repoView = [[NXHomeRepositoriesView alloc]init];
    [bgGradientView addSubview:repoView];
    self.repoView  = repoView;
    repoView.clickRepoItemFinishedBlock = ^(NXRepositoryModel *model) {
        StrongObj(self);
        [self clickRepoItem:model];
    };
    
//    if (buildFromSkyDRMEnterpriseTarget && [NXCommonUtils isCompanyAccountLogin]) {
//        [repoView setHidden:YES];
//    }else{
//        [repoView setHidden:NO];
//    }
    
    UIView *waitingView = [[UIView alloc]init];
    [homeScrollView addSubview:waitingView];
    self.waitingView = waitingView;
    waitingView.backgroundColor = homeScrollView.backgroundColor;
     [NXMBManager showLoadingToView:waitingView];
    
    self.scrollContentY = self.topPartViewGeight + 200 + 40;
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [homeScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
                make.left.equalTo(self.view);
                make.right.equalTo(self.view);
                make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
            }];
        }
    }else{
        [homeScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuideBottom);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
        }];
    }
    [bgGradientView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(homeScrollView);
        make.left.right.equalTo(self.view);
    }];
    [headInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bgGradientView);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@KSHEADINFOVIEWHEIGHT);
    }];
    
    [stateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headInfoView.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@KSSTATEVIEWHEIGHT);
    }];
//
//    if (buildFromSkyDRMEnterpriseTarget && [NXCommonUtils isCompanyAccountLogin]) {
//        [repoView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(stateView.mas_bottom);
//            make.left.right.equalTo(self.view);
//            make.height.equalTo(@1);
//            make.bottom.equalTo(bgGradientView).offset(-5);
//        }];
//
//        [waitingView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(repoView.mas_bottom);
//            make.left.right.equalTo(self.view);
//            make.height.equalTo(@200);
//        }];
//    }else{
        [repoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(stateView.mas_bottom);
            make.left.right.equalTo(self.view);
            make.height.equalTo(@KSREPOVIEWHEIGHT);
            make.bottom.equalTo(bgGradientView).offset(-6);
        }];
        
        [waitingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(repoView.mas_bottom);
            make.left.right.equalTo(self.view);
            make.height.equalTo(@200);
        }];
   // }
    [gradientLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bgGradientView.mas_bottom);
        make.left.right.equalTo(bgGradientView);
        make.height.equalTo(@8);
    }];
}

#pragma mark ---->go to porfile
- (void)leftBarButtonItemClcik:(UIBarButtonItem *) sender {
    [self goToProfilePage];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark ------>check profile info on headInfoView
- (void)checkProfileInfo {
    NXGetProfileAPI *api = [[NXGetProfileAPI alloc] init];
    WeakObj(self);
    [api requestWithObject:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        if (error) {
            DLog(@"%@", error.localizedDescription);
            return;
        }
        StrongObj(self);
        NXGetProfileResponse *ret = (NXGetProfileResponse *)response;
        if (ret.rmsStatuCode != 200) {
            DLog(@"%@", ret.rmsStatuMessage);
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
                [[NXLoginUser sharedInstance] updateUserinfo:ret.result];
                [self.headInfoView updateUserNameAndHeadImage];
            });
    }];
}

- (void)checkMySpaceState {
     WeakObj(self);
//    NXMyDriveGetUsageRequeset *usageApi = [[NXMyDriveGetUsageRequeset alloc]init];
//    [usageApi requestWithObject:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
//         StrongObj(self);
//        NXMyDriveGetUsageResponse *usageResponse = (NXMyDriveGetUsageResponse *)response;
//        if (!error && usageResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) {
//            NSDictionary *usageDic = @{@"usage":usageResponse.usage?:@0,@"myVaultUsage":usageResponse.myVaultUsage?:@0,@"quota":usageResponse.quota?:@0,@"vaultQuota":usageResponse.vaultQuota?:@0};
//            dispatch_async(dispatch_get_main_queue(), ^{
////                [NXMBManager hideHUDForView:self.view];
//                [self.stateView updateOneItems:0 withDict:usageDic];
//               
//                });
//        }
//    }];
    
    NXSharedWithMeFileListParameterModel *parModel = [[NXSharedWithMeFileListParameterModel alloc] init];
   [[NXLoginUser sharedInstance].sharedFileManager getSharedWithMeFileListWithParameterModel:parModel shouldReadCache:NO wtihCompletion:^(NXSharedWithMeFileListParameterModel *parameterModel, NSArray *fileListArray, NSError *error) {
       if (!error) {
           _sharedWithMeCount = fileListArray.count;
       }else{
           _sharedWithMeCount = 0;
       }
     ;
      
   }];
    NXMyVaultListParModel *myVaultModel = [[NXMyVaultListParModel alloc] init];
    [[NXLoginUser sharedInstance].myVault getMyVaultFileListUnderRootFolderWithFilterModel:myVaultModel shouldReadCache:NO withCompletion:^(NSArray *fileList, NXFileBase *parentFolder, NXMyVaultListParModel *filterModel, NSError *error) {
           StrongObj(self);
           NSMutableArray *noDeletedFile = [NSMutableArray arrayWithArray:fileList];
           for(NXMyVaultFile *file in fileList){
               if (file.isDeleted == YES) {
                   [noDeletedFile removeObject:file];
               }
           }
           if (!error) {
                 _myVaultFilesTotalCount = noDeletedFile.count;
           }else{
               _myVaultFilesTotalCount = 0;
           }
          [[NXLoginUser sharedInstance].myRepoSystem fileListForRepository:[[NXLoginUser sharedInstance].myRepoSystem getNextLabsRepository] readCache:YES delegate:self];
       }];
    
    if ([NXCommonUtils isSupportWorkspace]) {
        [[NXLoginUser sharedInstance].workSpaceManager getWorkSpaceFileNumberAndStorageWithCompletion:^(NSNumber *fileNumber, NSNumber *storageSize, NSError *error) {
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *workSpaceDict = @{@"workSpace":@{@"totalFiles":fileNumber,@"usage":storageSize}};
                    [self.stateView updateOneItems:1 withDict:workSpaceDict];
                });
            }
        }];
    }
}

- (void)updateProjectInfoUILayout {
    if (self.waitingView) {
        [NXMBManager hideHUDForView:self.waitingView];
        [self.waitingView removeFromSuperview];
        self.waitingView = nil;
    }
    
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            if (self.byMeProjectArray.count > 0) {
                [self.byMeProjectsView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.gradientLineView.mas_bottom).offset(10);
                    make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
                    make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
                    make.height.equalTo(@KSCOLLECTIONVIEWHIGHT);
                }];
                self.scrollContentY = self.topPartViewGeight+KSCOLLECTIONVIEWHIGHT+20+50;
                [self.byMeCollectionView reloadData];
                if (self.byOtherProjectArray.count > 0) {
                    [self.byOtherProjectsView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(self.byMeProjectsView.mas_bottom).offset(10);
                        make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
                        make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
                        make.height.equalTo(@KSCOLLECTIONVIEWHIGHT);
                    }];
                    [self.byOtherConllectionView reloadData];
                   
                    self.scrollContentY = self.topPartViewGeight+KSCOLLECTIONVIEWHIGHT*2+20+50;
                }else {
                    if (_byOtherProjectsView) {
                        _byOtherProjectsView.hidden = YES;
                        [self.byOtherConllectionView removeFromSuperview];
                        self.byOtherConllectionView = nil;
                        [_byOtherProjectsView removeFromSuperview];
                        _byOtherProjectsView = nil;
                    }
                   
                }

            }else {
                [self.byMeProjectsView removeFromSuperview];
                self.byMeProjectsView = nil;
                if (self.byOtherProjectArray.count>0) {
                    [self.byOtherProjectsView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(self.gradientLineView.mas_bottom).offset(10);
                        make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
                        make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
                        make.height.equalTo(@KSCOLLECTIONVIEWHIGHT);
                    }];
                   
                    [self.byOtherConllectionView reloadData];
                    
                    self.scrollContentY = self.topPartViewGeight+KSCOLLECTIONVIEWHIGHT*2+40+50;
                }else {
                    if (_byOtherProjectsView) {
                        _byOtherProjectsView.hidden = YES;
                        [self.byOtherConllectionView removeFromSuperview];
                        self.byOtherConllectionView = nil;
                        [_byOtherProjectsView removeFromSuperview];
                        _byOtherProjectsView = nil;
                    }
                   
                    self.scrollContentY = self.topPartViewGeight+KSCOLLECTIONVIEWHIGHT+20+40;
                }
            }
        }
    }
    else
    {
        if (self.byMeProjectArray.count > 0) {
            [self.byMeProjectsView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.gradientLineView.mas_bottom).offset(10);
                make.left.right.equalTo(self.view);
                make.height.equalTo(@KSCOLLECTIONVIEWHIGHT);
            }];
            self.scrollContentY = self.topPartViewGeight+KSCOLLECTIONVIEWHIGHT+20+50;
            [self.byMeCollectionView reloadData];
            if (self.byOtherProjectArray.count > 0) {
                [self.byOtherProjectsView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.byMeProjectsView.mas_bottom).offset(10);
                    make.left.right.equalTo(self.view);
                    make.height.equalTo(@KSCOLLECTIONVIEWHIGHT);
                }];
                [self.byOtherConllectionView reloadData];
                
                self.scrollContentY = self.topPartViewGeight+KSCOLLECTIONVIEWHIGHT*2+20+50;
            }else {
                if (_byOtherProjectsView) {
                    _byOtherProjectsView.hidden = YES;
                    [self.byOtherConllectionView removeFromSuperview];
                    self.byOtherConllectionView = nil;
                    [_byOtherProjectsView removeFromSuperview];
                    _byOtherProjectsView = nil;
                }
               
            }
            
        }else {
            [self.byMeProjectsView removeFromSuperview];
            self.byMeProjectsView = nil;
            if (self.byOtherProjectArray.count>0) {
                [self.byOtherProjectsView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.gradientLineView.mas_bottom).offset(10);
                    make.left.right.equalTo(self.view);
                    make.height.equalTo(@KSCOLLECTIONVIEWHIGHT);
                }];
               
                [self.byOtherConllectionView reloadData];
                self.scrollContentY = self.topPartViewGeight+KSCOLLECTIONVIEWHIGHT*2+40+50;
            }else {
                if (_byOtherProjectsView) {
                    _byOtherProjectsView.hidden = YES;
                    [self.byOtherConllectionView removeFromSuperview];
                    self.byOtherConllectionView = nil;
                    [_byOtherProjectsView removeFromSuperview];
                    _byOtherProjectsView = nil;
                }
                self.scrollContentY = self.topPartViewGeight+KSCOLLECTIONVIEWHIGHT+20+40;
            }
        }
    }
}

#pragma mark   ----》NSAttributedString
- (NSAttributedString *)createAttributeString:(NSString *)title subTitle1:(NSString *)subtitle1 subTitle2:(NSString *)subTitle2 {
    NSMutableAttributedString *myprojects = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName :[UIColor lightGrayColor],NSFontAttributeName:[UIFont systemFontOfSize:17]}];
    
    NSAttributedString *sub1 = [[NSMutableAttributedString alloc] initWithString:subtitle1 attributes:@{NSForegroundColorAttributeName :[UIColor blackColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:17]}];
    NSAttributedString *sub2 ;
    if (subTitle2) {
         sub2 = [[NSMutableAttributedString alloc] initWithString:subTitle2 attributes:@{NSForegroundColorAttributeName :[UIColor lightGrayColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:17]}];
    }
    
    [myprojects appendAttributedString:sub1];
    [myprojects appendAttributedString:sub2];
    return myprojects;
}
#pragma mark ----- getNewDataAndreload UI
- (void)getNewDataFromAPIandReload {
    WeakObj(self);
    [[NXLoginUser sharedInstance].myProject allMyProjectsWithCompletion:^(NSArray *projectsCreatedByMe, NSArray *projectsInvitedByOthers, NSArray *pendingProjects, NSError *error) {
        if (error) {
             dispatch_async(dispatch_get_main_queue(), ^{
            if (self.waitingView) {
                [NXMBManager hideHUDForView:self.waitingView];
                [self.waitingView removeFromSuperview];
                self.waitingView = nil;
            }
                 [NXMBManager showMessage:error.localizedDescription toView:self.view hideAnimated:YES afterDelay:2.0];
             });
        }
        if (projectsCreatedByMe == nil) {
            return ;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
        if (!error) {
            StrongObj(self);
            self.byMeProjectArray = [self sortByKey:@"lastActionTime" fromArray:projectsCreatedByMe];
            self.byOtherProjectArray = [self sortByKey:@"inviteTime" fromArray:pendingProjects];
            NSArray *otherArray = [self sortByKey:@"lastActionTime" fromArray:projectsInvitedByOthers];
            [self.byOtherProjectArray addObjectsFromArray:otherArray];
            [self updateProjectInfoUILayout];
        }
             });
    }];
}
#pragma mark --->sort by createdTime
- (NSMutableArray *)sortByKey:(NSString *)key fromArray:(NSArray *)array {
    NSMutableArray * resultArray = [NSMutableArray arrayWithArray:array];
    NSSortDescriptor *sortCreateTime = [[NSSortDescriptor alloc] initWithKey:key ascending:NO];
    [resultArray sortUsingDescriptors:@[sortCreateTime]];
    return resultArray;
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView.tag == kotherProjectsCollectionViewIdentifier) {
        if (self.byOtherProjectArray.count > 5) {
            return 5;
        }
        return self.byOtherProjectArray.count;
    }else if(collectionView.tag == kMyProjectsCollectionViewIdentifier){
        if (self.byMeProjectArray.count > 5) {
            return 5;
        }
        return self.byMeProjectArray.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView.tag == kotherProjectsCollectionViewIdentifier) {
        id model = self.byOtherProjectArray[indexPath.row];
        id cell = nil;
        if ([model isKindOfClass:[NXProjectModel class]]) {
            cell = (NXMyProjectItemCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"myProjectCell" forIndexPath:indexPath];
            ((NXMyProjectItemCell *)cell).model = model;
//            WeakObj(self);
            ((NXMyProjectItemCell *)cell).inviteLabelTouchUpInside = ^(NXProjectModel *projectModel)
            {
//                StrongObj(self);
               
//                [self inivitePeople:projectModel];
                
            };
             ((NXMyProjectItemCell *)cell).titleLabel.accessibilityValue = @"OTHER_PROJECT_NAME";
        }else if([model isKindOfClass:[NXPendingProjectInvitationModel class]])
        {
            cell = (NXProjectPendingInvitationCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"projectPendingInvitationCell" forIndexPath:indexPath];
            ((NXProjectPendingInvitationCell *)cell).titleLabel.accessibilityValue = @"PENDING_PROJECT_CELL";
            ((NXProjectPendingInvitationCell*)cell).model = model;
            WeakObj(collectionView);
            WeakObj(cell);
            ((NXProjectPendingInvitationCell *)cell).acceptInvitationBlock = ^(NXPendingProjectInvitationModel *invitation){
                StrongObj(cell);
                [NXMBManager showLoadingToView:collectionView];
                [[NXLoginUser sharedInstance].myProject acceptProjectInvitation:invitation withCompletion:^(NXProjectModel *project,NSTimeInterval serverTime,NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (error.code == NXRMC_ERROR_ACCEPT_PROJECT_INVITATION_EXPIRED) {
                            [NXMBManager hideHUDForView:cell];
                            [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_INVITATION_EXPIRED",NULL) toView:collectionView hideAnimated:YES afterDelay:kDelay];
                            return ;
                        }
                        if (!error) {
                            [NXMBManager hideHUDForView:collectionView];
                            [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_ACCEPT_INVITATION_SUCCESS", nil) toView:collectionView hideAnimated:YES afterDelay:kDelay];
                            
                        } else {
                            [NXMBManager hideHUDForView:collectionView];
                            [NXMBManager showMessage:error.localizedDescription?: NSLocalizedString(@"MSG_COM_ACCEPT_INVITATION_FAILED", nil) toView:collectionView hideAnimated:YES afterDelay:kDelay];
                        }
                        
                    });
                    
                }];
            };
        
            ((NXProjectPendingInvitationCell *)cell).ignoreInvitationBlock = ^(NXPendingProjectInvitationModel *invitation){
                NXProjectDeclineMsgView *msgView = [[NXProjectDeclineMsgView alloc]initWithTitle:NSLocalizedString(@"MSG_COM_DECLINE_PROJECT_INVITATION_WARNING", nil) inviteHander:^(NXProjectDeclineMsgView *alertView) {
                    NSString *declineReason = alertView.reasonStr;
                    if ([declineReason isEqualToString:@""] || declineReason == nil) {
                        declineReason = @"";
                    }
                    [NXMBManager showLoadingToView:collectionView];
                    [[NXLoginUser sharedInstance].myProject declineProjectInvitation:invitation forReason:declineReason withCompletion:^(NXPendingProjectInvitationModel *pendingInvitation, NSTimeInterval serverTime, NSError *error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                    [NXMBManager hideHUDForView:collectionView];
                                    if (!error) {
                                            StrongObj(collectionView);
                            
                                            if (self.byOtherProjectArray.count>1) {
                                            [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_DECLINE_INVITATION_SUCCESS", nil) toView:collectionView hideAnimated:YES afterDelay:kDelay];
                                            }
                                                                    
                                    }else {
                                        [NXMBManager showMessage:error.localizedDescription?:NSLocalizedString(@"MSG_COM_DECLINE_INVITATION_FAILED", nil) toView:collectionView hideAnimated:YES afterDelay:kDelay];
                                            }
                            });
                    }];
                    [alertView dismiss];
                }];
                [msgView show];
            };
        }
        if (cell == nil) {
            cell = [[UICollectionViewCell alloc] init];
        }
        return cell;
    }
    if (collectionView.tag == kMyProjectsCollectionViewIdentifier) {
        NXMyProjectItemCell *cell = (NXMyProjectItemCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"myProjectCell" forIndexPath:indexPath];
        
//        WeakObj(self);
        
        cell.inviteLabelTouchUpInside = ^(NXProjectModel *projectModel)
        {
//            StrongObj(self);
            
//            [self inivitePeople:projectModel];
        };
        cell.model = self.byMeProjectArray[indexPath.row];
        return cell;
    }
    assert(0);
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id projectModel = nil;
    if (collectionView.tag == kMyProjectsCollectionViewIdentifier) {
        projectModel = self.byMeProjectArray[indexPath.row];
    }else if(collectionView.tag == kotherProjectsCollectionViewIdentifier)
    {
        projectModel = self.byOtherProjectArray[indexPath.row];
        if ([projectModel isKindOfClass:[NXPendingProjectInvitationModel class]]) {
            return;
        }
    }
    
    if ([self.tabBarController.viewControllers[kNXMasterTabBarControllerIndexAllProjects] isKindOfClass:[NXHomeNavigationVC class]]) {
        NXHomeNavigationVC *filesNav = self.tabBarController.viewControllers[kNXMasterTabBarControllerIndexAllProjects];
        NXAllProjectsViewController *projectVC = filesNav.viewControllers.firstObject;
        [projectVC showProjectFilesPageWithModel:projectModel];
    }
    [self.tabBarController setSelectedIndex:kNXMasterTabBarControllerIndexAllProjects];
    
//    NXProjectFilesVC *filesVC = [[NXProjectFilesVC alloc] init];
//    filesVC.projectModel = projectModel;
//    [self.navigationController pushViewController:filesVC animated:NO];
//    NXProjectTabBarController *projectTabBar = [[NXProjectTabBarController alloc]initWithProject:projectModel];
//    projectTabBar.preTabBarController = (NXMasterTabBarViewController *)self.tabBarController;
//    [self.tabBarController.navigationController pushViewController:projectTabBar animated:YES];
//    projectTabBar.selectedIndex = kProjectTabBarDefaultSelectedIndex;
}
#pragma mark ---> go to other page
- (void)clickItemToOtherSpacePage:(NSInteger)index{
    switch (index) {
        case 0:
//  go to mySpace
            [self.tabBarController setSelectedIndex:2];
            break;
        case 1:
//  go to workspace
           [self.tabBarController setSelectedIndex:1];
            break;
        default:
            break;
    }

}

#pragma mark ----> click repo item
- (void)clickRepoItem:(NXRepositoryModel *)model {
   
    if (model.isAddItem) {
        NXAddRepositoryViewController *vc = [[NXAddRepositoryViewController alloc] init];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.primaryNavigationController pushViewController:vc animated:YES];
        return;
    }
    
    if ([self.tabBarController.viewControllers[kNXMasterTabBarControllerIndexRepositories] isKindOfClass:[NXFilesNavigationVC class]]) {
        NXFilesNavigationVC *filesNav = self.tabBarController.viewControllers[kNXMasterTabBarControllerIndexRepositories];
        NXRepositoriesVC *filesVC = filesNav.viewControllers.firstObject;
        [filesVC showRepoFilesByRepo:model];
    }
    [self.tabBarController setSelectedIndex:kNXMasterTabBarControllerIndexRepositories];
   
}
#pragma mark ----> activate project
- (void)acthivateProject {
    NXProjectGuideViewController *vc = [[NXProjectGuideViewController alloc] init];
    
    WeakObj(self);
    vc.clickBlock = ^(id sender) {
        StrongObj(self);
        NXNewProjectVC *projectVC = [[NXNewProjectVC alloc] init];
        projectVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:projectVC animated:YES];
    };
    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:vc];
    nav.navigationBar.tintColor = [UIColor blackColor];
    [self.tabBarController.navigationController presentViewController:nav animated:YES completion:nil];
}
#pragma mark ----> go to profile page

- (void)goToProfilePage {
   
    NXProfileViewController *profileVC = [[NXProfileViewController alloc] init];
    profileVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:profileVC animated:YES];
}

#pragma mark - Response to notification
- (void)responseToProjectInvitationChanged:(NSNotification *)notification
{
    [self getNewDataFromAPIandReload];
    [[NXLoginUser sharedInstance].myProject startSyncProjectInfo];
}

- (void)responseToProjectListChanged:(NSNotification *)notification
{
    [self getNewDataFromAPIandReload];
}
- (void)responseToRepositoryListChanged:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *array = [[NXLoginUser sharedInstance].myRepoSystem allAuthReposiories];
        [self.repoView upDateNewInfoWith:array];
    });
    
}

- (void)createANewProject:(id)sender {
    NXNewProjectVC *projectVC = [[NXNewProjectVC alloc] init];
    projectVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:projectVC animated:YES];
}
- (void)viewDidDisappear:(BOOL)animated
{
     [super viewDidDisappear:animated];
}
- (void)updateSupportWorkspaceState:(id)sender{
    [self checkMySpaceState];
}
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NXLoginUser sharedInstance].myProject pauseSyncProjectInfo];
}
#pragma mark -----invitePeople

- (void)showCrashExceptInfo {
    NSString *exceptPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"Exception"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *exceptFileList = [fileManager contentsOfDirectoryAtPath:exceptPath error:nil];
    if (exceptFileList.count > 0) {
        UIBarButtonItem *exceptButton = [[UIBarButtonItem alloc]initWithTitle:@"Except" style:UIBarButtonItemStylePlain target:self action:@selector(checkException)];
        self.navigationItem.rightBarButtonItems = @[exceptButton];
    }
    
}
- (void)checkException {
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *path = paths.lastObject;
    NSString *exceptPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"Exception"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *exceptFileList = [fileManager subpathsOfDirectoryAtPath:exceptPath error:nil];
    NXExceptInfoViewController *exceptVC = [[NXExceptInfoViewController alloc]init];
    exceptVC.exceptLists = [NSMutableArray arrayWithArray:exceptFileList];
    [self.navigationController pushViewController:exceptVC animated:YES];
}

#pragma mark --mark NXRepoSystemFileInfoDelegate

- (void)updateFileListFromParentFolder:(NXFileBase *)parentFolder resultFileList:(NSArray *)resultFileList error:(NSError *) error
{
  //TODO
}

- (void)didGetFileListUnderParentFolder:(NXFileBase *)parentFolder fileList:(NSArray *)fileList error:(NSError *)error
{
    NSUInteger total = _myVaultFilesTotalCount + _sharedWithMeCount + [[NXLoginUser sharedInstance].myRepoSystem allMyDriveFilesCount];
    [self.stateView updateMySpaceItemFilesCount:total];
}
@end
