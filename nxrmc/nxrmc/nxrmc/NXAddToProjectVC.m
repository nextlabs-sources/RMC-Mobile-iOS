//
//  NXAddToProjectVC.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/3/13.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXAddToProjectVC.h"
#import "NXRMCDef.h"
#import "NXFileBase.h"
#import "Masonry.h"
#import "NXAddToProjectCell.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXMBManager.h"
#import "NXWebFileManager.h"
#import "NXReAddFileToProjectVC.h"
#import "NXAddToProjectLastVC.h"
#import "NXRepoTableViewCell.h"
#import "NXFileChooseFlowViewController.h"

@interface NXAddToProjectVC ()<UITableViewDelegate,UITableViewDataSource,NXFileChooseFlowViewControllerDelegate>
@property (nonatomic, strong) UITableView *tableView;
//@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSArray *currentClassifications;
@property (nonatomic, strong) NXLRights *fileRights;
@property (nonatomic, strong) UIView *workSpaceView;
@property (nonatomic, assign) BOOL isFromProjectAndAdmin;
@property (nonatomic, assign) BOOL isAdhocEncrypted;
@property (nonatomic, strong)NSArray *projectsArray;
@property (nonatomic, strong)NSArray *reposArray;
@property (nonatomic, strong)NSMutableArray <NSDictionary *> *dataArray;
@property (nonatomic, strong)NXFolder *saveFolder;
@property (nonatomic, strong)NXProjectModel *targetProject;
@property (nonatomic, strong)NXRepositoryModel *targetRepo;
@property (nonatomic, assign)BOOL isCanAddToMySpace;
@property (nonatomic, assign)BOOL isCanAddToWorkSpace;
@property (nonatomic, assign)BOOL isCanAddToProject;
@property (nonatomic, assign)BOOL isCanAddToRepo;
@property (nonatomic, assign)BOOL isCanAddToSharedWorkspace;

@property (nonatomic, strong) NXFileBase *operationFile;
@end

