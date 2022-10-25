//
//  NXRepositoriesVC.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/9/16.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXRepositoriesVC.h"
#import "Masonry.h"
#import "NXRMCDef.h"
#import "NXProfileSectionHeaderView.h"
#import "NXRepositoryModel.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXMBManager.h"
#import "NXRepoTableViewCell.h"
#import "NXHomeRepoVC.h"
#import "NXRepositoryInfoViewController.h"
#import "NXFilesNavigationVC.h"
#import "NXEmptyView.h"

@interface NXRepositoriesVC ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong) NSArray *tableArray;
@property (nonatomic, strong) NXEmptyView *emptyView;
@end

@implementation NXRepositoriesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = NSLocalizedString(@"UI_HOMEVC_REPOSITORY", NULL);
    UITableView *tableView = [[UITableView alloc]init];
    [self.view addSubview:tableView];
       
    tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    tableView.tableFooterView = [[UIView alloc] init];
    tableView.showsVerticalScrollIndicator = NO;
    tableView.cellLayoutMarginsFollowReadableWidth = NO;
   
    [tableView registerClass:[NXRepoTableViewCell class] forCellReuseIdentifier:@"kCellIdentifier"];
    tableView.delegate = self;
    tableView.dataSource = self;
   
   [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
       if (@available(iOS 11.0, *)) {
           make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
           make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
       } else {
           make.top.equalTo(self.mas_topLayoutGuideBottom);
           make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
       }
       make.left.equalTo(self.view);
       make.right.equalTo(self.view);
   }];
       
    self.tableView = tableView;
    [self emptyView];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
     [self reloadData];
}

- (NXEmptyView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[NXEmptyView alloc]init];
        _emptyView.textLabel.text = NSLocalizedString(@"UI_NO_REPO_CONFIGURED", NULL);
        _emptyView.textLabel.font = [UIFont systemFontOfSize:15];
        [self.view addSubview:_emptyView];
        _emptyView.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:235.0/255.0 blue:242.0/255.0 alpha:1.0];
        [_emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuideBottom);
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
    }
    return _emptyView;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tableArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sectionData = self.tableArray[section];
    NSArray *array = sectionData.lastObject;
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NXProfileSectionHeaderView *headerView = [[NXProfileSectionHeaderView alloc] init];
    
    NSArray *sectionData = self.tableArray[section];
    headerView.model = sectionData.firstObject;
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NXRepoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kCellIdentifier" forIndexPath:indexPath];
    NSArray *sectionData = self.tableArray[indexPath.section];
    NSArray *respositoriesArray = sectionData.lastObject;
    NXRepositoryModel *boundService = respositoriesArray[indexPath.row];
    cell.model = boundService;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSArray *sectionData = self.tableArray[indexPath.section];
//    NSArray *respositoriesArray = sectionData.lastObject;
//    NXRepositoryModel *repo = respositoriesArray[indexPath.row];
    return YES;
}
- (NSArray<UITableViewRowAction *>*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *manageAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Manage" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [tableView setEditing:NO animated:NO];
        NSArray *sectionData = self.tableArray[indexPath.section];
        NSArray *respositoriesArray = sectionData.lastObject;
        NXRepositoryModel *repoModel = respositoriesArray[indexPath.row];
        NXRepositoryInfoViewController *vc = [[NXRepositoryInfoViewController alloc] initWithRepository:repoModel];
        NXFilesNavigationVC *nav= [[NXFilesNavigationVC alloc] initWithRootViewController:vc];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController presentViewController:nav animated:YES completion:nil];
        
    }];
    manageAction.backgroundColor = RMC_MAIN_COLOR;
    return @[manageAction];
}
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        WeakObj(self);
//
//        NSArray *sectionData = self.tableArray[indexPath.section];
//        NSArray *respositoriesArray = sectionData.lastObject;
//        NXRepositoryModel *repo = respositoriesArray[indexPath.row];
//
//        NSString *message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"UI_COM_ARE_YOU_SURE_WANT_TO_DEL", NULL), repo.service_alias];
//        [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message: message style:UIAlertControllerStyleAlert cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherActionTitles:@[NSLocalizedString(@"UI_BOX_OK", NULL)] inViewController:self position:self.view tapBlock:^(UIAlertAction *action, NSInteger index) {
//            if (index == 1) {
//                StrongObj(self);
//                [NXMBManager showLoadingToView:self.view];
//                [[NXLoginUser sharedInstance].myRepoSystem deleteRepository:repo completion:^(NXRepositoryModel *repoModel, NSError *error) {
//                    dispatch_main_async_safe(^{
//                        [NXMBManager hideHUDForView:self.view];
//                        if (error) {
//                            [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_DEL_REPO_ERROR", nil) toView:self.view hideAnimated:YES afterDelay:kDelay];
//                        }else{
//                            [self reloadData];
//                        }
//
//                    });
//                }];
//            }else{
//                StrongObj(self);
//                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
//            }
//        }];
//    }
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sectionData = self.tableArray[indexPath.section];
    NSArray *respositoriesArray = sectionData.lastObject;
    NXRepositoryModel *repoModel = respositoriesArray[indexPath.row];
    NXHomeRepoVC *repoVC = [[NXHomeRepoVC alloc] init];
    repoVC.currentRepoModel = repoModel;
    [self.navigationController pushViewController:repoVC animated:NO];
}
- (void)reloadData {
    NSArray<NXRepositoryModel *> *dataArray = [[NXLoginUser sharedInstance].myRepoSystem allAuthReposiories];
    
    NSMutableArray *repositories = [NSMutableArray array];
    
    for (NXRepositoryModel *model in dataArray) {
        if (model.service_type.integerValue != kServiceSkyDrmBox) {
            [repositories addObject:model];
        }
    }
    
    NSMutableArray *tableData = [NSMutableArray array];
    if (repositories.count) {
        [tableData addObject:@[NSLocalizedString(@"UI_CONNECT_REPO", NULL), repositories]];
    }
    self.tableArray = [NSArray arrayWithArray:tableData];
    [self.tableView reloadData];
    
    void (^showEmptyView)(bool) = ^void (bool empty){
        if (empty) {
            self.emptyView.hidden = false;
            self.tableView.hidden = true;
        } else {
            self.emptyView.hidden = true;
            self.tableView.hidden = false;
        }
    };
    showEmptyView(repositories.count == 0 ? true: false);
}
- (void)showRepoFilesByRepo:(NXRepositoryModel *)repoModel {
    NXHomeRepoVC *repoVC = [[NXHomeRepoVC alloc] init];
    repoVC.currentRepoModel = repoModel;
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self.navigationController pushViewController:repoVC animated:NO];
    
}
@end
