//
//  NXProjectFileListSearchResultViewController.m
//  nxrmc
//
//  Created by xx-huang on 17/02/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectFileListSearchResultViewController.h"

#import "NXFileBase.h"
#import "NXFolder.h"
#import "NXProjectFileItemCell.h"
#import "NXSharePointFile.h"
#import "NXSharePointFolder.h"
#import "NXCommonUtils.h"
#import "NXRMCDef.h"
#import "AppDelegate.h"
#import "Masonry.h"

@interface NXProjectFileListSearchResultViewController ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, weak) UITableView *tableView;
@property (nonatomic,weak) UIView *noSerchResultsTipsView;

@end

@implementation NXProjectFileListSearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateData {
    
    if (self.dataArray.count == 0) {
        [self.noSerchResultsTipsView setHidden:NO];
    }
    else
    {
        [self.noSerchResultsTipsView setHidden:YES];
    }
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /////////////////
    NXProjectFileItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NXFileBase *fileModel = self.dataArray[indexPath.row];

    cell.model = fileModel;
    cell.projectModel = self.searchProjet;
    
    WeakObj(self);
    cell.swipeButtonBlock = ^(SwipeButtonType type){
        StrongObj(self);
        if (self) {
            if (type == SwipeButtonTypeDelete) {
                [self.delegate fileListResultVC:self deleteItem:fileModel];
                
            }else if(type == SwipeButtonTypeActiveLog) {
                [self.delegate fileListResultVC:self infoForItem:fileModel];
            }
        }
        
        if (DELEGATE_HAS_METHOD(self.resignActiveDelegate, @selector(searchVCShouldResignActive))) {
            [self.resignActiveDelegate searchVCShouldResignActive];
        }
    };

    cell.accessBlock = ^(id sender) {
        StrongObj(self);
        if (DELEGATE_HAS_METHOD(self.delegate, @selector(fileListResultVC:accessForItem:))) {
//            [self.delegate fileListResultVC:self propertyForItem:fileModel];
            [self.delegate fileListResultVC:self accessForItem:fileModel];
        }
        if (DELEGATE_HAS_METHOD(self.resignActiveDelegate, @selector(searchVCShouldResignActive))) {
            [self.resignActiveDelegate searchVCShouldResignActive];
        }
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NXFileBase *fileItem = self.dataArray[indexPath.row];
    if (_delegate && [_delegate respondsToSelector:@selector(fileListResultVC: didSelectItem:)]) {
        [_delegate fileListResultVC:self didSelectItem:fileItem];
    }
    
    if (self.resignActiveDelegate && [self.resignActiveDelegate respondsToSelector:@selector(searchVCShouldResignActive)]) {
        [self.resignActiveDelegate searchVCShouldResignActive];
    }
}

#pragma mark

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self.parentViewController isKindOfClass:[UISearchController class]]) {
        UISearchController *searchVC = (UISearchController *)self.parentViewController;
        [searchVC.searchBar resignFirstResponder];
    }
}

#pragma mark
- (void)commonInit {
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:tableView];
    tableView.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
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
    [tableView registerClass:[NXProjectFileItemCell class] forCellReuseIdentifier:@"cell"];
    tableView.tableFooterView = [[UIView alloc] init];
    tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100,50)];
    
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

@end