@implementation NXAddToProjectVC
- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.operationFile = [self.currentFile copy];
    [self configurationNavigation];
    [self checkRightsFromTheFile:self.currentFile];
}
- (void)checkRightsFromTheFile:(NXFileBase *)fileItem {
    if (self.fileOperationType == NXFileOperationTypeAddProjectFileToProject || self.fileOperationType == NXFileOperationTypeAddProjectFileToWorkSpace || [fileItem isKindOfClass:[NXProjectFile class]]) {
        if ([[NXLoginUser sharedInstance] isProjectAdmin]) {
            self.isFromProjectAndAdmin = YES;
        }
    }
    [NXMBManager showLoadingToView:self.view];
    [[NXLoginUser sharedInstance].nxlOptManager getNXLFileRights:fileItem withWatermark:YES withCompletion:^(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray<NXWatermarkWord *> *waterMarkWords, NSString *owner, BOOL isOwner, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *errorMessage = nil;
            if (!error) {
                if (classifications) {
                    self.currentClassifications = classifications;
                    self.isAdhocEncrypted = NO;
                }else{
                    self.fileRights = rights;
                    self.isAdhocEncrypted = YES;
                }
                [self checkTheFileCanAddToWhichSpace:rights];
                if (self.fileOperationType == NXFileOperationTypeAddProjectFileToProject || [fileItem isKindOfClass:[NXProjectFile class]]) {
                    if (([rights DecryptRight] || [rights DownloadRight]) || self.isFromProjectAndAdmin) {
                        [self commonInit];
                        [self getNewDataFromAPIandReload];
                    }else{
                        errorMessage = NSLocalizedString(@"MSG_NO_ACCESS_RIGHT",NULL);
                    }
                }else{
                   [self commonInit];
                    [self getNewDataFromAPIandReload];
                }
                
            }else{
                [NXMBManager hideHUD];
                errorMessage = error.localizedDescription;
            }
            if (errorMessage) {
                [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:errorMessage  style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_OK", NULL) cancelActionTitle:nil OKActionHandle:^(UIAlertAction *action) {
                    [self back:nil];
                } cancelActionHandle:nil inViewController:self position:self.view];
            }
        });
        
    }];
}
- (void)checkTheFileCanAddToWhichSpace:(NXLRights *)rights {
   
    self.isCanAddToMySpace = NO;
    self.isCanAddToRepo = NO;
    self.isCanAddToProject = NO;
    self.isCanAddToWorkSpace = NO;
    self.isCanAddToSharedWorkspace = NO;
    switch (self.currentFile.sorceType) {
        case NXFileBaseSorceTypeProject:
        {
            if ([rights DecryptRight] || ([[NXLoginUser sharedInstance] isProjectAdmin] && [rights ViewRight])) {
                self.isCanAddToMySpace = YES;
                self.isCanAddToProject = YES;
                self.isCanAddToWorkSpace = YES;
                self.isCanAddToSharedWorkspace = YES;
            }
            if ([rights DownloadRight] || ([[NXLoginUser sharedInstance] isProjectAdmin] && [rights ViewRight])) {
                self.isCanAddToRepo = YES;
            }
            
        }
            break;
        case NXFileBaseSorceTypeShareWithMe:
        {
            if ([rights DecryptRight]) {
                self.isCanAddToMySpace = YES;
            }
            if ([rights DownloadRight]) {
                self.isCanAddToRepo = YES;
                self.isCanAddToProject = YES;
                self.isCanAddToWorkSpace = YES;
                self.isCanAddToSharedWorkspace = YES;
            }
        }
            break;
        case NXFileBaseSorceTypeWorkSpace:
        {
            if ([rights DecryptRight] || ([[NXLoginUser sharedInstance] isTenantAdmin] && [rights ViewRight])) {
                self.isCanAddToMySpace = YES;
            }
            if ([rights DownloadRight] || ([[NXLoginUser sharedInstance] isTenantAdmin] && [rights ViewRight])) {
                self.isCanAddToRepo = YES;
                self.isCanAddToProject = YES;
                self.isCanAddToWorkSpace = YES;
                self.isCanAddToSharedWorkspace = YES;
            }
        }
            break;
        case NXFileBaseSorceTypeSharedWorkspaceFile:
        case NXFileBaseSorceTypeRepoFile:{
            self.isCanAddToMySpace = YES;
            self.isCanAddToRepo = YES;
            self.isCanAddToProject = YES;
            self.isCanAddToWorkSpace = YES;
            self.isCanAddToSharedWorkspace = YES;
        }
            break;
        case NXFileBaseSorceTypeLocalFiles:
        case NXFileBaseSorceTypeMyVaultFile:
        {
            self.isCanAddToMySpace = YES;
            self.isCanAddToRepo = YES;
            self.isCanAddToProject = YES;
            self.isCanAddToWorkSpace = YES;
            self.isCanAddToSharedWorkspace = YES;
        }
            break;
        default:
            break;
    }
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}
#pragma mark ----- getNewDataAndreload UI
- (void)getNewDataFromAPIandReload {
    WeakObj(self);
    [self.dataArray removeAllObjects];
//    self.reposArray = [[NXLoginUser sharedInstance].myRepoSystem allAuthReposioriesExceptMyDrive];
    if (self.isCanAddToRepo && self.isCanAddToSharedWorkspace) {
        self.reposArray = [[NXLoginUser sharedInstance].myRepoSystem allAuthReposioriesExceptMyDrive];
    }else if(self.isCanAddToRepo && !self.isCanAddToSharedWorkspace) {
        self.reposArray = [[NXLoginUser sharedInstance].myRepoSystem allAuthReposioriesExceptApplicationRepos];
    }else if (!self.isCanAddToRepo && self.isCanAddToSharedWorkspace){
        self.reposArray = [[NXLoginUser sharedInstance].myRepoSystem allApplicationRepositories];
    }else{
        self.reposArray = [NSArray array];
    }
    
    if (self.fileOperationType != NXFileOperationTypeAddMyVaultFileToOther) {
        [self.dataArray addObject:@{@"myspace":@[]}];
    }
    if (self.fileOperationType == NXFileOperationTypeAddWorkSPaceFileToOther) {
        if (self.reposArray.count > 0) {
            NSDictionary *repoDict = @{@"repository":self.reposArray};
            [self.dataArray addObject:repoDict];
        }
    }else {
        if ([NXCommonUtils isSupportWorkspace]) {
            [self.dataArray addObject:@{@"workspace":@[]}];
        }
        if ((self.currentFile.serviceType = [NSNumber numberWithInteger:NXFileBaseSorceTypeSharedWorkspaceFile])&&self.currentFile.repoId ) {
            self.fromRepoModel = [[NXLoginUser sharedInstance].myRepoSystem getRepositoryModelByFileItem:self.currentFile];
            if (self.reposArray.count > 0) {
                if (self.fromRepoModel) {
                    NSMutableArray *currentArray = [NSMutableArray arrayWithArray:self.reposArray];
                    if ([self.reposArray containsObject:self.fromRepoModel]) {
                        [currentArray removeObject:self.fromRepoModel];
                    }
                    self.reposArray = currentArray;
                }
            }
        }
        if (self.reposArray.count > 0) {
            NSDictionary *repoDict = @{@"repository":self.reposArray};
            [self.dataArray addObject:repoDict];
        }
        
    }
    if (self.isCanAddToProject) {
        [[NXLoginUser sharedInstance].myProject allMyProjectsWithCompletion:^(NSArray *projectsCreatedByMe, NSArray *projectsInvitedByOthers, NSArray *pendingProjects, NSError *error) {
            StrongObj(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                [NXMBManager hideHUD];
                if (!error) {
                    NSMutableArray *allProjectArray = [NSMutableArray arrayWithArray:projectsCreatedByMe];
                        [allProjectArray addObjectsFromArray:projectsInvitedByOthers];
                    if (self.fromProjectModel) {
                        if ([allProjectArray containsObject:self.fromProjectModel]) {
                            [allProjectArray removeObject:self.fromProjectModel];
                        }
                    }
                    self.projectsArray = allProjectArray;
                    if (self.projectsArray.count > 0) {
                        NSDictionary *projectDict = @{@"project":self.projectsArray};
                        [self.dataArray addObject:projectDict];
                    }
                }else{
                    [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2];
                }
                [self.tableView reloadData];
            });
        }];
        
    }else{
        [self.tableView reloadData];
    }
    
}
//- (void)getNewDataFromAPIandReload {
//    WeakObj(self);
//    [[NXLoginUser sharedInstance].myProject allMyProjectsWithCompletion:^(NSArray *projectsCreatedByMe, NSArray *projectsInvitedByOthers, NSArray *pendingProjects, NSError *error) {
//        StrongObj(self);
//        if (!error) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//            NSMutableArray *allProjectArray = [NSMutableArray arrayWithArray:projectsCreatedByMe];
//                [allProjectArray addObjectsFromArray:projectsInvitedByOthers];
//                if (self.fromProjectModel) {
//                    if ([allProjectArray containsObject:self.fromProjectModel]) {
//                        [allProjectArray removeObject:self.fromProjectModel];
//
//                    }
//                }
//
//                self.dataArray = allProjectArray;
//                [self.tableView reloadData];
//
//            });
//        }
//
//    }];
//}
- (void)configurationNavigation {
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationItem.title =  NSLocalizedString(@"UI_ADD_PROTECTED_FILE", NULL);
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}
- (void)commonInit {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Select a location to add file";
    titleLabel.textColor = RMC_MAIN_COLOR;
    [self.view addSubview:titleLabel];
    titleLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UITableView *tableView = [[UITableView alloc] init];
    tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsVerticalScrollIndicator = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView = tableView;
    tableView.tableHeaderView = [[UIView alloc] init];
    tableView.tableFooterView = [[UIView alloc] init];
    [tableView registerClass:[NXAddToProjectCell class] forCellReuseIdentifier:@"cell"];
    [tableView registerClass:[NXRepoTableViewCell class] forCellReuseIdentifier:@"repoCell"];
    
    if (@available(iOS 11.0, *)) {
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(15);
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).offset(10);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).offset(-10);
            make.height.equalTo(@30);
        }];
    }else {
       [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
           make.top.equalTo(self.mas_topLayoutGuideBottom).offset(10);
           make.height.equalTo(@30);
           make.left.equalTo(self.view).offset(10);
           make.right.equalTo(self.view).offset(-10);
       }];
}
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(10);
        make.bottom.equalTo(self.view).offset(-10);
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
    }];
