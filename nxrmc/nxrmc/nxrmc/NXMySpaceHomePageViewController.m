//
//  NXMySpaceHomePageViewController.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2020/4/22.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXMySpaceHomePageViewController.h"
#import "NXMySpaceHomePageTableViewCell.h"
#import "NXMySpaceHomePageRepoModel.h"
#import "NXRMCDef.h"
#import "NXCommonUtils.h"
#import "NXMyDriveGetUsageAPI.h"
#import "NXPullDownButton.h"
#import "NXMySpaceFilesPageViewController.h"
#import "NXMyVaultViewController.h"
#import "NXFilesViewController.h"
#import "NXFilesNavigationVC.h"
#import "NXMyDriveViewController.h"
#import "NXSharedWithMeContainerVC.h"
#import "NXSharedWithMeFileListParameterModel.h"
#import "NXNetworkHelper.h"
@interface NXMySpaceHomePageViewController ()<UITableViewDelegate,UITableViewDataSource,NXRepoSystemFileInfoDelegate>
@property (nonatomic,strong) UITableView *tableview;
@property (nonatomic,strong) NSArray *dataSourceArray;
@property(nonatomic, assign) BOOL isUp;
@property(nonatomic,assign) NSUInteger myVaultFilesTotalCount;

@end

@implementation NXMySpaceHomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataSourceArray = [[NSArray alloc] init];
    [self commonInit];
    [self initDataSource];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
      WeakObj(self);
        NXMyDriveGetUsageRequeset *usageApi = [[NXMyDriveGetUsageRequeset alloc]init];
        [usageApi requestWithObject:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
             StrongObj(self);
            NXMyDriveGetUsageResponse *usageResponse = (NXMyDriveGetUsageResponse *)response;
            if (!error && usageResponse.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) {
                NSDictionary *usageDic = @{@"usage":usageResponse.usage?:@0,@"myVaultUsage":usageResponse.myVaultUsage?:@0,@"quota":usageResponse.quota?:@0,@"vaultQuota":usageResponse.vaultQuota?:@0};
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateOneItems:0 withDict:usageDic];
                });
            }
        }];
    if (![[NXNetworkHelper sharedInstance] isNetworkAvailable]) {
       NSArray *myVaultFiles = [[NXLoginUser sharedInstance].myVault getAllMyVaultFileInCoreData];
        NSArray *sharedwithMeFiles = [[NXLoginUser sharedInstance].sharedFileManager getSharedWithMeFileListFromStorage];
        NXMySpaceHomePageRepoModel *myDriveitem = self.dataSourceArray[1];
         myDriveitem.filesCount = [NSString stringWithFormat:@" %lu files",(unsigned long)[[NXLoginUser sharedInstance].myRepoSystem allMyDriveFilesCount]];
         
         NXMySpaceHomePageRepoModel *myVaultitem = self.dataSourceArray[2];
        NSMutableArray *noDeletedFile = [NSMutableArray arrayWithArray:myVaultFiles];
                     for(NXMyVaultFile *file in myVaultFiles){
                         if (file.isDeleted == YES) {
                             [noDeletedFile removeObject:file];
                         }
                     }
         myVaultitem.filesCount = [NSString stringWithFormat:@" %lu files",noDeletedFile.count];
        
        NXMySpaceHomePageRepoModel *sharedWithMeItem = self.dataSourceArray[3];
        sharedWithMeItem.filesCount = [NSString stringWithFormat:@" %lu files",sharedwithMeFiles.count];
        [self.tableview reloadData];
    }else{
        NXMyVaultListParModel *myVaultModel = [[NXMyVaultListParModel alloc] init];
             [[NXLoginUser sharedInstance].myVault getMyVaultFileListUnderRootFolderWithFilterModel:myVaultModel shouldReadCache:NO withCompletion:^(NSArray *fileList, NXFileBase *parentFolder, NXMyVaultListParModel *filterModel, NSError *error) {
                 StrongObj(self);
                 
                 NSMutableArray *noDeletedFile = [NSMutableArray arrayWithArray:fileList];
                              for(NXMyVaultFile *file in fileList){
                                  if (file.isDeleted == YES) {
                                      [noDeletedFile removeObject:file];
                                  }
                              }
                 if (!error) {
                       _myVaultFilesTotalCount = noDeletedFile.count;
                 }else{
                     _myVaultFilesTotalCount = 0;
                 }
                 
                 NXMySpaceHomePageRepoModel *myDriveitem = self.dataSourceArray[1];
                  myDriveitem.filesCount = [NSString stringWithFormat:@" %lu files",(unsigned long)[[NXLoginUser sharedInstance].myRepoSystem allMyDriveFilesCount]];
                  
                  NXMySpaceHomePageRepoModel *myVaultitem = self.dataSourceArray[2];
                  myVaultitem.filesCount = [NSString stringWithFormat:@" %lu files",(unsigned long)_myVaultFilesTotalCount];
                 
                 NXMySpaceHomePageRepoModel *sharedWithMeItem = self.dataSourceArray[3];
                 dispatch_main_sync_safe((^{
                                    [self.tableview reloadData];
                                 }));
                  NXSharedWithMeFileListParameterModel *parModel = [[NXSharedWithMeFileListParameterModel alloc] init];
                 [[NXLoginUser sharedInstance].sharedFileManager getSharedWithMeFileListWithParameterModel:parModel shouldReadCache:NO wtihCompletion:^(NXSharedWithMeFileListParameterModel *parameterModel, NSArray *fileListArray, NSError *error) {
                     NSUInteger sharedWithMeCount = fileListArray.count;
                     sharedWithMeItem.filesCount = [NSString stringWithFormat:@" %lu files",(unsigned long)sharedWithMeCount];
                     dispatch_main_sync_safe((^{
                                         [self.tableview reloadData];
                                      }));
                 }];
             }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)commonInit{
    [self configureNavigationBar];
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    tableView.frame = self.view.frame;
    self.tableview = tableView;
    [self.view addSubview:tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[NXMySpaceHomePageTableViewCell class] forCellReuseIdentifier:@"homePageTableViewCell"];
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.view);
    }];
}

