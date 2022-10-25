//
//  NXPeopleViewController.m
//  nxrmc
//
//  Created by nextlabs on 1/20/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXPeopleViewController.h"
#import "NXProjectMemberDetailViewController.h"
#import "NXPeoplePendingViewController.h"

#import "NXPeopleItemCell.h"
#import "NXMBManager.h"

#import "NXRMCDef.h"
#import "NXLoginUser.h"
#import "AppDelegate.h"
#import "NXAlertView.h"
#import "NXCommonUtils.h"
#import "NXFilterViewController.h"
#import "Masonry.h"
#import "NXLProfile.h"
//#import "NXPeoplePendingItemCell.h"

@interface NXPeopleViewController ()<NXProjectMemberListSearchResultDelegate,NXSearchVCUpdateDelegate,NXProjectMemberListSearchResultDelegate,NXSearchVCResignActiveDelegate>

@property(nonatomic, assign) BOOL isOwerByMe;
@property(nonatomic, strong) NSNumber *projectOwerId;

@property(nonatomic, strong) NSArray<NXProjectMemberModel *> *dataArray;
@property(nonatomic, strong) NSArray<NXPendingProjectInvitationModel *> *pendingArray;
@property(nonatomic, strong) NSArray *allSortByTypes;
@property(nonatomic, assign) NSInteger currentSortBy_type;

@property(nonatomic, strong) NXSearchViewController *searchVC;

@end

@implementation NXPeopleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self commonInit];
    [self reloadNewData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self pullDownRefreshWork];
    [self.searchVC setActive:NO];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.searchVC setActive:NO];
}

#pragma mark

- (NSArray<NXPendingProjectInvitationModel *> *)pendingArray {
    if (!_pendingArray) {
        _pendingArray = [NSArray array];
    }
    return _pendingArray;
}

- (NSArray<NXProjectMemberModel *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSArray array];
    }
    return _dataArray;
}

- (void)setProjectModel:(NXProjectModel *)projectModel {
    if (_projectModel == projectModel) {
        return;
    }
    _projectModel = projectModel;
    self.isOwerByMe = self.projectModel.isOwnedByMe;
    self.projectOwerId = self.projectModel.projectOwner.userId;
    self.dataArray = self.projectModel.homeShowMembers;
    self.sortOption = self.currentSortBy_type;
    
}

#pragma mark
- (void)pullDownRefreshWork {

    [[NXLoginUser sharedInstance].myProject getAllMembersContainPendingsInProject:self.projectModel isReadCache:NO withCompletion:^(NXProjectModel *project, NSArray *memebersArray, NSArray *pendingsArray, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.refreshControl.isRefreshing) {
                    [self.refreshControl endRefreshing];
                }
                if (error == nil) {
                    self.dataArray = memebersArray;
                    self.pendingArray = pendingsArray;
                    self.sortOption = self.currentSortBy_type;
                } else {
                    [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2.0];
                }
            });
    }];
}

- (void)responseToProjectMemberUpdate:(NSNotification *)notification {
       [self reloadNewData];
}

- (void)reloadNewData {
    self.projectModel = [[NXLoginUser sharedInstance].myProject getProjectModelForProjectId:self.projectModel.projectId];
    
    if (self.dataArray.count == 0 && self.pendingArray.count == 0 && self.projectModel) {
        [NXMBManager showLoadingToView:self.view];
    }
    WeakObj(self);
    [[NXLoginUser sharedInstance].myProject getAllMembersContainPendingsInProject:self.projectModel isReadCache:YES withCompletion:^(NXProjectModel *project, NSArray *memebersArray, NSArray *pendingsArray, NSError *error) {
        dispatch_main_async_safe(^{
            StrongObj(self);
            if (self) {
                [NXMBManager hideHUDForView:self.view];
                if (!error) {
                    self.dataArray = memebersArray;
                    self.pendingArray = pendingsArray;
                    self.sortOption = self.currentSortBy_type;
                }
            }
        });
    }];
}

