//
//  NXProjectSummaryVC.m
//  Demo
//
//  Created by Bill (Guobin) Zhang on 5/8/17.
//  Copyright © 2017 Bill (Guobin) Zhang. All rights reserved.
//

#import "NXProjectSummaryVC.h"
#import "NXPresentNavigationController.h"

#import "Masonry.h"
#import "NXProjectMemberHeaderView.h"
#import "NXProjectModel.h"
#import "NXProjectFileItemCell.h"
#import "AppDelegate.h"
#import "NXCommonUtils.h"
#import "NXProjectFileListSearchResultViewController.h"
#import "NXFileActivityLogViewController.h"
#import "NXAlertView.h"
#import "NXFilePropertyVC.h"
#import "NXMBManager.h"
#import "NXLoginUser.h"
#import "UIView+UIExt.h"
#import "NXEmptyView.h"
#import "NXUpdateProjectInfoVC.h"
#import "NXLProfile.h"
#import "NXAddToProjectVC.h"
#import "NXShareViewController.h"
#import "NXAddToProjectFileInfoVC.h"
#import "NXNXLFileSharingSelectVC.h"
#import "NXProjectFileManageShareVC.h"
#import "NXMasterTabBarViewController.h"
#import "NXOriginalFilesTransfer.h"
#import "NXNetworkHelper.h"
@interface NXProjectSummaryVC ()<UITableViewDelegate,UITableViewDataSource,NXOperationVCDelegate,DetailViewControllerDelegate>
@property(nonatomic, strong)NSArray *dataArray;
@property(nonatomic, strong)UITableView *tableView;

@property(nonatomic, weak)NXProjectMemberHeaderView *memberHeaderView;
@property(nonatomic, weak)UIView *percentageView;
@property(nonatomic, weak)UIView *progressView;
@property(nonatomic, weak)UILabel *usageLabel;
@property(nonatomic, weak)UILabel *freeLabel;
@property(nonatomic, strong)UIView *headerView;
@property(nonatomic, strong)UIView *configurationView;
@property(nonatomic, strong)NXEmptyView *emptyView;
@end

@implementation NXProjectSummaryVC
- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSArray array];
    }
    return _dataArray;
}
- (NXEmptyView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[NXEmptyView alloc]init];
        _emptyView.textLabel.text = NSLocalizedString(@"UI_NO_RECENT_FILE", NULL);
        _emptyView.imageView.image = [UIImage imageNamed:@"emptyFolder"];
        [self.view addSubview:_emptyView];
        
        if (_configurationView) {
            [_emptyView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_configurationView.mas_bottom);
                make.left.right.equalTo(self.view);
                make.bottom.equalTo(self.view);
            }];
        } else {
            [_emptyView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.headerView.mas_bottom);
                make.left.right.equalTo(self.view);
                make.bottom.equalTo(self.view);
            }];
        }
    }
    return _emptyView;
}