- (void)configureNavigationBar
{
    self.navigationItem.title = @"MySpace";
   
}

- (void)initDataSource{
    
    NXMySpaceHomePageRepoModel *mySpace =  [[NXMySpaceHomePageRepoModel alloc] initWithType:NXMySpaceHomePageRepoModelTypeMySpace title:@"MySpace" filesCount:@"0 files" Des:@"Store,protect,and share your files in MySpace" proportion:0.0 spaceUsedDesStr:@""];
    
    NXMySpaceHomePageRepoModel *myDrive =  [[NXMySpaceHomePageRepoModel alloc] initWithType:NXMySpaceHomePageRepoModelTypeMyDrive title:@"MyDrive" filesCount:@"0 files" Des:@"Store your files in MyDrive" proportion:0.0 spaceUsedDesStr:@""];
    
    NXMySpaceHomePageRepoModel *myVault =   [[NXMySpaceHomePageRepoModel alloc] initWithType:NXMySpaceHomePageRepoModelTypeMyVault title:@"MyVault" filesCount:@"0 files" Des:@"Share your rights protected files from MyVault" proportion:0.0 spaceUsedDesStr:@""];
    
     NXMySpaceHomePageRepoModel *sharedWithMe =  [[NXMySpaceHomePageRepoModel alloc] initWithType:NXMySpaceHomePageRepoModelTypeSharedWithMe title:@"Shared with me" filesCount:@"0 files" Des:@"Access files shared with me" proportion:0.0 spaceUsedDesStr:@""];
    
    NSMutableArray * dataArray = [NSMutableArray new];
    [dataArray addObject:mySpace];
    [dataArray addObject:myDrive];
    [dataArray addObject:myVault];
    [dataArray addObject:sharedWithMe];
    _dataSourceArray = [dataArray copy];
}

