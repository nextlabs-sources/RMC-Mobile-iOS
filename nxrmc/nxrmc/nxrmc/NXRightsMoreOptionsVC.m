//
//  NXRightsMoreOptionsVC.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/6/13.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXRightsMoreOptionsVC.h"
#import "Masonry.h"
#import "NXRMCDef.h"
#import "NXRightsMoreOptionsCell.h"
#import "NXRightsCellModel.h"
#import "NXLRights.h"
@interface NXRightsMoreOptionsVC ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *modelArray;
@end

@implementation NXRightsMoreOptionsVC
- (NSMutableArray *)modelArray {
    if (!_modelArray) {
        _modelArray = [NSMutableArray array];
    }
    return _modelArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.dataArray enumerateObjectsUsingBlock:^(NXRightsCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.modelArray addObject:[obj copy]];
    }];

    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationItem.title = @"More options";
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClicked:)];
    rightItem.accessibilityValue = @"UI_BOX_CANCEL";
    self.navigationItem.rightBarButtonItem = rightItem;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.tintColor = nil;
    
    UITableView *tableView = [[UITableView alloc]init];
    tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    tableView.tableFooterView = [[UIView alloc]init];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    [tableView registerClass:[NXRightsMoreOptionsCell class] forCellReuseIdentifier:@"cell"];
    
    
    
    
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(kMargin * 4);
                make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            }];
        }
    }else{
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuideBottom).offset(kMargin * 4);
            make.left.right.bottom.equalTo(self.view);
        }];
    }
}

#pragma mark ------> tableView delegate and dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.modelArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NXRightsMoreOptionsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.model = self.modelArray[indexPath.row];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}



- (void)cancelButtonClicked:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)back:(id)sender {
    if (self.finishedOptionBlock) {
        self.finishedOptionBlock(self.modelArray);
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
@end
