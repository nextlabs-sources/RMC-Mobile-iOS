//
//  NXAllProjectsViewController.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 30/10/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXAllProjectsViewController.h"
#import "NXProjectTotalNumView.h"
#import "Masonry.h"
#import "NXRMCDef.h"
#import "NXCustomHomeTittleView.h"
#import "NXInviteMessageCell.h"
#import "NXAllProjectDetailCell.h"
#import "NXLoginUser.h"
#import "NXMBManager.h"
#import "NXPendingProjectInvitationModel.h"
#import "NXProjectModel.h"
#import "NXProjectTabBarController.h"
#import "NXProjectDeclineMsgView.h"
#import "NXNewProjectVC.h"
#import "NXFilterViewController.h"
#import "NXProjectSearchResultVC.h"
#import "NXSearchViewController.h"
#import "NXCommonUtils.h"
#import "HexColor.h"
#import "NXProjectFilesVC.h"
@interface NXAllProjectsViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,NXFilterViewControllerDelegate,NXProjectListSearchResultDelegate,NXSearchVCResignActiveDelegate,NXSearchVCUpdateDelegate>
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *pendingArray;
@property (nonatomic, strong) NSMutableArray *byMeArray;
@property (nonatomic, strong) NSMutableArray *byOtherArray;
@property (nonatomic, strong) NSMutableArray *projectDicArray;
@property (nonatomic, strong) NSMutableDictionary *dataDic;
@property (nonatomic, assign) BOOL isAddCreateItem;
@property(nonatomic, strong) NSArray *allSortByTypes;
@property(nonatomic, assign) NSInteger currentSortBy_type;
@property(nonatomic, strong) NXSearchViewController *searchVC;

@end

@implementation NXAllProjectsViewController
- (NSMutableArray *)projectDicArray {
    if (!_projectDicArray) {
        _projectDicArray = [NSMutableArray array];
    }
    return _projectDicArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];

    // Do any additional setup after loading the view.
    [self commonInitNavgationBar];
    self.allSortByTypes = @[@(NXSortOptionNameAscending),@(NXSortOptionNameDescending),@(NXSortOptionModifiedDate)];
    self.currentSortBy_type = NXSortOptionNameAscending;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseToProjectInvitationChanged:) name:NXPrjectInvitationNotifiy object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseToProjectListChanged:) name:NOTIFICATION_PROJECT_LIST_UPDATED object:nil];
