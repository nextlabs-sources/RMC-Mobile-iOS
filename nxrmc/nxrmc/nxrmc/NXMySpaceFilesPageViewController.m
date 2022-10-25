//
//  NXMySpaceFilesPageViewController.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2020/4/26.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXMySpaceFilesPageViewController.h"
#import "NXFilesViewController.h"
#import "NXPullDownButton.h"
#import "Masonry.h"
#import "NXMutipleSwitch.h"
#import "NXMyVaultViewController.h"
#import "NXSearchViewController.h"
#import "MyVaultSeachResultViewController.h"
#import "NXMyVaultFileTableViewController.h"
#import "NXCommonUtils.h"
#import "NXPageSelectMenuView.h"
#import "NXRepoFilesViewController.h"
#import "NXMyVaultFileTableViewController.h"
#import "NXFilterViewController.h"

@interface NXMySpaceFilesPageViewController ()<NXSearchVCUpdateDelegate,NXMyVaultResignActiveDelegate,NXSearchVCResignActiveDelegate,NXFilterViewControllerDelegate>

@property(nonatomic, strong) UIBarButtonItem *searchTabBarItem;
@property(nonatomic, strong) UIBarButtonItem *ellipsisItem;
@property(nonatomic, strong) NXPullDownButton *pulldownBtn;
@property(nonatomic, strong) NXFilesViewController *myDriveVC;
@property(nonatomic, strong) NXMyVaultViewController *myVaultVC;
@property(nonatomic, strong) NXSearchViewController *searchVC;
@property(nonatomic, weak) id<NXSearchDataSourceProtocol> currentSelectVC;
@property(nonatomic, strong) NSArray *itemsArray;
@end

@implementation NXMySpaceFilesPageViewController

#pragma -mark LifeCycle

