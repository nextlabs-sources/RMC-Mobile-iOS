//
//  NXProjectFilesVC.m
//  Demo
//
//  Created by Bill (Guobin) Zhang on 5/8/17.
//  Copyright © 2017 Bill (Guobin) Zhang. All rights reserved.
//

#import "NXProjectFilesVC.h"
#import "NXProjectFileNavViewController.h"
#import "NXProjectFileTableViewController.h"
#import "Masonry.h"
#import "NXMyProjectManager.h"
#import "NXFilterViewController.h"
#import "NXProjectsNavigationController.h"
#import "NXCommonUtils.h"
#import "NXPageSelectMenuView.h"
#import "NXProjectOfflineFileVC.h"
#import "NXFileListSearchResultVC.h"
#import "MyVaultSeachResultViewController.h"
#import "NXNetworkHelper.h"
#import "UIView+UIExt.h"
#import "NXProjectOtherFileListVC.h"
#import "NXListMembershipsAPI.h"
#import "NXMBManager.h"
@interface NXProjectFilesVC ()<NXSearchVCUpdateDelegate,NXSearchVCResignActiveDelegate,NXProjectFileListSearchResultDelegate,NXPageSelectMenuViewDelegate>
//@property(nonatomic ,strong)NSArray *allSortByTypes;
//@property(nonatomic, assign) NSInteger currentSortBy_type;

@property(nonatomic, strong) NXSearchViewController *searchVC;
@property(nonatomic, strong) NXPageSelectMenuView *menuView;
@property(nonatomic, strong) NSArray *menuTitlesArray;
@property(nonatomic, strong) NSMutableArray *childVCArray;
@property(nonatomic, strong) NXProjectOfflineFileVC *offlineVC;
@property(nonatomic, strong) UIView *contentView;
@property(nonatomic, assign) NSInteger currentPageIndex;
@end

@implementation NXProjectFilesVC
- (NSMutableArray *)childVCArray {
    if (!_childVCArray) {
        _childVCArray = [NSMutableArray array];
    }
    return _childVCArray;
}
- (NXProjectFileNavViewController *)projectFileListNav {
    if (!_projectFileListNav) {
        NXProjectFolder *rootFolder = [NXMyProjectManager rootFolderForProject:self.projectModel];
        NXProjectFileTableViewController *fileListVC = [[NXProjectFileTableViewController alloc] initWithProjectModel:self.projectModel currentFolder:rootFolder];
        _projectFileListNav = [[NXProjectFileNavViewController alloc] initWithRootViewController:fileListVC];
        _projectFileListNav.sortOption = NXSortOptionDateDescending;
    }
    return _projectFileListNav;
}
- (NXProjectOfflineFileVC *)offlineVC {
    if (!_offlineVC) {
        _offlineVC = [[NXProjectOfflineFileVC alloc]init];
        _offlineVC.projectModel = self.projectModel;
    }
    return _offlineVC;
}

- (void)checkTheProjectMemberShip {
    if (!self.projectModel.membershipId) {
        [NXMBManager showLoading];
        [[NXLoginUser sharedInstance].myProject getMemberShipID:self.projectModel withCompletion:^(NXProjectModel *projectModel, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [NXMBManager hideHUD];
                if (!error) {
                    self.projectModel.membershipId = projectModel.membershipId;
                }else{
                    [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:kDelay];
                }
            });
           
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureNavigationBar];
    // Do any additional setup after loading the view.
    // listen to the net work statues change
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NetStatusChanged:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(projectKicked:) name:NOTIFICATION_PROJECT_YOU_ARE_KICKED_OUTSIDE object:nil];
    self.view.backgroundColor = [UIColor whiteColor];
