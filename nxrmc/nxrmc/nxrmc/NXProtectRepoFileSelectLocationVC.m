//
//  NXProtectRepoFileSelectLocationVC.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/5/26.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXProtectRepoFileSelectLocationVC.h"
#import "NXCustomTitleView.h"
#import "Masonry.h"
#import "UIImage+ColorToImage.h"
#import "UIView+UIExt.h"
#import "NXLoginUser.h"
#import "NXRepositoryModel.h"
#import "NXRepoCell.h"
#import "NXProtectFileSelectSaveLocationSecondVC.h"
#import "NXFileChooseFlowViewController.h"
#import "NXProtectFileAfterSelectedLocationVC.h"
@interface NXProtectRepoFileSelectLocationVC ()<UITableViewDelegate,UITableViewDataSource,NXFileChooseFlowViewControllerDelegate>
@property(nonatomic, strong)NSMutableArray *dataArray;
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)NXRepositoryModel *fileFormRepo;
@property(nonatomic, strong)NXFileBase *targetFolder;
@end

@implementation NXProtectRepoFileSelectLocationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataArray = [NSMutableArray array];
    if (self.fileItem.sorceType == NXFileBaseSorceTypeRepoFile) {
         NXRepositoryModel *repoModel =  [[NXLoginUser sharedInstance].myRepoSystem getRepositoryModelByRepoId:self.fileItem.repoId];
        if (repoModel.service_type.integerValue != kServiceSkyDrmBox) {
             [self.dataArray addObject:repoModel];
        }
    }