-(void)onTapMoreButtonWith:(NXProjectMemberModel *)memberModel isOwner:(BOOL)isOwner;
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    NXAlertView *alertView = [NXAlertView alertViewWithTitle:memberModel.displayName andMessage:@""];
    WeakObj(self);
    [alertView addItemWithTitle:NSLocalizedString(@"UI_VIEW_MEMBER_DETAIL", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
        StrongObj(self);
        NXProjectMemberDetailViewController *vc = [[NXProjectMemberDetailViewController alloc] init];
        vc.isOwerByMe = self.isOwerByMe;
        [vc configureProjectMemberModel:memberModel];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
     
    }];
    
    if (isOwner == YES) {
        if (![[memberModel.userId stringValue] isEqualToString: [NXLoginUser sharedInstance].profile.userId])
        {
            [alertView addItemWithTitle:NSLocalizedString(@"UI_REMOVE_FROM_PROJECT", NULL) type:NXAlertViewItemTypeDestructive handler:^(NXAlertView *alertView) {
                StrongObj(self);
                [self removeFromProject:memberModel];
                
            }];
        }
    }
    
    alertView.transitionStyle = NXAlertViewTransitionStyleSlideFromBottom;
    [alertView show];
}

-(void)onClickMoreButtonWith:(NXPendingProjectInvitationModel *)invitationModel isOwner:(BOOL)isOwner;
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    NXAlertView *alertView = [NXAlertView alertViewWithTitle:invitationModel.displayName andMessage:@""];
    WeakObj(self);
    [alertView addItemWithTitle:NSLocalizedString(@"UI_VIEW_INVITATION_DETAIL", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
        StrongObj(self);
        
        NXPeoplePendingViewController *infoVC = [[NXPeoplePendingViewController alloc]init];
        infoVC.currentModel = invitationModel;
        infoVC.isOwerByMe = self.isOwerByMe;
        infoVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:infoVC animated:YES];
    }];
    
    if (isOwner) {
        
        [alertView addItemWithTitle:NSLocalizedString(@"UI_RESEND_INVITATION", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
            StrongObj(self);
            [self resendInvitation:invitationModel];
        }];
        
        [alertView addItemWithTitle:NSLocalizedString(@"UI_REVOKE_INVITATION", NULL) type:NXAlertViewItemTypeDestructive handler:^(NXAlertView *alertView) {
            StrongObj(self);
            [self revokeInvitation:invitationModel];
        }];
    }
    
    alertView.transitionStyle = NXAlertViewTransitionStyleSlideFromBottom;
    [alertView show];
}

- (void)revokeInvitation:(NXPendingProjectInvitationModel *)invitationMemdol {
    
    NSString *message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"MSG_DO_YOU_WANT_TO_REVOKE", NULL),invitationMemdol.inviteeEmail];
    [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message: message style:UIAlertControllerStyleAlert cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherActionTitles:@[NSLocalizedString(@"UI_BOX_OK", NULL)] inViewController:self position:self.view tapBlock:^(UIAlertAction *action, NSInteger index) {
        if (index == 1) {
            [NXMBManager showLoadingToView:self.view];
            WeakObj(self);
            [[NXLoginUser sharedInstance].myProject revokeProjectInvitation:invitationMemdol withComoletion:^(NSString *statusCode, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    StrongObj(self);
                    [NXMBManager hideHUDForView:self.view];
                    if (!error&&[statusCode isEqualToString:@"200"]) {
                        [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_REVOKE_INVITATION_SUCCESS", nil) hideAnimated:YES afterDelay:1.5];
                    }
                    else
                    {
                        [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:1.5];
                    }
                });
            }];
        }
    }];
}

- (void)resendInvitation:(NXPendingProjectInvitationModel *)invitationMemdol {
    [NXMBManager showLoadingToView:self.view];
    WeakObj(self);
    [[NXLoginUser sharedInstance].myProject resendProjectInvitation:invitationMemdol withComoletion:^(NSString *statusCode, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            StrongObj(self);
            [NXMBManager hideHUDForView:self.view];
            if (!error&&[statusCode isEqualToString:@"200"]) {
                
                [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_RESEND_INVITATION_SUCCESS", nil) hideAnimated:YES afterDelay:1.5];
            }
            else
            {
                [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:1.5];
            }
        });
    }];
}

