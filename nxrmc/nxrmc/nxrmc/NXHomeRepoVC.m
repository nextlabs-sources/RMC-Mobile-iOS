//
//  NXHomeRepoVC.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2020/9/10.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXHomeRepoVC.h"
#import "NXRepoFilesNavigationController.h"
#import "NXRepoFilesViewController.h"
#import "NXFileListSearchResultVC.h"
#import "MyVaultSeachResultViewController.h"
#import "NXFilterViewController.h"
#import "UIView+UIExt.h"
#import "Masonry.h"
#import "NXPageSelectMenuView.h"
#import "NXCommonUtils.h"
#import "NXFileSort.h"
#import "NXNetworkHelper.h"
#import "NXRepositoryModel.h"

@interface NXHomeRepoVC ()<NXPageSelectMenuViewDelegate,NXSearchVCUpdateDelegate,NXSearchVCResignActiveDelegate>

@property(nonatomic, strong) NSMutableArray *childVCArray;
@property(nonatomic, strong) NXPageSelectMenuView *menuView;
@property(nonatomic, strong) NXSearchViewController *searchVC;
@property(nonatomic, strong) UIView *contentView;
@property(nonatomic, strong) UIBarButtonItem *searchTabBarItem;
@property(nonatomic, strong) UIBarButtonItem *ellipsisItem;
@property(nonatomic,weak) id<NXSearchDataSourceProtocol> currentSelectVC;
@property(nonatomic, strong) NSArray *titleArray;
@property(nonatomic, strong) UIBarButtonItem *navigationBarselectAllButton;
@property(nonatomic, strong) UIBarButtonItem *navigationBarCancelButton;

@end

@implementation NXHomeRepoVC

- (NXRepoFilesNavigationController *)fileListNav {
    if (!_fileListNav) {
        _fileListNav = [[NXRepoFilesNavigationController alloc] init];
        _fileListNav.currentFolder = [[NXLoginUser sharedInstance].myRepoSystem rootFolderForRepo:self.currentRepoModel];
    }
    return _fileListNav;
}



- (NXRepoFilesNavigationController *)onlyprotectedfileListNav {
    if (!_onlyprotectedfileListNav) {
        _onlyprotectedfileListNav = [[NXRepoFilesNavigationController alloc] init];
        _onlyprotectedfileListNav.currentFolder = [[NXLoginUser sharedInstance].myRepoSystem rootFolderForRepo:self.currentRepoModel];
        _onlyprotectedfileListNav.isOnlyNxlFile = YES;
    }
    return _onlyprotectedfileListNav;
}

-(NSMutableArray *)childVCArray{
    if (!_childVCArray) {
        _childVCArray = [NSMutableArray array];
    }
    return _childVCArray;
}

- (void)setCurrentPageIndex:(NSInteger)currentPageIndex {
    [self.menuView setCurrentIndex:currentPageIndex];
    _currentPageIndex = currentPageIndex;
}
- (void)setSelectPageIndex:(NSInteger)selectPageIndex {
    [self.menuView setSelectIndex:selectPageIndex];
    _currentPageIndex = selectPageIndex;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //UINavigationBar
    [self configureNavigationBar];
    [self commonInit];

    // listen to the net work statues change
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NetStatusChanged:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.searchVC setActive:NO];
    
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self NetStatusChanged:nil];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.menuView addShadow:UIViewShadowPositionBottom color:[UIColor lightGrayColor]];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.searchVC setActive:NO];
}

#pragma mark ----> commonInit

- (void)commonInit {
    [self.childVCArray addObject:self.fileListNav];
    [self.childVCArray addObject:self.onlyprotectedfileListNav];
    self.titleArray = @[NSLocalizedString(@"UI_MENU_ALL_FILES",NULL),
                         NSLocalizedString(@"UI_MYVAULT_PROTECTED", NULL)];
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIView *greenBgView =[[UIView alloc]init];
    greenBgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:greenBgView];
    [greenBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@20);
    }];
    
    NXPageSelectMenuView *menuView = [[NXPageSelectMenuView alloc]initWithFrame:self.navigationController.view.frame andItems:self.titleArray];
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
    
    self.currentPageIndex = self.menuView.currentIndex;
    [self addChildViewControllerToFilesViewControllerWithIndex:self.currentPageIndex];
}

