//
//  NXFilterViewController.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 8/5/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXFilterViewController.h"
#import "Masonry.h"
#import "NXNormalCell.h"
#import "NXRepositoryModel.h"
#import "NXLoginUser.h"
#import "NXMBManager.h"
#import "NXFileSort.h"
#import "NXCommonUtils.h"
@interface NXFilterViewController ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
@property(nonatomic, strong)UITableView *repoTableView;
@property(nonatomic, strong) NSDictionary *repoSelIconDict;
@property(nonatomic, strong) NSDictionary *repoIconDict;
@property(nonatomic, strong) NSDictionary *sortByTypeDict;
@property(nonatomic, strong) NSArray<NXRepositoryModel *> *dataArray;
@property(nonatomic, strong) NSMutableArray *selServiceArray;
@property(nonatomic, strong) NSMutableArray *changeServiceArray;
@property(nonatomic, strong) NSMutableSet<NSNumber *> *selectIndexes;
@property(nonatomic, strong) NSMutableArray *segmentItemStrs;
@property(nonatomic, strong) UISegmentedControl *sortSetment;
@property(nonatomic, assign) NSInteger currentSortByType;
@end

@implementation NXFilterViewController
#pragma mark
- (NSMutableArray *)segmentItemStrs {
    if (!_segmentItemStrs) {
        _segmentItemStrs = [NSMutableArray array];
        for (NSNumber *itemNum in self.segmentItems) {
            NSString *itemStr = _sortByTypeDict[itemNum];
            [_segmentItemStrs addObject:itemStr];
        }
    }
    return _segmentItemStrs;
}
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
//    if (buildFromSkyDRMEnterpriseTarget && [NXCommonUtils isCompanyAccountLogin]) {
//           NXRepositoryModel *myDrive = [[NXLoginUser sharedInstance].myRepoSystem getNextLabsRepository];
//              _dataArray = [NSArray arrayWithObject:myDrive];
//
//       }else{
              _dataArray = [[NXLoginUser sharedInstance].myRepoSystem allAuthReposiories];
//       }
       
    return _dataArray;
}
- (NSMutableArray *)changeServiceArray {
    if (!_changeServiceArray) {
        _changeServiceArray = [NSMutableArray array];
    }
    return _changeServiceArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    UITapGestureRecognizer *tapGetRer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeThisPage:)];
    tapGetRer.delegate = self;
    [self.view addGestureRecognizer:tapGetRer];

    _repoIconDict = @{[NSNumber numberWithInteger:kServiceDropbox]:[UIImage imageNamed:@"dropbox - gray"],
                      [NSNumber numberWithInteger:kServiceSharepointOnline]:[UIImage imageNamed:@"sharepoint - gray"],
                      [NSNumber numberWithInteger:kServiceSharepoint]:[UIImage imageNamed:@"sharepoint - gray"],
                      [NSNumber numberWithInteger:kServiceOneDrive]:[UIImage imageNamed:@"onedrive - gray"],
                      [NSNumber numberWithInteger:kServiceGoogleDrive]:[UIImage imageNamed:@"google-drive-notSelected"],
                      [NSNumber numberWithInteger:kServiceBOX]:[UIImage imageNamed:@"box - gray"],
                      [NSNumber numberWithInteger:kServiceSkyDrmBox]:[UIImage imageNamed:@"MyDrive - gray"],
                      [NSNumber numberWithInteger:kServiceOneDriveApplication]:[UIImage imageNamed:@"onedrive - gray"]
                      
    };
    _repoSelIconDict = @{[NSNumber numberWithInteger:kServiceDropbox]:[UIImage imageNamed:@"dropbox - black"],
                         [NSNumber numberWithInteger:kServiceSharepointOnline]:[UIImage imageNamed:@"sharepoint - black"],
                         [NSNumber numberWithInteger:kServiceSharepoint]:[UIImage imageNamed:@"sharepoint - black"],
                         [NSNumber numberWithInteger:kServiceOneDrive]:[UIImage imageNamed:@"onedrive - black"],
                         [NSNumber numberWithInteger:kServiceGoogleDrive]:[UIImage imageNamed:@"google-drive-color"],
                         [NSNumber numberWithInteger:kServiceBOX]:[UIImage imageNamed:@"box - black"],
                         [NSNumber numberWithInteger:kServiceSkyDrmBox]:[UIImage imageNamed:@"MyDrive"],
                         [NSNumber numberWithInteger:kServiceOneDriveApplication]:[UIImage imageNamed:@"onedrive - black"]
                         
    };
    _sortByTypeDict = @{[NSNumber numberWithInteger: NXSortOptionNameAscending]:@"A to Z",
                        [NSNumber numberWithInteger: NXSortOptionNameDescending]:@"Z to A",
                        [NSNumber numberWithInteger: NXSortOptionDriveAscending]:@"Source",
                        [NSNumber numberWithInteger: NXSortOptionDateDescending]:@"Date",
                        [NSNumber numberWithInteger: NXSortOptionDateAscending]:@"Date up",
                        [NSNumber numberWithInteger: NXSortOptionSizeAscending]:@"Size",
                        [NSNumber numberWithInteger: NXSortOptionSharedByDescending]:@"Shared By",
                        [NSNumber numberWithInteger:NXSortOptionSharedByAscending]:@"Shared By",
                        [NSNumber numberWithInteger:NXSortOptionOperationResultAscending]:@"Result",
                        [NSNumber numberWithInteger:NXSortOptionOperationAscending]:@"Operation",
                        [NSNumber numberWithInteger:NXSortOptionModifiedDate]:@"Modified Date"
                        };
    [self commonInit];
    [self reloadNewData];

}
- (void)commonInit {
    // titleView
    UIView *titleView = [[UIView alloc]init];
    titleView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:titleView];
