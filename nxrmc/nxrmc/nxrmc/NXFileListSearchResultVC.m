//
//  NXFileListSearchResultVC.m
//  nxrmc
//
//  Created by nextlabs on 1/10/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXFileListSearchResultVC.h"
#import "NXFolder.h"
#import "NXSharePointFile.h"
#import "NXSharePointFolder.h"
#import "NXRMCDef.h"
#import "NXCommonUtils.h"
#import "AppDelegate.h"
#import "Masonry.h"
#import "NXMyVaultCell.h"
@interface NXFileListSearchResultVC ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, weak) UITableView *tableView;
@property (nonatomic,weak) UIView *noSerchResultsTipsView;

@end

@implementation NXFileListSearchResultVC

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
     NXFileBase *fileItem = self.dataArray[indexPath.row];
    if (fileItem.sorceType == NXFileBaseSorceTypeMyVaultFile) {
        NXMyVaultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myVaultCell"];
        cell.model = fileItem;
           cell.selectionStyle = UITableViewCellSelectionStyleNone;
           WeakObj(self);
           cell.accessBlock = ^(id sender) {
               StrongObj(self);
               if (self) {
                   [self.delegate accessButtonClickForFileItem:fileItem];
                   if (self.resignActiveDelegate && [self.resignActiveDelegate respondsToSelector:@selector(searchVCShouldResignActive)]) {
                       [self.resignActiveDelegate searchVCShouldResignActive];
                   }
               }
           };
           
           cell.swipeButtonBlock = ^(SwipeButtonType type) {
               StrongObj(self);
               if (self) {
                   [self.delegate swipeButtonClick:type fileItem:fileItem];
                   if (self.resignActiveDelegate && [self.resignActiveDelegate respondsToSelector:@selector(searchVCShouldResignActive)] && type!= SwipeButtonTypeFavorite && type!= SwipeButtonTypeOffline) {
                       [self.resignActiveDelegate searchVCShouldResignActive];
                   }
               }
           };

           return cell;
    }else{
        NXFileItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
          
           cell.model = fileItem;
           cell.selectionStyle = UITableViewCellSelectionStyleNone;
           WeakObj(self);
           cell.accessBlock = ^(id sender) {
               StrongObj(self);
               if (self) {
                   [self.delegate accessButtonClickForFileItem:fileItem];
                   if (self.resignActiveDelegate && [self.resignActiveDelegate respondsToSelector:@selector(searchVCShouldResignActive)]) {
                       [self.resignActiveDelegate searchVCShouldResignActive];
                   }
               }
           };
           
           cell.swipeButtonBlock = ^(SwipeButtonType type) {
               StrongObj(self);
               if (self) {
                   [self.delegate swipeButtonClick:type fileItem:fileItem];
                   if (self.resignActiveDelegate && [self.resignActiveDelegate respondsToSelector:@selector(searchVCShouldResignActive)] && type!= SwipeButtonTypeFavorite && type!= SwipeButtonTypeOffline) {
                       [self.resignActiveDelegate searchVCShouldResignActive];
                   }
               }
           };

           return cell;
        
    }

   
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
    [tableView registerClass:[NXFileItemCell class] forCellReuseIdentifier:@"cell"];
    [tableView registerClass:[NXMyVaultCell class] forCellReuseIdentifier:@"myVaultCell"];
    tableView.tableFooterView = [[UIView alloc] init];
    tableView.estimatedRowHeight = 70;
    
    self.tableView = tableView;
     if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
                make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
            }];
        }
     }else{
         [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
             make.edges.equalTo(self.view);
             make.top.equalTo(self.mas_topLayoutGuideBottom);
         }];
     }
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
