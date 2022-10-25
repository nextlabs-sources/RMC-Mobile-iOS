//
//  NXProjectMemberDetailViewController.m
//  nxrmc
//
//  Created by xx-huang on 06/02/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectMemberDetailViewController.h"
#import "NXProjectMemberDetailCell.h"
#import "NXProjectMemberDetailHeaderView.h"
#import "UIView+UIExt.h"
#import "Masonry.h"
#import "NXLoginUser.h"
#import "MBProgressHUD.h"
#import "NXMBManager.h"
#import "UIImage+Cutting.h"
#import "NXCommonUtils.h"
#import "NXLProfile.h"
@interface NXProjectMemberDetailViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NXProjectMemberDetailHeaderView *headerView;
@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) UIButton *delMemberBtn;
@property (nonatomic,strong) UILabel *inviteByLabel;
@property (nonatomic,strong) UIButton *closeButton;

@property (nonatomic,strong) NXProjectMemberModel *memberModel;
@property (nonatomic,strong) NXProjectModel *projectModel;
@property (nonatomic,strong) NSMutableArray *dataSource;
@end

@implementation NXProjectMemberDetailViewController

#pragma -mark LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self commonInit];
    
    _dataSource = [[NSMutableArray alloc] init];
    
    [self configureDataSource];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(projectMemberDidUpdated:) name:NOTIFICATION_PROJECT_MEMBER_UPDATED object:nil];
}

- (void)projectMemberDidUpdated:(NSNotification *)notification
{
    WeakObj(self);
    NXProjectModel *projectModel = [[NXLoginUser sharedInstance].myProject getProjectModelForProjectId:self.memberModel.projectId];
    [[NXLoginUser sharedInstance].myProject allMemebersInProject:projectModel withCompletion:^(NXProjectModel *project, NSArray *memebersArray, NSError *error) {
        StrongObj(self);
        if (self) {
            if (!error) {
                if (![memebersArray containsObject:self.memberModel]) {
                    dispatch_main_async_safe(^{
                        [self backToMembersPage];
                    });
                }
            }
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    WeakObj(self);
    [[NXLoginUser sharedInstance].myProject getMemberDetails:_memberModel withCompletion:^(NXProjectMemberModel *memberDetail, NSError *error) {
        
        StrongObj(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                _memberModel.inviterEmail = memberDetail.inviterEmail;
                _memberModel.inviterDisplayName = memberDetail.inviterDisplayName;
                NSString *str = nil;
                if (_memberModel.inviterDisplayName == nil) {
                    
                }
                else
                {
                    NSString *invitedByStr = NSLocalizedString(@"UI_INVITE_BY",NULL);
                    str = [NSString stringWithFormat:@"%@ %@",invitedByStr,_memberModel.inviterDisplayName];
                    
                    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:str];
                    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, invitedByStr.length)];
                            self.inviteByLabel.attributedText = attrStr;
//                    self.headerView.invitedByLabel.attributedText = attrStr;
                }
            }        });
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark Method

- (void)configureProjectMemberModel:(NXProjectMemberModel *)memberModel
{
     _memberModel = memberModel;
}

- (void)commonInit {
    
    self.view.backgroundColor = [UIColor whiteColor];
//    self.navigationItem.title = [self textTwoLongDotsInMiddleWithStr:_memberModel.displayName];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - kMargin * 2, self.view.bounds.size.height - 80)];
    [self.view addSubview:tableView];
    tableView.cellLayoutMarginsFollowReadableWidth = NO;
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 160)];
    [footView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:footView];
    
    UIButton *removeFromProjectButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
    [footView addSubview:removeFromProjectButton];
    
    [removeFromProjectButton cornerRadian:4];
//    removeFromProjectButton.backgroundColor = [UIColor colorWithRed:227.0/255.0 green:84.0/255.0 blue:84.0/255.0 alpha:1.0];
    removeFromProjectButton.backgroundColor = [UIColor whiteColor];
    removeFromProjectButton.layer.borderColor = [UIColor redColor].CGColor;
    removeFromProjectButton.layer.borderWidth = 0.7;
    [removeFromProjectButton setTitle:NSLocalizedString(@"UI_REMOVE_FROM_PROJECT", NULL) forState:UIControlStateNormal];
    [removeFromProjectButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [removeFromProjectButton addTarget:self action:@selector(removeFromProject:) forControlEvents:UIControlEventTouchUpInside];
    removeFromProjectButton.titleLabel.font = [UIFont systemFontOfSize:16];
    
    UILabel *invitedByLabel = [[UILabel alloc] init];
    invitedByLabel.font = [UIFont systemFontOfSize:15];
    invitedByLabel.textColor = [UIColor blackColor];
    invitedByLabel.textAlignment = NSTextAlignmentCenter;
    invitedByLabel.userInteractionEnabled = YES;
    [footView addSubview:invitedByLabel];
    self.inviteByLabel = invitedByLabel;
    
//    UIButton *closeButton = [[UIButton alloc] init];
//    [closeButton setImage:[UIImage imageNamed:@"Cancel Black"] forState:UIControlStateNormal];
//    [closeButton addTarget:self action:@selector(closeClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:closeButton];
//    self.closeButton = closeButton;
//    
//    [self.closeButton setHidden:YES];

    NXProjectMemberDetailHeaderView *headerView = [[NXProjectMemberDetailHeaderView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 280)];
    self.headerView = headerView;
    UIImage *headImage = [UIImage imageWithBase64Str:_memberModel.avatarBase64];
    
    if (!headImage) {
//        headerView.avatarImageView.image = [UIImage imageNamed:@"Account"];
        headerView.nameStr = _memberModel.displayName;
    } else {
        headerView.avatarImageView.hidden = NO;
        [headerView.avatarImageView setImage:headImage];
    }

    headerView.nameLabel.text = _memberModel.displayName;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:_memberModel.joinTime]];
    NSString *joinOnStr = NSLocalizedString(@"UI_JOIN_ON", NULL);
    NSString *astr = [NSString stringWithFormat:@"%@ %@",joinOnStr,strDate];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:astr];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, joinOnStr.length)];
    headerView.joinTimeLabel.attributedText = attrStr;
    
    tableView.tableHeaderView = headerView;
    tableView.tableFooterView = footView;
    tableView.estimatedRowHeight = 65;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [tableView registerClass:[NXProjectMemberDetailCell class] forCellReuseIdentifier:@"contentCell"];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    self.tableView = tableView;
    