//    UILabel *titleLabel = [[UILabel alloc]init];
//    titleLabel.textAlignment = NSTextAlignmentCenter;
//    titleLabel.text = @"Filter";
//    [titleView addSubview:titleLabel];
//    UIButton *applyBtn = [[UIButton alloc]init];
//    [applyBtn setTitle:@"Apply" forState:UIControlStateNormal];
//    [applyBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    applyBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
//    [applyBtn addTarget:self action:@selector(applyClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [titleView addSubview:applyBtn];
    [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(@64);
    }];
//    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.view).offset(20);
//        make.centerX.equalTo(titleView);
//        make.width.equalTo(@60);
//        make.height.equalTo(@40);
//    }];
//    [applyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.and.width.height.equalTo(titleLabel);
//        make.right.equalTo(titleView).offset(-10);
//    }];
    // sort by view
    UIView *sortByView = [[UIView alloc]init];
    sortByView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:sortByView];
    UILabel *sortLabel = [[UILabel alloc]init];
    sortLabel.text = @"Sort by";
    [sortByView addSubview:sortLabel];
    UISegmentedControl *sortSetment = [[UISegmentedControl alloc]initWithItems:self.segmentItemStrs];
    NSInteger selectedIndex =  [self.segmentItems indexOfObject:@(self.selectedSortType)];
    sortSetment.selectedSegmentIndex = selectedIndex;
    self.currentSortByType = self.selectedSortType;
    sortSetment.tintColor = [UIColor blackColor];
    [sortSetment addTarget:self action:@selector(handleSegmentControlAction:) forControlEvents:UIControlEventValueChanged];
    [sortByView addSubview:sortSetment];
    self.sortSetment = sortSetment;
    
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [sortByView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(titleView.mas_bottom);
                make.left.right.equalTo(self.view);
                make.height.equalTo(@80);
            }];
            
            [sortLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(sortByView.mas_safeAreaLayoutGuideTop);
                make.left.equalTo(sortByView.mas_safeAreaLayoutGuideLeft).offset(10);
                make.width.equalTo(@80);
                make.height.equalTo(@20);
            }];
            
            [sortSetment mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(sortLabel.mas_bottom).offset(5);
                make.left.equalTo(sortByView.mas_safeAreaLayoutGuideLeft).offset(10);
                make.right.equalTo(sortByView.mas_safeAreaLayoutGuideRight).offset(-10);
                make.height.equalTo(@35);
            }];
        }
    }
    else
    {
        [sortByView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleView.mas_bottom);
            make.left.right.equalTo(self.view);
            make.height.equalTo(@80);
        }];
        
        [sortLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(sortByView);
            make.left.equalTo(sortByView).offset(10);
            make.width.equalTo(@80);
            make.height.equalTo(@20);
        }];
        
        [sortSetment mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(sortLabel.mas_bottom).offset(5);
            make.left.equalTo(sortByView).offset(10);
            make.right.equalTo(sortByView).offset(-10);
            make.height.equalTo(@35);
        }];
    }

    // cancel button
    UIButton *cancelBtn = [[UIButton alloc]init];
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"Cancel White"] forState:UIControlStateNormal];
    cancelBtn.accessibilityValue = @"NXFILTERVC_CANCEL_BTN";
    [cancelBtn addTarget:self action:@selector(cancelPage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-20);
        make.centerX.equalTo(self.view);
        make.width.height.equalTo(@50);
        
    }];
    
    if (!self.isSupportRepo) {
        return;
    }
