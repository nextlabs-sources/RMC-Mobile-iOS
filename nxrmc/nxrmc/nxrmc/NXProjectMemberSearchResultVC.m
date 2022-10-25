//
//  NXProjectMemberSearchResultVC.m
//  nxrmc
//
//  Created by xx-huang on 14/02/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectMemberSearchResultVC.h"
#import "NXProjectMemberDetailViewController.h"
#import "NXPeopleItemCell.h"
#import "NXPeoplePendingItemCell.h"
#import "AppDelegate.h"
#import "Masonry.h"
#import "NXRMCDef.h"


@interface NXProjectMemberSearchResultVC ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, weak) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *memberItems;
@property(nonatomic, strong) NSMutableArray *pendingItems;

@property (nonatomic,weak) UIView *noSerchResultsTipsView;
@end

@implementation NXProjectMemberSearchResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateData {
    _pendingItems = [[NSMutableArray alloc]init];
    _memberItems = [[NSMutableArray alloc]init];
    for (id item in self.dataArray) {
        if ([item isKindOfClass:[NXPendingProjectInvitationModel class]]) {
            [_pendingItems addObject:item];
        }else if ([item isKindOfClass:[NXProjectMemberModel class]]){
            [_memberItems addObject:item];
        }
    }
    
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_pendingItems.count>0&&_memberItems.count>0) {
        if (section == 0) {
            return _memberItems.count;
        }
        return _pendingItems.count;
    }else if (_pendingItems.count == 0 && _memberItems.count == 0){
        return 0;
    }
    if (_pendingItems.count>0) {
        return  _pendingItems.count;
    }
    return _memberItems.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
        if (_pendingItems.count>0&&_memberItems.count>0) {
        return 2;
    }else if (_pendingItems.count == 0 && _memberItems.count == 0){
        return 0;
    }
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (_pendingItems.count>0&&_memberItems.count>0) {
        if (section == 0) {
            return NSLocalizedString(@"UI_ACTIVE", NULL);
        }
        return NSLocalizedString(@"UI_PENDING", NULL);
    }else if (_pendingItems.count == 0 && _memberItems.count == 0){
        return @"";
    }
    if (_pendingItems.count>0) {
     return  NSLocalizedString(@"UI_PENDING", NULL);
    }
    return NSLocalizedString(@"UI_ACTIVE", NULL);
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_pendingItems.count>0&&_memberItems.count>0) {
        if (indexPath.section == 0) {
            NXPeopleItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            NXProjectMemberModel *memberModel = _memberItems[indexPath.row];
            cell.model = memberModel;
            WeakObj(self);
            cell.accessBlock = ^(id sender) {
                    StrongObj(self);
                if (_delegate && [_delegate respondsToSelector:@selector(memberListResultVC:didClickMemberAccessButton:)]) {
                    [_delegate memberListResultVC:self didClickMemberAccessButton:memberModel];
                }
                
                if (self.resignActiveDelegate && [self.resignActiveDelegate respondsToSelector:@selector(searchVCShouldResignActive)]) {
                    [self.resignActiveDelegate searchVCShouldResignActive];
                }
            };
            
            return cell;
        }
        NXPeoplePendingItemCell *pendingCell = [tableView dequeueReusableCellWithIdentifier:@"pendingCell"];
        NXPendingProjectInvitationModel *pendingModel = _pendingItems[indexPath.row];
        pendingCell.model = pendingModel;
          WeakObj(self);
        pendingCell.accessBlock = ^(id sender) {
              StrongObj(self);
            if (_delegate && [_delegate respondsToSelector:@selector(memberListResultVC:didClickPendingAccessButton:)]) {
                [_delegate memberListResultVC:self didClickPendingAccessButton:pendingModel];
            }
            
            if (self.resignActiveDelegate && [self.resignActiveDelegate respondsToSelector:@selector(searchVCShouldResignActive)]) {
                [self.resignActiveDelegate searchVCShouldResignActive];
            }
        };
        return pendingCell;
        }else if (_pendingItems.count == 0 && _memberItems.count == 0){
        return [[UITableViewCell alloc] init];
    }
    if (_pendingItems.count>0) {
        NXPeoplePendingItemCell *pendingCell = [tableView dequeueReusableCellWithIdentifier:@"pendingCell"];
        NXPendingProjectInvitationModel *pendingModel = _pendingItems[indexPath.row];
        pendingCell.model = pendingModel;
         WeakObj(self);
        pendingCell.accessBlock = ^(id sender) {
              StrongObj(self);
            if (_delegate && [_delegate respondsToSelector:@selector(memberListResultVC:didClickPendingAccessButton:)]) {
                [_delegate memberListResultVC:self didClickPendingAccessButton:pendingModel];
            }
            
            if (self.resignActiveDelegate && [self.resignActiveDelegate respondsToSelector:@selector(searchVCShouldResignActive)]) {
                [self.resignActiveDelegate searchVCShouldResignActive];
            }
        };
        
        return pendingCell;
    }
    
    NXPeopleItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NXProjectMemberModel *memberModel = self.dataArray[indexPath.row];
    cell.model = memberModel;
   WeakObj(self);
    cell.accessBlock = ^(id sender) {
       StrongObj(self);
        if (_delegate && [_delegate respondsToSelector:@selector(memberListResultVC:didClickMemberAccessButton:)]) {
            [_delegate memberListResultVC:self didClickMemberAccessButton:memberModel];
        }
        
        if (self.resignActiveDelegate && [self.resignActiveDelegate respondsToSelector:@selector(searchVCShouldResignActive)]) {
            [self.resignActiveDelegate searchVCShouldResignActive];
        }
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id memberModel = nil;
    if (_pendingItems.count>0&&_memberItems.count>0) {
        if (indexPath.section == 0) {
            memberModel = _memberItems[indexPath.row];
        }else {
            memberModel = _pendingItems[indexPath.row];
        }
        
    }else if (_pendingItems.count == 0 && _memberItems.count == 0){
        memberModel = nil;
    }else if (_pendingItems.count>0) {
        memberModel = _pendingItems[indexPath.row];
    }else {
        memberModel = _memberItems[indexPath.row];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(memberListResultVC:didSelectItem:)]) {
        [_delegate memberListResultVC:self didSelectItem:memberModel];
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
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    tableView.cellLayoutMarginsFollowReadableWidth = NO;
    UIView *noSearchResultView = [[UIView alloc] initWithFrame:self.view.bounds];
    noSearchResultView.backgroundColor = [UIColor whiteColor];
    tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
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
    [tableView registerClass:[NXPeopleItemCell class] forCellReuseIdentifier:@"cell"];
    [tableView registerClass:[NXPeoplePendingItemCell class] forCellReuseIdentifier:@"pendingCell"];
    tableView.tableFooterView = [[UIView alloc] init];
    tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)];
    tableView.estimatedRowHeight = 50;
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
