//
//  NXWorkSpaceVC.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/9/23.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXWorkSpaceVC.h"
#import "NXNetworkHelper.h"
#import "NXWorkSpaceTableViewController.h"
#import "NXWorkSpaceFileNavVC.h"
#import "NXWorkSpaceItem.h"
#import "Masonry.h"
#import "NXRMCDef.h"
#import "NXPullDownButton.h"
#import "NXFilterViewController.h"
#import "NXLoginUser.h"
#import "NXWorkSpaceFileSearchResultVC.h"
#import "NXSearchViewController.h"
#import "NXCommonUtils.h"
#import "UIImage+ColorToImage.h"
#import "NXOfflineFilesViewController.h"
#import "NXPageSelectMenuView.h"
#import "NXHomeNavigationVC.h"
@interface NXWorkSpaceVC ()<NXFilterViewControllerDelegate,NXSearchVCUpdateDelegate,NXSearchVCResignActiveDelegate,NXWorkSpaceFileListSearchResultDelegate,NXPageSelectMenuViewDelegate>
@property(nonatomic, strong)UIView *contentView;
@property(nonatomic, strong) UIBarButtonItem *addTabBarItem;
@property(nonatomic, strong) UIBarButtonItem *searchTabBarItem;
@property(nonatomic, strong) UIBarButtonItem *ellipsisItem;
@property(nonatomic, strong) NXSearchViewController *searchVC;
@property(nonatomic, strong) NXOfflineFilesViewController *offlineVC;
@property(nonatomic, strong) NSMutableArray *childVCArray;
@property(nonatomic, strong) NSArray *menuTitlesArray;
@property(nonatomic, strong) NXPageSelectMenuView *menuView;
@property(nonatomic, assign) NSInteger currentPageIndex;
@property(nonatomic, assign) BOOL isUp;
@end

@implementation NXWorkSpaceVC
- (NSMutableArray *)childVCArray {
    if (!_childVCArray) {
        _childVCArray = [NSMutableArray array];
    }
    return _childVCArray;
}
- (NXWorkSpaceFileNavVC*)fileNavVC {
    if (!_fileNavVC) {
        NXWorkSpaceFolder *workSpaceFolder = [[NXLoginUser sharedInstance].workSpaceManager rootFolderForWorkSpace];
        NXWorkSpaceTableViewController *workSpaceTableVC = [[NXWorkSpaceTableViewController alloc]initWithCurrentFolder:workSpaceFolder];
        _fileNavVC = [[NXWorkSpaceFileNavVC alloc]initWithRootViewController:workSpaceTableVC];
        _fileNavVC.sortOption = NXSortOptionDateDescending;
        
    }
    return _fileNavVC;
}
- (NXOfflineFilesViewController *)offlineVC {
    if (!_offlineVC) {
        _offlineVC = [[NXOfflineFilesViewController alloc]initWithOfflineFilesFilter:NXOfflineFileFilterWorkSpace];
    }
    return _offlineVC;
}
- (void)configureNavigationBar
{
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search - black"] style:UIBarButtonItemStylePlain target:self action:@selector(searchItemClicked:)];
    searchItem.accessibilityValue = @"SEARCH_BAR_ITEM";
    UIBarButtonItem *ellipsisItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ellipsis - black"] style:UIBarButtonItemStylePlain target:self action:@selector(ellipsisItemClicked:)];
//    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
//    self.navigationItem.leftBarButtonItems = @[leftItem];
    
    self.searchTabBarItem = searchItem;
    self.ellipsisItem = ellipsisItem;
    self.navigationItem.rightBarButtonItems = @[searchItem,ellipsisItem];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.extendedLayoutIncludesOpaqueBars = YES;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.definesPresentationContext = NO;
//    self.navigationItem.hidesBackButton = NO;
    self.navigationItem.titleView = nil;
    self.navigationItem.title = @"WorkSpace";
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netStatusChanged:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    [self configureNavigationBar];
    UIView *subContentView = [[UIView alloc]init];
    [self.view addSubview:subContentView];
    self.contentView = subContentView;
    self.menuTitlesArray = @[NSLocalizedString(@"UI_MENU_ALL_FILES",NULL),
                             NSLocalizedString(@"UI_MENU_OFFLINE", NULL)];
    [self.childVCArray addObject:self.fileNavVC];
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
    [subContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(menuView.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
//    if (IS_IPHONE_X) {
//        if (@available(iOS 11.0, *)) {
//            [subContentView mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.top.equalTo(menuView.mas_bottom);
//                make.left.right.equalTo(self.view);
//                make.bottom.equalTo(self.view);
//            }];
//        }
//    }else{
//        [subContentView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.mas_topLayoutGuideBottom);
//            make.left.right.equalTo(self.view);
//            make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
//        }];
//    }
    _currentPageIndex = self.menuView.currentIndex;
    [self addChildViewControllerToFilesViewControllerWithIndex:_currentPageIndex];
   
    
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
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.searchVC setActive:NO];
    if ([self.navigationController isKindOfClass:[NXHomeNavigationVC class]]) {
         self.navigationController.navigationBar.tintColor = [UIColor blackColor];
        self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
        //    self.navigationBar.translucent = YES;
        self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    }
    [self netStatusChanged:nil];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([self.navigationController isKindOfClass:[NXHomeNavigationVC class]]) {
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:RMC_MAIN_COLOR] forBarMetrics:UIBarMetricsDefault];
           //    self.navigationBar.translucent = YES;
           
        self.navigationController.navigationBar.backgroundColor = RMC_MAIN_COLOR;
    }
   
}
- (void)netStatusChanged:(id)sender {
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
- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AFNetworkingReachabilityDidChangeNotification object:nil];
}

