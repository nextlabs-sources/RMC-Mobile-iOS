//
//  NXCustomActionSheetViewController.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 28/04/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXCustomActionSheetViewController.h"
#import "UIView+NXExtension.h"
#import "NXDefine.h"
#import "Masonry.h"
#import "NXActionSheetItem.h"
#import "NXActionSheetCommonViewController.h"
#import "NXActionSheetNavigationViewController.h"
#import "NXActionSheetTableViewCell.h"
#import "NXActionSheetSpecialTableViewCell.h"
#import "NXRMCDef.h"
#import "NXCommonUtils.h"

const static CGFloat tableviewRowHeight            = 50;

#pragma mark - NXCustomActionSheetWindow

@interface NXCustomActionSheetWindow ()
@end

@implementation NXCustomActionSheetWindow

- (instancetype)initWithFrame:(CGRect)frame andStyle:(NXActionSheetWindowBackgroundStyle)style {
    if (self = [super initWithFrame:frame]) {
        self.style = style;
        self.opaque = NO;
        self.windowLevel = 1999.0;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    switch (self.style) {
        case NXActionSheetWindowBackgroundStyleGradient: {
            size_t locationsCount = 2; // unsigned long
            CGFloat locations[2] = {0.0f, 1.0f};
            CGFloat colors[8] = {0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.75f};
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
            CGColorSpaceRelease(colorSpace);
            
            CGPoint center = CGPointMake(self.hd_width * 0.5, self.hd_height * 0.5);
            CGFloat radius = MIN(self.hd_width, self.hd_height) ;
            CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
            CGGradientRelease(gradient);
            break;
        }
            
        case NXActionSheetWindowBackgroundStyleSolid: {
            [[UIColor colorWithWhite:0 alpha:0.66] set];
            CGContextFillRect(context, self.bounds);
            break;
        }
    }
}

- (void)dismiss
{
    self.alpha = 0;
    [self removeFromSuperview];
    [NXFirstWindow makeKeyAndVisible];
}

@end

#pragma mark - NXCustomActionSheetViewController

@interface NXCustomActionSheetViewController ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIView *footView;
@property (nonatomic, weak) UIButton *crossButton;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic,weak) UITableView *tableView;

/** present background Window */
@property (nonatomic, strong) NXCustomActionSheetWindow *actionSheetWindow;
@property (nonatomic, assign) NXActionSheetWindowBackgroundStyle backgroundStyle;

@property (nonatomic, assign) CGFloat navigationViewHeight;

@end

@implementation NXCustomActionSheetViewController

#pragma mark - LifeCycle

- (instancetype)init
{
    self = [super init];
    if (self) {
         _items = [[NSMutableArray alloc] init];
        _currentItems = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickBackground:)];
    tapGesture.delegate = self;
    [_actionSheetWindow addGestureRecognizer:tapGesture];
    if ([NXCommonUtils isiPad]) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationWillChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
   
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)show
{
    NXActionSheetNavigationViewController *navVC = [[NXActionSheetNavigationViewController alloc] initWithRootViewController:self];
    navVC.view.backgroundColor = [UIColor whiteColor];
    [self configureSubviews];
    navVC.actionSheetWindow = self.actionSheetWindow;
    self.actionSheetWindow.rootViewController = navVC;
    [self.actionSheetWindow makeKeyAndVisible];
    
   
}

/**
 *  remove actionsheet window
 */
- (void)removeView {
  
    [self.actionSheetWindow dismiss];
    self.actionSheetWindow = nil;
    [self.view hd_removeAllSubviews];
    [self.view removeFromSuperview];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIWindow class]]){
        return YES;
    }
    else
    {
        return NO;
    }

}


#pragma mark - PropertyMethod

- (NXCustomActionSheetWindow *)actionSheetWindow {
    if (!_actionSheetWindow) {
        _actionSheetWindow = [[NXCustomActionSheetWindow alloc] initWithFrame:NXMainScreenBounds andStyle:self.backgroundStyle];
        _actionSheetWindow.alpha = 1.0;
    }
    return _actionSheetWindow;
}

- (void)onClickBackground:(id)sender
{
    [self removeView];
}

- (void)addItem:(NXActionSheetItem *)item
{
    [self.items addObject:item];
    [self.currentItems addObject:item];
}

#pragma mark - UI