//    // repositories view
//    UITableView *repoTableView = [[UITableView alloc]init];
//    repoTableView.delegate = self;
//    repoTableView.dataSource = self;
//    repoTableView.allowsMultipleSelection = YES;
//    [self.view addSubview:repoTableView];
//    repoTableView.backgroundColor = [UIColor clearColor];
//    [repoTableView registerClass:[NXNormalCell class] forCellReuseIdentifier:@"NXNormalCell"];
//    repoTableView.cellLayoutMarginsFollowReadableWidth = NO;
//    UIView *footView = [[UIView alloc]init];
//    footView.backgroundColor = repoTableView.backgroundColor;
//    repoTableView.tableFooterView = footView;
//    self.repoTableView = repoTableView;
//
//    [repoTableView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(sortByView.mas_bottom);
//            make.right.left.equalTo(self.view);
//            make.bottom.equalTo(self.view.mas_bottom).offset(-120);
//        }];
}
//#pragma mark -----> applyClick
//- (void)applyClicked:(UIButton *)sender {
//    if (self.isSupportRepo) {
//        for (NXRepositoryModel *item in self.changeServiceArray) {
//            WeakObj(self);
//            [[NXLoginUser sharedInstance].myRepoSystem updateRepository:item completion:^(NXRepositoryModel *repo, NSError *error) {
//                if (self) {
//                    StrongObj(self);
//                    if (error) {
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            [NXMBManager showMessage:error.localizedDescription toView:self.view hideAnimated:YES afterDelay:kDelay];
//                            return ;
//                        });
//                        
//                    } else {
//                        if (![self.selServiceArray containsObject:item]) {
//                            [[self mutableArrayValueForKeyPath:@"selServiceArray"]addObject:item];
//                        }
//                        
//                    }
//                }
//            }];
//        }
//
//    }
//    if ([self.delegate respondsToSelector:@selector(filterViewController:changeVauleSortTpye:)]) {
//        [self.delegate filterViewController:self changeVauleSortTpye:self.currentSortByType];
//    }
//   [self dismissViewControllerAnimated:YES completion:nil];
//    
//}
- (void)handleSegmentControlAction:(UISegmentedControl *)sender {
    self.currentSortByType = [self.segmentItems[sender.selectedSegmentIndex] integerValue];
    if ([self.delegate respondsToSelector:@selector(filterViewController:changeVauleSortTpye:)]) {
        [self.delegate filterViewController:self changeVauleSortTpye:self.currentSortByType];
    }
}
- (void)cancelPage:(UIButton *) sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
                [self reloadNewData];
                
            });
        }];
        return;
    }
    
    boundService.service_selected = @(!boundService.service_selected.boolValue);
    if (![self.selServiceArray containsObject:boundService]) {
        [[self mutableArrayValueForKeyPath:@"selServiceArray"]addObject:boundService];
    }
    if (![self.changeServiceArray containsObject:boundService]) {
        [self.changeServiceArray addObject:boundService];
    }else {
        NSInteger itemindex = [self.changeServiceArray indexOfObject:boundService];
        NXRepositoryModel *item = self.changeServiceArray[itemindex];
        item.service_selected = @(!item.service_selected.boolValue)
        ;
    }

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
     [[self mutableArrayValueForKeyPath:@"selServiceArray"]removeObject:boundService];
    if (![self.changeServiceArray containsObject:boundService]) {
        [self.changeServiceArray addObject:boundService];
    }else {
     NSInteger itemindex = [self.changeServiceArray indexOfObject:boundService];
        NXRepositoryModel *item = self.changeServiceArray[itemindex];
        item.service_selected = @(!item.service_selected.boolValue)
        ;
    }
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *bgView= [[UIView alloc]init];
    bgView.backgroundColor = [UIColor whiteColor];
    UILabel *repositoriesLabel = [[UILabel alloc]init];
    repositoriesLabel.text = @"Repositories";
    repositoriesLabel.frame = CGRectMake(0, 0, tableView.frame.size.width, 20);
    repositoriesLabel.backgroundColor = [UIColor whiteColor];
    [bgView addSubview:repositoriesLabel];
    
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [repositoriesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(bgView.mas_safeAreaLayoutGuideLeft).offset(20);
                make.right.equalTo(bgView.mas_safeAreaLayoutGuideRight);
                make.top.equalTo(bgView.mas_safeAreaLayoutGuideTop);
                make.bottom.equalTo(bgView.mas_safeAreaLayoutGuideBottom);
            }];
        }
    }
    return bgView;
}

#pragma mark
- (void)reloadNewData {
    self.selServiceArray = nil;
    [self.selectIndexes removeAllObjects];
    
    [self.repoTableView reloadData];
    WeakObj(self);
    [self.dataArray enumerateObjectsUsingBlock:^(NXRepositoryModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        StrongObj(self);
        if (obj.service_selected.boolValue == YES && obj.service_isAuthed.boolValue == YES) {
            [self.selectIndexes addObject:@(idx)];
            [[self mutableArrayValueForKeyPath:@"selServiceArray"]addObject:obj];
        }
    }];
    
    [self.selectIndexes enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
        [self.repoTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:obj.integerValue inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    }];
}
- (void)closeThisPage:(id) sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isMemberOfClass:[UIView class]]||[touch.view isMemberOfClass:[UITableView class]]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
