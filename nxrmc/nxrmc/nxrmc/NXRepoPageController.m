//
//  NXRepoPageController.m
//  AlphaVC
//
//  Created by helpdesk on 7/11/16.
//  Copyright © 2016年 nextlabs. All rights reserved.
//

#import "NXRepoPageController.h"
#import "NXProfileNavigationController.h"

#import "Masonry.h"
#import "NXNavigationBarView.h"
#import "NXNormalCell.h"
#import "UIView+UIExt.h"
#import "NXSortByView.h"
#import "NXMBManager.h"
#import "UIImage+ColorToImage.h"
#import "NXAddRepositoryViewController.h"
#import "NXLoginUser.h"
#import "NXBoundService+CoreDataClass.h"
#import "NXCommonUtils.h"
@interface NXRepoPageController ()<UITableViewDelegate, UITableViewDataSource, NXNavigationBarViewDelegate>

@property(nonatomic, strong) NSDictionary *repoSelIconDict;
@property(nonatomic, strong) NSDictionary *repoIconDict;
@property(nonatomic, strong) NSArray<NXRepositoryModel *> *dataArray;
@property(nonatomic, strong) NSMutableArray *selServiceArray;
@property(nonatomic, strong) NSMutableSet<NSNumber *> *selectIndexes;

@property(nonatomic, weak) UITableView *tableView;
@property(nonatomic, weak) UILabel *noteLabel;
@property(nonatomic, weak) UIButton *cancelBtn;
@property(nonatomic, weak) UIButton *addRepositoryBtn;
@property(nonatomic, weak) NXNavigationBarView *barView;
//@property(nonatomic, strong) UIView *curtabBarView;
@end

@implementation NXRepoPageController
//- (UIView *)curtabBarView {
//    if (!_curtabBarView) {
//        _curtabBarView = [self.tabBarController.view viewWithTag:TABBAR_VIEW_TAG];
//        }
//    return _curtabBarView;
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self commonInit];
    // Do any additional setup after loading the view.
    _repoIconDict = @{[NSNumber numberWithInteger:kServiceDropbox]:[UIImage imageNamed:@"dropbox - gray"],
                      [NSNumber numberWithInteger:kServiceSharepointOnline]:[UIImage imageNamed:@"sharepoint - gray"],
                      [NSNumber numberWithInteger:kServiceSharepoint]:[UIImage imageNamed:@"sharepoint - gray"],
                      [NSNumber numberWithInteger:kServiceOneDrive]:[UIImage imageNamed:@"onedrive - gray"],
                      [NSNumber numberWithInteger:kServiceGoogleDrive]:[UIImage imageNamed:@"google-drive-notSelected"],
                      [NSNumber numberWithInteger:kServiceSkyDrmBox]:[UIImage imageNamed:@"MyDrive - gray"],
                      [NSNumber numberWithInteger:kServiceBOX]:[UIImage imageNamed:@"box - gray"],
                      [NSNumber numberWithInteger:kServiceOneDriveApplication]:[UIImage imageNamed:@"onedrive - gray"],
                      [NSNumber numberWithInteger:KServiceSharepointOnlineApplication]:[UIImage imageNamed:@"sharepoint - gray"],
    };
    _repoSelIconDict = @{[NSNumber numberWithInteger:kServiceDropbox]:[UIImage imageNamed:@"dropbox - black"],
                       [NSNumber numberWithInteger:kServiceSharepointOnline]:[UIImage imageNamed:@"sharepoint - black"],
                       [NSNumber numberWithInteger:kServiceSharepoint]:[UIImage imageNamed:@"sharepoint - black"],
                       [NSNumber numberWithInteger:kServiceOneDrive]:[UIImage imageNamed:@"onedrive - black"],
                       [NSNumber numberWithInteger:kServiceGoogleDrive]:[UIImage imageNamed:@"google-drive-color"],
                       [NSNumber numberWithInteger:kServiceSkyDrmBox]:[UIImage imageNamed:@"MyDrive"],
                       [NSNumber numberWithInteger:kServiceBOX]:[UIImage imageNamed:@"box - black"],
                       [NSNumber numberWithInteger:kServiceOneDriveApplication]:[UIImage imageNamed:@"onedrive - black"],
                         [NSNumber numberWithInteger:KServiceSharepointOnlineApplication]:[UIImage imageNamed:@"sharepoint - black"],
    };
   
    if (KScreenWidth > 414&&![NXCommonUtils isiPad]) {
        [self.barView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).with.offset(0);
            make.left.equalTo(self.view.mas_left);
            make.right.equalTo(self.view.mas_right);
            make.height.equalTo(@44);
          }];
      }
    
    [self addObserver:self forKeyPath:@"selServiceArray" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotateScreenRepo) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(repositoryInfoDidUpdate:) name:NOTIFICATION_REPO_UPDATED object:nil];
    
    [self.barView.rightBarBtn setTitle:NSLocalizedString(@"UNSELECT ALL", NULL) forState:UIControlStateSelected];
    [self.barView.rightBarBtn setTitle:NSLocalizedString(@"SELECT ALL", NULL) forState:UIControlStateNormal];
    
    [self reloadData];
}

