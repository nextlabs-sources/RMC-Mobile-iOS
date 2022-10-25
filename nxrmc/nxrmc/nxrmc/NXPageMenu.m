//
//  NXPageMenu.m
//  nxrmc
//
//  Created by nextlabs on 1/13/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXPageMenu.h"

#import "Masonry.h"
#import "NXRMCDef.h"

@implementation NXPageMenuSetting

- (instancetype)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

#pragma mark
- (void)commonInit {
    self.menuHeight = 44;
    self.menuSelectedTinColor = [UIColor whiteColor];
    self.menuTinColor = [UIColor whiteColor];
    self.menuBackgroundColor = RMC_MAIN_COLOR;
    self.viewBackgroundColor = [UIColor whiteColor];
}

- (void)setMenuHeight:(CGFloat)menuHeight {
    _menuHeight = menuHeight;
}

- (void)setMenuTinColor:(UIColor *)menuTinColor {
    _menuTinColor = menuTinColor;
}

- (void)setMenuSelectedTinColor:(UIColor *)menuSelectedTinColor {
    _menuSelectedTinColor = menuSelectedTinColor;
}

- (void)setMenuBackgroundColor:(UIColor *)menuBackgroundColor {
    _menuBackgroundColor = menuBackgroundColor;
}

- (void)setViewBackgroundColor:(UIColor *)viewBackgroundColor {
    _menuBackgroundColor = viewBackgroundColor;
}

@end

@interface NXPageMenu ()

@property(nonatomic, weak) UIScrollView *controllerScrollView;
@property(nonatomic, weak) UIScrollView *menusScrollView;

@property(nonatomic, strong) NXPageMenuSetting *setting;
@property(nonatomic, strong) NSMutableArray *controllers;
@property(nonatomic, assign) NSInteger currentIndex;

@end

@implementation NXPageMenu

- (instancetype)initWithViewControllers:(NSArray *)viewControllers setting:(NXPageMenuSetting *)setting {
    if (self = [super init]) {
        self.setting = setting;
        self.controllers = [NSMutableArray arrayWithArray:viewControllers];
        [self commonInit];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.controllerScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - self.setting.menuHeight);
    self.menusScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), self.setting.menuHeight);
}

- (void)dealloc {
    DLog();
}

- (void)valueChanged:(UISegmentedControl *)controller {
    NSInteger selectedIndex = controller.selectedSegmentIndex;
    if (selectedIndex == self.currentIndex) {
        return;
    }
    UIViewController *newVC = [self addPageAtIndex:selectedIndex];
    [self removePageAtIndex:self.currentIndex];
    self.currentIndex = selectedIndex;
    self.currentPageIndex = selectedIndex;
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageMenu:didMoveToPage:index:)]) {
        [self.delegate pageMenu:self didMoveToPage:newVC index:selectedIndex];
    }
}

- (UIViewController *)addPageAtIndex:(NSInteger)index {
    UIViewController *newVC = self.controllers[index];
    [newVC willMoveToParentViewController:self];
    newVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.setting.menuHeight);
    [self addChildViewController:newVC];
    [_controllerScrollView addSubview:newVC.view];
    [newVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.menusScrollView.mas_bottom);
        make.bottom.equalTo(self.view);
        make.width.equalTo(self.view);
        make.left.equalTo(self.controllerScrollView);
    }];
    [newVC didMoveToParentViewController:self];
    return newVC;
}

- (void)removePageAtIndex:(NSInteger)index {
    UIViewController *oldVC = self.controllers[index];
    [oldVC willMoveToParentViewController:nil];
    [oldVC.view removeFromSuperview];
    [oldVC removeFromParentViewController];
    [oldVC didMoveToParentViewController:nil];
}

#pragma mark
- (void)commonInit {
    UIScrollView *controllerScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.setting.menuHeight, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds) - self.setting.menuHeight)];
    [self.view addSubview:controllerScrollView];
    
    UIScrollView *menusScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), self.setting.menuHeight)];
    [self.view addSubview:menusScrollView];
    
    self.menusScrollView = menusScrollView;
    self.controllerScrollView = controllerScrollView;
    
    [menusScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.equalTo(self.view);
        make.height.equalTo(@(self.setting.menuHeight));
    }];
    
    [controllerScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.bottom.equalTo(self.view);
        make.top.equalTo(menusScrollView.mas_bottom);
    }];
    
    controllerScrollView.pagingEnabled = YES;
    controllerScrollView.bounces = NO;
    controllerScrollView.alwaysBounceHorizontal = NO;
    controllerScrollView.scrollEnabled = NO;
    
    menusScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), self.setting.menuHeight);
    menusScrollView.backgroundColor = RMC_MAIN_COLOR;
    
    UISegmentedControl *segmentController = [[UISegmentedControl alloc] init];
    [menusScrollView addSubview:segmentController];
    [segmentController mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(menusScrollView);
        make.height.equalTo(menusScrollView).multipliedBy(0.6);
        make.width.equalTo(menusScrollView).multipliedBy(0.8);
    }];
    
    segmentController.tintColor = self.setting.menuTinColor;
    segmentController.selectedSegmentIndex = 0;
    [segmentController addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.controllers enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(UIViewController *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *title = obj.title ? :[NSString stringWithFormat:@"MENU%ld", idx];
            [segmentController insertSegmentWithTitle:title atIndex:idx animated:YES];
            
            if (idx == 0) {
                segmentController.selectedSegmentIndex = 0;
                self.currentIndex = 0;
                [self addChildViewController:obj];
                [controllerScrollView addSubview:obj.view];
                
                [obj.view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(menusScrollView.mas_bottom);
                    make.bottom.equalTo(self.view);
                    make.width.equalTo(self.view);
                    make.left.equalTo(controllerScrollView);
                }];
                
                [obj didMoveToParentViewController:self];
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(pageMenu:didMoveToPage:index:)]) {
                    [self.delegate pageMenu:self didMoveToPage:obj index:idx];
                }
            }
        });
    }];
}

@end
