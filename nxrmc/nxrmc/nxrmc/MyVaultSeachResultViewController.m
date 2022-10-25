//
//  MyVaultSeachResultViewController.m
//  nxrmc
//
//  Created by nextlabs on 1/4/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "MyVaultSeachResultViewController.h"

#import "Masonry.h"
#import "NXMyVaultCell.h"
#import "NXSharedFileCell.h"

#import "NXSharedWithMeFile.h"
#import "NXMyVaultFile.h"
#import "NXFavoriteFileCell.h"

#import "NXCommonUtils.h"
#import "NXOfflineFileCell.h"

@interface MyVaultSeachResultViewController ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, weak) UITableView *tableView;
@property (nonatomic,weak) UIView *noSerchResultsTipsView;

@property(nonatomic, strong) NSString *cellType;

@end

@implementation MyVaultSeachResultViewController

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
    } else {
        [self.noSerchResultsTipsView setHidden:YES];
        NXFileBase *file = self.dataArray[0];
        if (self.searchFromFavoritePage == YES) {
              self.cellType = @"favoriteCell";
        }
        else
        {
            if ([file isKindOfClass:[NXMyVaultFile class]]) {
                self.cellType = @"cell";
            } else if ([file isKindOfClass:[NXSharedWithMeFile class]]) {
                self.cellType = @"sharedFileCell";
            }else if ([file isKindOfClass:[NXOfflineFile class]]){
                self.cellType = @"offlineCell";
            }
        }
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
    NXMyVaultCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellType?:@"cell"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NXMyVaultFile *model = self.dataArray[indexPath.row];
    
    cell.model = model;
    
    WeakObj(self);
    cell.accessBlock = ^(id sender) {
        StrongObj(self);
        if (self) {
            if (DELEGATE_HAS_METHOD(self.delegate, @selector(accessButtonClickForFileItem:))) {
                [self.delegate accessButtonClickForFileItem:model];
            }
            if (DELEGATE_HAS_METHOD(self.resignActiveDelegate, @selector(searchVCShouldResignActive))) {
                [self.resignActiveDelegate searchVCShouldResignActive];
            }
        }
    };
    cell.swipeButtonBlock = ^(SwipeButtonType type){
        StrongObj(self);
        if (DELEGATE_HAS_METHOD(self.delegate, @selector(swipeButtonClick:fileItem:))) {
            [self.delegate swipeButtonClick:type fileItem:model];
        }
        if (DELEGATE_HAS_METHOD(self.resignActiveDelegate, @selector(searchVCShouldResignActive))) {
            [self.resignActiveDelegate searchVCShouldResignActive];
        }
    };
    
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 70;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id fileItem = self.dataArray[indexPath.row];
    if ([fileItem isKindOfClass:[NXMyVaultFile class]]) {
        NXMyVaultFile *myvaulteFile = fileItem;
        if (DELEGATE_HAS_METHOD(self.delegate, @selector(myVaultFileListResultVC:didSelectItem:))) {
            [self.delegate myVaultFileListResultVC:self didSelectItem:myvaulteFile];
        }
    }else if ([fileItem isKindOfClass:[NXOfflineFile class]]){
          NXOfflineFile *offlineFile = fileItem;
        if (DELEGATE_HAS_METHOD(self.delegate, @selector(offlineFileListResultVC:didSelectItem:))) {
             [self.delegate offlineFileListResultVC:self didSelectItem:offlineFile];
        }
    }else if ([fileItem isKindOfClass:[NXSharedWithMeFile class]]){
        NXSharedWithMeFile *sharedWithMeFile = fileItem;
        if (DELEGATE_HAS_METHOD(self.delegate, @selector(myVaultFileListResultVC:didSelectItem:))) {
            [self.delegate myVaultFileListResultVC:self didSelectItem:(NXMyVaultFile *)sharedWithMeFile];
        }
       
    }
    
    if (DELEGATE_HAS_METHOD(self.resignActiveDelegate, @selector(searchVCShouldResignActive))) {
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
    [tableView registerClass:[NXMyVaultCell class] forCellReuseIdentifier:@"cell"];
    [tableView registerClass:[NXSharedFileCell class] forCellReuseIdentifier:@"sharedFileCell"];
    [tableView registerClass:[NXFavoriteFileCell class] forCellReuseIdentifier:@"favoriteCell"];
    [tableView registerClass:[NXOfflineFileCell class] forCellReuseIdentifier:@"offlineCell"];
    tableView.tableFooterView = [[UIView alloc] init];
    if (self.isFromWorkSpace) {
        tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    }else{
        tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 50)];
    }
    tableView.estimatedRowHeight = 70;
    
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