-(instancetype)init{
    self = [super init];
    if (self) {
         NXFilesViewController *filesVC = [[NXFilesViewController alloc] init];
         NXMyVaultViewController *myVaultVC = [[NXMyVaultViewController alloc] init];
        _myDriveVC = filesVC;
        _myVaultVC = myVaultVC;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self configureNavigationBar];
    
    NXMutipleSwitch *switchMenu = [[NXMutipleSwitch alloc] initWithItems:@[@"MyDrive",@"MyVault"]];
    switchMenu.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1.0];
     switchMenu.frame = CGRectMake(0, 0, 180, 30);
     [switchMenu addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
     switchMenu.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
     switchMenu.layer.borderColor = [UIColor clearColor].CGColor;
     switchMenu.selectedTitleColor = RMC_MAIN_COLOR;
     switchMenu.titleColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
     switchMenu.trackerColor = [UIColor whiteColor];
     [self.view addSubview:switchMenu];
    
    [switchMenu mas_makeConstraints:^(MASConstraintMaker *make) {
          make.top.equalTo(self.mas_topLayoutGuideBottom);
          make.height.equalTo(@(35));
          make.width.equalTo(@180);
          make.centerX.equalTo(self.view);
    }];
    
    if (self.selectedType == NXMySpaceFilesPageSelectedTypeMyDrive) {
         [self showMyDrive];
         [switchMenu setSelectedSegmentIndex:0];
       }
       
       if (self.selectedType == NXMySpaceFilesPageSelectedTypeMyVault) {
           [self showMyVault];
           [switchMenu setSelectedSegmentIndex:1];
       }
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma -mark UIConfigure Method

- (void)configureNavigationBar
{
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search - black"] style:UIBarButtonItemStylePlain target:self action:@selector(searchItemClicked:)];
    searchItem.accessibilityValue = @"SEARCH_BAR_ITEM";
    UIBarButtonItem *ellipsisItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ellipsis - black"] style:UIBarButtonItemStylePlain target:self action:@selector(ellipsisItemClicked:)];
    self.searchTabBarItem = searchItem;
    self.ellipsisItem = ellipsisItem;
    self.navigationItem.rightBarButtonItems = @[searchItem,ellipsisItem];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.extendedLayoutIncludesOpaqueBars = YES;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.definesPresentationContext = NO;
    
//    NSString *buttonTitle = @"MySpace";
//    CGSize buttonSize = [self sizeOfLabelWithCustomMaxWidth:self.view.bounds.size.width/4*3 systemFontSize:14 andFilledTextString:buttonTitle];
//    NXPullDownButton *pullDownBtn = [[NXPullDownButton alloc]init];
//    pullDownBtn.frame = CGRectMake(0, 0,buttonSize.width/0.7, 25);
//    pullDownBtn.titleLabel.font = [UIFont systemFontOfSize:14];
//    pullDownBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
//    pullDownBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
//    [pullDownBtn addTarget:self action:@selector(clickMySpaceDown:) forControlEvents:UIControlEventTouchUpInside];
//    [pullDownBtn setTitle:buttonTitle forState:UIControlStateNormal];
//    [pullDownBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [pullDownBtn setImage:[UIImage imageNamed:@"down arrow - black1"] forState:UIControlStateNormal];
//    self.navigationItem.titleView = pullDownBtn;
//    self.pulldownBtn = pullDownBtn;
//    pullDownBtn.contentMode = UIViewContentModeScaleAspectFit;
    
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

    self.navigationItem.leftBarButtonItem = nil;
    [self.navigationItem setHidesBackButton:YES];
    self.navigationItem.titleView = nil;
    self.navigationItem.title = nil;
}

- (void)onTapCancelButton:(id)sender
{
    [self configureNavigationBar];
     self.searchVC.active = NO;
}

#pragma -mark OnClick Event


- (void)searchItemClicked:(id)sender {
    
    if (self.selectedType == NXMySpaceFilesPageSelectedTypeMyDrive) {
        NXSearchResultViewController *resultVC = nil;
         if ([self.currentSelectVC isKindOfClass:[NXRepoFilesViewController class]]) {
             resultVC = [[NXFileListSearchResultVC alloc] init];
             resultVC.searchFromFavoritePage = NO;
             ((NXFileListSearchResultVC *)resultVC).delegate = self.myDriveVC.fileListNav.viewControllers.lastObject;
         }
         else if ([self.currentSelectVC isKindOfClass:[NXFavoriteViewController class]])
         {
             resultVC  = [[MyVaultSeachResultViewController alloc] init];
             resultVC.searchFromFavoritePage = YES;
             ((MyVaultSeachResultViewController *)resultVC).delegate = self.myDriveVC.childVCArray[1];
         }
         else if ([self.currentSelectVC isKindOfClass:[NXOfflineFilesViewController class]])
         {
             resultVC  = [[MyVaultSeachResultViewController alloc] init];
             resultVC.searchFromFavoritePage = NO;
             ((MyVaultSeachResultViewController *)resultVC).delegate = self.myDriveVC.childVCArray[2];
         }
         else if ([self.currentSelectVC isKindOfClass:[NXSharedByMeVC class]])
         {
             resultVC  = [[MyVaultSeachResultViewController alloc] init];
              resultVC.searchFromFavoritePage = NO;
             ((MyVaultSeachResultViewController *)resultVC).delegate = self.myDriveVC.childVCArray[3];
         }
         else if([self.currentSelectVC isKindOfClass:[NXSharedWithMeVC class]])
         {
             resultVC  = [[MyVaultSeachResultViewController alloc] init];
             resultVC.searchFromFavoritePage = NO;
             ((MyVaultSeachResultViewController *)resultVC).delegate = self.myDriveVC.childVCArray[4];
         }
         else {
             return;
         }
         
         [self hiddenNavigatinBarItems];
         
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
    
    if (self.selectedType == NXMySpaceFilesPageSelectedTypeMyVault) {
        MyVaultSeachResultViewController *resultVC = [[MyVaultSeachResultViewController alloc] init];
              
              if ([self.currentSelectVC isKindOfClass:[NXMyVaultFileTableViewController class]]) {
                  
                  NSArray *vcList = self.myVaultVC.subViewControllers;
                  NXMyVaultFileTableViewController *vc = [vcList objectAtIndex:self.myVaultVC.menuView.currentIndex];
                  resultVC.delegate = vc;
              }
              [self hiddenNavigatinBarItems];
              NXSearchViewController *searchVC = [[NXSearchViewController alloc] initWithSearchResultsController:resultVC];
              searchVC.updateDelegate = self;
              resultVC.resignActiveDelegate = self;
              searchVC.searchBar.placeholder = NSLocalizedString(@"UI_BEGIN_YOUR_SEARCH", NULL);
              [searchVC.searchBar sizeToFit];
              searchVC.hidesNavigationBarDuringPresentation = NO;
              self.definesPresentationContext = YES;
              self.searchVC = searchVC;
              self.navigationItem.titleView = self.searchVC.searchBar;
              [self.searchVC setActive:YES];
    }
}

- (void)ellipsisItemClicked:(id)sender {
    
    if (self.selectedType == NXMySpaceFilesPageSelectedTypeMyDrive) {
        NXFilterViewController *filterVC = [[NXFilterViewController alloc]init];
           filterVC.providesPresentationContextTransitionStyle = true;
           filterVC.definesPresentationContext = true;
           filterVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
           if ([self.myDriveVC.childVCArray[self.myDriveVC.currentPageIndex] isKindOfClass:[NXRepoFilesNavigationController class]]) {
               filterVC.isSupportRepo = YES;
           } else {
               filterVC.isSupportRepo = NO;
           }
           
           filterVC.delegate = self;
           // not change
           NSMutableArray *sortByInfos = [self.myDriveVC allSortByTypesAndCurrentSortByType];
           if (sortByInfos) {
               filterVC.selectedSortType = [sortByInfos.firstObject integerValue];
               filterVC.segmentItems = sortByInfos.lastObject;
           }
           [self presentViewController:filterVC animated:YES completion:nil];
    }
    
    if (self.selectedType == NXMySpaceFilesPageSelectedTypeMyVault) {
        NXFilterViewController *filterVC = [[NXFilterViewController alloc]init];
          filterVC.providesPresentationContextTransitionStyle = true;
          filterVC.definesPresentationContext = true;
          filterVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
          filterVC.segmentItems = self.myVaultVC.allSortByTypes;
          NXMyVaultFileTableViewController *currentVC = self.myVaultVC.subViewControllers[self.myVaultVC.currentPageIndex];
          filterVC.selectedSortType = currentVC.sortOption;
          filterVC.delegate = self;
          [self presentViewController:filterVC animated:YES completion:nil];
    }
    
}

- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma -mark switch action

- (void)switchAction:(NXMutipleSwitch *)multipleSwitch {
    NSLog(@"switchAction:点击了第%zd个",multipleSwitch.selectedSegmentIndex);
    if (multipleSwitch.selectedSegmentIndex == 0) {
        self.selectedType = NXMySpaceFilesPageSelectedTypeMyDrive;
        [self showMyDrive];
    }
    
    if (multipleSwitch.selectedSegmentIndex == 1) {
        self.selectedType = NXMySpaceFilesPageSelectedTypeMyVault;
        [self showMyVault];
    }
}

#pragma -mark private Method
- (CGSize)sizeOfLabelWithCustomMaxWidth:(CGFloat)width systemFontSize:(CGFloat)fontSize andFilledTextString:(NSString *)str{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width, 0)];
    label.text = str;
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:fontSize];
    [label sizeToFit];
    CGSize size = label.frame.size;
    return size;
}

