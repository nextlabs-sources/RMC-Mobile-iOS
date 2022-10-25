//
//  NXTargetPorjectsSelectVC.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/12/12.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXTargetPorjectsSelectVC.h"
#import "NXMBManager.h"
#import "NXMessageViewManager.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "Masonry.h"
#import "NXAddToProjectCell.h"
#import "UIView+UIExt.h"
#import "UIImage+ColorToImage.h"
#import "NXSharedWithProjectFile.h"
#import "NXFileChooseFlowViewController.h"
#import "NXProtectFileSelectSaveLocationSecondVC.h"
#import "NXProtectFileAfterSelectedLocationVC.h"
@interface NXTargetPorjectsSelectVC ()<UITableViewDelegate,UITableViewDataSource,NXFileChooseFlowViewControllerDelegate>
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) UIButton *nextBtn;
@property(nonatomic, strong) NSMutableDictionary *dataDictionary;
@property(nonatomic, strong) NSMutableArray *selectedProjects;
@property(nonatomic, strong)NXFileBase *targetFolder;
@property(nonatomic, strong)NXProjectModel *targetProject;
@end

@implementation NXTargetPorjectsSelectVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configurationNavigation];
    [self commonInit];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getNewDataFromAPIandReload];
}
- (void)configurationNavigation {
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    if (self.isForProtect) {
        self.navigationItem.title = NSLocalizedString(@"UI_SAVE_FILE_LOCATION", NULL);
    }else{
         self.navigationItem.title = @"Share";
    }
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
}
- (void)commonInit {
    self.dataDictionary = [NSMutableDictionary dictionary];
    self.selectedProjects = [NSMutableArray array];
    UITableView *tableView = [[UITableView alloc]init];
    tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsVerticalScrollIndicator = NO;
    if (!self.isForProtect) {
      tableView.allowsMultipleSelection = YES;
    }
    self.tableView = tableView;
    tableView.tableFooterView = [[UIView alloc]init];
    [tableView registerClass:[NXAddToProjectCell class] forCellReuseIdentifier:@"cell"];
    UIView *sectionView = [[UIView alloc]init];
    sectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    sectionView.bounds = CGRectMake(0, 0, self.view.frame.size.width, 40);
    UIImageView *headerView = [[UIImageView alloc]init];
    headerView.image = [UIImage imageNamed:@"Black_project-icon"];
    headerView.frame = CGRectMake(20, 10, 30, 30);
    [sectionView addSubview:headerView];
    UILabel *projectName = [[UILabel alloc]init];
    projectName.frame = CGRectMake(60, 10, 100, 30);
    projectName.text = @"Project";
    [sectionView addSubview:projectName];
    tableView.tableHeaderView = sectionView;
    tableView.tableFooterView = [[UIView alloc] init];
    tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UIButton *protectButton = [[UIButton alloc] init];
    protectButton.enabled = NO;
    [protectButton setTitle:@"Share" forState:UIControlStateNormal];
    [protectButton addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
    [protectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [protectButton setBackgroundImage:[UIImage imageWithSize:CGSizeMake(200, 200) colors:@[RMC_GRADIENT_START_COLOR, RMC_GRADIENT_END_COLOR] gradientType:GradientTypeLeftToRight] forState:UIControlStateNormal];
    [protectButton cornerRadian:3];
    [self.view addSubview:protectButton];
    self.nextBtn = protectButton;
    if (self.isForProtect) {
        self.nextBtn.hidden = YES;
    }
    
    if (IS_IPHONE_X) {
           if (@available(iOS 11.0, *)) {
               [protectButton mas_makeConstraints:^(MASConstraintMaker *make) {
                   make.centerX.equalTo(self.view);
                   make.width.equalTo(@300);
                   make.height.lessThanOrEqualTo(@(40));
                   make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-10);
               }];
               [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                   make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(5);
                   make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
                   make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
                   make.bottom.equalTo(protectButton.mas_top).offset(-10);
               }];
           }
    }else {
        [protectButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.width.equalTo(@300);
            make.height.lessThanOrEqualTo(@(40));
            make.bottom.equalTo(self.view).offset(-10);
        }];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuideBottom).offset(5);
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(protectButton.mas_top).offset(-10);
        }];
    }
}

