//
//  NXSkyDRMItemsView.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/6/3.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXSkyDRMItemsView.h"
#import "Masonry.h"
#import "NXTargetPorjectsSelectVC.h"
#import "NXProtectFileAfterSelectedLocationVC.h"
#import "NXFileChooseFlowViewController.h"
#import "NXAddToProjectCell.h"
#import "NXProjectModel.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXMBManager.h"
#import "NXRepoTableViewCell.h"

@interface NXSkyDRMItemsView ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)NSArray *projectsArray;
@property(nonatomic, strong)NSArray *reposArray;
@property(nonatomic, strong)NSMutableArray <NSDictionary *> *dataArray;
@end
@implementation NXSkyDRMItemsView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
        [self getNewDataFromAPIandReload];
    }
    return self;
}
- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (void)getNewDataFromAPIandReload {
    WeakObj(self);
    [self.dataArray removeAllObjects];
    if ([NXCommonUtils isSupportWorkspace]) {
        [self.dataArray addObject:@{@"workspace":[NSArray array]}];
    }
    [self.dataArray addObject:@{@"mySpace":[NSArray array]}];
    self.reposArray = [[NXLoginUser sharedInstance].myRepoSystem allAuthReposioriesExceptMyDrive];
    if (self.reposArray.count > 0) {
        NSDictionary *repoDict = @{@"repository":self.reposArray};
        [self.dataArray addObject:repoDict];
    }
    [[NXLoginUser sharedInstance].myProject allMyProjectsWithCompletion:^(NSArray *projectsCreatedByMe, NSArray *projectsInvitedByOthers, NSArray *pendingProjects, NSError *error) {
        StrongObj(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                NSMutableArray *allProjectArray = [NSMutableArray arrayWithArray:projectsCreatedByMe];
                    [allProjectArray addObjectsFromArray:projectsInvitedByOthers];
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
}
- (void)commonInit{
    self.projectsArray = [NSArray array];
    self.backgroundColor = [UIColor whiteColor];
    UITableView *tableView = [[UITableView alloc]init];
    tableView.backgroundColor = [UIColor whiteColor];
    [self addSubview:tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsVerticalScrollIndicator = NO;
    self.tableView = tableView;
    tableView.tableFooterView = [[UIView alloc]init];
    [tableView registerClass:[NXAddToProjectCell class] forCellReuseIdentifier:@"cell"];
    [tableView registerClass:[NXRepoTableViewCell class] forCellReuseIdentifier:@"repoCell"];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}
- (UIView *)commonInitHeaderViewWithItemTitle:(NSString *)title leftImageName:(NSString *)imageName {
    UIView *toProjectView = [[UIView alloc] init];
    toProjectView.backgroundColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1.0];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.text = title;
    [toProjectView addSubview:imageView];
    [toProjectView addSubview:textLabel];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(toProjectView).offset(15);
        make.left.equalTo(toProjectView).offset(8);
        make.height.equalTo(@30);
        make.width.equalTo(@35);
    }];
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageView.mas_right).offset(10);
        make.width.equalTo(@100);
        make.centerY.equalTo(imageView);
        make.height.equalTo(@30);
    }];
    return toProjectView;
    
}

- (UIView *)commonInitSaveToProjectItem {
    UIView *toProjectView = [[UIView alloc] init];
    toProjectView.backgroundColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:0.8];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Black_project-icon"]];
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.text = @"Project";
    [toProjectView addSubview:imageView];
    [toProjectView addSubview:textLabel];
    [self addSubview:toProjectView];
    [self addSubview:toProjectView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(toProjectView).offset(15);
        make.left.equalTo(toProjectView).offset(8);
        make.height.equalTo(@30);
        make.width.equalTo(@35);
    }];
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageView.mas_right).offset(10);
        make.width.equalTo(@100);
        make.centerY.equalTo(imageView);
        make.height.equalTo(@30);
    }];
    return toProjectView;
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
    if (![NXCommonUtils isSupportWorkspace]) {
        toWorkSpaceView.userInteractionEnabled = NO;
        toWorkSpaceView.backgroundColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1.0];
    }else{
        toWorkSpaceView.userInteractionEnabled = YES;
        toWorkSpaceView.backgroundColor = [UIColor whiteColor];
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
- (UIView *)commonInitSaveToMyVaultViewItem {
    UIView *toWorkSpaceView = [[UIView alloc] init];
    toWorkSpaceView.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MyDrive"]];
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.text = @"MySpace";
    UIImageView *rightImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessoryIcon"]];
    [toWorkSpaceView addSubview:rightImage];
    [toWorkSpaceView addSubview:imageView];
    [toWorkSpaceView addSubview:textLabel];
  
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toSelectMyVault:)];
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 65;
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
    }else if([item isEqualToString:@"mySpace"]){
        view = [self commonInitSaveToMyVaultViewItem];
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
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = self.dataArray[indexPath.section];
    NSArray *itemArray = dict.allValues.firstObject;
    if (self.selectedItemModelCompletion) {
        self.selectedItemModelCompletion(itemArray[indexPath.row]);
    }
}

- (void)toSelectMyVault:(id)sender {
    if (self.selectedCompletion) {
        self.selectedCompletion(@"myVault");
    }
}
- (void)toSelectWorkSpace:(id)sender {
    if (self.selectedCompletion) {
        self.selectedCompletion(@"workspace");
    }
}



@end
