//
//  NXLocalContactsVC.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/4/25.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXLocalContactsVC.h"
#import "Masonry.h"
#import "NXRMCDef.h"
#import "NXContactInfoTool.h"
#import "NXMBManager.h"
#import "NXSearchContactResultVC.h"
#import "NXEmailContactCell.h"
@interface NXLocalContactsVC ()<UITableViewDelegate,UITableViewDataSource,UISearchControllerDelegate,NXEmailContactCellDelegate,NXSearchContactResultVCDelegate>
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSMutableArray *emailcontactArray;
@property (nonatomic, strong)NSMutableArray *sectionTitlesArray;
@property (nonatomic, strong)NSMutableArray *sectionContactsArray;
@property (nonatomic, strong)UISearchController *searchController;
@property (nonatomic, strong)NXSearchContactResultVC *resultVC;
@property (nonatomic, strong)UIView *bgSerachView;
@end

@implementation NXLocalContactsVC
- (NSMutableArray *)emailcontactArray {
    if (!_emailcontactArray) {
        _emailcontactArray = [NSMutableArray array];
    }
    return _emailcontactArray;
}
-  (NSMutableArray *)sectionTitlesArray {
    if (!_sectionTitlesArray) {
        _sectionTitlesArray = [NSMutableArray array];
    }
    return _sectionTitlesArray;
}
- (NSMutableArray *)sectionContactsArray {
    if (!_sectionContactsArray) {
        _sectionContactsArray = [NSMutableArray array];
    }
    return _sectionContactsArray;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [NXContactInfoTool getOnlyEmailContactsWithCompletion:^(NSArray<NSDictionary *> *contacts, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                [self dealWithDataFromLocalContacts:contacts];
                self.resultVC.allContactsArray = self.emailcontactArray;
            }else{
                [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:kDelay];
            }
        });
    }];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}
- (void)dealWithDataFromLocalContacts:(NSArray *)contacts {
    for (NSDictionary *dict in contacts) {
        NXEmailContact *contact = [[NXEmailContact alloc]initWithDictionary:dict];
        [self.emailcontactArray addObject:contact];
    }
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    NSUInteger sectionNum = [collation sectionTitles].count;
    NSMutableArray *sectionArray = [[NSMutableArray alloc]init];
    for (int i = 0; i<sectionNum; i++) {
        [sectionArray addObject:[[NSMutableArray alloc]init]];
    }
    for (NXEmailContact *contact in self.emailcontactArray) {
           NSUInteger sectionIndex = [collation sectionForObject:contact         collationStringSelector:@selector(fullName)];
        [sectionArray[sectionIndex] addObject:contact];
    }
    for (NSUInteger i = 0; i< sectionNum; i++) {
        NSMutableArray *contactsForSection = sectionArray[i];
        if (contactsForSection.count) {
             NSArray *sortedContactArrayForSection = [collation sortedArrayFromArray:contactsForSection collationStringSelector:@selector(fullName)];
            sectionArray[i] = sortedContactArrayForSection;
        }
    }
    NSMutableArray *emptyArray = [NSMutableArray array];
    [sectionArray enumerateObjectsUsingBlock:^(NSMutableArray *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.count == 0) {
            [emptyArray addObject:obj];
        }else{
            [self.sectionTitlesArray addObject:[collation sectionTitles][idx]];
            [self.sectionContactsArray addObject:obj];
        }
    }];
    [self.tableView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItems = @[rightItem];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor colorWithRed:47.0/255.0 green:128.0/255.0 blue:237.0/255.0 alpha:1.0]];
//    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
//    self.navigationItem.leftBarButtonItems = @[leftItem];
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.frame = CGRectMake(0, 0, 40, 140);
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"Choose a contact to email";
    self.navigationItem.titleView = titleLabel;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    UITableView *tableView = [[UITableView alloc] init];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.sectionIndexColor = [UIColor colorWithRed:47.0/255.0 green:128.0/255.0 blue:237.0/255.0 alpha:1.0];
    [tableView registerClass:[NXEmailContactCell class] forCellReuseIdentifier:@"cell"];
    tableView.allowsSelection = NO;
   
    
    NXSearchContactResultVC *resultVC = [[NXSearchContactResultVC alloc]init];
    resultVC.delegate = self;
    self.resultVC = resultVC;
    self.searchController  = [[UISearchController alloc]initWithSearchResultsController:resultVC];
    self.searchController.searchBar.placeholder = @"Search";
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchController.delegate = self;
    self.searchController.searchResultsUpdater = resultVC;
    self.definesPresentationContext = YES;
    self.navigationController.extendedLayoutIncludesOpaqueBars = NO;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.searchController.hidesNavigationBarDuringPresentation = YES;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.obscuresBackgroundDuringPresentation = YES;
    UIView *searchBarBgView = [[UIView alloc]init];
    [searchBarBgView addSubview:self.searchController.searchBar];
    [self.view addSubview:searchBarBgView];
    self.bgSerachView = searchBarBgView;
    
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [searchBarBgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(kMargin);
                make.left.equalTo(self.view);
                make.right.equalTo(self.view);
                make.height.equalTo(@55);
            }];
            [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(searchBarBgView.mas_bottom).offset(kMargin);
                make.left.right.equalTo(self.view);
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            }];
        }
    }else{
        [searchBarBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuideBottom).offset(kMargin);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.height.equalTo(@40);
        }];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(searchBarBgView.mas_bottom).offset(kMargin);
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
        }];
    }
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  [self.sectionContactsArray[section] count];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionTitlesArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NXEmailContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NXEmailContact *contact = self.sectionContactsArray[indexPath.section][indexPath.row];
    cell.contactModel = contact;
    cell.delegate = self;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sectionTitlesArray[section];
}
- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.sectionTitlesArray;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}
- (void)cancel:(id)sender {
    if ([self.delegate respondsToSelector:@selector(cancelSelctedEmail)]) {
        [self.delegate cancelSelctedEmail];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark ------> cell delegate
- (void)emailBtnWhichTitle:(NSString *)title ClickedFromEmailBtnView:(NXEmailBtnsView *)emailBtnsView {
    [self afterSelectedEmail:title];
}
#pragma mark ------>
- (void)theEmailBtnBeClickedOnSearchResultPageWithTitle:(NSString *)title {
    [self afterSelectedEmail:title];
}
- (void)afterSelectedEmail:(NSString *)emailStr {
    if ([self.delegate respondsToSelector:@selector(selectedEmail:)]) {
        [self.delegate selectedEmail:emailStr];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
@end
@implementation NXEmailContact

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
       [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}
@end
