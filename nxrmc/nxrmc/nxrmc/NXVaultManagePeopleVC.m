//
//  NXVaultManagePeopleVC.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/4/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXVaultManagePeopleVC.h"
#import "NXVaultAddPeopleVC.h"

#import "Masonry.h"
#import "NXVaultPeopleTableViewCell.h"
#import "NXRMCDef.h"
#import "UIView+UIExt.h"
#import "NXMBManager.h"

#import "NXLoginUser.h"
#import "NXCommonUtils.h"

@interface NXVaultManagePeopleVC ()<UITableViewDelegate, UITableViewDataSource, NXOperationVCDelegate>

@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, weak) UIButton *closeButton;

@property(nonatomic, strong)NSMutableArray *dataArray;

@end

@implementation NXVaultManagePeopleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self commonInit];
    
    [NXMBManager showLoadingToView:self.mainView];
    [self updateData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray=[NSMutableArray array];
    }
    return _dataArray;
}
#pragma mark
- (void)backClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - private method
- (void)updateData {
    WeakObj(self);
    [[NXLoginUser sharedInstance].myVault metaData:self.fileItem withCompletetino:^(NXMyVaultFile *file, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            StrongObj(self);
            [NXMBManager hideHUDForView:self.mainView];
            if (error) {
                [NXMBManager showMessage:error.localizedDescription toView:self.mainView hideAnimated:YES afterDelay:kDelay];
                return;
            }
            self.fileItem.rights = file.rights;
            self.fileItem.recipients = file.recipients;
            self.dataArray = [NSMutableArray arrayWithArray:self.fileItem.recipients];
            [self.tableView reloadData];
        });
    }];
}

- (void)revokePeople:(NSString *)people {
    
    WeakObj(self);
    [NXMBManager showLoadingToView:self.mainView];
    [[NXLoginUser sharedInstance].nxlOptManager updateSharedFileRecipients:self.fileItem newRecipients:@[] removedRecipients:@[people] comment:@"" withCompletion:^(NSArray *newRecipients, NSArray *removedRecipients, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            StrongObj(self);
            [NXMBManager hideHUDForView:self.mainView];
            if (error) {
                [NXMBManager showMessage:error.localizedDescription?error.localizedDescription:NSLocalizedString(@"MSG_REMOVE_FAILED", nil) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
            } else {
                [NXMBManager showMessage:NSLocalizedString(@"MSG_REMOVE_SUCCESS", nil) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
                [self updateData];
                if (DELEGATE_HAS_METHOD(self.delegate, @selector(viewcontroller:didfinishedOperationFile:toFile:))) {
                    [self.delegate viewcontroller:self didfinishedOperationFile:self.fileItem toFile:nil];
                }
            }
        });
    }];
}

#pragma mark
- (void)viewcontroller:(NXFileOperationPageBaseVC *)vc didfinishedOperationFile:(NXFileBase *)file toFile:(NXFileBase *)resultFile {
    [self updateData];
    [self.delegate viewcontroller:self didfinishedOperationFile:self.fileItem toFile:nil];
}

#pragma mark - UITableViewDelegate UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return self.dataArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"section1Cell"];
        cell.textLabel.text = NSLocalizedString(@"UI_SHARE_WITH_MORE_PEOPLE", NULL);
        cell.imageView.image = [UIImage imageNamed:@"add - black"];
        
        UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessoryIcon"]];
        [accessoryView setFrame:CGRectMake(0, 0, 20, 20)];
        cell.accessoryView = accessoryView;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    } else {
        NXVaultPeopleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (!cell) {
            cell =  [[NXVaultPeopleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if (indexPath.row + 1  == self.dataArray.count) {
            //remove sperator line
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, tableView.bounds.size.width);
        } else {
            //spearator line leading to border
            cell.separatorInset = UIEdgeInsetsMake(0, -60, 0, 0);
        }
        
        NSString *model = self.dataArray[indexPath.row];
        
        cell.model = model;
        WeakObj(self);
        cell.clickActionBlock = ^(id sender) {
            StrongObj(self);
            [self revokePeople:model];
        };
        
        if (self.fileItem.isRevoked || self.fileItem.isDeleted) {
            cell.accessoryView = nil;
        } else {
            cell.accessoryView = cell.accessoryButton;
        }
        
        return cell;
    }
    assert(true);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 44;
    } else {
        return 70;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.01;
    } else {
        return 30;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 10;
    } else {
        return 0.01;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"";
    } else {
        NSString *str = [NSString stringWithFormat:NSLocalizedString(@"UI_SHARE_WITH %ld people", NULL), self.dataArray.count];
        return str;
    }
}

//fix bug that section title always caps.
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]] && [self respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
        headerView.textLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (self.fileItem.isRevoked || self.fileItem.isDeleted) {
            return;
        }
        NXVaultAddPeopleVC *vc = [[NXVaultAddPeopleVC alloc] init];
        vc.fileItem = self.fileItem;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark
- (void)commonInit {
    self.mainView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.topView.model = self.fileItem;
    WeakObj(self);
    self.topView.backClickAction = ^(id sender) {
        StrongObj(self);
        [self backClicked:nil];
    };
    
    [self.bottomView removeFromSuperview];
    
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottomLayoutGuideBottom);
    }];
}

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        [self.mainView addSubview:tableView];
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        tableView.tableFooterView = [[UIView alloc]init];
        tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        tableView.showsVerticalScrollIndicator = NO;
        tableView.cellLayoutMarginsFollowReadableWidth = NO;
        tableView.separatorColor = tableView.backgroundColor;
        
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topView.mas_bottom).offset(kMargin);
            make.left.equalTo(self.view).offset(kMargin);
            make.right.equalTo(self.view).offset(-kMargin);
            make.bottom.equalTo(self.mas_bottomLayoutGuideBottom);
        }];
        _tableView = tableView;
    }
    return _tableView;
}

@end
