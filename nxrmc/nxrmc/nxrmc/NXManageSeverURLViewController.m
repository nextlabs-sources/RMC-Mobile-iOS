    //
//  NXManageSeverURLViewController.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2018/6/27.
//  Copyright © 2018年 nextlabs. All rights reserved.
//

#import "NXManageSeverURLViewController.h"
#import "Masonry.h"
#import "NXRMCDef.h"
#import "NXRepositoryHeaderView.h"
#import "NXProfileSectionHeaderView.h"
#import "NXSeverURLTableViewCell.h"
#import "NXChangeServerURLView.h"
#import "NXCommonUtils.h"
@interface NXManageSeverURLViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)NSArray *allCommanyURLs;
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, assign)NSInteger currentIndex;
@end

@implementation NXManageSeverURLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self commonInit];
    [self reloadNewData];
}
- (void)reloadNewData {
    self.allCommanyURLs = [NXCommonUtils getUserRememberedAndManagedLoginUrlList];
    NSString * currentURL = [NXCommonUtils getUserCurrentSelectedLoginURL];
    [self.allCommanyURLs enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:currentURL]) {
            self.currentIndex = idx;
            *stop = YES;
        }
    }];
    [self.tableView reloadData];
    if (currentURL) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = backBtn;
    self.title = NSLocalizedString(@"UI_CHANGE_URL", NULL);
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}
- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)commonInit {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    NXRepositoryHeaderView *headerView = [[NXRepositoryHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 75)];
    headerView.title = NSLocalizedString(@"UI_ADD_A_COMPANY_URL", NULL);
    
    WeakObj(self);
    headerView.clickBlock = ^(id sender) {
        StrongObj(self);
        [self addCompanyURL];
    };
    UITableView *tableView = [[UITableView alloc]init];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableHeaderView = headerView;
    tableView.tableFooterView = [[UIView alloc]init];
    tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    tableView.showsVerticalScrollIndicator = NO;
    tableView.cellLayoutMarginsFollowReadableWidth = NO;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView registerClass:[NXSeverURLTableViewCell class] forCellReuseIdentifier:@"cell"];
   if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {

            [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
               make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
               make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
               make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
               make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            }];
        }
   } else {
       
       [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
           make.top.equalTo(self.mas_topLayoutGuideBottom);
           make.right.left.equalTo(self.view);
           make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
       }];
   }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allCommanyURLs.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NXSeverURLTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.urlStr = self.allCommanyURLs[indexPath.row];
    WeakObj(self);
    cell.editURLHandle = ^(NSString *currentUrlStr) {
        NXChangeServerURLView *urlView = [[NXChangeServerURLView alloc]init];
        urlView.urlStr = currentUrlStr;
        WeakObj(urlView);
        urlView.onSaveClickHandle = ^(NSString *urlStr) {
            StrongObj(self);
            [NXCommonUtils updateUserLoginUrl:currentUrlStr newLoginUrl:urlStr isMakeDefault:NO];
            [self reloadNewData];
        };
        urlView.removeHandle = ^(NSString *urlStr) {
            StrongObj(self);
            StrongObj(urlView);
            NSString *message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"MSG_DO_YOU_WANT_TO_REMOVE", NULL),urlStr];
            [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName]message: message style:UIAlertControllerStyleAlert cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherActionTitles:@[NSLocalizedString(@"UI_BOX_OK", NULL)] inViewController:self position:urlView tapBlock:^(UIAlertAction *action, NSInteger index) {
                if (index == 1) {
                    [NXCommonUtils removeUserRememberedLoginUrl:urlStr];
                    [urlView close];
                    [self reloadNewData];
                }
            }];
          
        };
        [urlView show];
         urlView.changeType = NXChangeServerURLViewTypeEditURL;
    };
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NXProfileSectionHeaderView *headerView = [[NXProfileSectionHeaderView alloc] init];
    headerView.model = NSLocalizedString(@"UI_COMPANY_ACCOUNTS_B", NULL);
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *urlStr = self.allCommanyURLs[indexPath.row];
    [NXCommonUtils setUserRememberedAndSelectedLoginUrl:urlStr];
}

- (void)addCompanyURL {
    NXChangeServerURLView *urlView = [[NXChangeServerURLView alloc]init];
    WeakObj(self);
    urlView.onSaveClickHandle = ^(NSString *urlStr) {
        StrongObj(self);
        [self reloadNewData];
    };
    [urlView show];
    urlView.changeType = NXChangeServerURLViewTypeAddURL;
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