//    if ((buildFromSkyDRMEnterpriseTarget &&[NXCommonUtils isCompanyAccountLogin])&&(self.fileOperationType == NXFileOperationTypeAddProjectFileToProject || self.fileOperationType == NXFileOperationTypeAddLocalProtectedFileToOther || self.fileOperationType == NXFileOperationTypeAddRepoProtectedFileToOther || self.fileOperationType == NXFileOperationTypeAddMyVaultFileToOther)) {
//        if (IS_IPHONE_X) {
//               if (@available(iOS 11.0, *)) {
//                   [self.workSpaceView mas_makeConstraints:^(MASConstraintMaker *make) {
//                       make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(5);
//                       make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
//                       make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
//                       make.height.equalTo(@50);
//                   }];
//                   [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//                       make.top.equalTo(self.workSpaceView.mas_bottom).offset(5);
//                       make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
//                       make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
//                       make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
//                   }];
//               }
//           }else {
//               [self.workSpaceView mas_makeConstraints:^(MASConstraintMaker *make) {
//                   make.top.equalTo(self.mas_topLayoutGuideBottom).offset(5);
//                   make.left.right.equalTo(self.view);
//                   make.height.equalTo(@50);
//               }];
//               [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//                   make.top.equalTo(self.workSpaceView.mas_bottom).offset(5);;
//                   make.left.right.bottom.equalTo(self.view);
//               }];
//           }
//    }else{
//        if (IS_IPHONE_X) {
//               if (@available(iOS 11.0, *)) {
//                   [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//                       make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(5);
//                       make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
//                       make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
//                       make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
//                   }];
//               }
//        }else {
//               [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//                   make.top.equalTo(self.mas_topLayoutGuideBottom).offset(5);
//                   make.left.right.bottom.equalTo(self.view);
//               }];
//        }
//    }
}
- (UIView *)commonInitSaveToWorkSpaceViewItem {
    UIView *toWorkSpaceView = [[UIView alloc] init];
    toWorkSpaceView.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Black-workspace-icon"]];
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.text = @"WorkSpace";
    UIImageView *rightImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessoryIcon"]];
    [toWorkSpaceView addSubview:rightImage];
    [toWorkSpaceView addSubview:imageView];
    [toWorkSpaceView addSubview:textLabel];
    if ([NXCommonUtils isSupportWorkspace] && self.isCanAddToWorkSpace) {
        toWorkSpaceView.userInteractionEnabled = YES;
         toWorkSpaceView.backgroundColor = [UIColor whiteColor];
    }else{
        toWorkSpaceView.userInteractionEnabled = NO;
       toWorkSpaceView.backgroundColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1.0];
    }

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toSelectWorkSpace:)];
    [toWorkSpaceView addGestureRecognizer:tapGesture];
    [rightImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(toWorkSpaceView);
        make.right.equalTo(toWorkSpaceView).offset(-15);
        make.height.width.equalTo(@20);
    }];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(toWorkSpaceView).offset(15);
        make.left.equalTo(toWorkSpaceView).offset(8);
        make.height.equalTo(@30);
        make.width.equalTo(@35);
    }];
    
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageView.mas_right).offset(10);
        make.width.equalTo(@100);
        make.centerY.equalTo(imageView);
        make.height.equalTo(@30);
    }];
    return toWorkSpaceView;
}
- (UIView *)commonInitSaveToMySpaceViewItem {
    UIView *toMySpaceView = [[UIView alloc] init];
    toMySpaceView.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MyDrive"]];
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.text = @"MySpace";
    UIImageView *rightImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessoryIcon"]];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [toMySpaceView addSubview:lineView];
    
    [toMySpaceView addSubview:rightImage];
    [toMySpaceView addSubview:imageView];
    [toMySpaceView addSubview:textLabel];
    if (self.isAdhocEncrypted && self.isCanAddToMySpace) {
        toMySpaceView.userInteractionEnabled = YES;
        toMySpaceView.backgroundColor = [UIColor whiteColor];
    }else{
        toMySpaceView.userInteractionEnabled = NO;
        toMySpaceView.backgroundColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1.0];
    }
   
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toSelectMySpaceView:)];
    [toMySpaceView addGestureRecognizer:tapGesture];
    [rightImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(toMySpaceView);
        make.right.equalTo(toMySpaceView).offset(-15);
        make.height.width.equalTo(@20);
    }];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(toMySpaceView).offset(15);
        make.left.equalTo(toMySpaceView).offset(8);
        make.height.equalTo(@30);
        make.width.equalTo(@35);
    }];
    
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageView.mas_right).offset(10);
        make.width.equalTo(@100);
        make.centerY.equalTo(imageView);
        make.height.equalTo(@30);
    }];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(toMySpaceView);
        make.left.equalTo(imageView).offset(5);
        make.bottom.equalTo(toMySpaceView);
        make.height.equalTo(@1.5);
    }];
    return toMySpaceView;
}
- (UIView *)commonInitHeaderViewWithItemTitle:(NSString *)title leftImageName:(NSString *)imageName {
    UIView *toProjectView = [[UIView alloc] init];
    toProjectView.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.font = [UIFont boldSystemFontOfSize:14];
    textLabel.text = title;
//    [toProjectView addSubview:imageView];
    [toProjectView addSubview:textLabel];
//    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(toProjectView).offset(15);
//        make.left.equalTo(toProjectView).offset(8);
//        make.height.equalTo(@30);
//        make.width.equalTo(@35);
//    }];
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(toProjectView).offset(10);
        make.width.equalTo(@100);
        make.centerY.equalTo(toProjectView);
        make.height.equalTo(@35);
    }];
    return toProjectView;
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSDictionary *dict = self.dataArray[section];
    NSString *item = dict.allKeys.firstObject;
    if ([item isEqualToString:@"workspace"] || [item isEqualToString:@"myspace"] ) {
        return 65;
    }else{
        return 30;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *dict = self.dataArray[section];
    NSArray *itemArray = dict.allValues.firstObject;
    return  itemArray.count;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view;
    NSDictionary *dict = self.dataArray[section];
    NSString *item = dict.allKeys.firstObject;
    if ([item isEqualToString:@"repository"]) {
       view = [self commonInitHeaderViewWithItemTitle:@"Repositories" leftImageName:@"Repositories-black"];
    }else if([item isEqualToString:@"project"]){
        view = [self commonInitHeaderViewWithItemTitle:@"Projects" leftImageName:@"Black_project-icon"];
    }else if([item isEqualToString:@"workspace"]){
        view = [self commonInitSaveToWorkSpaceViewItem];
    }else if([item isEqualToString:@"myspace"]){
        view = [self commonInitSaveToMySpaceViewItem];
    }
    return view;
   
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = self.dataArray[indexPath.section];
    NSString *item = dict.allKeys.firstObject;
    NSArray *itemArray = dict.allValues.firstObject;
    if ([item isEqualToString:@"repository"]) {
        NXRepoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"repoCell" forIndexPath:indexPath];
        cell.model = itemArray[indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
       
    }else if([item isEqualToString:@"project"]){
        NXAddToProjectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.model = itemArray[indexPath.row];
        [cell isShowAccessBtnIconImage:YES];
        return  cell;
    }
    return [[UITableViewCell alloc] init];
}
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSDictionary *dict = self.dataArray[indexPath.section];
//    NSArray *itemArray = dict.allValues.firstObject;
//    if (self.selectedItemModelCompletion) {
//        self.selectedItemModelCompletion(itemArray[indexPath.row]);
//    }
//}
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NXAddToProjectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
//    cell.model = self.dataArray[indexPath.row];
//    return cell;
//}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = self.dataArray[indexPath.section];
    NSArray *itemArray = dict.allValues.firstObject;
    id itemModel = itemArray[indexPath.row];
    if ([itemModel isKindOfClass:[NXProjectModel class]]) {
        self.fileOperationType = NXFileOperationTypeAddNXLFileToProject;
        self.targetProject = itemModel;
        NXFileChooseFlowViewController *vc = [[NXFileChooseFlowViewController alloc]initWithProject:itemModel type:NXFileChooseFlowViewControllerTypeChooseDestFolder];
       
        vc.fileChooseVCDelegate = self;

        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController presentViewController:vc animated:YES completion:nil];
        