#pragma -mark Button Event

- (void)removeFromProject:(NXProjectMemberModel *)memberModel
{
    NSString *message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"MSG_DO_YOU_WANT_TO_REMOVE", NULL),memberModel.displayName];
    [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message: message style:UIAlertControllerStyleAlert cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherActionTitles:@[NSLocalizedString(@"UI_BOX_OK", NULL)] inViewController:self position:self.view tapBlock:^(UIAlertAction *action, NSInteger index) {
        if (index == 1) {
            [NXMBManager showLoadingToView:self.view];
            WeakObj(self);
            [[NXLoginUser sharedInstance].myProject removeProjectMember:memberModel withCompletion:^(NSError *error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    StrongObj(self);
                    [NXMBManager hideHUDForView:self.view];
                    if (!error) {
                        NSString *message = [[NSString alloc] initWithFormat:NSLocalizedString(@"MSG_COM_REMOVE_MEMEBER_SUCCESS", nil), memberModel.displayName];
                        [NXMBManager showMessage:message hideAnimated:YES afterDelay:1.5];
                        self.projectModel = [[NXLoginUser sharedInstance].myProject getProjectModelForProjectId:self.projectModel.projectId];
                    }
                    else
                    {
                        [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:1.5];
                    }
                });
            }];
        }
    }];
}

#pragma -mark NXSearchDataSourceProtocol
- (NSArray *)getSearchDataSource {
    NSArray *searchArray = [NSArray array];
    searchArray = [searchArray arrayByAddingObjectsFromArray:_dataArray];
    searchArray = [searchArray arrayByAddingObjectsFromArray:_pendingArray];
    return searchArray;
}

#pragma mark - NXProjectMemberListSearchResultDelegate
- (void)memberListResultVC:(NXProjectMemberSearchResultVC *)resultVC didSelectItem:(id)item {
    [resultVC.view removeFromSuperview];
    if ([item isKindOfClass:[NXProjectMemberModel class]]) {
        NXProjectMemberDetailViewController *vc = [[NXProjectMemberDetailViewController alloc] init];
        [vc configureProjectMemberModel:item];
        vc.isOwerByMe = self.isOwerByMe;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([item isKindOfClass:[NXPendingProjectInvitationModel class]]) {
        NXPeoplePendingViewController *infoVC = [[NXPeoplePendingViewController alloc]init];
        infoVC.currentModel = item;
        infoVC.isOwerByMe = self.isOwerByMe;
        infoVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:infoVC animated:YES];
    }
}

- (void)memberListResultVC:(NXProjectMemberSearchResultVC *)resultVC didClickMemberAccessButton:(id)item
{
    [self onTapMoreButtonWith:item isOwner:self.projectModel.isOwnedByMe];
}

- (void)memberListResultVC:(NXProjectMemberSearchResultVC *)resultVC didClickPendingAccessButton:(id)item
{
     [self onClickMoreButtonWith:item isOwner:self.projectModel.isOwnedByMe];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.dataArray.count;
    }
    return self.pendingArray.count;
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.pendingArray.count>0) {
        return 2;
    }else if (self.dataArray.count>0){
        return 1;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"UI_ACTIVE", NULL);
    }
    return NSLocalizedString(@"UI_PENDING", NULL);
}