- (UIView *)configurationView {
    if (!_configurationView) {
        _configurationView = [[UIView alloc]init];
        [self.view addSubview:_configurationView];
        _configurationView.backgroundColor = [UIColor colorWithRed:248/256.0 green:248/256.0 blue:248/256.0 alpha:1];
        UIImageView *leftImageView = [[UIImageView alloc]init];
        leftImageView.image = [UIImage imageNamed:@"Settings.png"];
        [_configurationView addSubview:leftImageView];
        UILabel *configurationLabel = [[UILabel alloc]init];
        configurationLabel.text = NSLocalizedString(@"UI_PROJECT_CONFIGURATION",NULL);
        [_configurationView addSubview:configurationLabel];
        UIImageView *rightImageView = [[UIImageView alloc]init];
        rightImageView.image = [UIImage imageNamed:@"right chevron - black"];
        [_configurationView addSubview:rightImageView];
        UITapGestureRecognizer *tapGetRer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(configurationProject:)];
        [_configurationView addGestureRecognizer:tapGetRer];
        
        if (IS_IPHONE_X) {
            if (@available(iOS 11.0, *)) {
                
                [leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(_configurationView.mas_safeAreaLayoutGuideCenterY);
                    make.left.equalTo(_configurationView.mas_safeAreaLayoutGuideLeft).offset(15);
                    make.width.and.height.equalTo(@30);
                }];
                [configurationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(_configurationView.mas_safeAreaLayoutGuideCenterY);
                    make.left.equalTo(leftImageView.mas_right).offset(10);
                    make.height.equalTo(@30);
                }];
                [rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(_configurationView.mas_safeAreaLayoutGuideCenterY);
                    make.right.equalTo(_configurationView.mas_safeAreaLayoutGuideRight).offset(-10);
                    make.width.equalTo(@10);
                    make.height.equalTo(@15);
                }];
            }
        }
        else
        {
            [leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_configurationView);
                make.left.equalTo(_configurationView).offset(15);
                make.width.and.height.equalTo(@30);
            }];
            [configurationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_configurationView);
                make.left.equalTo(leftImageView.mas_right).offset(10);
                make.height.equalTo(@30);
            }];
            [rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_configurationView);
                make.right.equalTo(_configurationView).offset(-10);
                make.width.equalTo(@10);
                make.height.equalTo(@15);
            }];
        }
    }
    return _configurationView;
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self commonInit];
    [NXMBManager showLoadingToView:self.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseToProjectMemberUpdate:) name:NOTIFICATION_PROJECT_MEMBER_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableview:) name:NOTIFICATION_MARK_AS_OFFLINE_VC_NEED_UPDATE object:nil];
}

- (void)responseToProjectMemberUpdate:(NSNotification *)notification
{
    self.projectModel = [[NXLoginUser sharedInstance].myProject getProjectModelForProjectId:self.projectModel.projectId];
    NSMutableArray *itemNames = [NSMutableArray array];
    for (NXProjectMemberModel *item in self.projectModel.homeShowMembers) {
        [itemNames addObject:item.displayName];
    }
    if (self.projectModel.totalMembers > self.projectModel.homeShowMembers.count) {
        for (int i = 0; i < self.projectModel.totalMembers - self.projectModel.homeShowMembers.count; i++) {
            [itemNames addObject:@""];
        }
    }
    self.memberHeaderView.items = itemNames;
}

- (void)refreshTableview:(NSNotification *)notification
{
    [self.tableView reloadData];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getNewDataAndreloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PROJECT_MASTER_TABBAR_ADDBUTTON_NEED_DISPLAY object:nil];
}