//    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(footView.mas_bottom).offset(kMargin);
//        make.centerX.equalTo(self.view);
//        make.width.and.height.equalTo(@50);
//        make.bottom.equalTo(self.mas_bottomLayoutGuideTop).offset(-kMargin * 2);
//    }];
    
    
    [invitedByLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(footView).offset(kMargin * 5);
        make.centerX.equalTo(footView);
        make.width.equalTo(footView).multipliedBy(0.9);
    }];
    
    [removeFromProjectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(invitedByLabel.mas_bottom).offset(kMargin * 4);
        make.centerX.equalTo(self.view);
        make.height.equalTo(@(40));
        make.width.equalTo(footView).multipliedBy(0.6);
    }];
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.left.and.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    if (self.isOwerByMe == YES) {
        if ([[self.memberModel.userId stringValue]isEqualToString: [NXLoginUser sharedInstance].profile.userId]) {
            removeFromProjectButton.hidden = YES;
        } else {
            removeFromProjectButton.hidden = NO;
        }
    } else {
        removeFromProjectButton.hidden = YES;
    }
    self.delMemberBtn = removeFromProjectButton;
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)configureDataSourceWithDataModel:(NXProjectMemberModel *)dataModel
{
    // TODO
}

- (void)configureDataSource
{
    dataModel *model = [[dataModel alloc] initWithTittle:@"Email" content:_memberModel.email];
    [_dataSource addObject:model];
}

#pragma -mark Button Event

- (void)removeFromProject:(id)sender
{
     NSString *message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"MSG_DO_YOU_WANT_TO_REMOVE", NULL),self.memberModel.displayName];
    [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message: message style:UIAlertControllerStyleAlert cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherActionTitles:@[NSLocalizedString(@"UI_BOX_OK", NULL)] inViewController:self position:self.view tapBlock:^(UIAlertAction *action, NSInteger index) {
        if (index == 1) {
    [NXMBManager showLoadingToView:self.view];
    WeakObj(self);
    [[NXLoginUser sharedInstance].myProject removeProjectMember:_memberModel withCompletion:^(NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            StrongObj(self);
            [NXMBManager hideHUDForView:self.view];
            if (!error) {
                NSString *message = [[NSString alloc] initWithFormat:NSLocalizedString(@"MSG_COM_REMOVE_MEMEBER_SUCCESS", nil), _memberModel.displayName];
                [NXMBManager showMessage:message hideAnimated:YES afterDelay:1.5];
                [self performSelector:@selector(backToMembersPage) withObject:nil afterDelay:2.0];
            }
            else
            {
                [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:1.5];
            }
        });
    }];
}
    }];
     }
- (void)backToMembersPage {
//    self.delMemberBtn.backgroundColor = [UIColor groupTableViewBackgroundColor];
//    self.delMemberBtn.userInteractionEnabled = NO;
//    self.delMemberBtn.hidden = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)closeClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma -mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    if (section == 0) {
        view.backgroundColor = [UIColor whiteColor];
    } else {
        view.backgroundColor = self.view.backgroundColor;
    }
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    dataModel *obj = [_dataSource objectAtIndex:indexPath.row];
    
    NXProjectMemberDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contentCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell configureCellWithDataModel:obj];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
}
- (NSString *)textTwoLongDotsInMiddleWithStr:(NSString *)str {
    NSString *newStr = nil;
    if (str.length>35) {
        NSString *frontStr = [str substringToIndex:15];
        NSString *behindStr = [str substringFromIndex:str.length-15];
        NSString *dotStr = @"...";
        newStr = [NSString stringWithFormat:@"%@%@%@",frontStr,dotStr,behindStr];
        return newStr;
    }
    return str;
}
@end
