//
//  NXFileOperationPageBaseVC.m
//  nxrmc
//
//  Created by nextlabs on 11/18/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXFileOperationPageBaseVC.h"

#import "Masonry.h"
#import "NXRMCDef.h"

@interface NXFileOperationPageBaseVC ()

@end

@implementation NXFileOperationPageBaseVC
- (instancetype)initWithSupportSortSearch:(BOOL)supportSortSearch
                        sortClickCallBack:(ClickActionBlock)sortCallBack
                      searchClickCallBack:(ClickActionBlock)searchCallBack {
    if (self = [super init]) {
        self.showSortSearch = supportSortSearch;
        self.sortCallBack = sortCallBack;
        self.searchCallBack = searchCallBack;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self common];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    DLog(@"%s", __FUNCTION__);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

#pragma mark -
- (void)showTopView {
    if (self.topView.isHidden) {
        self.topView.hidden = NO;
        [self.mainView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topView.mas_bottom);
            if (_bottomView) {
                make.bottom.equalTo(_bottomView.mas_top);
            }else {
                make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
            }
            make.width.equalTo(self.view);
            make.centerX.equalTo(self.view);
        }];
    }
}

- (void)hideTopView {
    if (self.topView.isHidden == NO) {
        self.topView.hidden = YES;
        [self.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
            make.width.equalTo(self.view);
            make.centerX.equalTo(self.view);
        }];
    }
}

- (void)common {
    self.hidesBottomBarWhenPushed = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    [self.view addSubview: scrollView];
    _mainView = scrollView;
    
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.backgroundColor = [UIColor whiteColor];
 
    
    NXOperationVCTitleView *topView = [[NXOperationVCTitleView alloc] initWithFrame:CGRectZero supportSortAndSearch:self.showSortSearch];
    topView.searchClickAction = self.searchCallBack;
    topView.sortClickAction = self.sortCallBack;
    [self.view addSubview:topView];
    _topView = topView;
    
    _topView.backgroundColor = [UIColor whiteColor];
    _topView.backClickAction = ^(id sender) {
        [self.navigationController popViewControllerAnimated:YES];
    };
    
    UIView *bottomView = [[UIView alloc] init];
    [self.view addSubview:bottomView];
    _bottomView = bottomView;
    
    bottomView.backgroundColor = [UIColor whiteColor];
    
    if (@available(iOS 11.0, *)) {
        [topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.view);
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
            
        }];
    }else {
        [topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.view);
            make.top.equalTo(self.mas_topLayoutGuideBottom);
        }];
    }
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
        make.left.and.right.equalTo(self.view);
        make.height.equalTo(self.view).multipliedBy(0.12);
    }];
    
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topView.mas_bottom);
        make.bottom.equalTo(bottomView.mas_top);
        make.width.equalTo(self.view);
        make.centerX.equalTo(self.view);
    }];

   // scrollView.contentInsetAdjustmentBehavior =UIScrollViewContentInsetAdjustmentScrollableAxes;
 
#if 0
    self.topView.backgroundColor = [UIColor lightGrayColor];
    self.bottomView.backgroundColor = [UIColor blueColor];
    self.mainView.backgroundColor = [UIColor magentaColor];
#endif
}

@end