- (void)ellipsisItemClicked:(id)sender {
     NXFilterViewController *filterVC = [[NXFilterViewController alloc]init];
       filterVC.providesPresentationContextTransitionStyle = true;
       filterVC.definesPresentationContext = true;
       filterVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
       filterVC.delegate = self;
       UIViewController *currentVC = self.childVCArray[self.currentPageIndex];
       if ([currentVC isKindOfClass:[NXWorkSpaceFileNavVC class]]) {
           NXWorkSpaceFileNavVC *selectVC = (NXWorkSpaceFileNavVC *)currentVC;
           NXWorkSpaceTableViewController *lastFileVC = selectVC.viewControllers.lastObject;
           filterVC.selectedSortType = lastFileVC.sortOption;
           filterVC.segmentItems = lastFileVC.allSortByTypes;

       }else if ([currentVC isKindOfClass:[NXFileBaseViewController class]]) {
           NXFileBaseViewController *baseVC = (NXFileBaseViewController *)currentVC;
           filterVC.selectedSortType = baseVC.sortOption;
           filterVC.segmentItems = baseVC.allSortByTypes;
       }
       
       [self presentViewController:filterVC animated:YES completion:nil];
}
- (void)searchItemClicked:(id)sender {
    NXSearchResultViewController *resultVC = nil;
       UIViewController *currentVC = self.childVCArray[self.currentPageIndex];
       if ([currentVC isKindOfClass:[NXWorkSpaceFileNavVC class]]) {
           resultVC = [[NXWorkSpaceFileSearchResultVC alloc] init];
           ((NXWorkSpaceFileSearchResultVC*)resultVC).delegate = self;
       }else if ([currentVC isKindOfClass:[NXOfflineFilesViewController class]]) {
           resultVC  = [[MyVaultSeachResultViewController alloc] init];
           resultVC.searchFromFavoritePage = NO;
           ((MyVaultSeachResultViewController *)resultVC).isFromWorkSpace = YES;
           ((MyVaultSeachResultViewController *)resultVC).delegate = self.childVCArray[1];
       }
       
       [self hiddenNavigatinBarItems];
       
       resultVC.resignActiveDelegate = self;
       
       NXSearchViewController *searchVC  = [[NXSearchViewController alloc] initWithSearchResultsController:resultVC];
       
       searchVC.updateDelegate = self;
    
    resultVC.resignActiveDelegate = self;
    searchVC.updateDelegate = self;
    
    searchVC.searchBar.placeholder = NSLocalizedString(@"UI_BEGIN_YOUR_SEARCH", NULL);
    searchVC.searchBar.accessibilityValue = @"SEARCH_INPUT_VIEW";
    [searchVC.searchBar sizeToFit];
    searchVC.hidesNavigationBarDuringPresentation = NO;
    
    self.navigationController.extendedLayoutIncludesOpaqueBars = NO;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.definesPresentationContext = YES;
    
    self.searchVC = searchVC;
    // self.navigationItem.titleView = self.searchVC.searchBar;
    self.navigationItem.titleView = self.searchVC.searchBar;
    
    [self.searchVC.searchBar becomeFirstResponder];
}
//- (void)back:(id)sender {
//     if (self.navigationController.viewControllers.count == 1) {
//          [self.navigationController.tabBarController.navigationController popViewControllerAnimated:YES];
//      } else {
//          [self.navigationController popViewControllerAnimated:YES];
//      }
//}
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
    self.searchVC.active = NO;
    [self configureNavigationBar];
   
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
    [self.searchVC.searchBar becomeFirstResponder];
}