#pragma mark ----- getNewDataAndreload UI
- (void)getNewDataFromAPIandReload {
    WeakObj(self);
    [[NXLoginUser sharedInstance].myProject allMyProjectsWithCompletion:^(NSArray *projectsCreatedByMe, NSArray *projectsInvitedByOthers, NSArray *pendingProjects, NSError *error) {
        StrongObj(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    NSMutableArray *byMeArray = [NSMutableArray arrayWithArray:projectsCreatedByMe];
                    NSMutableArray *byOtherArray = [NSMutableArray arrayWithArray:projectsInvitedByOthers];
                    if (self.fromProjectModel) {
                        if ([byMeArray containsObject:self.fromProjectModel]) {
                            [byMeArray removeObject:self.fromProjectModel];
                        }
                        if ([byOtherArray containsObject:self.fromProjectModel]) {
                            [byOtherArray removeObject:self.fromProjectModel];
                        }
                    }
                    for (NXProjectModel *model in self.sharedProjects) {
                        if ([byMeArray containsObject:model]) {
                            [byMeArray removeObject:model];
                        }
                        if ([byOtherArray containsObject:model]) {
                            [byOtherArray removeObject:model];
                        }
                    }
                    [self.dataDictionary removeAllObjects];
                    
                    if (byMeArray.count) {
                        [self.dataDictionary setValue:byMeArray forKey:@"me"];
                    }
                    if (byOtherArray.count) {
                        [self.dataDictionary setValue:byOtherArray forKey:@"others"];
                    }
                    if (!byOtherArray.count&&!byMeArray.count) {
                        [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:@"There are no more projects"  style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_OK", NULL) cancelActionTitle:nil OKActionHandle:^(UIAlertAction *action) {
                                [self dismissSelf];
                        } cancelActionHandle:nil inViewController:self position:self.view];
                    }
                    [self.tableView reloadData];
                }else{
                    [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:error.localizedDescription  style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_OK", NULL) cancelActionTitle:nil OKActionHandle:^(UIAlertAction *action) {
                        [self back:nil];
                    } cancelActionHandle:nil inViewController:self position:self.view];
                }
            });
    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = self.dataDictionary.allKeys[section];
    NSArray *dataArray = [self.dataDictionary valueForKey:key];
    return  dataArray.count;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *projectName = [[UILabel alloc]init];
    projectName.frame = CGRectMake(20, 10, 300, 30);
    NSString *key = self.dataDictionary.allKeys[section];
    NSArray *dataArray = [self.dataDictionary valueForKey:key];
    if ([key isEqualToString:@"me"]) {
        projectName.attributedText = [self createAttributeString:@"Projects created by " subTitle1:key subTitle2:[NSString stringWithFormat:@"(%ld)",dataArray.count]];
    }else if ([key isEqualToString:@"others"]){
         projectName.attributedText = [self createAttributeString:@"Projects invited by" subTitle1:key subTitle2:[NSString stringWithFormat:@"(%ld)",dataArray.count]];
    }
    [bgView addSubview:projectName];
    return bgView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataDictionary.allKeys.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NXAddToProjectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSString *key = self.dataDictionary.allKeys[indexPath.section];
    NSArray *dataArray = [self.dataDictionary valueForKey:key];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = dataArray[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    NSString *key = self.dataDictionary.allKeys[indexPath.section];
    NSArray *dataArray = [self.dataDictionary valueForKey:key];
    NXProjectModel *model = dataArray[indexPath.row];
    if (self.isForProtect) {
        [self goToSelectSavePath:model];
        return;
    }
    NXAddToProjectCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell isShowRightImageView:YES];
    if (![self.selectedProjects containsObject:model]) {
        [self.selectedProjects addObject:model];
    }
    self.nextBtn.enabled = YES;
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NXAddToProjectCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell isShowRightImageView:NO];
    NSString *key = self.dataDictionary.allKeys[indexPath.section];
    NSArray *dataArray = [self.dataDictionary valueForKey:key];
    NXProjectModel *model = dataArray[indexPath.row];
    if ([self.selectedProjects containsObject:model]) {
        [self.selectedProjects removeObject:model];
    }
    if (!self.selectedProjects.count) {
        self.nextBtn.enabled = NO;
    }
}