//    NSArray *otherFileTypes = [NSArray arrayWithObjects:@(NXProjectFileListByOperationTypeSharebyFiles),@(NXProjectFileListByOperationTypeShareWithFiles), nil];
    self.menuTitlesArray = @[NSLocalizedString(@"UI_MENU_ALL_FILES",NULL),
//                             NSLocalizedString(@"UI_MENU_SHARE_FROM_THIS_PROJECT", NULL),
//                             NSLocalizedString(@"UI_MENU_SHARE_WITH_THIS_PROJECT", NULL),
                             NSLocalizedString(@"UI_MENU_OFFLINE", NULL)];
    [self.childVCArray addObject:self.projectFileListNav];
//    for (NSNumber *type in otherFileTypes) {
//        NSInteger integter = [type integerValue];
//        NXProjectOtherFileListVC *otherFilesVC = [[NXProjectOtherFileListVC alloc] initWithProjectModel:self.projectModel];
//        otherFilesVC.operationType = integter;
//        [self.childVCArray addObject:otherFilesVC];
//    }
    [self.childVCArray addObject:self.offlineVC];
    
    UIView *greenBgView =[[UIView alloc]init];
    greenBgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:greenBgView];
    [greenBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@20);
    }];
    NXPageSelectMenuView *menuView = [[NXPageSelectMenuView alloc]initWithFrame:self.navigationController.view.frame andItems:self.menuTitlesArray];
    [self.view addSubview:menuView];
    self.menuView = menuView;
    menuView.delegate = self;
    
    [menuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@35);
    }];
    UIView *subContentView = [[UIView alloc]init];
    [self.view addSubview:subContentView];
    self.contentView = subContentView;
    
    [subContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(menuView.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
    }];
    _currentPageIndex = self.menuView.currentIndex;
    [self addChildViewControllerToFilesViewControllerWithIndex:_currentPageIndex];
}

#pragma mark ----> select menu delegate
- (void)withNXPageSelectMenuView:(NXPageSelectMenuView *)selectMenuView selectMenuButtonClicked:(UIButton *)sender {
    _currentPageIndex = self.menuView.currentIndex;
    [self addChildViewControllerToFilesViewControllerWithIndex:_currentPageIndex];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSTimeInterval lastActionTime = [[NSDate date] timeIntervalSince1970];
    self.projectModel.lastActionTime = lastActionTime;
    [[NXLoginUser sharedInstance].myProject activeProject:self.projectModel atLocalTime:lastActionTime * 1000];
    [self checkTheProjectMemberShip];
    [self NetStatusChanged:nil];
    [self.searchVC setActive:NO];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.menuView addShadow:UIViewShadowPositionBottom color:[UIColor lightGrayColor]];
    
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NXLoginUser sharedInstance].myProject inactiveProject:self.projectModel];
    [self.searchVC setActive:NO];
}