#pragma mark
//- (void)search:(id)sender {
//    
//}
//
//- (void)more:(id)sender {
//    
//}
- (void)configureNavigationBarButtons{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(backToAllProjects:)];
    self.navigationItem.leftBarButtonItems = @[backItem];
    
}
- (void)commonInit {
   
    [self configureNavigationBarButtons];
    UIView *headerView = [[UIView alloc]init];
    headerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headerView];
    self.headerView = headerView;
    
    UIView *percentageView = [[UIView alloc]init];
    percentageView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:percentageView];
    percentageView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.percentageView = percentageView;
    UIView *progressView = [[UIView alloc]init];
    [percentageView addSubview:progressView];
    progressView.backgroundColor = RMC_MAIN_COLOR;
    self.progressView = progressView;
    UILabel *usageLabel = [[UILabel alloc]init];
    [headerView addSubview:usageLabel];
    self.usageLabel = usageLabel;
    UILabel *freeLabel = [[UILabel alloc]init];
    [headerView addSubview:freeLabel];
    self.freeLabel = freeLabel;
    
    UILabel *descriptionLabel = [[UILabel alloc]init];
    descriptionLabel.font = [UIFont systemFontOfSize:14];
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    descriptionLabel.numberOfLines = 0;
    NSString *descrStr = [self.projectModel.projectDescription stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    descrStr = [descrStr stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    descriptionLabel.text = descrStr;
    CGSize descriptionLabelSize = [self sizeOfLabelWithCustomMaxWidth:self.navigationController.view.bounds.size.width-40 systemFontSize:14 andFilledTextString:descrStr];
    [headerView addSubview:descriptionLabel];
    NXProjectMemberHeaderView *memberView = [[NXProjectMemberHeaderView alloc]init];
//    memberView.maxCount = 8;
    NSMutableArray *itemNames = [NSMutableArray array];
    for (NXProjectMemberModel *item in self.projectModel.homeShowMembers) {
        [itemNames addObject:item.displayName];
    }
    if (self.projectModel.totalMembers > self.projectModel.homeShowMembers.count) {
        for (int i = 0; i < self.projectModel.totalMembers - self.projectModel.homeShowMembers.count; i++) {
            [itemNames addObject:@""];
        }
    }
    memberView.items = itemNames;
    CGFloat widthPID ;
    if (itemNames.count >= 6) {
        widthPID = 35 * 6 + 5;
    }else {
        widthPID = itemNames.count * 35 + 5;
    }
    [headerView addSubview:memberView];
    UITapGestureRecognizer *tapGetRer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickHeadImage:)];
    [memberView addGestureRecognizer:tapGetRer];
    self.memberHeaderView = memberView;
    
    UIView *lineView = [[UIView alloc]init];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [headerView addSubview:lineView];
    
    UITableView *tableView = [[UITableView alloc]init];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[NXProjectFileItemCell class] forCellReuseIdentifier:@"cell"];
    tableView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    tableView.cellLayoutMarginsFollowReadableWidth = NO;
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.left.right.equalTo(self.view);
    }];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(headerView);
        make.left.right.equalTo(headerView);
        make.height.equalTo(@1);
    }];
    [percentageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerView).offset(5);
        make.left.equalTo(headerView).offset(40);
        make.right.equalTo(headerView).offset(-40);
        make.height.equalTo(@10);
    }];
    [usageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(percentageView.mas_bottom).offset(4);
        make.left.equalTo(percentageView);
        make.width.equalTo(percentageView).multipliedBy(0.5);
        make.height.equalTo(@10);
        
    }];
    [freeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.width.height.equalTo(usageLabel);
        make.right.equalTo(percentageView);
    }];
    [descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(usageLabel.mas_bottom).offset(5);
        make.left.equalTo(headerView).offset(20);
        make.right.equalTo(headerView).offset(-20);
        make.height.equalTo(@(descriptionLabelSize.height+5));
    }];
    
    [memberView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(descriptionLabel.mas_bottom).offset(10);
        make.centerX.equalTo(headerView);
        make.width.equalTo(@(widthPID));
        make.height.equalTo(@40);
        make.bottom.equalTo(headerView).offset(-5);
    }];
    if (self.projectModel.isOwnedByMe) {
        [self.configurationView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(headerView.mas_bottom);
            make.left.right.equalTo(self.view);
            make.height.equalTo(@55);
        }];
        [tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.configurationView.mas_bottom);
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
        }];
    } else {
        [tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(headerView.mas_bottom);
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
        }];
    }
    
}
#pragma mark ------>tableView delegate and dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NXProjectFileItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NXFileBase *fileModel = self.dataArray[indexPath.row];
    cell.model = fileModel;
    cell.projectModel = self.projectModel;
    WeakObj(self);
    cell.swipeButtonBlock = ^(SwipeButtonType type){
        StrongObj(self);
        if (type == SwipeButtonTypeDelete) {
            [self fileListResultVC:nil didSelectItem:fileModel];
        } else if (type == SwipeButtonTypeActiveLog) {
            [self fileListResultVC:nil infoForItem:fileModel];
        }
    };
    
    cell.accessBlock = ^(id sender) {
        StrongObj(self);
        //        [self fileListResultVC:nil propertyForItem:fileModel];
        [self fileListResultVC:nil accessForItem:fileModel];
    };
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NXFileBase *fileModel = self.dataArray[indexPath.row];
    NXFileState state =[[NXOfflineFileManager sharedInstance] currentState:fileModel];
    if (state == NXFileStateOfflined) {
        fileModel.isOffline = YES;
    }
    if([fileModel isKindOfClass:[NXProjectFile class]]){
        AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [app showFileItem:fileModel from:self withDelegate:self];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count?1:0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *bgView= [[UIView alloc]init];
    bgView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *repositoriesLabel = [[UILabel alloc]init];
    repositoriesLabel.text = NSLocalizedString(@"UI_RECENT_FILES", NULL);
    repositoriesLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [bgView addSubview:repositoriesLabel];
    [repositoriesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.height.equalTo(bgView);
        make.left.equalTo(bgView).offset(10);
    }];
    
    return bgView;
}
#pragma -mark NXProjectFileListSearchResultDelegate
- (void)fileListResultVC:(NXProjectFileListSearchResultViewController *)resultVC didSelectItem:(NXFileBase *)item {
    [resultVC.view removeFromSuperview];
    NXFileBase *selectedFileItem = item;
    
    if([selectedFileItem isKindOfClass:[NXProjectFile class]]){
    
        AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [app showFileItem:selectedFileItem from:self withDelegate:self];
    }
}
#pragma -mark  file operation
- (void)fileListResultVC:(NXProjectFileListSearchResultViewController *)resultVC infoForItem:(NXFileBase *)item
{
    NXFileActivityLogViewController *logActivityVC = [[NXFileActivityLogViewController alloc]init];
    logActivityVC.fileItem = item;
    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc]initWithRootViewController:logActivityVC];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)fileListResultVC:(NXProjectFileListSearchResultViewController *)resultVC accessForItem:(NXFileBase *)item {
    [NXMBManager showLoading];
    [[NXLoginUser sharedInstance].nxlOptManager getNXLFileRights:item withWatermark:NO withCompletion:^(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray<NXWatermarkWord *> *waterMarkWords, NSString *owner, BOOL isOwner, NSError *error) {
        BOOL isValidity = YES;
        
        if (rights.getVaildateDateModel) {
            
            if (![NXCommonUtils checkNXLFileisValid:[rights getVaildateDateModel]]) {
                 isValidity = NO;
             }
        }
        if(error){
            isValidity = NO;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [NXMBManager hideHUD];
            NXFileState state =[[NXOfflineFileManager sharedInstance] currentState:item];
             if (state == NXFileStateOfflined) {
                 item.isOffline = YES;
             }
             NXAlertView *alertView = [NXAlertView alertViewWithTitle:item.name andMessage:self.projectModel.name];
             WeakObj(self);
             if ([item isKindOfClass:[NXProjectFile class]]) {
                 [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_VIEW_FILE", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                     StrongObj(self);
                     [self fileListResultVC:nil didSelectItem:item];
                 }];
                 
                 [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_VIEW_FILE_INFO", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                     [self fileListResultVC:nil propertyForItem:item];
                 }];
                 if ([[NXNetworkHelper sharedInstance] isNetworkAvailable] && !error && isValidity && ([rights DecryptRight] || ([[NXLoginUser sharedInstance] isProjectAdmin] && [rights ViewRight]))) {
                     [alertView addItemWithTitle:NSLocalizedString(@"UI_ADD_FILE_TO", NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {

                         NXAddToProjectVC *VC = [[NXAddToProjectVC alloc]init];
                         VC.currentFile = item;
                         VC.fromProjectModel = self.projectModel;
                         VC.fileOperationType = NXFileOperationTypeAddProjectFileToProject;

                         UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:VC];
                         nav.modalPresentationStyle = UIModalPresentationFullScreen;
                         [self presentViewController:nav animated:YES completion:nil];
                     }];
                 }else{
                     [alertView addItemWithTitle:NSLocalizedString(@"UI_ADD_FILE_TO", NULL) type:NXAlertViewItemTypeClickForbidden handler:^(NXAlertView *alertView) {
                         
                     }];
                     
                 }
                 if ([[NXNetworkHelper sharedInstance] isNetworkAvailable] && isValidity && ([rights DownloadRight] || ([[NXLoginUser sharedInstance] isProjectAdmin] && [rights ViewRight]))) {
                     [alertView addItemWithTitle:@"Save as" type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                         [NXMBManager showLoading];

                         [[NXLoginUser sharedInstance].nxlOptManager saveAsNXlFileToLocal:item  withCompletion:^(NXFileBase *file, NSError *error) {
                             if (error) {
                                                     [[NXWebFileManager sharedInstance] saveAsFile:(NXFileBase<NXWebFileDownloadItemProtocol> *)item toDownloadType:0 completed:^(NXFileBase *file, NSData *fileData, NSError *error) {
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             [NXMBManager hideHUD];
                                                             if (error) {
                                                                 [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:1.5];

                                                             }else{
                                                                 [[NXOriginalFilesTransfer sharedIInstance] exportFile:file toOriginalFilesFromVC:self];
                                                                 [NXOriginalFilesTransfer sharedIInstance].exprotFileCompletion = ^(UIViewController *currentVC, NSURL *fileUrl, NSError *error1) {

                                                                     if (error1) {
                                                                     [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:1.5];
                                                                     }
                                                                 };
                                                             }
                                                         });

                                                     }];
                             }else{
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                    [NXMBManager hideHUD];
                                    [[NXOriginalFilesTransfer sharedIInstance] exportFile:file toOriginalFilesFromVC:self];
                                    [NXOriginalFilesTransfer sharedIInstance].exprotFileCompletion = ^(UIViewController *currentVC, NSURL *fileUrl, NSError *error1) {

                                        if (error1) {
                                        [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:1.5];
                                        }
                                    };

                                });
                             }


                         }];
                     }];
                     
                 }else{
                     [alertView addItemWithTitle:@"Save as" type:NXAlertViewItemTypeClickForbidden handler:^(NXAlertView *alertView) {
                         
                     }];
                     
                 }
                 if (self.projectModel.isOwnedByMe) {
                     [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_VIEW_ACTIVITY", NULL)   type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                         StrongObj(self);
                         [self fileListResultVC:nil infoForItem:item];
                     }];
                 }
         //        [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_SHARE",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
         //            NXProjectFileManageShareVC *vc = [[NXProjectFileManageShareVC alloc] init];
         //            vc.fileItem = item;
         //            vc.fromProjectModel = self.projectModel;
         //            NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:vc];
         //            [self.navigationController presentViewController:nav animated:YES completion:nil];
         //        }];
                
                 // only project admin can modify rights
                 if ([[NXLoginUser sharedInstance] isProjectAdmin]) {
                     [alertView addItemWithTitle:NSLocalizedString(@"UI_RECLASSIFY",NULL) type:NXAlertViewItemTypeDefault handler:^(NXAlertView *alertView) {
                         NXAddToProjectFileInfoVC *vc = [[NXAddToProjectFileInfoVC alloc] init];
                         NXProjectFile *projectFileItem = (NXProjectFile *)item;
                         projectFileItem.projectId = self.projectModel.projectId;
                         vc.currentFile = projectFileItem;
                         vc.toProject = self.projectModel;
                         vc.fileOperationType = NXFileOperationTypeProjectFileReclassify;
                         NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:vc];
                         [self.navigationController presentViewController:nav animated:YES completion:nil];
                     }];
                     
                 }
                 
             }
             if (self.projectModel.isOwnedByMe || [[NXLoginUser sharedInstance] isProjectAdmin]) {
                 [alertView addItemWithTitle:NSLocalizedString(@"UI_COM_OPT_DELETE", NULL) type:NXAlertViewItemTypeDestructive handler:^(NXAlertView *alertView) {
                     StrongObj(self);
                     [self fileListResultVC:nil deleteItem:item];
                 }];
             }
             
             alertView.transitionStyle = NXAlertViewTransitionStyleSlideFromBottom;
             [alertView show];
            
            
        });
    }];
    
   
}
- (void)fileListResultVC:(NXProjectFileListSearchResultViewController *)resultVC propertyForItem:(NXFileBase *)item
{
    NXFilePropertyVC *property = [[NXFilePropertyVC alloc] init];
    property.fileItem = item;
    //    property.isFromProjectFile = YES;
    NSString *currentUserId = [NXLoginUser sharedInstance].profile.userId;
    NXProjectFile *file = (NXProjectFile *)item;
    NSNumber *currentFileUserId = file.projectFileOwner.userId;
    if ([[currentFileUserId stringValue] isEqualToString:currentUserId]) {
        property.isSteward = YES;
    }else {
        property.isSteward = NO;
    }
    property.delegate = self;
    
    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:property];
    [self presentViewController:nav animated:YES completion:nil];
}
- (void)fileListResultVC:(NXProjectFileListSearchResultViewController *)resultVC deleteItem:(NXFileBase *)item
{
    NSString *message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"MSG_COM_DELETE_FILE_WARNING", NULL), item.name];
    WeakObj(self);
    [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message: message style:UIAlertControllerStyleAlert cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherActionTitles:@[NSLocalizedString(@"UI_BOX_OK", NULL)] inViewController:self position:self.view tapBlock:^(UIAlertAction *action, NSInteger index) {
        if (index == 1) { // user deside to delete this file
            StrongObj(self);
            [NXMBManager showLoadingToView:self.view];
            [[NXLoginUser sharedInstance].myProject removeFileItem:item withCompletion:^(NXFileBase *fileItem, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        [NXMBManager hideHUDForView:self.view];
                        [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_DELETE_FILE_FAILED", NULL) hideAnimated:YES afterDelay:kDelay];
                    }else{
                        [self getNewDataAndreloadData];
                    }
                });
            }];
        }
    }];
}
#pragma mark -----> getData
- (void)getNewDataAndreloadData {
    WeakObj(self);
    self.projectModel = [[NXLoginUser sharedInstance].myProject getProjectModelForProjectId:self.projectModel.projectId];
    NSMutableArray *itemNames = [NSMutableArray array];
    for (NXProjectMemberModel *item in self.projectModel.homeShowMembers) {
        [itemNames addObject:item.displayName];
    }
    if (self.projectModel.totalMembers > self.projectModel.homeShowMembers.count) {
        for (int i = 0; i < self.projectModel.totalMembers - self.projectModel.homeShowMembers.count; i++) {
            [itemNames addObject:@""];
        }
    }
    self.memberHeaderView.items = itemNames;
    [[NXLoginUser sharedInstance].myProject getFileListRecentFileForProject:self.projectModel withCompletion:^(NXProjectModel *project, NSArray *fileList,NSDictionary *spaceDict, NSError *error) {
      StrongObj(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *usedArray = [NSMutableArray array];
            [NXMBManager hideHUDForView:self.view];
            if (!error) {
                for (NXFileBase *item  in fileList) {
                    if ([item isKindOfClass:[NXProjectFile class]]) {
                        [usedArray addObject:item];
                    }
                }
                if (spaceDict) {
                    [self setProjectSpaceWithSpaceDictionary:spaceDict];
                }
                self.dataArray = [self sortByKey:@"lastModifiedDate" fromArray:usedArray];
                if (self.dataArray.count == 0) {
                    self.emptyView.hidden = NO;
                    self.tableView.hidden = YES;
                }else {
                    self.emptyView.hidden = YES;
                    self.tableView.hidden = NO;
                    [self.tableView reloadData];
                }
                
            }else {
                if (error.code == NXRMC_ERROR_CODE_PROJECT_KICKED ) {
                    return ;
                }
                [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:2.0];
            }
        });
        
    }];
}
#pragma mark ----> click memberView
- (void)clickHeadImage:(id)sender {

    [self.tabBarController setSelectedIndex:3];
}
- (void)configurationProject:(id)sender {
    NXUpdateProjectInfoVC *VC = [[NXUpdateProjectInfoVC alloc]init];
    VC.needUpdateProjectModel = self.configurationModel;
    VC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:VC animated:YES];
}
//- (void)search:(id)sender {
//    
//}
//
//- (void)more:(id)sender {
//    
//}

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
#pragma mark - DetailViewControllerDelegate
- (void)detailViewController:(DetailViewController *)detailVC SwipeToPreFileFrom:(NXFileBase *)file
{
    NSArray *fileArray = self.dataArray;
    NSUInteger index = [fileArray indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NXFileBase *fileObj = (NXFileBase *)obj;
        if ([fileObj.fullServicePath isEqualToString:file.fullServicePath]) {
            *stop = YES;
            return YES;
        }else{
            *stop = NO;
            return NO;
        }
    }];
    if (index == 0 || index == NSNotFound) {
        // first file item, show alert
        [detailVC showAutoDismissLabel:NSLocalizedString(@"MSG_COM_SWIPE_NO_MORE_FILE_TO_SHOW", nil)];
        return;
    }
    
    NXFileBase *newfile = fileArray[index - 1];
    [detailVC openFile:newfile];
    [self.tableView reloadData];
}
- (void)detailViewController:(DetailViewController *)detailVC SwipeToNextFileFrom:(NXFileBase *)file
{
    NSArray *fileArray = self.dataArray;
    NSUInteger index = [fileArray indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NXFileBase *fileObj = (NXFileBase *)obj;
        if ([fileObj.fullServicePath isEqualToString:file.fullServicePath]) {
            *stop = YES;
            return YES;
        }else{
            *stop = NO;
            return NO;
        }
    }];
    if (index == fileArray.count - 1 || index == NSNotFound) {
        // first file item, show alert
        [detailVC showAutoDismissLabel:NSLocalizedString(@"MSG_COM_SWIPE_NO_MORE_FILE_TO_SHOW", nil)];
        return;
    }
    
    NXFileBase *newfile = fileArray[index + 1];
    [detailVC openFile:newfile];
    [self.tableView reloadData];
}