#pragma mark - init navigationBar
- (void)configureNavigationBar
{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(backToAllRepoPage:)];
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search - black"] style:UIBarButtonItemStylePlain target:self action:@selector(searchItemClicked:)];
     backItem.accessibilityValue = @"BACK_BAR_ITEM";
    searchItem.accessibilityValue = @"SEARCH_BAR_ITEM";
    UIBarButtonItem *ellipsisItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ellipsis - black"] style:UIBarButtonItemStylePlain target:self action:@selector(ellipsisItemClicked:)];
    ellipsisItem.accessibilityValue = @"ELLIPSIS_BAR_ITEM";
    self.searchTabBarItem = searchItem;
    self.ellipsisItem = ellipsisItem;
    self.navigationItem.leftBarButtonItems = @[backItem];
    self.navigationItem.rightBarButtonItems = @[searchItem,ellipsisItem];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationItem.titleView = [self getTitleView];
   
    self.navigationController.extendedLayoutIncludesOpaqueBars = YES;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.definesPresentationContext = NO;
}
- (UIView *)getTitleView{
    UIView *titleView = [[UIView alloc] init];
    UIImageView *repoImageView = [[UIImageView alloc] initWithImage:[NXCommonUtils getRepoIconByRepoType:self.currentRepoModel.service_type.integerValue]];
    repoImageView.contentMode = UIViewContentModeScaleAspectFit;
    [titleView addSubview:repoImageView];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = self.currentRepoModel.service_alias;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [titleView addSubview:titleLabel];
    UIImageView *providerClassIcon = [[UIImageView alloc] initWithImage:[NXCommonUtils getProviderIconByRepoProviderClass:self.currentRepoModel.service_providerClass]];
     providerClassIcon.contentMode = UIViewContentModeScaleAspectFit;
    [titleView addSubview:providerClassIcon];
     
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(titleView);
        make.height.equalTo(@25);
        make.width.equalTo(titleView).multipliedBy(0.5);
    }];
    [repoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(titleLabel.mas_left).offset(-5);
        make.centerY.equalTo(titleView);
        make.height.width.equalTo(@25);
    }];
    [providerClassIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel.mas_right).offset(5);
           make.centerY.equalTo(titleView);
           make.height.width.equalTo(@25);
       }];
    return titleView;
}

- (void)backToAllRepoPage:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)ellipsisItemClicked:(UIBarButtonItem *)sender {
    NXFilterViewController *filterVC = [[NXFilterViewController alloc]init];
    filterVC.providesPresentationContextTransitionStyle = true;
    filterVC.definesPresentationContext = true;
    filterVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    if ([self.childVCArray[self.currentPageIndex] isKindOfClass:[NXRepoFilesNavigationController class]]) {
        filterVC.isSupportRepo = YES;
    } else {
        filterVC.isSupportRepo = NO;
    }
    
    filterVC.delegate = self;
    // not change
    NSMutableArray *sortByInfos = [self allSortByTypesAndCurrentSortByType];
    if (sortByInfos) {
        filterVC.selectedSortType = [sortByInfos.firstObject integerValue];
        filterVC.segmentItems = sortByInfos.lastObject;
    }
    [self presentViewController:filterVC animated:YES completion:nil];
}
- (void)searchItemClicked:(id)sender {
    NXSearchResultViewController *resultVC = nil;
    if ([self.currentSelectVC isKindOfClass:[NXRepoFilesViewController class]]) {
        resultVC = [[NXFileListSearchResultVC alloc] init];
        resultVC.searchFromFavoritePage = NO;
        if (self.currentPageIndex == 0) {
            ((NXFileListSearchResultVC *)resultVC).delegate = self.fileListNav.viewControllers.lastObject;
            
        }else{
            ((NXFileListSearchResultVC *)resultVC).delegate = self.onlyprotectedfileListNav.viewControllers.lastObject;
        }
       
    }
    else {
        return;
    }
    
    [self hiddenNavigatiBarItems];
    
    NXSearchViewController *searchVC = [[NXSearchViewController alloc] initWithSearchResultsController:resultVC];
    searchVC.updateDelegate = self;
    resultVC.resignActiveDelegate = self;
   
    searchVC.searchBar.placeholder = NSLocalizedString(@"UI_BEGIN_YOUR_SEARCH", NULL);
    [searchVC.searchBar sizeToFit];
    searchVC.hidesNavigationBarDuringPresentation = NO;
    
    self.navigationController.extendedLayoutIncludesOpaqueBars = NO;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.definesPresentationContext = YES;
    
    self.searchVC = searchVC;
    //self.navigationItem.titleView = self.searchVC.searchBar;
    self.navigationItem.titleView = self.searchVC.searchBar;
    [self.searchVC.searchBar becomeFirstResponder];
}