- (void)repositoryInfoDidUpdate:(NSNotification *)notification
{
    dispatch_main_async_safe(^{
        [self reloadData];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    self.navigationController.navigationBarHidden = YES;
//    for (UIView *view in self.tabBarController.view.subviews) {
//        if ([view isKindOfClass:[NXSortByButtonView class]]) {
//            view.hidden = YES;
//        }
//    }
//    self.curtabBarView.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//        self.navigationController.navigationBarHidden = NO;
   
    
//     self.curtabBarView.hidden = NO;

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //update some UI
    [self.cancelBtn cornerRadian:self.cancelBtn.bounds.size.width/2.0];
    [self.noteLabel addShadow:UIViewShadowPositionBottom color:[UIColor lightGrayColor] width:2 Opacity:0.8];
    [self.addRepositoryBtn cornerRadian:5];
    [self.barView addShadow:UIViewShadowPositionBottom color:[UIColor lightGrayColor] width:2 Opacity:0.8];
    
//    [self reloadData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:@"selServiceArray"];
    DLog();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
- (void)reloadData {
    self.selServiceArray = nil;
    [self.selectIndexes removeAllObjects];
    
    [self.tableView reloadData];
    WeakObj(self);
    [self.dataArray enumerateObjectsUsingBlock:^(NXRepositoryModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        StrongObj(self);
        if (obj.service_selected.boolValue == YES && obj.service_isAuthed.boolValue == YES) {
            [self.selectIndexes addObject:@(idx)];
            [[self mutableArrayValueForKeyPath:@"selServiceArray"]addObject:obj];
        }
    }];
    
    [self.selectIndexes enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:obj.integerValue inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    }];
}

- (void)loadServiceArrayData {
    [_selServiceArray removeAllObjects];
    for(NXRepositoryModel *service in self.dataArray) {
        if (service.service_selected.boolValue && service.service_isAuthed.boolValue) {
            [[self mutableArrayValueForKeyPath:@"selServiceArray"]addObject:service];
        }
    }
}

- (void)cancel {
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    //fix bug navigationBar  become green when set auth to repository;
    self.navigationController.navigationBarHidden=NO;
//    [self.view removeFromSuperview];
//    [self removeFromParentViewController];
    [self.navigationController popViewControllerAnimated:NO];
}

//- (void)notHiddenSortByButtonView{
//    for (UIView *view in self.tabBarController.view.subviews) {
//        if ([view isKindOfClass:[NXSortByButtonView class]]) {
//            view.hidden = NO;
//        }
//    }
//}

- (void)rotateScreenRepo {
    if ([NXCommonUtils isiPad]) {
        return;
    }
    if (KScreenWidth > 414) {
        [self.barView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).with.offset(0);
            make.left.equalTo(self.view.mas_left);
            make.right.equalTo(self.view.mas_right);
            make.height.equalTo(@44);
        }];
    } else {
        [self.barView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).with.offset(20);
            make.left.equalTo(self.view.mas_left);
            make.right.equalTo(self.view.mas_right);
            make.height.equalTo(@44);
        }];
    }
}

#pragma mark
- (NSMutableSet<NSNumber *> *)selectIndexes {
    if (!_selectIndexes) {
        _selectIndexes = [NSMutableSet set];
    }
    return _selectIndexes;
}

- (NSMutableArray *)selServiceArray {
    if (!_selServiceArray) {
        _selServiceArray =[NSMutableArray array];
    }
    return  _selServiceArray;
}