//    [self commonInitProjectTotalNumView];
//    [self commonInitProjectDetailInfoViewByCollectionView];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getNewDataFromAPIandReload];
}
- (void)getNewDataFromAPIandReload {
    WeakObj(self);
    [[NXLoginUser sharedInstance].myProject allMyProjectsWithCompletion:^(NSArray *projectsCreatedByMe, NSArray *projectsInvitedByOthers, NSArray *pendingProjects, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [NXMBManager showMessage:error.localizedDescription toView:self.view hideAnimated:YES afterDelay:2.0];
            });
        }
        if (projectsCreatedByMe == nil) {
            return ;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
                StrongObj(self);
                [self.byMeArray removeAllObjects];
                [self.byOtherArray removeAllObjects];
                self.byMeArray = [NSMutableArray arrayWithArray:projectsCreatedByMe];
                self.byOtherArray = [NSMutableArray arrayWithArray:projectsInvitedByOthers];
                self.pendingArray = pendingProjects;
            if (buildFromSkyDRMEnterpriseTarget && [NXCommonUtils isCompanyAccountLogin]) {
                self.isAddCreateItem = NO;
            }else{
                 self.isAddCreateItem = YES;
            }
        
            self.sortOption = self.currentSortBy_type;
        });
    }];
}
- (void)updateUILayout {
    [self commonInitProjectTotalNumView];
    if (self.collectionView) {
        [self.collectionView reloadData];
    }else {
        [self commonInitProjectDetailInfoViewByCollectionView];
    }
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
    // add rightButton just for titleView is center.
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search - black"] style:UIBarButtonItemStylePlain target:self action:@selector(searchItemClicked:)];
    searchItem.accessibilityValue = @"SEARCH_BAR_ITEM";
    UIBarButtonItem *ellipsisItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ellipsis - black"] style:UIBarButtonItemStylePlain target:self action:@selector(ellipsisItemClicked:)];
    ellipsisItem.accessibilityValue = @"ELLIPSIS_BAR_ITEM";
    self.navigationItem.rightBarButtonItems = @[ellipsisItem];
//    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
//    self.navigationItem.leftBarButtonItems = @[leftItem];
}
- (void)back:(id)sender {
    if (self.showType == NXAllProjectsVCShowTypeFromProject) {
        if ([self.tabBarController isKindOfClass:[NXMasterTabBarViewController class]]) {
            NXProjectTabBarController *projectTabBar = [[NXProjectTabBarController alloc] initWithProject:self.fromProjectModel];
            projectTabBar.preTabBarController = (NXMasterTabBarViewController *)self.tabBarController;
            [self.tabBarController.navigationController pushViewController:projectTabBar animated:YES];
            projectTabBar.selectedIndex = kProjectTabBarDefaultSelectedIndex;
            [self.navigationController popViewControllerAnimated:NO];
        }
    }else {
         [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark ------> search
- (void)searchItemClicked:(id)sender {
    [self hiddenNavigatinBarItems];
    
    NXProjectSearchResultVC *resultVC = [[NXProjectSearchResultVC alloc] init];
    resultVC.delegate = self;
    resultVC.resignActiveDelegate = self;
    
    NXSearchViewController *searchVC = [[NXSearchViewController alloc] initWithSearchResultsController:resultVC];
    
    searchVC.updateDelegate = self;
    searchVC.searchBar.barStyle = UIBarStyleDefault;
    if (@available(iOS 13.0, *)){
        NSMutableAttributedString *placeholderString = [[NSMutableAttributedString alloc] initWithString: NSLocalizedString(@"UI_SEARCH_PROJECT_NAME", NULL) attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:14.0]}];
           searchVC.searchBar.searchTextField.attributedPlaceholder = placeholderString;
    }else{
        UITextField *textfield = [searchVC.searchBar valueForKey:@"_searchField"];
        [textfield setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
        [textfield setValue:[UIFont systemFontOfSize:14.0] forKeyPath:@"_placeholderLabel.font"];
        searchVC.searchBar.placeholder = NSLocalizedString(@"UI_SEARCH_PROJECT_NAME", NULL);
    }
    [searchVC.searchBar sizeToFit];
    searchVC.searchBar.translucent = YES;
    [searchVC.searchBar setSearchFieldBackgroundImage:[self GetImageWithColor:[UIColor colorWithWhite:1.0 alpha:0.5] andHeight:26] forState:UIControlStateNormal];
    searchVC.hidesNavigationBarDuringPresentation = NO;

    self.navigationController.extendedLayoutIncludesOpaqueBars = NO;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.definesPresentationContext = YES;
    
    self.searchVC = searchVC;
    //self.navigationItem.titleView = self.searchVC.searchBar;
    self.navigationItem.titleView = self.searchVC.searchBar;
    
    [self.searchVC.searchBar becomeFirstResponder];
}
#pragma mark ------> sort by
- (void)ellipsisItemClicked:(UIBarButtonItem *)sender {
    NXFilterViewController *filterVC = [[NXFilterViewController alloc]init];
    filterVC.providesPresentationContextTransitionStyle = true;
    filterVC.definesPresentationContext = true;
    filterVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    filterVC.segmentItems = self.allSortByTypes;
    filterVC.selectedSortType = self.currentSortBy_type;
    filterVC.delegate = self;
    [self presentViewController:filterVC animated:YES completion:nil];
}
#pragma mark ------>  project total number view
- (void)commonInitProjectTotalNumView {
    UIView *headBgView = [[UIView alloc]init];
    headBgView.backgroundColor = RMC_MAIN_COLOR;
    self.headerView = headBgView;
    [self.view addSubview:headBgView];
    NXProjectTotalNumView *pendingView = [[NXProjectTotalNumView alloc]initWithProjectNumber:[NSNumber numberWithInteger:self.pendingArray.count] andProjectType:NXProjectTotalNumViewTypeForPending];
    [headBgView addSubview:pendingView];
    pendingView.clickBgViewFinishedBlock = ^(NSError *error) {
        if (self.collectionView && self.pendingArray.count > 0) {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
        }
    };
    NXProjectTotalNumView *byMeView = [[NXProjectTotalNumView alloc]initWithProjectNumber:[NSNumber numberWithInteger:self.isAddCreateItem ? self.byMeArray.count -1 : self.byMeArray.count ] andProjectType:NXProjectTotalNumViewTypeForByMe];
    [headBgView addSubview:byMeView];
    byMeView.clickBgViewFinishedBlock = ^(NSError *error) {
        if (self.collectionView && self.byMeArray.count > 0) {
            if (self.pendingArray.count > 0) {
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
            }else {
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
            }
        }
    };
    NXProjectTotalNumView *byOtherView = [[NXProjectTotalNumView alloc]initWithProjectNumber:[NSNumber numberWithInteger:self.byOtherArray.count] andProjectType:NXProjectTotalNumViewTypeForByOthers];
    [headBgView addSubview:byOtherView];
    byOtherView.clickBgViewFinishedBlock = ^(NSError *error) {
        if (self.collectionView && self.byOtherArray.count > 0) {
            if (self.pendingArray.count > 0 && self.byMeArray.count > 0) {
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
            }else if (self.pendingArray.count < 1 && self.byMeArray.count < 1) {
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
            }else {
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
            }
        }
    };
    NSArray *viewArray = @[pendingView,byMeView,byOtherView].copy;
    [viewArray mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headBgView).offset(20);
    }];
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [headBgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.right.left.equalTo(self.view);
            }];
            [viewArray mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(20);
                make.bottom.equalTo(self.headerView.mas_bottom).offset(-10);
            }];
        }
    }else {
        [headBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.left.equalTo(self.view);
        }];
        [viewArray mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuideBottom).offset(20);
            make.bottom.equalTo(self.headerView.mas_bottom).offset(-10);
        }];
    }
    [viewArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:8 leadSpacing:8 tailSpacing:8];
}


- (void)commonInitProjectDetailInfoViewByCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(20,0,20,0);
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    collectionView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerClass:[NXInviteMessageCell class] forCellWithReuseIdentifier:@"PendingCell"];
    [collectionView registerClass:[NXAllProjectDetailCell class] forCellWithReuseIdentifier:@"ProjectCell"];
    [collectionView registerClass:[NXAllProjectAddItemCell class] forCellWithReuseIdentifier:@"AddItemCell"];
    [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header"];
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.headerView.mas_bottom).offset(10);
                make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).offset(10);
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).offset(-10);
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            }];
        }
    }else {
        [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.headerView.mas_bottom).offset(10);
            make.left.equalTo(self.view).offset(10);
            make.right.equalTo(self.view).offset(-10);
            make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
        }];
    }
}
#pragma mark ---- > collectionView delegate and dataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.projectDicArray.count;
}
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSDictionary *dic = self.projectDicArray[section];
    NSString *key = [dic allKeys].firstObject;
    NSArray *projectArray = dic[key];
    return projectArray.count;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.projectDicArray[indexPath.section];
    NSString *key = [dic allKeys].firstObject;
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"Header" forIndexPath:indexPath];
        UILabel *label = [[UILabel alloc]init];
        label.frame = CGRectMake(5, 0, 300, 30);
    label.backgroundColor = self.view.backgroundColor;
        [header addSubview:label];
    if ([key isEqualToString:@"pending"]) {
        label.frame = CGRectZero;
    }else if ([key isEqualToString:@"byMe"]) {
        NSString *meStr = NSLocalizedString(@"UI_HOMEVC_PROJECT_BY_ME", NULL);
        label.attributedText = [self createAttributeString:NSLocalizedString(@"UI_HOMEVC_PROJECT_CREATED", NULL) subTitle1:[NSString stringWithFormat:@" %@",meStr] subTitle2:[NSString stringWithFormat:@" (%ld)",self.isAddCreateItem ? self.byMeArray.count - 1 : self.byMeArray.count]];
    }else if ([key isEqualToString:@"byOther"]) {
        NSString *otherStr = NSLocalizedString(@"UI_HOMEVC_PROJECT_BY_OTHER", NULL);
        label.attributedText = [self createAttributeString:NSLocalizedString(@"UI_HOMEVC_PROJECT_INVITED", NULL) subTitle1:[NSString stringWithFormat:@" %@",otherStr] subTitle2:[NSString stringWithFormat:@" (%ld)",self.byOtherArray.count]];
    }
        return header;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.projectDicArray[indexPath.section];
    NSString *key = [dic allKeys].firstObject;
    if ([key isEqualToString:@"pending"]) {
      NXInviteMessageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PendingCell" forIndexPath:indexPath];
        NXPendingProjectInvitationModel *invitation = self.pendingArray[indexPath.row];
        cell.model = invitation;
        WeakObj(cell);
        cell.clickAcceptFinishedBlock = ^(NSError *err) {
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
        cell.clickIgnoreFinishedBlock = ^(NSError *err) {
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
                                [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_DECLINE_INVITATION_SUCCESS", nil) toView:collectionView hideAnimated:YES afterDelay:kDelay];
                        }else {
                            [NXMBManager showMessage:error.localizedDescription?:NSLocalizedString(@"MSG_COM_DECLINE_INVITATION_FAILED", nil) toView:collectionView hideAnimated:YES afterDelay:kDelay];
                        }
                    });
                }];
                [alertView dismiss];
            }];
            [msgView show];
        };
        return cell;
    }
    if (buildFromSkyDRMEnterpriseTarget && [NXCommonUtils isCompanyAccountLogin]) {
        
    }else{
        if ([key isEqualToString:@"byMe"] && indexPath.row == 0){
            
            NXAllProjectAddItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AddItemCell" forIndexPath:indexPath];
            return cell;
        }
    }
    NXAllProjectDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProjectCell" forIndexPath:indexPath];
        if ([key isEqualToString:@"byMe"]) {
            cell.model = self.byMeArray[indexPath.row];
        }else {
            cell.model = self.byOtherArray[indexPath.row];
        }
        return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    NSDictionary *dic = self.projectDicArray[section];
    NSString *key = [dic allKeys].firstObject;
    if ([key isEqualToString:@"pending"]) {
        return CGSizeZero;
    }else {
        return CGSizeMake(collectionView.bounds.size.width, 30);
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.projectDicArray[indexPath.section];
    NSString *key = [dic allKeys].firstObject;
    if ([key isEqualToString:@"pending"]) {
       return CGSizeMake(collectionView.bounds.size.width, 100);
    }else {
       return CGSizeMake(collectionView.bounds.size.width, 80);
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.projectDicArray[indexPath.section];
    NSString *key = [dic allKeys].firstObject;
    if ([key isEqualToString:@"pending"]) {
        return;
    }else if ([key isEqualToString:@"byMe"] && indexPath.row == 0 && self.isAddCreateItem) {
            NXNewProjectVC *projectVC = [[NXNewProjectVC alloc] init];
            projectVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:projectVC animated:YES];
        return;
    }
    NSArray *projectArray = dic[key];
    NXProjectModel *model = projectArray[indexPath.row];
    NXProjectFilesVC *filesVC = [[NXProjectFilesVC alloc] init];
    filesVC.projectModel = model;
    [self.navigationController pushViewController:filesVC animated:NO];
//    NXProjectTabBarController *projectTabBar = [[NXProjectTabBarController alloc]initWithProject:model];
//    projectTabBar.preTabBarController = (NXMasterTabBarViewController *)self.tabBarController;
//    [self.tabBarController.navigationController pushViewController:projectTabBar animated:YES];
//    projectTabBar.selectedIndex = kProjectTabBarDefaultSelectedIndex;
//    [self.navigationController popViewControllerAnimated:NO];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark --->sort by createdTime
- (NSMutableArray *)sortByKey:(NSString *)key fromArray:(NSArray *)array {
    NSMutableArray * resultArray = [NSMutableArray arrayWithArray:array];
    
    NSSortDescriptor *sortCreateTime = [[NSSortDescriptor alloc] initWithKey:key ascending:NO];
    [resultArray sortUsingDescriptors:@[sortCreateTime]];
    return resultArray;
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
#pragma mark ----->filterVC delegate
- (void)filterViewController:(NXFilterViewController *)filterVC changeVauleSortTpye:(NSInteger)sortType {
    self.currentSortBy_type = sortType;
    self.sortOption = sortType;
}

- (void)setSortOption:(NXSortOption)sortOption {
    if ([self.byMeArray containsObject:@"addItem"]) {
        [self.byMeArray removeObject:@"addItem"];
    }
    switch (sortOption) {
        case NXSortOptionNameAscending:{
            NSMutableArray * byMeResultArray = [NSMutableArray arrayWithArray:self.byMeArray];
            NSSortDescriptor *byMeName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)];
            [byMeResultArray sortUsingDescriptors:@[byMeName]];
            self.byMeArray = byMeResultArray;
            
            NSMutableArray * byOtherResultArray = [NSMutableArray arrayWithArray:self.byOtherArray];
            NSSortDescriptor *byOtherName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)];
            [byOtherResultArray sortUsingDescriptors:@[byOtherName]];
            self.byOtherArray = byOtherResultArray;
            
            NSMutableArray * byPendingResultArray = [NSMutableArray arrayWithArray:self.pendingArray];
            NSSortDescriptor *byPendingName = [[NSSortDescriptor alloc] initWithKey:@"projectInfo.name" ascending:YES selector:@selector(localizedStandardCompare:)];
            [byPendingResultArray sortUsingDescriptors:@[byPendingName]];
            self.pendingArray = byPendingResultArray;
        }
            break;
        case NXSortOptionNameDescending:
        {
            NSMutableArray * byMeResultArray = [NSMutableArray arrayWithArray:self.byMeArray];
            NSSortDescriptor *byMeName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO selector:@selector(localizedStandardCompare:)];
            [byMeResultArray sortUsingDescriptors:@[byMeName]];
            self.byMeArray = byMeResultArray;
            NSMutableArray * byOtherResultArray = [NSMutableArray arrayWithArray:self.byOtherArray];
            NSSortDescriptor *byOtherName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO selector:@selector(localizedStandardCompare:)];
            [byOtherResultArray sortUsingDescriptors:@[byOtherName]];
            self.byOtherArray = byOtherResultArray;
            
            NSMutableArray * byPendingResultArray = [NSMutableArray arrayWithArray:self.pendingArray];
            NSSortDescriptor *byPendingName = [[NSSortDescriptor alloc] initWithKey:@"projectInfo.name" ascending:NO selector:@selector(localizedStandardCompare:)];
            [byPendingResultArray sortUsingDescriptors:@[byPendingName]];
            self.pendingArray = byPendingResultArray;
        }
            break;
        case NXSortOptionModifiedDate:
        {
            self.byMeArray = [self sortByKey:@"lastActionTime" fromArray:self.byMeArray];
            self.byOtherArray = [self sortByKey:@"lastActionTime" fromArray:self.byOtherArray];
            
            NSMutableArray * byPendingResultArray = [NSMutableArray arrayWithArray:self.pendingArray];
            NSSortDescriptor *byPendingTime = [[NSSortDescriptor alloc] initWithKey:@"inviteTime" ascending:NO];
            [byPendingResultArray sortUsingDescriptors:@[byPendingTime]];
            self.pendingArray = byPendingResultArray;
        }
        default:
            break;
    }
    if (self.isAddCreateItem) {
        [self.byMeArray insertObject:@"addItem" atIndex:0];
    }
    [self.projectDicArray removeAllObjects];
    if (self.pendingArray.count > 0) {
        NSDictionary *dic = @{@"pending":self.pendingArray}.copy;
        [self.projectDicArray addObject:dic];
    }
    if (self.byMeArray.count > 0) {
        NSDictionary *dic = @{@"byMe":self.byMeArray}.copy;
        [self.projectDicArray addObject:dic];
    }
    
    if (self.byOtherArray.count > 0) {
        NSDictionary *dic = @{@"byOther":self.byOtherArray}.copy;
        [self.projectDicArray addObject:dic];
    }
    [self updateUILayout];
}

