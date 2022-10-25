//
//  MyVaultViewController.m
//  nxrmc
//
//  Created by nextlabs on 12/29/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXMyVaultViewController.h"

#import "NXSearchViewController.h"
#import "MyVaultSeachResultViewController.h"

#import "Masonry.h"
#import "NXMyVaultCell.h"
#import "UIView+UIExt.h"
#import "NXMyVaultHeaderView.h"
#import "NXMBManager.h"

#import "NXRMCDef.h"
#import "AppDelegate.h"
#import "NXMyVault.h"

#import "NXFileSort.h"
#import "NXCommonUtils.h"
#import "NXPageSelectMenuView.h"
#import "NXMyVaultFileTableViewController.h"
#import "NXFilterViewController.h"
#import "NXPullDownButton.h"
#import "NXFavoriteViewController.h"
#import "NXOfflineFilesViewController.h"
#import "NXNetworkHelper.h"
#define kSectionHeaderHeight 25

@interface NXMyVaultViewController ()<NXMyVaultResignActiveDelegate,NXSearchVCUpdateDelegate,NXPageSelectMenuViewDelegate,NXSearchVCResignActiveDelegate,NXMyVaultSearchResultDelegate>

@property(nonatomic, strong) NSMutableArray<NSDictionary *> *dataArray;
@property(nonatomic, strong) NSMutableArray *originArray;
@property(nonatomic, strong) NXSearchViewController *searchVC;
@property(nonatomic, strong) NXMyVaultListParModel *listParModel;
@property(nonatomic, strong) NSMutableArray *subViewControllers;
@property(nonatomic, assign) NXSortOption option;
@property(nonatomic, strong) UIView *contentView;
@property(nonatomic, weak) id<NXSearchDataSourceProtocol> currentSelectVC;
@property(nonatomic, strong) NSArray *itemsArray;
@property(nonatomic, strong) NSMutableArray *fileTypeArray;
@property(nonatomic, assign) NSInteger currentPageIndex;
@property(nonatomic, strong) NSArray *allSortByTypes;
@property(nonatomic, strong) UIBarButtonItem *searchItem;
@property(nonatomic, strong) UIBarButtonItem *ellipsisItem;
@property(nonatomic, strong) NXPageSelectMenuView *menuView;
@property(nonatomic, strong) NXFavoriteViewController *favoriteVC;
@property(nonatomic, strong) NXOfflineFilesViewController *offlineVC;

@end

@implementation NXMyVaultViewController
-(NSMutableArray*)subViewControllers {
    if (!_subViewControllers) {
        _subViewControllers = [NSMutableArray array];
    }
    return _subViewControllers;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self commonInitInfoArrays];
    [self configureNavigationBar];
    [self createSubChildVC];
    [self commonInit];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netStatusChanged:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
}
- (NXFavoriteViewController *)favoriteVC
{
    if (!_favoriteVC) {
        _favoriteVC = [[NXFavoriteViewController alloc] initWithOfflineFilesFilter:NXFavoriteFileFilterMyVault];
    }
    
    return _favoriteVC;
}

- (NXOfflineFilesViewController *)offlineVC
{
    if (!_offlineVC) {
        _offlineVC = [[NXOfflineFilesViewController alloc] initWithOfflineFilesFilter:NXOfflineFileFilterMyVault];
    }
    
    return _offlineVC;
}
- (void)commonInitInfoArrays {

    NSString *allItem = NSLocalizedString(@"UI_MYVAULT_ALL_FILES",NULL);
    NSString *favoriteItem = NSLocalizedString(@"UI_MENU_FAVORITE", NULL);
    NSString *offineItem =NSLocalizedString(@"UI_MENU_OFFLINE", NULL);
    NSString *activeSharesItem = NSLocalizedString(@"UI_MYVAULT_ACTIVE_SHARES", NULL);
    NSString *deletedItem = NSLocalizedString(@"UI_MYVAULT_DELETED",NULL);
    NSString *revokedItem = NSLocalizedString(@"UI_MYVAULT_REVOKED", NULL);

    NSArray *itemArray = @[allItem,favoriteItem,offineItem, activeSharesItem,deletedItem,revokedItem];
    
    NSMutableArray *fileType = @[@(NXMyvaultListFilterTypeAllFiles),
                          @(NXMyvaultListFilterTypeActivedTransaction),
                          @(NXMyvaultListFilterTypeActivedDeleted),
                          @(NXMyvaultListFilterTypeActivedRevoked)].mutableCopy;
    
    self.allSortByTypes = @[@(NXSortOptionDateDescending),@(NXSortOptionNameAscending),@(NXSortOptionNameDescending),@(NXSortOptionSizeAscending)];
    
    self.fileTypeArray = fileType;
    self.itemsArray = itemArray;
}