- (void)showMyDrive{
    
    [self.myVaultVC willMoveToParentViewController:nil];
    [self.myVaultVC removeFromParentViewController];
    [self.myVaultVC.view removeFromSuperview];
    
    [self addChildViewController:self.myDriveVC];
    [self.view addSubview:self.myDriveVC.view];
    
    [self.myDriveVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
          make.left.right.bottom.equalTo(self.view);
          make.top.equalTo(self.mas_topLayoutGuideBottom).offset(35);
      }];
}

-(void)showMyVault{
  
    [self.myDriveVC willMoveToParentViewController:nil];
    [self.myDriveVC removeFromParentViewController];
    [self.myDriveVC.view removeFromSuperview];
    
    [self addChildViewController:self.myVaultVC];
    [self.view addSubview:self.myVaultVC.view];
    
    [self.myVaultVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(self.mas_topLayoutGuideBottom).offset(35);
     }];
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

- (id<NXSearchDataSourceProtocol>)currentSelectVC
{
    if (self.selectedType == NXMySpaceFilesPageSelectedTypeMyDrive) {
        NSArray *vcList = self.myDriveVC.childVCArray;
           NSInteger currentIndex = self.myDriveVC.menuView.currentIndex;
           if (currentIndex == 0) {
               NXRepoFilesNavigationController *nav = [vcList objectAtIndex:currentIndex];
               return nav.viewControllers.lastObject;
           } else {
               return [vcList objectAtIndex:currentIndex];
           }
           return nil;
    }else{
        NSMutableArray *vcList = self.myVaultVC.subViewControllers;
          id<NXSearchDataSourceProtocol> vc = [vcList objectAtIndex:self.myVaultVC.menuView.currentIndex];
          return vc;
    }
}

#pragma mark ----->filterVC delegate
- (void)filterViewController:(NXFilterViewController *)filterVC changeVauleSortTpye:(NSInteger)sortType {
    
    if (self.selectedType == NXMySpaceFilesPageSelectedTypeMyDrive) {
        UIViewController * currentVC = self.myDriveVC.childVCArray[self.myDriveVC.currentPageIndex];
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
    
    if (self.selectedType == NXMySpaceFilesPageSelectedTypeMyVault) {
        self.myVaultVC.currentSortBy_type = sortType;
          UIViewController *currentVC = self.myVaultVC.subViewControllers[self.myVaultVC.currentPageIndex];
           if ([currentVC isKindOfClass:[NXMyVaultFileTableViewController class]]) {
              NXMyVaultFileTableViewController *lastFileVC = (NXMyVaultFileTableViewController *)currentVC;
              lastFileVC.sortOption = sortType;
          }
    }
}

@end