-(void)addChildViewControllerToFilesViewControllerWithIndex:(NSInteger)index {
   
    for (UIViewController *subVC in self.childVCArray) {
        if ([self.childViewControllers containsObject:subVC]) {
            [subVC willMoveToParentViewController:nil];
            [subVC.view removeFromSuperview];
            [subVC removeFromParentViewController];
            [subVC didMoveToParentViewController:nil];
        }
    }
    UIViewController *newVC = self.childVCArray[index];
    [newVC willMoveToParentViewController:self];
    [self addChildViewController:newVC];
    [self.contentView addSubview:newVC.view];
    [newVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
}
#pragma -mark METHOD

- (id<NXSearchDataSourceProtocol>)currentSelectVC
{
    NSArray *vcList = self.childVCArray;
    NSInteger currentIndex = self.menuView.currentIndex;
    if (currentIndex == 0) {
       NXProjectFileNavViewController *nav = [vcList objectAtIndex:currentIndex];
        return nav.viewControllers.lastObject;
    } else {
        return [vcList objectAtIndex:currentIndex];
    }
    return nil;
}
#pragma mark
- (void)search:(id)sender {
    NXSearchResultViewController *resultVC = nil;
    UIViewController *currentVC = self.childVCArray[self.currentPageIndex];
    if ([currentVC isKindOfClass:[NXProjectFileNavViewController class]]) {
        resultVC = [[NXProjectFileListSearchResultViewController alloc] init];
        ((NXProjectFileListSearchResultViewController*)resultVC).searchProjet = self.projectModel;
        ((NXProjectFileListSearchResultViewController*)resultVC).delegate = self;
    }else if ([currentVC isKindOfClass:[NXProjectOfflineFileVC class]]) {
        resultVC  = [[MyVaultSeachResultViewController alloc] init];
        resultVC.searchFromFavoritePage = NO;
        ((MyVaultSeachResultViewController *)resultVC).delegate = self.childVCArray[self.currentPageIndex];
    }else if ([currentVC isKindOfClass:[NXProjectOtherFileListVC class]]) {
        resultVC  = [[NXProjectFileListSearchResultViewController alloc] init];
        resultVC.searchFromFavoritePage = NO;
        ((NXProjectFileListSearchResultViewController *)resultVC).delegate = self.childVCArray[self.currentPageIndex];
    }
    
    [self hiddenNavigatinBarItems];
    
    resultVC.resignActiveDelegate = self;
    
    NXSearchViewController *searchVC  = [[NXSearchViewController alloc] initWithSearchResultsController:resultVC];
    
    searchVC.updateDelegate = self;
    
    searchVC.searchBar.placeholder = NSLocalizedString(@"UI_BEGIN_YOUR_SEARCH", NULL);
    searchVC.searchBar.accessibilityValue = @"SEARCH_INPUT_VIEW";
    [searchVC.searchBar sizeToFit];
    searchVC.hidesNavigationBarDuringPresentation = NO;
   
    
    self.navigationController.extendedLayoutIncludesOpaqueBars = NO;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.definesPresentationContext = YES;
    
    self.searchVC = searchVC;
    self.navigationItem.titleView = self.searchVC.searchBar;

    [self.searchVC.searchBar becomeFirstResponder];
}

- (void)more:(id)sender {
    NXFilterViewController *filterVC = [[NXFilterViewController alloc]init];
    filterVC.providesPresentationContextTransitionStyle = true;
    filterVC.definesPresentationContext = true;
    filterVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    filterVC.delegate = self;
    UIViewController *currentVC = self.childVCArray[self.currentPageIndex];
    if ([currentVC isKindOfClass:[NXProjectFileNavViewController class]]) {
        NXProjectFileNavViewController *selectVC = (NXProjectFileNavViewController *)currentVC;
        NXProjectFileTableViewController *lastFileVC = selectVC.viewControllers.lastObject;
        filterVC.selectedSortType = lastFileVC.sortOption;
        filterVC.segmentItems = lastFileVC.allSortByTypes;

    }else if ([currentVC isKindOfClass:[NXFileBaseViewController class]]) {
        NXFileBaseViewController *baseVC = (NXFileBaseViewController *)currentVC;
        filterVC.selectedSortType = baseVC.sortOption;
        filterVC.segmentItems = baseVC.allSortByTypes;
    }else if ([currentVC isKindOfClass:[NXProjectOtherFileListVC class]]) {
        NXProjectOtherFileListVC *otherVC = (NXProjectOtherFileListVC *)currentVC;
        filterVC.segmentItems = otherVC.allSortByTypes;
        filterVC.selectedSortType = otherVC.sortOption;
    }
    
    [self presentViewController:filterVC animated:YES completion:nil];
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
    [self.searchVC setActive:NO];
    [self configureNavigationBar];
}

- (void)configureNavigationBar
{
    //configure UINavigationBar
//    NXProjectsNavigationController *navigationVC = (NXProjectsNavigationController *)self.navigationController;
//    [navigationVC configureTitleView:self];

    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(backToAllProjectsPage:)];
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search - black"] style:UIBarButtonItemStylePlain target:self action:@selector(search:)];
    searchItem.accessibilityValue = @"SEARCH_BAR_ITEM";
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ellipsis - black"] style:UIBarButtonItemStylePlain target:self action:@selector(more:)];
    self.navigationItem.leftBarButtonItems = @[backItem];
    self.navigationItem.rightBarButtonItems = @[searchItem, moreItem];
    self.navigationItem.titleView = [self getTitleView];
    self.navigationController.extendedLayoutIncludesOpaqueBars = YES;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.definesPresentationContext = NO;
}
- (UIView *)getTitleView{
    UIView *titleView = [[UIView alloc] init];
    UIImageView *projectImageView = [[UIImageView alloc] init];
    projectImageView.contentMode = UIViewContentModeScaleAspectFit;
    [titleView addSubview:projectImageView];
    if (self.projectModel.isOwnedByMe) {
        projectImageView.image = [UIImage imageNamed:@"CreatedbyMe"];
    }else{
        projectImageView.image = [UIImage imageNamed:@"InvitedbyOthers"];
    }
    UILabel *titleLabel = [[UILabel alloc] init];
    
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [titleView addSubview:titleLabel];
    titleLabel.text = self.projectModel.name;
     
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(titleView);
        make.centerX.equalTo(titleView).offset(13);
        make.height.equalTo(@25);
        make.width.equalTo(titleView).multipliedBy(0.6);
    }];
    [projectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(titleLabel.mas_left).offset(-5);
        make.centerY.equalTo(titleView);
        make.height.width.equalTo(@25);
    }];
    return titleView;
}
- (void)configureNavigationRightBarButtons
{
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search - black"] style:UIBarButtonItemStylePlain target:self action:@selector(search:)];
    searchItem.accessibilityValue = @"SEARCH_BAR_ITEM";
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ellipsis - black"] style:UIBarButtonItemStylePlain target:self action:@selector(more:)];
    self.navigationItem.rightBarButtonItems = @[searchItem, moreItem];
}