- (void)next:(id)sender {
    [NXMBManager showLoading];
    NSMutableArray *receipients = [NSMutableArray array];
    for (NXProjectModel *prjectModel in self.selectedProjects) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setValue:prjectModel.projectId forKey:@"projectId"];
        [receipients addObject:dictionary];
    }
    if ([self.currentFile isKindOfClass:[NXSharedWithProjectFile class]]) {
        [[NXLoginUser sharedInstance].sharedFileManager reshareProjectFile:(NXSharedWithProjectFile *)self.currentFile withReceivers:receipients withCompletion:^(NXSharedWithProjectFile *originalFile, NXSharedWithProjectFile *freshFile, NXSharedWithMeReshareProjectFileResponseModel *responseModel, NSError *error) {
            WeakObj(self);
               dispatch_main_async_safe((^{
                   StrongObj(self);
                   [NXMBManager hideHUD];
                   if (error) {
                       [NXMBManager showMessage:error.localizedDescription toView:self.view hideAnimated:YES afterDelay:kDelay];
                   }else{
                       [NXMessageViewManager showMessageViewWithTitle:self.currentFile.name details:NSLocalizedString(@"MSG_COM_SUCCESS_SHARED", NULL) appendInfo:nil appendInfo2:nil image:[UIImage imageNamed:@"Success - White tick"] dismissAfter:kDelay*2 type:NXMessageViewManagerTypeGreen];
                       [self performSelector:@selector(dismissSelf) withObject:nil afterDelay:kDelay*2 + 0.5];
                   }
               }));
            
        }];
        return;
    }
       
   
    [[NXLoginUser sharedInstance].nxlOptManager shareProjectFile:self.currentFile fromPorject:self.fromProjectModel toRecipinets:receipients comment:@" " withCompletion:^(NSString *sharedFileName, NSString *duid, NSArray *alreadySharedArray, NSArray *newSharedArray, NSError *error) {
        WeakObj(self);
            dispatch_main_async_safe((^{
                StrongObj(self);
                [NXMBManager hideHUD];
                if (error) {
                    [NXMBManager showMessage:error.localizedDescription toView:self.view hideAnimated:YES afterDelay:kDelay];
                }else{
                    if ([self.delegate respondsToSelector:@selector(successToShareProjects:)]) {
                        [self.delegate successToShareProjects:newSharedArray];
                        
                    }
                    [NXMessageViewManager showMessageViewWithTitle:self.currentFile.name details:NSLocalizedString(@"MSG_COM_SUCCESS_SHARED", NULL) appendInfo:nil appendInfo2:nil image:[UIImage imageNamed:@"Success - White tick"] dismissAfter:kDelay*2 type:NXMessageViewManagerTypeGreen];
                     [self performSelector:@selector(dismissSelf) withObject:nil afterDelay:kDelay*2 + 0.5];
                }
                
                
            }));
    }];
}
- (void)dismissSelf {
[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark   ----》NSAttributedString
- (NSAttributedString *)createAttributeString:(NSString *)title subTitle1:(NSString *)subtitle1 subTitle2:(NSString *)subTitle2 {
    NSMutableAttributedString *myprojects = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName :[UIColor lightGrayColor],NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    
    NSAttributedString *sub1 = [[NSMutableAttributedString alloc] initWithString:subtitle1 attributes:@{NSForegroundColorAttributeName :[UIColor blackColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:15]}];
    NSAttributedString *sub2 ;
    [myprojects appendAttributedString:sub1];
    if (subTitle2) {
         sub2 = [[NSMutableAttributedString alloc] initWithString:subTitle2 attributes:@{NSForegroundColorAttributeName :[UIColor lightGrayColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:15]}];
        [myprojects appendAttributedString:sub2];
    }
    
    return myprojects;
}
- (void)goToSelectSavePath:(NXProjectModel *)model {
    self.targetProject = model;
    NXFileChooseFlowViewController *VC = [[NXFileChooseFlowViewController alloc] initWithProject:model type:NXFileChooseFlowViewControllerTypeChooseDestFolder];
    VC.fileChooseVCDelegate = self;
    VC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:VC animated:YES completion:nil];
}
#pragma mark ------> fileChooseDelegate
- (void)fileChooseFlowViewController:(NXFileChooseFlowViewController *)vc didChooseFile:(NSArray *)choosedFiles {
    if (choosedFiles.count) {
        self.targetFolder = choosedFiles.lastObject;
    }
    NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
    VC.fileItem = self.currentFile;
    VC.saveFolder = self.targetFolder;
    VC.targetProject = self.targetProject;
    VC.locationType = NXProtectSaveLoactionTypeProject;
    [self.navigationController pushViewController:VC animated:NO];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)fileChooseFlowViewControllerDidCancelled:(NXFileChooseFlowViewController *)vc {
    //
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