- (void)updateOneItems:(NSInteger)index withDict:(NSDictionary *)dic{
    NXMySpaceHomePageRepoModel *mySpaceitem = self.dataSourceArray[index];
    NXMySpaceHomePageRepoModel *item = self.dataSourceArray[index + 1];
    long long myDriveTotalUsageSize = [(NSNumber *)dic[@"quota"] longLongValue];
    long long myVaultTotalUsageSize = [(NSNumber *)dic[@"vaultQuota"] longLongValue];
    long long mySpaceTotalUsageSize = [(NSNumber *)dic[@"vaultQuota"] longLongValue];
    if([dic.allKeys.firstObject isEqualToString:@"workSpace"]){
        NSNumber *fileCount = dic[@"workSpace"][@"totalFiles"];
        NSNumber *usageNumber = dic[@"workSpace"][@"usage"];
        long usage = [usageNumber longValue];
        item.filesCount = [NSString stringWithFormat:@"%ld files",[fileCount longValue]];
        if (usage == 0) {
            item.spaceUsedDesStr = @"0 KB";
        }else{
            item.spaceUsedDesStr = [NSByteCountFormatter stringFromByteCount:usage countStyle:NSByteCountFormatterCountStyleBinary];
        }
    }else{
    
        long long myVaultUsageSize = [(NSNumber *)dic[@"myVaultUsage"] longLongValue];
        long long myDriveUsageSize = [(NSNumber *)dic[@"usage"] longLongValue] - [(NSNumber *)dic[@"myVaultUsage"] longLongValue];
        long long mySpaceUsageSize =  [(NSNumber *)dic[@"usage"] longLongValue];
        
        if (mySpaceUsageSize == 0) {
                   mySpaceitem.spaceUsedDesStr = @"0 KB";
                   mySpaceitem.proportion = 0.0;
               }else {
                   mySpaceitem.spaceUsedDesStr = [NSString stringWithFormat:@"%@ of %@ Used", [NSByteCountFormatter stringFromByteCount:mySpaceUsageSize countStyle:NSByteCountFormatterCountStyleBinary], [NSByteCountFormatter stringFromByteCount:mySpaceTotalUsageSize countStyle:NSByteCountFormatterCountStyleBinary]];
                   mySpaceitem.proportion = (mySpaceUsageSize) / (mySpaceTotalUsageSize * 1.0000000000);
               }

        if (myDriveUsageSize == 0) {
            item.spaceUsedDesStr = @"0 KB";
            item.proportion = 0.0;
            mySpaceitem.myDriveProportion = 0.0;
        }else {
            item.spaceUsedDesStr = [NSString stringWithFormat:@"%@", [NSByteCountFormatter stringFromByteCount:myDriveUsageSize countStyle:NSByteCountFormatterCountStyleBinary]];
            item.proportion = (myDriveUsageSize) / (myDriveTotalUsageSize * 1.0000000000);
            mySpaceitem.myDriveProportion =  item.proportion ;
        }

        NXMySpaceHomePageRepoModel *item2 = self.dataSourceArray[index+2];
        if (myVaultUsageSize == 0) {
            item2.spaceUsedDesStr = @"0 KB";
            item2.proportion = 0.0;
            mySpaceitem.myVaultProportion = 0.0;
        }else {
            item2.spaceUsedDesStr = [NSString stringWithFormat:@"%@", [NSByteCountFormatter stringFromByteCount:myVaultUsageSize countStyle:NSByteCountFormatterCountStyleBinary]];
            item2.proportion = (myVaultUsageSize) / (myVaultTotalUsageSize * 1.0000000000);
            mySpaceitem.myVaultProportion =  item2.proportion;
        }
    }
    
     [self.tableview reloadData];
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

#pragma --mark UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NXMySpaceHomePageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"homePageTableViewCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NXMySpaceHomePageRepoModel *model = self.dataSourceArray[indexPath.section];
    cell.model = model;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   // NXMySpaceFilesPageViewController *filesSwitchVC = [[NXMySpaceFilesPageViewController alloc] init];
    if (indexPath.section == 0) {
    }else{
         if (indexPath.section == 1) {
//             NXFilesViewController *filesVC = [[NXFilesViewController alloc] init];
//              [filesVC configureBackButton];
//             filesVC.forShowMyDrivePurpose = YES;
             NXMyDriveViewController * myDriveVC = [[NXMyDriveViewController alloc] init];
             self.currentmydriveVC = myDriveVC;
             [self.navigationController pushViewController:myDriveVC animated:NO];
           }
        
           if (indexPath.section == 2) {
//               filesSwitchVC.selectedType = NXMySpaceFilesPageSelectedTypeMyVault;
                 NXMyVaultViewController *myVaultVC = [[NXMyVaultViewController alloc] init];
               self.currentmydriveVC = nil;
                 [myVaultVC configureBackButton];
                 [self.navigationController pushViewController:myVaultVC animated:NO];
           }
        
        if (indexPath.section == 3) {
            NXSharedWithMeContainerVC *sharedWithMeContainerVC = [[NXSharedWithMeContainerVC alloc] init];
            self.currentmydriveVC = nil;
            [self.navigationController pushViewController:sharedWithMeContainerVC animated:NO];
        }
         
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataSourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   // NXMySpaceHomePageRepoModel *model = self.dataSourceArray[indexPath.section];
//    if (model.repoDescription.length > 0) {
//         return 175;
//    }else{
//        return 130;
//    }
    if (indexPath.section == 0) {
        return 165;
    }else{
        return 110;
    }
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
//    if (section == 0) {
//        return 70;
//    }
    return 18.0;
}


-(CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0;
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 30, 70)];
          UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, self.view.frame.size.width - 30, 45)];
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.numberOfLines = 0;
        titleLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        titleLabel.text = @"";
          [view addSubview:titleLabel];
        return view;
    }
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma --mark NXRepoSystemFileInfoDelegate

- (void)updateFileListFromParentFolder:(NXFileBase *)parentFolder resultFileList:(NSArray *)resultFileList error:(NSError *) error
{
    
}
- (void)didGetFileListUnderParentFolder:(NXFileBase *)parentFolder fileList:(NSArray *)fileList error:(NSError *)error
{
//     NXMySpaceHomePageRepoModel *myDriveitem = self.dataSourceArray[1];
//    myDriveitem.filesCount = [NSString stringWithFormat:@" %lu files",(unsigned long)[[NXLoginUser sharedInstance].myRepoSystem allMyDriveFilesCount]];
//
//    NXMySpaceHomePageRepoModel *myVaultitem = self.dataSourceArray[2];
//    myVaultitem.filesCount = [NSString stringWithFormat:@" %lu files",(unsigned long)_myVaultFilesTotalCount];
//    dispatch_main_sync_safe((^{
//       [self.tableview reloadData];
//    }));
}

@end
