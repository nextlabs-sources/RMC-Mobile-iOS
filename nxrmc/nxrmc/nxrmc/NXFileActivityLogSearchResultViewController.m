//
//  NXFileActivityLogSearchResultViewController.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 10/13/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXFileActivityLogSearchResultViewController.h"
#import "Masonry.h"
#import "NXLogInfoTableViewCell.h"
#import "NXNXLFileLogStorage.h"
#import "NXRMCDef.h"

@interface NXFileActivityLogSearchResultViewController ()<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, weak) UITableView *tableView;
@property (nonatomic,weak) UIView *noSerchResultsTipsView;
@end

@implementation NXFileActivityLogSearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - commonInit
- (void)commonInit {
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:tableView];
    tableView.cellLayoutMarginsFollowReadableWidth = NO;
    UIView *noSearchResultView = [[UIView alloc] initWithFrame:self.view.bounds];
    noSearchResultView.backgroundColor = [UIColor whiteColor];
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height/2, self.view.bounds.size.width, 55.0)];
    tipsLabel.text = @"No search results";
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.font = [UIFont systemFontOfSize:20];
    tipsLabel.textColor = [UIColor grayColor];
    [noSearchResultView addSubview:tipsLabel];
    [self.view addSubview:noSearchResultView];
    
    self.noSerchResultsTipsView = noSearchResultView;
    [self.noSerchResultsTipsView setHidden:YES];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[NXLogInfoTableViewCell class] forCellReuseIdentifier:@"cell"];
    tableView.tableFooterView = [[UIView alloc] init];
    tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)];
    tableView.estimatedRowHeight = 70;
    
    self.tableView = tableView;
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.noSerchResultsTipsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(@55);
        make.center.equalTo(self.view);
    }];
}

#pragma mark - overwrite super method
- (void)updateData {
    if (self.dataArray.count == 0) {
        [self.noSerchResultsTipsView setHidden:NO];
    } else {
        [self.noSerchResultsTipsView setHidden:YES];
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate  UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NXLogInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NXNXLFileLogModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    if (indexPath.row + 1  == self.dataArray.count) {
        //remove sperator line
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, tableView.bounds.size.width);
    } else {
        //spearator line leading to border
        cell.separatorInset = UIEdgeInsetsMake(0, -60, 0, 0);
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NXNXLFileLogModel *logModel = self.dataArray[indexPath.row];
    if (DELEGATE_HAS_METHOD(self.delegate, @selector(fileActivityLogSearchResultVC:didSelectItem:))) {
        [self.delegate fileActivityLogSearchResultVC:self didSelectItem:logModel];
    }
}

@end