- (void)searchControllerWillDissmiss:(NXSearchViewController *)searchController
{
    [self configureNavigationBar];
    self.searchVC = nil;
}

- (void)cancelButtonClicked:(NXSearchViewController *)searchController;
{
    [self configureNavigationBar];
}

- (void)searchVCShouldResignActive
{
    [self.searchVC setActive:NO];
    [self configureNavigationBar];
}

#pragma -mark METHOD

- (id<NXSearchDataSourceProtocol>)currentSelectVC
{
    NSArray *vcList = self.childVCArray;
       NSInteger currentIndex = self.menuView.currentIndex;
       if (currentIndex == 0) {
          NXWorkSpaceFileNavVC *nav = [vcList objectAtIndex:currentIndex];
           return nav.viewControllers.lastObject;
       } else {
           return [vcList objectAtIndex:currentIndex];
       }
       return nil;
}
- (CGSize)sizeOfLabelWithCustomMaxWidth:(CGFloat)width systemFontSize:(CGFloat)fontSize andFilledTextString:(NSString *)str{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width, 0)];
    label.text = str;
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:fontSize];
    [label sizeToFit];
    CGSize size = label.frame.size;
    return size;
}
#pragma mark ----->filterVC delegate
- (void)filterViewController:(NXFilterViewController *)filterVC changeVauleSortTpye:(NSInteger)sortType {
    for (UIViewController *subVC in self.childViewControllers) {
        if ([subVC isKindOfClass:[NXWorkSpaceFileNavVC class]]) {
            NXWorkSpaceFileNavVC *currentVC = (NXWorkSpaceFileNavVC *)subVC;
            currentVC.sortOption = sortType;
            NXWorkSpaceTableViewController *lastFileVC = currentVC.viewControllers.lastObject;
            lastFileVC.sortOption = sortType;
        }else if ([subVC isKindOfClass:[NXFileBaseViewController class]]) {
            NXFileBaseViewController *lastFileVC = (NXFileBaseViewController *)subVC;
            lastFileVC.sortOption = sortType;
        }
    }
}
#pragma mark ----> select menu delegate
- (void)withNXPageSelectMenuView:(NXPageSelectMenuView *)selectMenuView selectMenuButtonClicked:(UIButton *)sender {
    _currentPageIndex = self.menuView.currentIndex;
    [self addChildViewControllerToFilesViewControllerWithIndex:_currentPageIndex];
}
#pragma mark - NXProjectFileListSearchResultDelegate
- (void)fileListResultVC:(NXWorkSpaceFileSearchResultVC *)resultVC didSelectItem:(NXFileBase *)item{
    if ([self.fileNavVC.topViewController isKindOfClass:[NXWorkSpaceTableViewController class]]) {
        [((NXWorkSpaceTableViewController *)self.fileNavVC.topViewController) fileListResultVC:resultVC didSelectItem:item];
    }
}

- (void)fileListResultVC:(NXWorkSpaceFileSearchResultVC *)resultVC deleteItem:(NXFileBase *)item
{
    if ([self.fileNavVC.topViewController isKindOfClass:[NXWorkSpaceTableViewController class]]) {
        [((NXWorkSpaceTableViewController *)self.fileNavVC.topViewController) fileListResultVC:resultVC deleteItem:item];
    }
}
- (void)fileListResultVC:(NXWorkSpaceFileSearchResultVC *)resultVC infoForItem:(NXFileBase *)item
{
    if ([self.fileNavVC.topViewController isKindOfClass:[NXWorkSpaceTableViewController class]]) {
        [((NXWorkSpaceTableViewController *)self.fileNavVC.topViewController) fileListResultVC:resultVC infoForItem:item];
    }
}
- (void)fileListResultVC:(NXWorkSpaceFileSearchResultVC *)resultVC propertyForItem:(NXFileBase *)item
{
    if ([self.fileNavVC.topViewController isKindOfClass:[NXWorkSpaceTableViewController class]]) {
        [((NXWorkSpaceTableViewController *)self.fileNavVC.topViewController) fileListResultVC:resultVC propertyForItem:item];
    }
}

- (void)fileListResultVC:(NXWorkSpaceFileSearchResultVC *)resultVC accessForItem:(NXFileBase *)item
{
    if ([self.fileNavVC.topViewController isKindOfClass:[NXWorkSpaceTableViewController class]]) {
        [((NXWorkSpaceTableViewController *)self.fileNavVC.topViewController) fileListResultVC:resultVC accessForItem:item];
    }
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