//fix bug that section title always caps.
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]] && [self respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
        headerView.textLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NXPeopleItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    if (indexPath.section == 0) {
        if (indexPath.row < self.dataArray.count) {
            NXProjectMemberModel *memberModel = self.dataArray[indexPath.row];
            cell.model = memberModel;
            WeakObj(self);
            cell.accessBlock = ^(id sender) {
                StrongObj(self);
                [self onTapMoreButtonWith:memberModel isOwner: self.projectModel.isOwnedByMe];
            };
        }
    } else if (indexPath.section == 1) {
//        NXPeoplePendingItemCell *pendingCell = [tableView dequeueReusableCellWithIdentifier:@"pendingCell"];
        NXPendingProjectInvitationModel *pendingModel = self.pendingArray[indexPath.row];
        cell.pendingModel = pendingModel;
        
        WeakObj(self);
        cell.accessBlock = ^(id sender) {
            StrongObj(self);
            [self onClickMoreButtonWith:pendingModel isOwner:self.projectModel.isOwnedByMe];
        };
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NXProjectMemberModel *memberModel = self.dataArray[indexPath.row];
        NXProjectMemberDetailViewController *vc = [[NXProjectMemberDetailViewController alloc] init];
         vc.isOwerByMe = self.isOwerByMe;
        [vc configureProjectMemberModel:memberModel];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.section == 1) {
        NXPendingProjectInvitationModel *pendingModel = self.pendingArray[indexPath.row];
        NXPeoplePendingViewController *infoVC = [[NXPeoplePendingViewController alloc]init];
        infoVC.currentModel = pendingModel;
        infoVC.isOwerByMe = self.isOwerByMe;
        infoVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:infoVC animated:YES];
    }
}
#pragma mark --- > sortBy 
- (void)sortByImem:(id)sender {
    NXFilterViewController *filterVC = [[NXFilterViewController alloc]init];
    filterVC.providesPresentationContextTransitionStyle = true;
    filterVC.definesPresentationContext = true;
    filterVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    filterVC.segmentItems = self.allSortByTypes;
    filterVC.selectedSortType = self.currentSortBy_type;
    filterVC.delegate = self;
    [self presentViewController:filterVC animated:YES completion:nil];
}

#pragma mark ----->filterVC delegate
- (void)filterViewController:(NXFilterViewController *)filterVC changeVauleSortTpye:(NSInteger)sortType {
    self.currentSortBy_type = sortType;
    self.sortOption = sortType;
}

- (void)setSortOption:(NXSortOption)sortOption {
    switch (sortOption) {
        case NXSortOptionNameAscending:{
          NSMutableArray * memberResultArray = [NSMutableArray arrayWithArray:self.dataArray];
            NSSortDescriptor *displayName = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSSortDescriptor *projectOwner = [[NSSortDescriptor alloc]initWithKey:@"isProjectOwner" ascending:NO];
            [memberResultArray sortUsingDescriptors:@[displayName]];
             [memberResultArray sortUsingDescriptors:@[projectOwner]];
            self.dataArray = memberResultArray;
            NSMutableArray * pendingResultArray = [NSMutableArray arrayWithArray:self.pendingArray];
            NSSortDescriptor *inviteeEmail = [[NSSortDescriptor alloc] initWithKey:@"inviteeEmail" ascending:YES];
            [pendingResultArray sortUsingDescriptors:@[inviteeEmail]];
            self.pendingArray = pendingResultArray;
        }
            break;
        case NXSortOptionNameDescending:
        {
            NSMutableArray * memberResultArray = [NSMutableArray arrayWithArray:self.dataArray];
            NSSortDescriptor *displayName = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:NO selector:@selector(localizedStandardCompare:)];
            NSSortDescriptor *projectOwner = [[NSSortDescriptor alloc]initWithKey:@"isProjectOwner" ascending:NO];
            [memberResultArray sortUsingDescriptors:@[displayName]];
            [memberResultArray sortUsingDescriptors:@[projectOwner]];
            self.dataArray = memberResultArray;
            NSMutableArray * pendingResultArray = [NSMutableArray arrayWithArray:self.pendingArray];
            NSSortDescriptor *inviteeEmail = [[NSSortDescriptor alloc] initWithKey:@"inviteeEmail" ascending:NO selector:@selector(localizedStandardCompare:)];
            [pendingResultArray sortUsingDescriptors:@[inviteeEmail]];
            self.pendingArray = pendingResultArray;
        }
            break;
        case NXSortOptionDateDescending:{
            NSMutableArray * memberResultArray = [NSMutableArray arrayWithArray:self.dataArray];
            NSSortDescriptor *joinTime = [[NSSortDescriptor alloc] initWithKey:@"joinTime" ascending:NO];
            [memberResultArray sortUsingDescriptors:@[joinTime]];
            NSSortDescriptor *projectOwner = [[NSSortDescriptor alloc]initWithKey:@"isProjectOwner" ascending:NO];
            [memberResultArray sortUsingDescriptors:@[projectOwner]];
            self.dataArray = memberResultArray;
            NSMutableArray * pendingResultArray = [NSMutableArray arrayWithArray:self.pendingArray];
            NSSortDescriptor *inviteTime = [[NSSortDescriptor alloc] initWithKey:@"inviteTime" ascending:NO];
            [pendingResultArray sortUsingDescriptors:@[inviteTime]];
            self.pendingArray = pendingResultArray;
        }
        default:
            break;
    }
    [self.tableView reloadData];
}

