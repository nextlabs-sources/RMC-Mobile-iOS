//
//  NXProtectedResultVC.m
//  nxrmc
//
//  Created by Sznag on 2020/12/28.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXProtectedResultVC.h"
#import "Masonry.h"
#import "NXCommonUtils.h"
#import "UIImage+ColorToImage.h"
#import "UIView+UIExt.h"
#import "NXProtectFileResultCell.h"
@interface NXProtectedResultVC ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong)UIButton *closeBtn;
@end

@implementation NXProtectedResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.hidesBackButton = YES;
    [self commonInitUI];
    self.view.backgroundColor = [UIColor whiteColor];
}
- (void)commonInitUI {
    UILabel *successLabel = [[UILabel alloc] init];
    [self.view addSubview:successLabel];
   
    successLabel.attributedText = [self createAttributeString:[NSString stringWithFormat:@"The %ld of %ld files are protected successfully and save to ",self.successFileArray.count,self.allFilesArray.count] subTitle1:self.savePath?:@"/"];
    successLabel.numberOfLines = 0;
    
    UILabel *failLabel = [[UILabel alloc] init];
    [self.view addSubview:failLabel];
    failLabel.text = [NSString stringWithFormat:@"The %ld of %ld could not be protected.",self.failFileArray.count,self.allFilesArray.count];
    failLabel.font = [UIFont systemFontOfSize:14];
    failLabel.textColor = [UIColor redColor];
    failLabel.hidden = YES;
    UIButton *closeBtn = [[UIButton alloc] init];
    [self.view addSubview:closeBtn];
    [closeBtn setTitle:@"Ok" forState:UIControlStateNormal];
    closeBtn.accessibilityValue = @"CLOSE_BTN";
    [closeBtn addTarget:self action:@selector(closeThisPage:) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeBtn setBackgroundImage:[UIImage imageWithSize:CGSizeMake(200, 200) colors:@[RMC_GRADIENT_START_COLOR, RMC_GRADIENT_END_COLOR] gradientType:GradientTypeLeftToRight] forState:UIControlStateNormal];
    [closeBtn cornerRadian:3];
    self.closeBtn = closeBtn;
//    closeBtn.hidden = YES;
    long height = self.allFilesArray.count *70;
    if (height>self.view.bounds.size.height/2) {
        height = self.view.bounds.size.height/2;
    }
    UITableView *tableView = [[UITableView alloc] init];
    [self.view addSubview:tableView];
    [tableView registerClass:[NXProtectFileResultCell class] forCellReuseIdentifier:@"cell"];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [[UIView alloc] init];
    if (self.failFileArray) {
        failLabel.hidden = NO;
    }
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(kMargin * 5);
        } else {
            make.top.equalTo(self.mas_topLayoutGuideBottom);
            // Fallback on earlier versions
        }
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(height));
    }];
    [failLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tableView.mas_bottom).offset(kMargin * 5);
        make.left.equalTo(self.view).offset(kMargin *2);
        make.right.equalTo(self.view).offset(-kMargin*2);
    }];
    [successLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(failLabel.mas_bottom).offset(kMargin);
        make.right.left.equalTo(failLabel);
        make.height.equalTo(@40);
        
    }];
    
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-80);
        make.height.equalTo(@40);
        make.width.height.equalTo(@120);
    }];
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return  self.failFileArray.count;
    }else{
        return self.successFileArray.count;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NXProtectFileResultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NXFileBase *model;
    NXResultModel *resultModel = [[NXResultModel alloc] init];
    if (indexPath.section == 0) {
        model = self.failFileArray[indexPath.row];
        resultModel.fileItem = model;
        resultModel.isSuccess = NO;
        cell.model = resultModel;
        
    }else{
        model = self.successFileArray[indexPath.row];
        resultModel.fileItem = model;
        resultModel.isSuccess = YES;
        cell.model = resultModel;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NXFileBase *model;
        model = self.failFileArray[indexPath.row];
        [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:model.localPath  style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_OK", NULL) cancelActionTitle:nil OKActionHandle:^(UIAlertAction *action) {
           
        } cancelActionHandle:nil inViewController:self position:self.view];
        
    }
}

- (void)closeThisPage:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark   ----》NSAttributedString
- (NSAttributedString *)createAttributeString:(NSString *)title subTitle1:(NSString *)subtitle1 {
    NSMutableAttributedString *myprojects = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName :[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    
    NSAttributedString *sub1 = [[NSMutableAttributedString alloc] initWithString:subtitle1 attributes:@{NSForegroundColorAttributeName :[UIColor blackColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:15]}];
    [myprojects appendAttributedString:sub1];

    return myprojects;
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
