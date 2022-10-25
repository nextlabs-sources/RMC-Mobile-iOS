//
//  NXSharedWithMeContainerVC.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2020/9/8.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXSharedWithMeContainerVC.h"
#import "NXMyDriveViewController.h"
#import "NXMyDriveFilesNavigatonVC.h"
#import "NXMyDriveFilesListVC.h"
#import "NXMyDriveFavoritesVC.h"
#import "NXMyDriveOfflineFilesVC.h"
#import "NXFilterViewController.h"
#import "NXPageSelectMenuView.h"
#import "Masonry.h"
#import "UIView+UIExt.h"
#import "NXPullDownButton.h"
#import "NXCommonUtils.h"
#import "NXOfflineFilesViewController.h"
#import "NXNetworkHelper.h"

@interface NXSharedWithMeContainerVC ()<NXPageSelectMenuViewDelegate,NXSearchVCUpdateDelegate,NXSearchVCResignActiveDelegate,NXFilterViewControllerDelegate>
@property(nonatomic, strong) NXMyDriveFilesListVC *fileListVC;
@property(nonatomic, strong) NXSharedWithMeVC *sharedWithMeVC;
@property(nonatomic, strong) NXMyDriveFavoritesVC *favoriteVC;
@property(nonatomic, strong) NXOfflineFilesViewController *offlineVC;
@property(nonatomic, strong) NXSearchViewController *searchVC;
@property(nonatomic, strong) NSMutableArray *childVCArray;
@property(nonatomic, strong) UIView *contentView;
@property(nonatomic, strong) UIBarButtonItem *addTabBarItem;
@property(nonatomic, strong) UIBarButtonItem *searchTabBarItem;
@property(nonatomic, strong) UIBarButtonItem *ellipsisItem;
@property(nonatomic,weak) id<NXSearchDataSourceProtocol> currentSelectVC;
@property(nonatomic, strong) NXPageSelectMenuView *menuView;
@property(nonatomic, assign) NSInteger currentSortBy_type;
@property(nonatomic, strong) NSMutableArray *titleArray;
@end

@implementation NXSharedWithMeContainerVC

-(NXSharedWithMeVC *)sharedWithMeVC {
    if (!_sharedWithMeVC) {
        _sharedWithMeVC = [[NXSharedWithMeVC alloc]init];
    }
    return _sharedWithMeVC;
}

-(NXOfflineFilesViewController *)offlineVC{
    if (!_offlineVC) {
        _offlineVC  = [[NXOfflineFilesViewController alloc] initWithOfflineFilesFilter:NXOfflineFileFilterSharedWithMe];
    }
    return _offlineVC;
}
-(NSMutableArray *)childVCArray{
    if (!_childVCArray) {
        _childVCArray = [NSMutableArray array];
    }
    return _childVCArray;
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.menuView addShadow:UIViewShadowPositionBottom color:[UIColor lightGrayColor]];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.searchVC setActive:NO];
    self.menuView.currentFrame = self.navigationController.view.frame;
    [self.menuView commonInitWithItems:self.titleArray];
    [self netStatusChanged:nil];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureNavigationBar];
    [self commonInit];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netStatusChanged:) name:AFNetworkingReachabilityDidChangeNotification object:nil];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.searchVC setActive:NO];
}
#pragma mark ----> init navigationBar
- (void)configureNavigationBar
{
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search - black"] style:UIBarButtonItemStylePlain target:self action:@selector(searchItemClicked:)];
    searchItem.accessibilityValue = @"SEARCH_BAR_ITEM";
    self.searchTabBarItem = searchItem;
    UIBarButtonItem *ellipsisItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ellipsis - black"] style:UIBarButtonItemStylePlain target:self action:@selector(ellipsisItemClicked:)];
    self.ellipsisItem = ellipsisItem;
    self.navigationItem.rightBarButtonItems = @[searchItem,ellipsisItem];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.definesPresentationContext = YES;
    self.navigationItem.titleView = nil;
    self.navigationItem.title = @"MySpace ";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
}