-(void)createSubChildVC {
    for (int i = 0; i<self.fileTypeArray.count; i++) {
        NXMyVaultFileTableViewController *myVaultFileVC =[[NXMyVaultFileTableViewController alloc]init];
        [self.subViewControllers addObject:myVaultFileVC];
    }
    [self.subViewControllers insertObject:self.favoriteVC atIndex:1];
    [self.fileTypeArray insertObject:@(100) atIndex:1];
    [self.subViewControllers insertObject:self.offlineVC atIndex:2];
    [self.fileTypeArray insertObject:@(100) atIndex:2];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.searchVC.active = NO;
    [self netStatusChanged:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self updateData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.searchVC.active = NO;
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.menuView addShadow:UIViewShadowPositionBottom color:[UIColor lightGrayColor]];
    
}

- (NXMyVaultListParModel *)listParModel {
    if (!_listParModel) {
        _listParModel = [[NXMyVaultListParModel alloc] init];
    }
    return _listParModel;
}
#pragma mark

- (void)configureBackButton{
      self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
}

- (void)configureMyVautTitle{
    
}

- (void)back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)commonInit {
    UIView *greenBgView =[[UIView alloc]init];
    greenBgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:greenBgView];
    
    UILabel *myVaultLabel = [[UILabel alloc] init];
    myVaultLabel.text = @"MyVault";
    myVaultLabel.font = [UIFont systemFontOfSize:22.0 weight:UIFontWeightBold];
    myVaultLabel.textColor = [UIColor colorWithRed:79.0/255.0 green:79.0/255.0 blue:79.0/255.0 alpha:1.0];
    [greenBgView addSubview:myVaultLabel];
    
    [greenBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@45);
    }];
     
    [myVaultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.equalTo(greenBgView);
        make.left.equalTo(greenBgView).offset(10);
    }];
     
    NXPageSelectMenuView *menuView = [[NXPageSelectMenuView alloc]initWithFrame:self.navigationController.view.frame andItems:self.itemsArray];
    [self.view addSubview:menuView];
    menuView.delegate = self;
    self.menuView = menuView;
    [menuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(greenBgView.mas_bottom).offset(5);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
    }];
    UIView *contentView = [[UIView alloc]init];
    [self.view addSubview:contentView];
    self.contentView = contentView;
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(menuView.mas_bottom).offset(2);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
    }];
    self.currentPageIndex = self.menuView.currentIndex;
    [self addChildViewControllerToFilesViewControllerWithIndex:0];
}
#pragma mark add childVC
-(void)addChildViewControllerToFilesViewControllerWithIndex:(NSInteger)index {
    for (UIViewController *subVC in self.subViewControllers) {
        if ([self.childViewControllers containsObject:subVC]) {
            [subVC willMoveToParentViewController:nil];
            [subVC.view removeFromSuperview];
            [subVC removeFromParentViewController];
            [subVC didMoveToParentViewController:nil];
        }
    }
    UIViewController *newVC = self.subViewControllers[index];
    if ([newVC isKindOfClass:[NXMyVaultFileTableViewController class]]) {
        NXMyVaultFileTableViewController *myVaultVC = (NXMyVaultFileTableViewController *)newVC;
        self.listParModel.filterType = [self.fileTypeArray[index] integerValue];
        myVaultVC.listParModel = self.listParModel;
    }
   
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

#pragma mark ----> select menu delegate
- (void)withNXPageSelectMenuView:(NXPageSelectMenuView *)selectMenuView selectMenuButtonClicked:(UIButton *)sender {
    self.currentPageIndex = self.menuView.currentIndex;
    [self addChildViewControllerToFilesViewControllerWithIndex:self.currentPageIndex];
}
- (void)configureNavigationBar
{
    self.view.backgroundColor = [UIColor whiteColor];
    //fix searchbar disappear bug
    //self.navigationController.extendedLayoutIncludesOpaqueBars = YES;
    //self.extendedLayoutIncludesOpaqueBars = YES;
//    self.definesPresentationContext = NO;
    
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search - black"] style:UIBarButtonItemStylePlain target:self action:@selector(searchItemClicked:)];
    searchItem.accessibilityValue = @"SEARCH_BAR_ITEM";
    self.searchItem = searchItem;
    UIBarButtonItem *ellipsisItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ellipsis - black"] style:UIBarButtonItemStylePlain target:self action:@selector(ellipsisItemClicked:)];
    self.ellipsisItem = ellipsisItem;
    self.navigationItem.rightBarButtonItems = @[searchItem,ellipsisItem];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.definesPresentationContext = YES;
    self.navigationItem.titleView = nil;
    self.navigationItem.title = @"MySpace ";
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

    //self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    self.navigationItem.titleView = nil;
    self.navigationItem.title = nil;
}

- (void)onTapCancelButton:(id)sender
{
    [self configureNavigationBar];
     self.searchVC.active = NO;
}

#pragma mark ----->right barButtonItemClick
- (void)ellipsisItemClicked:(UIBarButtonItem *)sender {
    NXFilterViewController *filterVC = [[NXFilterViewController alloc]init];
    filterVC.providesPresentationContextTransitionStyle = true;
    filterVC.definesPresentationContext = true;
    filterVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    filterVC.segmentItems = self.allSortByTypes;
    NXMyVaultFileTableViewController *currentVC = self.subViewControllers[self.currentPageIndex];
    filterVC.selectedSortType = currentVC.sortOption;
    filterVC.delegate = self;
    [self presentViewController:filterVC animated:YES completion:nil];
}
#pragma mark ----->filterVC delegate
- (void)filterViewController:(NXFilterViewController *)filterVC changeVauleSortTpye:(NSInteger)sortType {
    self.currentSortBy_type = sortType;
    UIViewController * currentVC = self.subViewControllers[self.currentPageIndex];
     if ([currentVC isKindOfClass:[NXMyVaultFileTableViewController class]]) {
        NXMyVaultFileTableViewController *lastFileVC = (NXMyVaultFileTableViewController *)currentVC;
        lastFileVC.sortOption = sortType;
     }else if([currentVC isKindOfClass:[NXFavoriteViewController class]]){
         NXFavoriteViewController *lastFileVC = (NXFavoriteViewController *)currentVC;
         lastFileVC.sortOption = sortType;
     }else if([currentVC isKindOfClass:[NXOfflineFilesViewController class]]){
         NXOfflineFilesViewController *lastFileVC = (NXOfflineFilesViewController *)currentVC;
         lastFileVC.sortOption = sortType;
     }
}
- (void)netStatusChanged:(id)sender {
    __block NSInteger offLineIndex = -1;
    NSMutableArray *unableArray = [NSMutableArray array];
    [self.itemsArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:NSLocalizedString(@"UI_MENU_OFFLINE", NULL)]) {
            offLineIndex = idx;
        }else {
            [unableArray addObject:obj];
        }
    }];
    if (self.currentPageIndex == offLineIndex) {
        UIViewController *VC = self.subViewControllers[offLineIndex];
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
        [self.menuView cancelUnableForButtions:self.itemsArray];
    }
    
}
- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AFNetworkingReachabilityDidChangeNotification object:nil];
}
#pragma mark ----> search item
- (void) searchItemClicked:(id)sender {
    DLog(@"search item");
    
    MyVaultSeachResultViewController *resultVC = [[MyVaultSeachResultViewController alloc] init];
    
    if ([self.currentSelectVC isKindOfClass:[NXMyVaultFileTableViewController class]]) {
        
        NSArray *vcList = self.subViewControllers;
        NXMyVaultFileTableViewController *vc = [vcList objectAtIndex:_menuView.currentIndex];
        resultVC.delegate = vc;
    }else if([self.currentSelectVC isKindOfClass:[NXFavoriteViewController class]]){
        resultVC.delegate = self.favoriteVC;
    }else if([self.currentSelectVC isKindOfClass:[NXOfflineFilesViewController class]]){
        resultVC.delegate = self.offlineVC;
    }
    [self hiddenNavigatinBarItems];
    NXSearchViewController *searchVC = [[NXSearchViewController alloc] initWithSearchResultsController:resultVC];
    searchVC.updateDelegate = self;
    
    resultVC.resignActiveDelegate = self;
    
    searchVC.searchBar.placeholder = NSLocalizedString(@"UI_BEGIN_YOUR_SEARCH", NULL);
    [searchVC.searchBar sizeToFit];
    searchVC.hidesNavigationBarDuringPresentation = NO;
//    searchVC.searchBar.showsCancelButton = NO;
//    
//    self.navigationController.extendedLayoutIncludesOpaqueBars = NO;
//    self.extendedLayoutIncludesOpaqueBars = NO;
    self.definesPresentationContext = YES;
    
    self.searchVC = searchVC;
    self.navigationItem.titleView = self.searchVC.searchBar;
    
    
    [self.searchVC.searchBar becomeFirstResponder];

}
#pragma -mark NXSearchVCUpdateDelegate

- (void)updateSearchResultsForSearchController:(NXSearchViewController *)vc resultSeachVC:(NXSearchResultViewController *)resultVC {
    
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

- (void)searchControllerDidPresent:(NXSearchViewController *)searchController {
}


- (void)searchVCShouldResignActive
{
    [self.searchVC setActive:NO];
    [self configureNavigationBar];
}
#pragma -mark METHOD

- (id<NXSearchDataSourceProtocol>)currentSelectVC
{
    NSMutableArray *vcList = self.subViewControllers;
    id<NXSearchDataSourceProtocol> vc = [vcList objectAtIndex:_menuView.currentIndex];
    return vc;
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

- (void)myVaultFileListResultVC:(MyVaultSeachResultViewController *)resultVC didSelectItem:(NXMyVaultFile *)item {
  
}


@end