#pragma -mark  NXSearchVCUpdateDelegate

- (void)updateSearchResultsForSearchController:(NXSearchViewController *)vc resultSeachVC:(NXSearchResultViewController *)resultVC
{
    NSString *searchString = [vc.searchBar text];
    if (![searchString isEqualToString:@""]) {
        
        NSArray *data = [self.currentSelectVC getSearchDataSource];
        
        // filter ...a
        NSPredicate *preicate = [NSPredicate predicateWithFormat:@"self.name contains [cd] %@", searchString];
        resultVC.dataArray = [[NSArray alloc] initWithArray:[data filteredArrayUsingPredicate:preicate]];
        [resultVC updateData];
    }
    else
    {
        // TODO
    }

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
        NXRepoFilesNavigationController *nav = [vcList objectAtIndex:currentIndex];
        return nav.viewControllers.lastObject;
    } else {
        NXRepoFilesNavigationController *nav = [vcList objectAtIndex:currentIndex];
        return nav.viewControllers.lastObject;
    }
    return nil;
}


#pragma mark ----> select menu delegate
- (void)withNXPageSelectMenuView:(NXPageSelectMenuView *)selectMenuView selectMenuButtonClicked:(UIButton *)sender {
    self.currentPageIndex = self.menuView.currentIndex;
    [self addChildViewControllerToFilesViewControllerWithIndex:self.currentPageIndex];
}


- (void)hiddenNavigatiBarItems
{
    if ([NXCommonUtils isiPad]) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onTapCancelButton:)];
        self.navigationItem.rightBarButtonItems = @[cancelButton];
    }else
    {
        self.navigationItem.rightBarButtonItems = nil;
    }

    self.navigationItem.leftBarButtonItem  = nil;
    self.navigationItem.hidesBackButton = YES;
}

- (void)onTapCancelButton:(id)sender
{
    [self configureNavigationBar];
    self.searchVC.active = NO;
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


#pragma mark - NXFilterViewControllerDelegate
- (void)filterViewController:(NXFilterViewController *)filterVC changeVauleSortTpye:(NSInteger)sortType {
    UIViewController * currentVC = self.childVCArray[self.currentPageIndex];
    if ([currentVC isKindOfClass:[NXRepoFilesNavigationController class]]) {
        NXRepoFilesNavigationController *repofileNav = (NXRepoFilesNavigationController *)currentVC;
        repofileNav.sortOption = sortType;
        NXRepoFilesViewController *lastFileVC = repofileNav.viewControllers.lastObject;
        lastFileVC.sortOption = sortType;
    }else if ([currentVC isKindOfClass:[NXFileBaseViewController class]]) {
        NXFileBaseViewController *lastFileVC = (NXFileBaseViewController *)currentVC;
        lastFileVC.sortOption = sortType;
    }
}

#pragma mark ---->allSortByTypeAndCurrentSortByType
- (NSMutableArray *)allSortByTypesAndCurrentSortByType {
    NSMutableArray *array = [NSMutableArray array];
    UIViewController *currentVC = self.childVCArray[self.currentPageIndex];
    if ([currentVC isKindOfClass:[NXRepoFilesNavigationController class]]) {
        NXRepoFilesNavigationController *selectVC = (NXRepoFilesNavigationController *)currentVC;
        NXRepoFilesViewController *lastFileVC = selectVC.viewControllers.lastObject;
        [array addObject:@(lastFileVC.sortOption)];
        [array addObject:selectVC.allSortByTypes];
    }else if ([currentVC isKindOfClass:[NXFileBaseViewController class]]) {
        NXFileBaseViewController *baseVC = (NXFileBaseViewController *)currentVC;
        [array addObject:@(baseVC.sortOption)];
        [array addObject:baseVC.allSortByTypes];
    }
    return array;
}
#pragma mark ---->return size from title size
- (CGSize)sizeOfLabelWithCustomMaxWidth:(CGFloat)width systemFontSize:(CGFloat)fontSize andFilledTextString:(NSString *)str{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width, 0)];
    label.text = str;
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:fontSize];
    [label sizeToFit];
    CGSize size = label.frame.size;
    return size;
}
- (void)NetStatusChanged:(id)sender {
    __block NSInteger offLineIndex = -1;
    NSMutableArray *unableArray = [NSMutableArray array];
    [self.titleArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
       [self.menuView cancelUnableForButtions:self.titleArray];
    }
    
}
- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AFNetworkingReachabilityDidChangeNotification object:nil];
}
@end