- (void)hiddenNavigatinBarItems
{
    if ([NXCommonUtils isiPad]) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onTapCancelButton:)];
        self.navigationItem.rightBarButtonItems = @[cancelButton];
    }else
    {
        self.navigationItem.rightBarButtonItems = nil;
    }
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.title = nil;
}
- (void)onTapCancelButton:(id)sender
{
    [self commonInitNavgationBar];
    self.searchVC.active = NO;
    [self.searchVC.searchBar removeFromSuperview];
    self.searchVC = nil;
}
#pragma mark  - NXSearchVCUpdateDelegate

- (void)updateSearchResultsForSearchController:(NXSearchViewController *)vc resultSeachVC:(NXSearchResultViewController *)resultVC
{
    NSString *searchString = [vc.searchBar text];
    if (![searchString isEqualToString:@""]) {
        NSArray *data;
        NSPredicate *preicate;
        
        data = [self getSearchDataSource];
        preicate = [NSPredicate predicateWithFormat:@"self.name contains [cd] %@", searchString];
        
        resultVC.dataArray = [[NSArray alloc] initWithArray:[data filteredArrayUsingPredicate:preicate]];
    }
    else
    {
        resultVC.dataArray = nil;
    }
    
    [resultVC updateData];
}

- (void)searchControllerWillPresent:(NXSearchViewController *)searchController
{
    dispatch_async(dispatch_get_main_queue(),^{
        [self.searchVC.searchBar becomeFirstResponder];
    });
}

