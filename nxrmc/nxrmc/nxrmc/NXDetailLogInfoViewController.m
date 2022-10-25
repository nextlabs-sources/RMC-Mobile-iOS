//
//  NXDetailLogInfoViewController.m
//  nxrmc
//
//  Created by helpdesk on 11/4/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXDetailLogInfoViewController.h"
#import "NXNXLFileLogManager.h"
#import "Masonry.h"
@interface NXDetailLogInfoViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation NXDetailLogInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationItem.title = @"Detail  Log";
    [self commonInit];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
#pragma mark
- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)commonInit {
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStyleDone target:self action:@selector(back:)];

    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    
    tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    tableView.tableFooterView = [[UIView alloc]init];
    tableView.cellLayoutMarginsFollowReadableWidth = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view).offset(kMargin);
        make.right.equalTo(self.view).offset(-kMargin);
        make.bottom.equalTo(self.view);
    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 8.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
    }
    
    switch (indexPath.section) {
        case 0:
//            cell.textLabel.text = @"User";
//            cell.detailTextLabel.text = self.logModel.email;
//            break;
//         case 1:
//            cell.textLabel.text = @"Operation";
//            cell.detailTextLabel.textColor = RMC_MAIN_COLOR;
//            cell.detailTextLabel.text = self.logModel.operation;
//            break;
//        case 2:
//            cell.textLabel.text = @"Device Id";
//            cell.detailTextLabel.text = self.logModel.deviceId;
//            break;
//        case 3:
//            cell.textLabel.text = @"Application";
//            cell.detailTextLabel.text = self.logModel.deviceType;
//            break;
//            case 4:
//            cell.textLabel.text = @"Time";
//            cell.detailTextLabel.text = self.logModel.accessTimeStr;
//            break;
//            case 5:
//            cell.textLabel.text = @"Result";
//            cell.detailTextLabel.textColor = RMC_MAIN_COLOR;
//            cell.detailTextLabel.text = self.logModel.accessResult;
//            break;
//            case 6:
            cell.textLabel.text = @"ActivityDetail";
            cell.detailTextLabel.textColor = RMC_MAIN_COLOR;
            cell.detailTextLabel.text = self.logModel.activityData;
            cell.detailTextLabel.numberOfLines = 0;
        break;
        default:
            break;
    }
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