//    NXRepositoryModel *filesModel = [[NXRepositoryModel alloc] init];
//    filesModel.isAddItem = YES;
//    filesModel.service_alias = @"Files";
    NXRepositoryModel *skyDRMModel = [[NXRepositoryModel alloc] init];
    skyDRMModel.isAddItem = YES;
    skyDRMModel.service_alias = @"SkyDRM";
    [self.dataArray addObject:skyDRMModel];
    [self initNavigationBar];
    [self commonInitUI];
   
}
- (void)initNavigationBar {
    NXCustomTitleView *titleView = [[NXCustomTitleView alloc] init];
    titleView.text = NSLocalizedString(@"UI_SAVE_FILE_LOCATION", NULL);
    self.navigationItem.titleView = titleView;
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClicked:)];
    leftItem.accessibilityValue = @"UI_BOX_CANCEL";
    self.navigationItem.leftBarButtonItem = leftItem;
    self.automaticallyAdjustsScrollViewInsets = NO;
}
- (void)commonInitUI{
    if (!self.fileItem) {
        return;
    }
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *defaultSaveLabel = [[UILabel alloc] init];
    NSString *defaultPath;
    if (self.fileItem.sorceType == NXFileBaseSorceTypeLocalFiles || self.fileItem.sorceType == NXFileBaseSorceTypeLocal) {
        defaultPath = @"Files:/";
    }else{
        NXRepositoryModel *model = [[NXLoginUser sharedInstance].myRepoSystem getRepositoryModelByRepoId:self.fileItem.repoId];
        self.fileFormRepo = model;
        self.targetFolder = [[NXLoginUser sharedInstance].myRepoSystem parentForFileItem:self.fileItem];
        defaultPath = [NSString stringWithFormat:@"%@:%@",model.service_alias,[self.fileItem.fullPath stringByReplacingOccurrencesOfString:self.fileItem.name withString:@""]];
        if (model.service_type.integerValue == kServiceSkyDrmBox) {
            defaultPath = @"MyVault:/";
        }
    }
    defaultSaveLabel.attributedText = [self createAttributeString:@"File will be saved " subTitle:defaultPath];
    defaultSaveLabel.numberOfLines = 0;
    [self.view addSubview:defaultSaveLabel];
    defaultSaveLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UITableView *tableView = [[UITableView alloc] init];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    [tableView registerClass:[NXRepoCell class] forCellReuseIdentifier:@"cell"];
    tableView.tableFooterView = [[UIView alloc] init];
    self.tableView = tableView;
    
    UIButton *nextButton = [[UIButton alloc] init];
    [self.view addSubview:nextButton];
    nextButton.hidden = YES;
    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
    nextButton.accessibilityValue = @"NEXT_BTN";
    [nextButton addTarget:self action:@selector(nextBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextButton setBackgroundImage:[UIImage imageWithSize:CGSizeMake(200, 200) colors:@[RMC_GRADIENT_START_COLOR, RMC_GRADIENT_END_COLOR] gradientType:GradientTypeLeftToRight] forState:UIControlStateNormal];
    [nextButton cornerRadian:3];

    [defaultSaveLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(10);
            
        } else {
            make.top.equalTo(self.mas_topLayoutGuideBottom).offset(10);
        }
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.height.equalTo(@40);
    }];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(defaultSaveLabel.mas_bottom).offset(10);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(nextButton.mas_top).offset(-10);
    }];
    
   [nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
       make.centerX.equalTo(self.view);
       make.width.equalTo(@300);
       make.bottom.equalTo(self.view).offset(-20);
       make.height.lessThanOrEqualTo(@(40));
   }];

    
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NXRepoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.model = self.dataArray[indexPath.row];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NXRepositoryModel *model = self.dataArray[indexPath.row];
    if (model.isAddItem) {
        if ([model.service_alias isEqualToString:@"Files"]) {
            NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
            VC.fileItem = self.fileItem;
            VC.locationType = NXProtectSaveLoactionTypeLocalFiles;
            [self.navigationController pushViewController:VC animated:YES];
            
        }else{
            NXProtectFileSelectSaveLocationSecondVC *VC = [[NXProtectFileSelectSaveLocationSecondVC alloc] init];
            VC.fileItem = self.fileItem;
            [self.navigationController pushViewController:VC animated:YES];
        }
    }else{
        NXFileChooseFlowViewController *VC = [[NXFileChooseFlowViewController alloc] initWithRepository:model type:NXFileChooseFlowViewControllerTypeChooseDestFolder isSupportMultipleSelect:NO];
        VC.fileChooseVCDelegate = self;
        VC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController presentViewController:VC animated:YES completion:nil];
    }
}
- (void)cancelButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)nextBtnClick:(id)sneder {
    NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
    VC.fileItem = self.fileItem;
    if (self.fileItem.sorceType == NXFileBaseSorceTypeLocalFiles || self.fileItem.sorceType == NXFileBaseSorceTypeLocal) {
        VC.locationType = NXProtectSaveLoactionTypeLocalFiles;
    }else if (self.fileItem.sorceType == NXFileBaseSorceTypeRepoFile) {
        if (self.fileFormRepo.service_type.integerValue == kServiceSkyDrmBox) {
            VC.locationType = NXProtectSaveLoactionTypeMyVault;
        }else{
            VC.locationType = NXProtectSaveLoactionTypeFileRepo;
        }
    }
    VC.saveFolder = self.targetFolder;
    [self.navigationController pushViewController:VC animated:YES];
}
- (NSAttributedString *)createAttributeString:(NSString *)title subTitle:(NSString *)subtitle {
    NSMutableAttributedString *myprojects = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName :[UIColor darkTextColor],NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    
    NSAttributedString *sub1 = [[NSMutableAttributedString alloc] initWithString:subtitle attributes:@{NSForegroundColorAttributeName :[UIColor blackColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:14]}];
    [myprojects appendAttributedString:sub1];
    return myprojects;
}

#pragma mark ------> fileChooseDelegate
- (void)fileChooseFlowViewController:(NXFileChooseFlowViewController *)vc didChooseFile:(NSArray *)choosedFiles {
    if (choosedFiles.count) {
        self.targetFolder = choosedFiles.lastObject;
    }
    NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
    VC.fileItem = self.fileItem;
    VC.saveFolder = self.targetFolder;
    VC.locationType = NXProtectSaveLoactionTypeFileRepo;
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
