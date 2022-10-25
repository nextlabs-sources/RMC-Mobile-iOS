//
//  NXActionSheetCommonViewController.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 02/05/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXActionSheetCommonViewController.h"
#import "NXCustomActionSheetViewController.h"
#import "NXActionSheetNavigationViewController.h"
#import "Masonry.h"
#import "NXDefine.h"
#import "NXActionSheetItem.h"
#import "NXActionSheetTableViewCell.h"
#import "NXActionSheetSpecialTableViewCell.h"
#import "NXRMCDef.h"
#import "NXCommonUtils.h"
@interface NXActionSheetCommonViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic, assign) CGFloat navigationViewHeight;

@end

@implementation NXActionSheetCommonViewController

#pragma mark - LifeCycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        _items = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureSubviews];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(onTapBack:)];
    self.navigationItem.leftBarButtonItem = backButton;
    if ([NXCommonUtils isiPad]) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationWillChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
   
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark Selector Method

- (void)onTapBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - PropertyMethod

- (void)addItemWithTitle:(NSString *)title
{
    NXActionSheetItem *item = [[NXActionSheetItem alloc] init];
    
    item.title = title;
    [self.items addObject:item];
}

- (void)addItem:(NXActionSheetItem *)item
{
    [self.items addObject:item];
}

#pragma mark - UI

- (void)configureSubviews {
    
    /** UITableView */
    UITableView *contentTableView = [[UITableView alloc] init];
    contentTableView.rowHeight = 50;
    contentTableView.sectionFooterHeight = 0.1;
    contentTableView.sectionHeaderHeight = 0.1;
    contentTableView.scrollEnabled = YES;
    contentTableView.showsVerticalScrollIndicator = YES;
    contentTableView.userInteractionEnabled = YES;
    contentTableView.bounces = YES;
    contentTableView.delegate = self;
    contentTableView.dataSource = self;
    contentTableView.cellLayoutMarginsFollowReadableWidth = NO;
    [contentTableView registerClass:[NXActionSheetTableViewCell class] forCellReuseIdentifier:@"actionSheetCommonItemCell"];
    [contentTableView registerClass:[NXActionSheetSpecialTableViewCell class] forCellReuseIdentifier:@"NXActionSheetSpecialTableViewCell"];
    self.tableView = contentTableView;
    [self.view addSubview:contentTableView];
//   [self.view setBackgroundColor:[UIColor redColor]];
//    
//    self.tableView.backgroundColor = [UIColor greenColor];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        if (IS_IPHONE_X) {
            if (@available(iOS 11.0, *)) {
                make.edges.equalTo(self.view.mas_safeAreaLayoutGuide);
            }
        }
        else
        {
            make.edges.equalTo(self.view);
        }
    }];
    
     _navigationViewHeight = (self.items.count * 50 + 44);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma -mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NXActionSheetItem *obj = [_items objectAtIndex:indexPath.row];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (obj.shouldDisplayDividerLine == YES || obj.promptTitle.length > 0) {
        
        static NSString *cellIdentifier = @"NXActionSheetSpecialTableViewCell";
        NXActionSheetSpecialTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        [cell configureCellWithActionSheetItem:obj];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        if (obj.shouldDisplayDividerLine == YES) {
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
        return cell;
    }
    else
    {
        static NSString *cellIdentifier =  @"actionSheetCommonItemCell";
        NXActionSheetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        [cell configureCellWithActionSheetItem:obj];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NXActionSheetItem *obj = [_items objectAtIndex:indexPath.row];
    
    if (obj.subItems.count >= 1) {
        NXActionSheetCommonViewController *testVC = [[NXActionSheetCommonViewController alloc] init];
        testVC.actionSheetWindow = self.actionSheetWindow;
        
        for (NXActionSheetItem *item in obj.subItems) {
            [testVC addItem:item];
        }
        
        [self.navigationController pushViewController:testVC animated:YES];
    }
    else
    {
        [self.actionSheetWindow dismiss];
        
        if (obj.action) {
            obj.action(_actionSheetWindow);
            self.actionSheetWindow.rootViewController = nil;
            self.actionSheetWindow = nil;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 1.0)];
    
    horizontalLine.backgroundColor = NXColor(225, 225, 225);
    
    return horizontalLine;
}

// divide line from left

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NXActionSheetItem *obj = [_items objectAtIndex:indexPath.row];
    if (obj.shouldDisplayDividerLine == YES || (obj.promptTitle.length > 0 && obj.promptTitle.length < 50)) {
        return 40.0;
    }else if(obj.promptTitle.length > 50){
        return 50;
    }
    else
    {
        return 50.0;
    }
}

#pragma  -mark deviceOrientationNotification

- (void)deviceOrientationWillChange:(NSNotification *)notification
{
    CGFloat navigationViewHeight = _navigationViewHeight;
    CGFloat currentViewHeight = navigationViewHeight;
    NXActionSheetNavigationViewController *currentNavVC = nil;
    if ([self.navigationController isKindOfClass:[NXActionSheetNavigationViewController class]]) {
        currentNavVC = (NXActionSheetNavigationViewController *)self.navigationController;
    }
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        
        if (navigationViewHeight > NXMainScreenHeight - 150) {
            currentViewHeight = NXMainScreenHeight - 150;
        }
        
        [self.navigationController.view mas_updateConstraints:^(MASConstraintMaker *make) {
            
            if (IS_IPHONE_X) {
                if (@available(iOS 11.0, *)) {
                    make.leading.equalTo(currentNavVC.actionSheetWindow.mas_safeAreaLayoutGuideLeading);
                    make.trailing.equalTo(currentNavVC.actionSheetWindow.mas_safeAreaLayoutGuideTrailing);
                    make.bottom.equalTo(currentNavVC.actionSheetWindow.mas_safeAreaLayoutGuideBottom).offset(-100);
                    make.width.equalTo(currentNavVC.actionSheetWindow.mas_safeAreaLayoutGuideWidth);
                }
            }
            else
            {
                make.leading.equalTo(currentNavVC.actionSheetWindow);
                make.trailing.equalTo(currentNavVC.actionSheetWindow);
                make.bottom.equalTo(currentNavVC.actionSheetWindow).offset(-100);
                make.width.equalTo(currentNavVC.actionSheetWindow);
            }
            
            make.height.equalTo(@(currentViewHeight));
        }];
    }
    else
    {
        if (navigationViewHeight > NXMainScreenHeight - 150) {
            currentViewHeight = NXMainScreenHeight - 150;
        }
        [self.navigationController.view mas_updateConstraints:^(MASConstraintMaker *make) {
            
            if (IS_IPHONE_X) {
                if (@available(iOS 11.0, *)) {
                    make.leading.equalTo(currentNavVC.actionSheetWindow.mas_safeAreaLayoutGuideLeading);
                    make.trailing.equalTo(currentNavVC.actionSheetWindow.mas_safeAreaLayoutGuideTrailing);
                    make.bottom.equalTo(currentNavVC.actionSheetWindow.mas_safeAreaLayoutGuideBottom).offset(-100);
                    make.width.equalTo(currentNavVC.actionSheetWindow.mas_safeAreaLayoutGuideWidth);
                }
            }
            else
            {
                make.leading.equalTo(currentNavVC.actionSheetWindow);
                make.trailing.equalTo(currentNavVC.actionSheetWindow);
                make.bottom.equalTo(currentNavVC.actionSheetWindow).offset(-100);
                make.width.equalTo(currentNavVC.actionSheetWindow);
            }
            
            make.height.equalTo(@(currentViewHeight));
        }];
    }
}

@end