#pragma mark ----> commonInit
- (void)commonInit {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.childVCArray addObject:self.sharedWithMeVC];
    [self.childVCArray addObject:self.offlineVC];
    NSString *allItem = NSLocalizedString(@"UI_MENU_ALL_FILES",NULL);
    NSString *offlineItem = NSLocalizedString(@"UI_MENU_OFFLINE", NULL);
    NSMutableArray *titleArray = @[allItem,offlineItem].mutableCopy;
    self.titleArray = titleArray;
    UIView *greenBgView =[[UIView alloc]init];
    greenBgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:greenBgView];
    
    UILabel *sharedWithMeLabel = [[UILabel alloc] init];
      sharedWithMeLabel.text = @"Shared with me";
      sharedWithMeLabel.font = [UIFont systemFontOfSize:22.0 weight:UIFontWeightBold];
      sharedWithMeLabel.textColor = [UIColor colorWithRed:79.0/255.0 green:79.0/255.0 blue:79.0/255.0 alpha:1.0];
      [greenBgView addSubview:sharedWithMeLabel];
      
      [greenBgView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.top.equalTo(self.mas_topLayoutGuideBottom);
          make.left.equalTo(self.view);
          make.right.equalTo(self.view);
          make.height.equalTo(@45);
      }];
       
      [sharedWithMeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
          make.right.top.bottom.equalTo(greenBgView);
          make.left.equalTo(greenBgView).offset(10);
      }];
    
    NXPageSelectMenuView *menuView = [[NXPageSelectMenuView alloc]initWithFrame:self.navigationController.view.frame andItems:titleArray];
    [self.view addSubview:menuView];
    menuView.delegate = self;
    menuView.hidden = NO;
    self.menuView = menuView;
    [menuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(greenBgView.mas_bottom).offset(5);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
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
    [self addChildViewControllerToFilesViewControllerWithIndex:self.currentPageIndex];
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

-(void)back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ----->right barButtonItemClick
- (void)ellipsisItemClicked:(UIBarButtonItem *)sender {
    NXFilterViewController *filterVC = [[NXFilterViewController alloc]init];
    filterVC.providesPresentationContextTransitionStyle = true;
    filterVC.definesPresentationContext = true;
    filterVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    
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
      if ([self.currentSelectVC isKindOfClass:[NXSharedWithMeVC class]]) {
       resultVC  = [[MyVaultSeachResultViewController alloc] init];
       resultVC.searchFromFavoritePage = NO;
       ((MyVaultSeachResultViewController *)resultVC).delegate = self.childVCArray[0];
      }
      else if ([self.currentSelectVC isKindOfClass:[NXOfflineFilesViewController class]])
      {
          resultVC  = [[MyVaultSeachResultViewController alloc] init];
          resultVC.searchFromFavoritePage = NO;
          ((MyVaultSeachResultViewController *)resultVC).delegate = self.childVCArray[1];
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
      self.navigationItem.titleView = self.searchVC.searchBar;
      [self.searchVC.searchBar becomeFirstResponder];
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
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    self.navigationItem.titleView = nil;
    self.navigationItem.title = nil;
}

- (void)onTapCancelButton:(id)sender
{
    [self configureNavigationBar];
    self.searchVC.active = NO;
}
#pragma mark ----> select menu delegate
- (void)withNXPageSelectMenuView:(NXPageSelectMenuView *)selectMenuView selectMenuButtonClicked:(UIButton *)sender {
    _currentPageIndex = self.menuView.currentIndex;
    [self addChildViewControllerToFilesViewControllerWithIndex:self.currentPageIndex];
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
- (void)netStatusChanged:(id)sender {
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
#pragma -mark METHOD

- (id<NXSearchDataSourceProtocol>)currentSelectVC
{
    NSArray *vcList = self.childVCArray;
    NSInteger currentIndex = self.menuView.currentIndex;
    if (currentIndex == 0) {
        NXSharedWithMeVC *sharedWithMeVC = [vcList objectAtIndex:currentIndex];
        return sharedWithMeVC;
    } else {
        return [vcList objectAtIndex:currentIndex];
    }
    return nil;
}
#pragma mark ---->allSortByTypeAndCurrentSortByType
- (NSMutableArray *)allSortByTypesAndCurrentSortByType {
    NSMutableArray *array = [NSMutableArray array];
    UIViewController *currentVC = self.childVCArray[self.currentPageIndex];
    if ([currentVC isKindOfClass:[NXSharedWithMeVC class]]) {
        NXSharedWithMeVC *sharedWithMeVC = (NXSharedWithMeVC *)currentVC;
        [array addObject:@(sharedWithMeVC.sortOption)];
        [array addObject:sharedWithMeVC.allSortByTypes];
    }else if ([currentVC isKindOfClass:[NXFileBaseViewController class]]) {
        NXFileBaseViewController *baseVC = (NXFileBaseViewController *)currentVC;
        [array addObject:@(baseVC.sortOption)];
        [array addObject:baseVC.allSortByTypes];
    }
    return array;
}

#pragma mark ----->filterVC delegate
- (void)filterViewController:(NXFilterViewController *)filterVC changeVauleSortTpye:(NSInteger)sortType {
    self.currentSortBy_type = sortType;
    UIViewController * currentVC = self.childVCArray[self.currentPageIndex];
    if ([currentVC isKindOfClass:[NXSharedWithMeVC class]]) {
        NXSharedWithMeVC *sharedWithMeVC = (NXSharedWithMeVC *)currentVC;
        sharedWithMeVC.sortOption = sortType;
    }else if ([currentVC isKindOfClass:[NXFileBaseViewController class]]) {
        NXFileBaseViewController *lastFileVC = (NXFileBaseViewController *)currentVC;
        lastFileVC.sortOption = sortType;
    }
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