- (void)configureSubviews {
    
    /** UITableView */
    UITableView *contentTableView = [[UITableView alloc] init];
    contentTableView.rowHeight = tableviewRowHeight;
    contentTableView.sectionFooterHeight = 0.1;
    contentTableView.sectionHeaderHeight = 10;
    contentTableView.scrollEnabled = YES;
    contentTableView.showsVerticalScrollIndicator = YES;
    contentTableView.userInteractionEnabled = YES;
    contentTableView.bounces = YES;
    contentTableView.delegate = self;
    contentTableView.dataSource = self;
    contentTableView.cellLayoutMarginsFollowReadableWidth = NO;
    [contentTableView registerClass:[NXActionSheetTableViewCell class] forCellReuseIdentifier:@"NXActionSheetTableViewCell"];
    [contentTableView registerClass:[NXActionSheetSpecialTableViewCell class] forCellReuseIdentifier:@"NXActionSheetSpecialTableViewCell"];
    
    self.tableView = contentTableView;
    [self.view addSubview:contentTableView];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    
    /** foot view */
    UIView *footView = [[UIView alloc] init];
    footView.backgroundColor = [UIColor whiteColor];
    footView.layer.masksToBounds = YES;
    self.footView = footView;
    [self.actionSheetWindow addSubview:footView];
    //self.footView.backgroundColor = [UIColor redColor];
    
    /** cross button */
    UIButton *crossButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [crossButton setFrame:CGRectMake(0, 0, 50, 50)];
    crossButton.layer.cornerRadius = 0.5*crossButton.bounds.size.width;
   // [crossButton setBackgroundImage:[UIImage imageNamed:@"circleBackImg"] forState:UIControlStateNormal];
    [crossButton setImage:[UIImage imageNamed:@"Cancel White"] forState:UIControlStateNormal];
    [crossButton addTarget:self action:@selector(crossButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.crossButton = crossButton;
    [self.footView addSubview:crossButton];
    
    [self.footView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        if (IS_IPHONE_X) {
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(_actionSheetWindow.mas_safeAreaLayoutGuideBottom);
                make.leading.equalTo(_actionSheetWindow.mas_safeAreaLayoutGuideLeading);
                make.trailing.equalTo(_actionSheetWindow.mas_safeAreaLayoutGuideTrailing);
              make.width.equalTo(_actionSheetWindow.mas_safeAreaLayoutGuideWidth);
            }
        }
        else
        {
            make.bottom.equalTo(_actionSheetWindow);
            make.leading.equalTo(_actionSheetWindow);
            make.trailing.equalTo(_actionSheetWindow);
            make.width.equalTo(_actionSheetWindow);
        }
       
        make.height.equalTo(@100);
    }];
    
    [self.crossButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_footView);
        make.bottom.equalTo(_footView).offset(-25);
        make.width.equalTo(@50);
        make.height.equalTo(@50);
    }];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        if (IS_IPHONE_X) {
            if (@available(iOS 11.0, *)) {
                make.edges.equalTo(self.view.mas_safeAreaLayoutGuide);
            }
        }
        else {
            make.edges.equalTo(self.view);
        }
    }];
    
    _navigationViewHeight = (self.items.count * tableviewRowHeight + 10);

//    self.view.backgroundColor = [UIColor blueColor];
//    self.navigationController.view.backgroundColor = [UIColor orangeColor];
}

- (void)crossButtonClick:(id)sender
{
     [self removeView];
}

#pragma -mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.0;
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
        cell.accessibilityValue = obj.title;
        return cell;
    }
    else
    {
        static NSString *cellIdentifier =  @"NXActionSheetTableViewCell";
        NXActionSheetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        [cell configureCellWithActionSheetItem:obj];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessibilityValue = obj.title;
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
        [self removeView];
        
        if (obj.action) {
            obj.action(_actionSheetWindow);
        }
    }
    
    NSLog(@"%ld",(long)indexPath.row);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 10.0)];
    
    horizontalLine.backgroundColor = [UIColor whiteColor];
    
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
    if (obj.shouldDisplayDividerLine == YES || obj.promptTitle.length > 0) {
        return 40.0;
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
            {   make.leading.equalTo(currentNavVC.actionSheetWindow.mas_leading);
                make.trailing.equalTo(currentNavVC.actionSheetWindow.mas_trailing);
                make.bottom.equalTo(currentNavVC.actionSheetWindow.mas_bottom).offset(-100);
                make.width.equalTo(currentNavVC.actionSheetWindow.mas_width);
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
                make.leading.equalTo(currentNavVC.actionSheetWindow.mas_leading);
                make.trailing.equalTo(currentNavVC.actionSheetWindow.mas_trailing);
                make.bottom.equalTo(currentNavVC.actionSheetWindow.mas_bottom).offset(-100);
                make.width.equalTo(currentNavVC.actionSheetWindow.mas_width);
            }
            
            make.height.equalTo(@(currentViewHeight));
        }];
    }
}

@end