- (void)searchControllerWillDissmiss:(NXSearchViewController *)searchController
{
    [self commonInitNavgationBar];
    [self.searchVC.searchBar removeFromSuperview];
    self.searchVC = nil;
}

- (void)cancelButtonClicked:(NXSearchViewController *)searchController;
{
    dispatch_async(dispatch_get_main_queue(),^{
        [searchController.searchBar resignFirstResponder];
    });
}

- (void)searchVCShouldResignActive
{
    [self.searchVC setActive:NO];
    [self.searchVC.searchBar removeFromSuperview];
    self.searchVC = nil;
    [self commonInitNavgationBar];
}
#pragma -mark NXSearchDataSourceProtocol
- (NSArray *)getSearchDataSource {
    NSArray *searchArray = [NSArray array];
    NSMutableArray *realByMeArray = [[NSMutableArray alloc]initWithArray:self.byMeArray];
    if ([realByMeArray containsObject:@"addItem"]) {
        [realByMeArray removeObject:@"addItem"];
    }
    searchArray = [searchArray arrayByAddingObjectsFromArray:self.pendingArray];
    searchArray = [searchArray arrayByAddingObjectsFromArray:realByMeArray];
    searchArray = [searchArray arrayByAddingObjectsFromArray:self.byOtherArray];
    return searchArray;
}
#pragma mark ------> search delegate
- (void)projectListResultVC:(NXProjectSearchResultVC *)resultVC didSelectItem:(id)item {
    [resultVC.view removeFromSuperview];
    [self showProjectFilesPageWithModel:item];
    [self onTapCancelButton:nil];
    
//    NXProjectTabBarController *projectTabBar = [[NXProjectTabBarController alloc]initWithProject:item];
//    projectTabBar.preTabBarController = (NXMasterTabBarViewController *)self.tabBarController;
//    [self.tabBarController.navigationController pushViewController:projectTabBar animated:YES];
//    projectTabBar.selectedIndex = kProjectTabBarDefaultSelectedIndex;
//    [self.navigationController popViewControllerAnimated:NO];
}
- (void)projectListResultVC:(NXProjectSearchResultVC *)resultVC didClickPendingAcceptButton:(id)item {
    [resultVC.view removeFromSuperview];
    [self onTapCancelButton:nil];
    [NXMBManager showLoadingToView:self.collectionView];
    [[NXLoginUser sharedInstance].myProject acceptProjectInvitation:item withCompletion:^(NXProjectModel *project,NSTimeInterval serverTime,NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error.code == NXRMC_ERROR_ACCEPT_PROJECT_INVITATION_EXPIRED) {
                [NXMBManager hideHUDForView:self.collectionView];
                [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_INVITATION_EXPIRED",NULL) toView:self.collectionView hideAnimated:YES afterDelay:kDelay];
                return ;
            }
            if (!error) {
                [NXMBManager hideHUDForView:self.collectionView];
                [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_ACCEPT_INVITATION_SUCCESS", nil) toView:self.collectionView hideAnimated:YES afterDelay:kDelay];
                
            } else {
                [NXMBManager hideHUDForView:self.collectionView];
                [NXMBManager showMessage:error.localizedDescription?: NSLocalizedString(@"MSG_COM_ACCEPT_INVITATION_FAILED", nil) toView:self.collectionView hideAnimated:YES afterDelay:kDelay];
            }
            
        });
        
    }];
}
- (void)projectListResultVC:(NXProjectSearchResultVC *)resultVC didClickPendingDeclineAccessButton:(id)item {
    [resultVC.view removeFromSuperview];
    [self onTapCancelButton:nil];
    NXProjectDeclineMsgView *msgView = [[NXProjectDeclineMsgView alloc]initWithTitle:NSLocalizedString(@"MSG_COM_DECLINE_PROJECT_INVITATION_WARNING", nil) inviteHander:^(NXProjectDeclineMsgView *alertView) {
        NSString *declineReason = alertView.reasonStr;
        if ([declineReason isEqualToString:@""] || declineReason == nil) {
            declineReason = @"";
        }
        [NXMBManager showLoadingToView:self.collectionView];
        [[NXLoginUser sharedInstance].myProject declineProjectInvitation:item forReason:declineReason withCompletion:^(NXPendingProjectInvitationModel *pendingInvitation, NSTimeInterval serverTime, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [NXMBManager hideHUDForView:self.collectionView];
                if (!error) {
                    [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_DECLINE_INVITATION_SUCCESS", nil) toView:self.collectionView hideAnimated:YES afterDelay:kDelay];
                }else {
                    [NXMBManager showMessage:error.localizedDescription?:NSLocalizedString(@"MSG_COM_DECLINE_INVITATION_FAILED", nil) toView:self.collectionView hideAnimated:YES afterDelay:kDelay];
                }
            });
        }];
        [alertView dismiss];
    }];
    [msgView show];
}

- (UIImage*) GetImageWithColor:(UIColor*)color andHeight:(CGFloat)height
{
    CGRect r= CGRectMake(0.0f, 0.0f, 1.0f, height);
    UIGraphicsBeginImageContext(r.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, r);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}
- (void)deviceOrientationDidChange:(id)sender {
    [self.collectionView reloadData];
    
}
- (void)showProjectFilesPageWithModel:(NXProjectModel *)currentModel{
    if (!currentModel) {
        return;
    }
    NXProjectFilesVC *filesVC = [[NXProjectFilesVC alloc] init];
    filesVC.projectModel = currentModel;
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self.navigationController pushViewController:filesVC animated:NO];
}
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NXLoginUser sharedInstance].myProject pauseSyncProjectInfo];
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