- (NSArray<NXRepositoryModel *> *)dataArray {
    _dataArray = [[NXLoginUser sharedInstance].myRepoSystem allAuthReposiories];
    return _dataArray;
}

#pragma mark
- (void)leftBarBtnClicked:(UIButton *)sender {
//    [self notHiddenSortByButtonView];
    [self cancel];
}

- (void)cancelBtnClicked:(UIButton*)sender {
//    [self notHiddenSortByButtonView];
    [self cancel];
}

- (void)rightBarBtnClicked:(UIButton *)sender {
    if (sender.isSelected) {
        [self.dataArray enumerateObjectsUsingBlock:^(NXRepositoryModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.service_selected.boolValue) {
                [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:NO];
                [self tableView:self.tableView didDeselectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
            }
        }];
    } else {
        [self.dataArray enumerateObjectsUsingBlock:^(NXRepositoryModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!obj.service_selected.boolValue && obj.service_isAuthed.boolValue == YES) {
                [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
                [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
            }
        }];
    }
}

- (void)addRepositoryBtnClicked:(UIButton *)sender {
    [self.delegate serviceNXRepoPageVCDidSelectAddService:self];
    NXAddRepositoryViewController *addRepoVC = [[NXAddRepositoryViewController alloc]init];
    [self.navigationController pushViewController:addRepoVC animated:NO];
}

#pragma mark - NSKeyValueObserving
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"selServiceArray"]) {
        //select all means all authorizationed services has been selected.
        __block NSInteger authCount = 0;
        [self.dataArray enumerateObjectsUsingBlock:^(NXRepositoryModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.service_isAuthed.boolValue) {
                authCount++;
            }
        }];
        self.barView.rightBarBtn.selected = self.selServiceArray.count == authCount;
        if (DELEGATE_HAS_METHOD(self.delegate, @selector(serviceNXRepoPageVC:didSelectServices:))) {
            [self.delegate serviceNXRepoPageVC:self didSelectServices:self.selServiceArray];
        }
    }
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NXNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NXNormalCell" forIndexPath:indexPath];
    NXRepositoryModel *boundService = self.dataArray[indexPath.row];
    [cell reSet];
    [cell setMainTitle:boundService.service_alias forState:UIControlStateNormal];
    [cell setMainTitleColor:RMC_MAIN_COLOR forState:UIControlStateSelected];
    [cell setSubTitle:boundService.service_account forState:UIControlStateNormal];
    UIImage *iconImageGray =self.repoIconDict[boundService.service_type];
    UIImage *iconImage = self.repoSelIconDict[boundService.service_type];
    [cell setLeftImage:iconImageGray  forState:UIControlStateNormal];
    [cell setLeftImage:iconImage forState:UIControlStateSelected];
    
    if (boundService.service_isAuthed.boolValue) {
        [cell setRightImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [cell setRightImage:[UIImage imageNamed:@"repo selected - green"] forState:UIControlStateSelected];
    } else {
        [cell setRightImage:[UIImage imageNamed:@"HighPriority"] forState:UIControlStateNormal];
        [cell setRightImage:[UIImage imageNamed:@"HighPriority"] forState:UIControlStateSelected];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NXRepositoryModel *boundService = self.dataArray[indexPath.row];
    if (boundService.service_isAuthed.boolValue == NO) {
        WeakObj(self);
        [[NXLoginUser sharedInstance].myRepoSystem authRepositoyInViewController:self forRepo:boundService completion:^(NXRepositoryModel *repo, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                StrongObj(self);
                if (error && error.code != NXRMC_ERROR_CODE_CANCEL) {
                    [NXMBManager showMessage:error.localizedDescription toView:self.view hideAnimated:YES afterDelay:1.5 * kDelay];
                    return;
                }
                [self reloadData];

            });
        }];
        return;
    }
    
    boundService.service_selected = @(!boundService.service_selected.boolValue);
    WeakObj(self);
    [[NXLoginUser sharedInstance].myRepoSystem updateRepository:boundService completion:^(NXRepositoryModel *repo, NSError *error) {
        StrongObj(self);
        if (error) {
            [NXMBManager showMessage:error.localizedDescription toView:self.view hideAnimated:YES afterDelay:kDelay];
        } else {
            if (![self.selServiceArray containsObject:boundService]) {
                [[self mutableArrayValueForKeyPath:@"selServiceArray"]addObject:boundService];
            }
        }
    }];
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NXRepositoryModel *boundService = self.dataArray[indexPath.row];
    if (boundService.service_isAuthed.boolValue == NO) {
        return;
    }
    
    boundService.service_selected = @(!boundService.service_selected.boolValue);
    WeakObj(self);
    [[NXLoginUser sharedInstance].myRepoSystem updateRepository:boundService completion:^(NXRepositoryModel *repo, NSError *error) {
        StrongObj(self);
        if (error) {
            [NXMBManager showMessage:error.localizedDescription toView:self.view hideAnimated:YES afterDelay:kDelay];
        } else {
            [[self mutableArrayValueForKeyPath:@"selServiceArray"]removeObject:boundService];
        }
    }];
}