- (void)setProjectSpaceWithSpaceDictionary:(NSDictionary *)spaceDict {
    if (!spaceDict) {
        return;
    }
    NSNumber *projectUsage = spaceDict[@"usage"];
    NSNumber *projectQuota = spaceDict[@"quota"];
    NSString *usageStr = [NSByteCountFormatter stringFromByteCount:[projectUsage floatValue] countStyle:NSByteCountFormatterCountStyleBinary];
    self.usageLabel.textColor = [UIColor grayColor];
    self.usageLabel.font = [UIFont systemFontOfSize:10];
    self.usageLabel.text = [NSString stringWithFormat:@"%@ used",usageStr];
    if ([projectUsage floatValue] == 0) {
        self.usageLabel.text = @"0 KB used";
    }
    NSString *freeStr = [NSByteCountFormatter stringFromByteCount:[projectQuota floatValue] - [projectUsage floatValue] countStyle:NSByteCountFormatterCountStyleBinary];
    self.freeLabel.text = [NSString stringWithFormat:@"%@ free",freeStr];
    self.freeLabel.font = [UIFont systemFontOfSize:10];
    self.freeLabel.textAlignment = NSTextAlignmentRight;
    float usagePercentage = [projectUsage floatValue]/[projectQuota floatValue];
    if (usagePercentage > 0 && usagePercentage < 0.01) {
        usagePercentage = 0.01;
    }
    [self.progressView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.height.equalTo(self.percentageView);
        make.width.equalTo(self.percentageView).multipliedBy(usagePercentage);
    }];
}
- (void)backToAllProjects:(id)sender {
    UITabBarController *tabVC = self.tabBarController.navigationController.viewControllers.firstObject;
    if ([tabVC isKindOfClass:[NXMasterTabBarViewController class]]) {
        [self.tabBarController.navigationController popToRootViewControllerAnimated:YES];
        [tabVC setSelectedIndex:kNXMasterTabBarControllerIndexAllProjects];
    }else{
        NXMasterTabBarViewController *tabBarVC = [[NXMasterTabBarViewController alloc] init];
        [tabBarVC setSelectedIndex:kNXMasterTabBarControllerIndexAllProjects];
        [self.tabBarController.navigationController pushViewController:tabBarVC animated:YES];
    }
    
}
#pragma mark --->sort by createdTime
- (NSMutableArray *)sortByKey:(NSString *)key fromArray:(NSArray *)array {
    NSMutableArray * resultArray = [NSMutableArray arrayWithArray:array];
    NSSortDescriptor *sortCreateTime = [[NSSortDescriptor alloc] initWithKey:key ascending:NO];
    [resultArray sortUsingDescriptors:@[sortCreateTime]];
    return resultArray;
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