//        NXAddToProjectLastVC *VC = [[NXAddToProjectLastVC alloc]init];
//        if (self.fileOperationType) {
//            VC.fileOperationType = self.fileOperationType;
//            if (self.fileOperationType == NXFileOperationTypeAddRepoProtectedFileToOther || self.fileOperationType == NXFileOperationTypeAddLocalProtectedFileToOther || self.fileOperationType == NXFileOperationTypeAddMyVaultFileToOther || self.fileOperationType == NXFileOperationTypeAddWorkSPaceFileToOther) {
//                VC.fileOperationType = NXFileOperationTypeAddProjectFileToProject;
//            }
//        }else{
//            VC.fileOperationType = NXFileOperationTypeAddProjectFileToProject;
//        }
//        VC.currentFile = self.currentFile;
//        VC.currentClassifiations = self.currentClassifications;
//        VC.toProject = itemModel;
//        VC.isAdhocEncrypted = self.isAdhocEncrypted;
//        VC.fileRights = self.fileRights;
//        VC.folder = [NXMyProjectManager rootFolderForProject:VC.toProject];
//        [self.navigationController pushViewController:VC animated:YES];
        
    }else if([itemModel isKindOfClass:[NXRepositoryModel class]]){
        self.fileOperationType = NXFileOperationTypeAddNXLFileToRepo;
        self.targetRepo = itemModel;
        NXFileChooseFlowViewController *vc = [[NXFileChooseFlowViewController alloc]initWithRepository:itemModel type:NXFileChooseFlowViewControllerTypeChooseDestFolder isSupportMultipleSelect:NO];
       
        vc.fileChooseVCDelegate = self;

        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController presentViewController:vc animated:YES completion:nil];
       
    }
    
}
- (void)toSelectWorkSpace:(id)sender {
    self.fileOperationType = NXFileOperationTypeAddNXLFileToWorkSpace;
    NXFileChooseFlowViewController *vc = [[NXFileChooseFlowViewController alloc]initWithWorkSpaceType:NXFileChooseFlowViewControllerTypeChooseDestFolder];
   
    vc.type = NXFileChooseFlowViewControllerTypeChooseDestFolder;
    vc.fileChooseVCDelegate = self;

    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:vc animated:YES completion:nil];
    
}
- (void)toSelectMySpaceView:(id)sender {
    NXAddToProjectLastVC *VC = [[NXAddToProjectLastVC alloc]init];
    VC.currentFile = self.operationFile;
    VC.isLocalFile = self.isLocalFile;

    VC.isAdhocEncrypted = self.isAdhocEncrypted;
    VC.fileRights = self.fileRights;
    VC.fileOperationType = NXFileOperationTypeAddNXLFileToMySpace;
    VC.folder = [[NXLoginUser sharedInstance].myVault getmyVaultRootFolder];
    [self.navigationController pushViewController:VC animated:YES];
}
- (void)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark ------> fileChooseDelegate
- (void)fileChooseFlowViewController:(NXFileChooseFlowViewController *)vc didChooseFile:(NSArray *)choosedFiles {
    if (choosedFiles.count) {
        self.saveFolder = choosedFiles.lastObject;
        if (self.fileOperationType == NXFileOperationTypeAddNXLFileToProject) {
            NXAddToProjectLastVC *VC = [[NXAddToProjectLastVC alloc]init];
            VC.isLocalFile = self.isLocalFile;
            VC.currentFile = self.operationFile;
            VC.currentClassifiations = self.currentClassifications;
            VC.isAdhocEncrypted = self.isAdhocEncrypted;
            VC.fileRights = self.fileRights;
            VC.fileOperationType = self.fileOperationType;
            VC.folder = self.saveFolder;
            VC.toProject = self.targetProject;
            [self.navigationController pushViewController:VC animated:YES];
            
        }else if(self.fileOperationType == NXFileOperationTypeAddNXLFileToRepo){
            NXAddToProjectLastVC *VC = [[NXAddToProjectLastVC alloc]init];
            VC.fileOperationType = NXFileOperationTypeAddNXLFileToRepo;
            if ([self.targetRepo.service_providerClass isEqualToString:NSLocalizedString(@"UI_PROVIDERCLASS_APPLICATION", NULL)]) {
                VC.fileOperationType = NXFileOperationTypeAddFileToSharedWorkspace;
            }
            VC.toRepoModel = self.targetRepo;
            VC.currentFile = self.operationFile;
            VC.isLocalFile = self.isLocalFile;
            VC.currentClassifiations = self.currentClassifications;
            VC.isAdhocEncrypted = self.isAdhocEncrypted;
            VC.fileRights = self.fileRights;
            VC.folder = self.saveFolder;
            [self.navigationController pushViewController:VC animated:YES];
        }else if(self.fileOperationType == NXFileOperationTypeAddNXLFileToWorkSpace){
            NXAddToProjectLastVC *VC = [[NXAddToProjectLastVC alloc]init];
            VC.currentFile = self.operationFile;
            VC.isLocalFile = self.isLocalFile;
            VC.currentClassifiations = self.currentClassifications;
            VC.isAdhocEncrypted = self.isAdhocEncrypted;
            VC.fileRights = self.fileRights;
            VC.fileOperationType = self.fileOperationType;
            VC.folder = self.saveFolder;
            [self.navigationController pushViewController:VC animated:YES];
            
        }
    
    }
}
- (void)fileChooseFlowViewControllerDidCancelled:(NXFileChooseFlowViewController *)vc {
    //
}
@end