#pragma mark
- (void)search:(id)sender {
    [self hiddenNavigatinBarItems];
    
    NXProjectMemberSearchResultVC *resultVC = [[NXProjectMemberSearchResultVC alloc] init];
    resultVC.delegate = self;
    resultVC.resignActiveDelegate = self;
    
    NXSearchViewController *searchVC = [[NXSearchViewController alloc] initWithSearchResultsController:resultVC];
    
    searchVC.updateDelegate = self;
    
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
    [self configureNavigationBar];
    self.searchVC.active = NO;
}

#pragma mark  - NXSearchVCUpdateDelegate

- (void)updateSearchResultsForSearchController:(NXSearchViewController *)vc resultSeachVC:(NXSearchResultViewController *)resultVC
{
    NSString *searchString = [vc.searchBar text];
    if (![searchString isEqualToString:@""]) {
        NSArray *data;
        NSPredicate *preicate;
        
        data = [self getSearchDataSource];
        preicate = [NSPredicate predicateWithFormat:@"self.displayName contains [cd] %@ || self.email contains [cd] %@", searchString,searchString];
    
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
    [self.searchVC.searchBar removeFromSuperview];
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

- (void)configureNavigationBar
{
    //configure UINavigationBar
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search - black"] style:UIBarButtonItemStylePlain target:self action:@selector(search:)];
    searchItem.accessibilityValue = @"SEARCH_BAR_ITEM";
    UIBarButtonItem *sortByItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"ellipsis - black"] style:UIBarButtonItemStylePlain target:self action:@selector(sortByImem:)];
    self.navigationItem.rightBarButtonItems = @[searchItem,sortByItem];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    self.navigationItem.leftBarButtonItems = @[leftItem];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 25)];
    titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"View memebers";
    self.navigationItem.titleView = titleLabel;
    
   
    
    self.navigationController.extendedLayoutIncludesOpaqueBars = YES;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.definesPresentationContext = NO;
}

- (void)configureNavigationRightBarButtons
{
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search - black"] style:UIBarButtonItemStylePlain target:self action:@selector(search:)];
    searchItem.accessibilityValue = @"SEARCH_BAR_ITEM";
    UIBarButtonItem *sortByItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"ellipsis - black"] style:UIBarButtonItemStylePlain target:self action:@selector(sortByImem:)];
    self.navigationItem.rightBarButtonItems = @[searchItem,sortByItem];
}

#pragma mark
- (void)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark
- (void)commonInit {
    [self configureNavigationBar];
    self.allSortByTypes = @[@(NXSortOptionNameAscending),@(NXSortOptionNameDescending),@(NXSortOptionDateDescending)];
    self.currentSortBy_type = NXSortOptionNameAscending;
    [self.tableView registerClass:[NXPeopleItemCell class] forCellReuseIdentifier:@"cell"];
//    [self.tableView registerClass:[NXPeoplePendingItemCell class] forCellReuseIdentifier:@"pendingCell"];
    
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.estimatedRowHeight = 50;
    self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(pullDownRefreshWork) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.tintColor = [UIColor lightGrayColor];
    self.refreshControl.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
 
    
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseToProjectMemberUpdate:) name:NOTIFICATION_PROJECT_MEMBER_UPDATED object:nil];
}

@end