#pragma mark
- (void)commonInit {
    self.view.backgroundColor=[UIColor colorWithWhite:1.0 alpha:kAlpha];
    
    UILabel *noteLabel = [[UILabel alloc]init];
    [self.view addSubview:noteLabel];
    
    NXNavigationBarView *barView = [[NXNavigationBarView alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 44)];
    [self.view addSubview:barView];
    
    UIView *bottomView = [[UIView alloc] init];
    [self.view addSubview:bottomView];
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    
    noteLabel.backgroundColor = [UIColor lightGrayColor];
    noteLabel.text = NSLocalizedString(@"Only selected repositories will be shown in your home screen.", NULL);
    noteLabel.textAlignment = NSTextAlignmentCenter;
    noteLabel.font = [UIFont systemFontOfSize:13];
    noteLabel.numberOfLines = 0;
    noteLabel.backgroundColor = [UIColor colorWithRed:220/255.0 green:218/255.0 blue:220/255.0 alpha:1];

    barView.backgroundColor = [UIColor whiteColor];
    barView.delegate = self;
    
    tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.allowsMultipleSelection = YES;
    tableView.cellLayoutMarginsFollowReadableWidth = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[NXNormalCell class] forCellReuseIdentifier:@"NXNormalCell"];
    
    UIButton *addRepositoryBtn = [[UIButton alloc] init];
    [bottomView addSubview:addRepositoryBtn];
    UIButton *cancelBtn = [[UIButton alloc] init];
    [bottomView addSubview:cancelBtn];
    
    [addRepositoryBtn setTitle:@"ADD REPOSITORY  > " forState:UIControlStateNormal];
    [addRepositoryBtn addTarget:self action:@selector(addRepositoryBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [addRepositoryBtn setBackgroundImage:[UIImage imageWithSize:CGSizeMake(200, 200) colors:@[RMC_GRADIENT_START_COLOR, RMC_GRADIENT_END_COLOR] gradientType:GradientTypeLeftToRight] forState:UIControlStateNormal];

    [cancelBtn setImage:[UIImage imageNamed:@"Cancel Black"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.tintColor = [UIColor blackColor];
    
    cancelBtn.backgroundColor = [UIColor whiteColor];
    cancelBtn.layer.shadowOpacity = 0.9;
    cancelBtn.layer.shadowRadius = 2;
    cancelBtn.layer.shadowOffset = CGSizeMake(1, 1);
    cancelBtn.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    
    self.noteLabel = noteLabel;
    self.tableView =tableView;
    
    self.barView = barView;
    
    self.addRepositoryBtn = addRepositoryBtn;
    self.cancelBtn = cancelBtn;
    
    [barView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(20);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.equalTo(@44);
    }];
    [noteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(barView.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.equalTo(@35);
    }];
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(noteLabel.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
    }];
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tableView.mas_bottom);
        make.height.equalTo(@kBottomViewHeight);
        make.bottom.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
    }];
    
    [addRepositoryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bottomView);
        make.right.equalTo(bottomView).offset(-kMargin * 3);
        make.height.equalTo(bottomView).multipliedBy(0.45);
        make.width.equalTo(bottomView).multipliedBy(0.6);
    }];
    
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(addRepositoryBtn);
        make.width.equalTo(addRepositoryBtn.mas_height);
        make.right.equalTo(addRepositoryBtn.mas_left).offset(-kMargin * 2);
        make.centerY.equalTo(addRepositoryBtn);
    }];
}

@end
