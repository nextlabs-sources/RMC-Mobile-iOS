//
//  NXProjectsViewController.m
//  nxrmc
//
//  Created by nextlabs on 1/18/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXMyProjectsViewController.h"

#import "NXProjectTabBarController.h"

#import "NXNewProjectVC.h"



#import "NXMyProjectItemCell.h"
#import "NXProjectPendingInvitationCell.h"
#import "NXInviteMessageCell.h"
#import "NXAllProjectDetailCell.h"
#import "Masonry.h"
#import "NXLoginUser.h"
#import "NXMBManager.h"
#import "NXCommonUtils.h"
#import "NXEmptyView.h"
#import "NXProjectDeclineMsgView.h"

#define kMyProjectsCollectionViewIdentifier     123123
#define kotherProjectsCollectionViewIdentifier  123123234
#define KSCOLLECTIONVIEWHIGHT 180
#define kCellHeight 120
@interface NXMyProjectsViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *pendingArray;
@property (nonatomic, strong) NSMutableArray *byMeArray;
@property (nonatomic, strong) NSMutableArray *byOtherArray;
@property (nonatomic, strong) NSMutableArray *projectDicArray;
@property (nonatomic, strong) NSMutableDictionary *dataDic;
@property (nonatomic, assign) BOOL isAddCreateItem;
@property (nonatomic, strong) NSArray *allSortByTypes;
@property (nonatomic, strong) NXProjectModel *currentProject;
@property (nonatomic, strong) NXEmptyView *emptyView;
@end

@implementation  NXMyProjectsViewController
- (NSMutableArray *)projectDicArray {
    if (!_projectDicArray) {
        _projectDicArray = [NSMutableArray array];
    }
    return _projectDicArray;
}
- (NSMutableArray *)byMeArray {
    if (!_byMeArray) {
        _byMeArray = [NSMutableArray array];
    }
    return _byMeArray;
}

- (NSMutableArray *)byOtherArray {
    if (!_byOtherArray) {
        _byOtherArray = [NSMutableArray array];
    }
    return _byOtherArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseToProjectInvitationChanged:) name:NXPrjectInvitationNotifiy object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseToProjectListChanged:) name:NOTIFICATION_PROJECT_LIST_UPDATED object:nil];
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
            for (NXProjectModel *projectModel in projectsCreatedByMe) {
                if (self.currentProject.projectId != projectModel.projectId) {
                    [self.byMeArray addObject:projectModel];
                }
            }
            for (NXProjectModel *projectModel in projectsInvitedByOthers) {
                if (self.currentProject.projectId != projectModel.projectId) {
                    [self.byOtherArray addObject:projectModel];
                }
            }
            
            self.pendingArray =[NSMutableArray arrayWithArray:pendingProjects];
            
            
            
            if (buildFromSkyDRMEnterpriseTarget && [NXCommonUtils isCompanyAccountLogin]) {
                self.isAddCreateItem = NO;
            }else{
                 self.isAddCreateItem = YES;
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
            if (self.projectDicArray.count) {
                self.emptyView.hidden = YES;
                 [self.collectionView reloadData];
            }else{
                self.emptyView.hidden = NO;
                [self.view bringSubviewToFront:self.emptyView];
            }
           
        });
    }];
}

- (instancetype)initWithExceptModel:(id)projectModel {
   self = [super init];
    if (self) {
        _currentProject = projectModel;
    }
    return self;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
  
}

- (NXEmptyView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[NXEmptyView alloc]init];
        _emptyView.textLabel.text = NSLocalizedString(@"UI_NO_PROJECT_WWARNING", NULL);
        _emptyView.imageView.image = [UIImage imageNamed:@"emptyFolder"];
        [self.view addSubview:_emptyView];
    
        [_emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.center.equalTo(self.view);
            make.width.equalTo(self.view);
            make.bottom.equalTo(self.mas_bottomLayoutGuideBottom);
        }];
    }
    return _emptyView;
}



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
    self.tabBarController.navigationController.navigationBarHidden = YES;
    
    self.navigationController.navigationBar.backgroundColor = RMC_MAIN_COLOR;
    [self getNewDataFromAPIandReload];
  
}

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
    
    NXProjectTabBarController *projectTabBar = [[NXProjectTabBarController alloc]initWithProject:model];
    projectTabBar.preTabBarController = (NXMasterTabBarViewController *)self.tabBarController;
    [self.tabBarController.navigationController pushViewController:projectTabBar animated:YES];
    projectTabBar.selectedIndex = kProjectTabBarDefaultSelectedIndex;
    [self.navigationController popViewControllerAnimated:NO];
    
}
#pragma mark
- (void)commonInit {
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
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
               make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(10);
               make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).offset(10);
               make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).offset(-10);
               make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            }];
        }
    }else {
        [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuideBottom).offset(10);
            make.left.equalTo(self.view).offset(10);
            make.right.equalTo(self.view).offset(-10);
            make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
        }];
    }
   
}

#pragma mark   ----》NSAttributedString
- (NSAttributedString *)createAttributeString:(NSString *)title subTitle1:(NSString *)subtitle1 subTitle2:(NSString *)subTitle2 {
    NSMutableAttributedString *myprojects = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName :[UIColor lightGrayColor],NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    
    NSAttributedString *sub1 = [[NSMutableAttributedString alloc] initWithString:subtitle1 attributes:@{NSForegroundColorAttributeName :[UIColor blackColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:15]}];
    NSAttributedString *sub2 ;
    if (subTitle2) {
        sub2 = [[NSMutableAttributedString alloc] initWithString:subTitle2 attributes:@{NSForegroundColorAttributeName :[UIColor lightGrayColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:15]}];
    }
    
    [myprojects appendAttributedString:sub1];
    [myprojects appendAttributedString:sub2];
    return myprojects;
}

#pragma mark - Response to notification
- (void)responseToProjectInvitationChanged:(NSNotification *)notification
{
    [self getNewDataFromAPIandReload];
}
- (void)responseToProjectListChanged:(NSNotification *)notification
{
    [self getNewDataFromAPIandReload];
}

#pragma mark --->sort by createdTime
- (NSMutableArray *)sortByKey:(NSString *)key fromArray:(NSArray *)array {
    NSMutableArray * resultArray = [NSMutableArray arrayWithArray:array];
    
    NSSortDescriptor *sortCreateTime = [[NSSortDescriptor alloc] initWithKey:key ascending:NO];
    [resultArray sortUsingDescriptors:@[sortCreateTime]];
    return resultArray;
}
@end