#pragma mark
- (void)back:(id)sender {
    if (self.navigationController.viewControllers.count == 1) {
        [self.navigationController.tabBarController.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)backToAllProjectsPage:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark  - NXSearchVCUpdateDelegate

- (void)updateSearchResultsForSearchController:(NXSearchViewController *)vc resultSeachVC:(NXSearchResultViewController *)resultVC
{
    NSString *searchString = [vc.searchBar text];
    if (![searchString isEqualToString:@""]) {
        NSArray *data;
        NSPredicate *preicate;
         data = [self.currentSelectVC getSearchDataSource];
//        data = [((NXProjectFileTableViewController *)self.projectFileListNav.topViewController) getSearchDataSource];
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
    [self configureNavigationBar];
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
    [self configureNavigationBar];
}

#pragma mark - NXProjectFileListSearchResultDelegate
- (void)fileListResultVC:(NXProjectFileListSearchResultViewController *)resultVC didSelectItem:(NXFileBase *)item{
    if ([self.projectFileListNav.topViewController isKindOfClass:[NXProjectFileTableViewController class]]) {
        [((NXProjectFileTableViewController *)self.projectFileListNav.topViewController) fileListResultVC:resultVC didSelectItem:item];
    }
}

- (void)fileListResultVC:(NXProjectFileListSearchResultViewController *)resultVC deleteItem:(NXFileBase *)item
{
    if ([self.projectFileListNav.topViewController isKindOfClass:[NXProjectFileTableViewController class]]) {
        [((NXProjectFileTableViewController *)self.projectFileListNav.topViewController) fileListResultVC:resultVC deleteItem:item];
    }
}
- (void)fileListResultVC:(NXProjectFileListSearchResultViewController *)resultVC infoForItem:(NXFileBase *)item
{
    if ([self.projectFileListNav.topViewController isKindOfClass:[NXProjectFileTableViewController class]]) {
        [((NXProjectFileTableViewController *)self.projectFileListNav.topViewController) fileListResultVC:resultVC infoForItem:item];
    }
}
- (void)fileListResultVC:(NXProjectFileListSearchResultViewController *)resultVC propertyForItem:(NXFileBase *)item
{
    if ([self.projectFileListNav.topViewController isKindOfClass:[NXProjectFileTableViewController class]]) {
        [((NXProjectFileTableViewController *)self.projectFileListNav.topViewController) fileListResultVC:resultVC propertyForItem:item];
    }
}

- (void)fileListResultVC:(NXProjectFileListSearchResultViewController *)resultVC accessForItem:(NXFileBase *)item
{
    if ([self.projectFileListNav.topViewController isKindOfClass:[NXProjectFileTableViewController class]]) {
        [((NXProjectFileTableViewController *)self.projectFileListNav.topViewController) fileListResultVC:resultVC accessForItem:item];
    }
}

#pragma mark ----->filterVC delegate
- (void)filterViewController:(NXFilterViewController *)filterVC changeVauleSortTpye:(NSInteger)sortType {
//    self.currentSortBy_type = sortType;
    for (UIViewController *subVC in self.childViewControllers) {
        if ([subVC isKindOfClass:[NXProjectFileNavViewController class]]) {
            NXProjectFileNavViewController *currentVC = (NXProjectFileNavViewController *)subVC;
            currentVC.sortOption = sortType;
            NXProjectFileTableViewController *lastFileVC = currentVC.viewControllers.lastObject;
            lastFileVC.sortOption = sortType;
        } else if ([subVC isKindOfClass:[NXFileBaseViewController class]]) {
            NXFileBaseViewController *lastFileVC = (NXFileBaseViewController *)subVC;
            lastFileVC.sortOption = sortType;
        }else if ([subVC isKindOfClass:[NXProjectOtherFileListVC class]]) {
            NXProjectOtherFileListVC *otherVC = (NXProjectOtherFileListVC *)subVC;
            otherVC.sortOption = sortType;
        }
    }
}
- (void)NetStatusChanged:(id)sender {
    __block NSInteger offLineIndex = -1;
    NSMutableArray *unableArray = [NSMutableArray array];
    [self.menuTitlesArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:NSLocalizedString(@"UI_MENU_OFFLINE", NULL)]) {
            offLineIndex = idx;
        }else {
            [unableArray addObject:obj];
        }
    }];
    if (self.currentPageIndex == offLineIndex) {
        UIViewController *VC = self.childVCArray[offLineIndex];
        if ([VC isKindOfClass:[NXFileBaseViewController class]]) {
            NXFileBaseViewController *baseVC = (NXFileBaseViewController *)VC;
            [baseVC updateUI];
        }
    }
    if (![[NXNetworkHelper sharedInstance] isNetworkAvailable]) {
        if (offLineIndex > 0) {
            [self.menuView setUnableForButtons:unableArray andDefaultSelect:offLineIndex];
        }
        
    }else {
        [self.menuView cancelUnableForButtions:self.menuTitlesArray];
    }
    
}
- (void)projectKicked:(NSNotification *)notification{
    NSArray *projectIds = notification.userInfo[@"projectId"];
    for (NSNumber *pjtID in projectIds) {
        if (pjtID.integerValue == self.projectModel.projectId.integerValue) {
            [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:NSLocalizedString(@"MSG_PROJECT_KICKED_OUT", nil) style:UIAlertControllerStyleAlert OKActionTitle:@"OK" cancelActionTitle:nil OKActionHandle:^(UIAlertAction *action) {
                [self backToAllProjectsPage:nil];
            } cancelActionHandle:nil inViewController:[UIApplication sharedApplication].keyWindow.rootViewController position:nil];
        }
    }
}
- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AFNetworkingReachabilityDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_PROJECT_YOU_ARE_KICKED_OUTSIDE object:nil];
}
@end
