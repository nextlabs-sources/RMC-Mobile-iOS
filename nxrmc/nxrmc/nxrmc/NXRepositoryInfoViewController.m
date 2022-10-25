//
//  NXRepoInfoViewController.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 5/4/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXRepositoryInfoViewController.h"
#import "UIView+UIExt.h"
#import "Masonry.h"
#import "NXRMCUIDef.h"
#import "NXRMCDef.h"
#import "NXDownloadView.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXMBManager.h"
#import "NXWebFileManager.h"
#import "NXCacheManager.h"

#define DELETE_CACHE_TAG 10000
#define DELETE_REPO_TAG 10001
@interface NXRepositoryInfoViewController ()<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong) NXRepositoryModel *repo;
@property(nonatomic, weak) UIView *repoFaceView;
@property(nonatomic, weak) UIButton *editRepoAliasBtn;
@property(nonatomic, weak) UIView *repoDetailView;
@property(nonatomic, weak) UIImageView *repoIconImageView;
@property(nonatomic, weak) UILabel *repoAliasLabel;
@property(nonatomic, weak) UILabel *userNameLabel;
@property(nonatomic, weak) UILabel *accountTypeLabel;
@property(nonatomic, weak) UILabel *repoTypeLabel;
@property(nonatomic, weak) UIButton *repoRemoveBtn;
@property(nonatomic, weak) UIScrollView *mainScrollView;
@property(nonatomic, weak) UIView *repoCacheView;

@property(nonatomic, weak) UIView *storageView;
@property(nonatomic, weak) UIView *usedStorageView;
@property(nonatomic, weak) UILabel *storageDisplayView;
@property(nonatomic, weak) UIActivityIndicatorView *waitView;
@property(nonatomic, strong) NSString *quotaStr;
@property(nonatomic, strong) NSString *totalQuotaStr;
@property(nonatomic, strong) NSString *userNameStr;
@property(nonatomic, strong) NSString *userAccountStr;
//@property(nonatomic, strong) NSString *getRepoInfoOptIdentify;
@property(nonatomic, strong) NSNumber *totalQuotaNum;
@property(nonatomic, strong) NSNumber *usedQuotaNum;
@property(nonatomic, assign) CGFloat quotaUsed;

@property(nonatomic, weak) UILabel *offlineSizeLab;
@property(nonatomic, weak) UILabel *localCachedSizeLab;
@property(nonatomic, weak) UILabel *totalCachedSizeLab;
@property(nonatomic, weak) UIButton *cleanCacheBtn;
@property(nonatomic, weak) UIView *offlineLocalCacheView;
@property(nonatomic, weak) UIView *totalCacheView;

@property(nonatomic, assign) BOOL viewWillDisappear;

@end

@implementation NXRepositoryInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(backToRepositories:)];
    self.navigationItem.leftBarButtonItems = @[backItem];
    [self commonInit];
    [self updateUIContent];
//    WeakObj(self);
//    self.getRepoInfoOptIdentify = [[NXLoginUser sharedInstance].myRepoSystem getRepositoryInfo:self.repo completion:^(NXRepositoryModel *repoModel, NSString *userName, NSString *userEmail, NSNumber *totalQuota, NSNumber *usedQuota, NSError *error) {
//        StrongObj(self);
//        if (self) {
//            if (!error) {
//                self.totalQuotaNum = totalQuota;
//                self.usedQuotaNum = usedQuota;
//                if (self.usedQuotaNum.floatValue > self.totalQuotaNum.floatValue) {
//                    self.usedQuotaNum = self.totalQuotaNum;
//                }
//                NSByteCountFormatter *formatter = [[NSByteCountFormatter alloc] init];
//                formatter.allowsNonnumericFormatting = NO;
//                formatter.countStyle = NSByteCountFormatterCountStyleBinary;
//                NSString *usedQuotaStr = [formatter stringFromByteCount:self.usedQuotaNum.longLongValue];
//                NSString *totalQuotaStr = [formatter stringFromByteCount:self.totalQuotaNum.longLongValue];
//                self.quotaStr = [NSString stringWithFormat:@"%@ used / %@ total", usedQuotaStr, totalQuotaStr];
//
//                self.userAccountStr = userEmail;
//                self.userNameStr = userName;
//
//                dispatch_main_async_safe(^{
//                    [self.waitView stopAnimating];
//                    [self updateUIContent];
//
//                });
//            }else{
//                dispatch_main_async_safe(^{
//                    [self.waitView stopAnimating];
//
//                    if (_viewWillDisappear == NO) {
//                        if (error.code == NXRMC_ERROR_SERVICE_ACCESS_UNAUTHORIZED) {
//                            NSString *errorMessage = NSLocalizedString(@"MSG_ACCESS_REPO_UNAUTHORIZED", nil);
//                            [NXMBManager showMessage:errorMessage hideAnimated:YES afterDelay:kDelay];
//                        }else{
//                            [NXMBManager showMessage:error.localizedDescription?:NSLocalizedString(@"UI_GET_REPO_INFO_ERROR", nil) hideAnimated:YES afterDelay:kDelay];
//                        }
//
//                    }
//                });
//            }
//        }
//
//    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}
- (void)backToRepositories:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    self.mainScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, CGRectGetHeight(self.repoDetailView.frame) + CGRectGetHeight(self.repoCacheView.frame) + CGRectGetHeight(self.repoRemoveBtn.frame) + 8*kMargin);
    
    [self.repoCacheView addShadow:UIViewShadowPositionTop|UIViewShadowPositionBottom|UIViewShadowPositionLeft|UIViewShadowPositionRight color:[UIColor lightGrayColor] width:0.5 Opacity:0.6];
    [self.offlineLocalCacheView addShadow:UIViewShadowPositionBottom color:[UIColor blackColor] width:0.1 Opacity:1.0];
//    if(OFFLINE_ON){
//        [self.offlineLocalCacheView addShadow:UIViewShadowPositionBottom color:[UIColor blackColor] width:0.1 Opacity:1.0];
//    }
//    
//    [self.totalCacheView addShadow:UIViewShadowPositionBottom color:[UIColor blackColor] width:0.1 Opacity:0.6];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated
{
    _viewWillDisappear = YES;
    [super viewWillDisappear:animated];
//    [[NXLoginUser sharedInstance].myRepoSystem cancelOperation:self.getRepoInfoOptIdentify];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self deviceOrientationDidChange:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (instancetype)initWithRepository:(NXRepositoryModel *)repo
{
    if (self = [super init]) {
        _repo = repo;
        if(repo.service_type.integerValue != kServiceOneDrive){
            _userAccountStr = repo.service_account;
        }
        
        if (repo.service_type.integerValue == kServiceSharepoint || repo.service_type.integerValue == kServiceSharepointOnline) {
            _userAccountStr = @"";
        }
    }
    return self;
}


- (void)commonInit
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UIScrollView *mainScrollView = [[UIScrollView alloc] init];
    mainScrollView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:mainScrollView];
    self.mainScrollView = mainScrollView;
    
    
    UIView *repoDetailView = [[UIView alloc] init];
    [self.mainScrollView addSubview:repoDetailView];
    repoDetailView.backgroundColor = [UIColor whiteColor];
    self.repoDetailView = repoDetailView;
    
    UIView *repoFaceView = [[UIView alloc] init];
    [self.repoDetailView addSubview:repoFaceView];
    [repoFaceView borderWidth:1.5f];
    [repoFaceView borderColor:[UIColor blackColor]];
    [repoFaceView cornerRadian:2.0f clipsToBounds:YES];
    self.repoFaceView = repoFaceView;
    
    UIImageView *repoIconImageView = [[UIImageView alloc] init];
    repoIconImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.repoFaceView addSubview:repoIconImageView];
    self.repoIconImageView = repoIconImageView;
    
    UIButton *editRepoAliasBtn = [[UIButton alloc] init];
    [self.repoDetailView addSubview:editRepoAliasBtn];
    [editRepoAliasBtn addTarget:self action:@selector(didClickChangeRepoAlias:) forControlEvents:UIControlEventTouchUpInside];
    self.editRepoAliasBtn = editRepoAliasBtn;
    [self.editRepoAliasBtn setTitle:NSLocalizedString(@"UI_EDIT_NAME", nil) forState:UIControlStateNormal];
    [self.editRepoAliasBtn setTitleColor:RMC_TINT_BLUE forState:UIControlStateNormal];
    self.editRepoAliasBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    
    if (self.repo.service_type.integerValue == kServiceSharepoint || [self.repo.service_providerClass isEqualToString:NSLocalizedString(@"UI_PROVIDERCLASS_APPLICATION", nil)]) {
        [self.editRepoAliasBtn setHidden:YES];
    }
    else
    {
        [self.editRepoAliasBtn setHidden:NO];
    }
    UILabel *repoAliasLabel = [[UILabel alloc] init];
    repoAliasLabel.textColor = [UIColor blackColor];
    repoAliasLabel.lineBreakMode = NSLineBreakByWordWrapping;
    repoAliasLabel.numberOfLines = 2;
    repoAliasLabel.textAlignment = NSTextAlignmentCenter;
    repoAliasLabel.font = [UIFont systemFontOfSize:15.0];
    [self.repoFaceView addSubview:repoAliasLabel];
    self.repoAliasLabel = repoAliasLabel;
    
    UILabel *userNameLabel = [[UILabel alloc] init];
    userNameLabel.numberOfLines = 3;
    userNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    userNameLabel.textColor = [UIColor blackColor];
    userNameLabel.text = NSLocalizedString(@"UI_USER_NAME", nil);
    userNameLabel.font = [UIFont systemFontOfSize:kMiniFontSize];
    [self.repoDetailView addSubview:userNameLabel];
    self.userNameLabel = userNameLabel;
    
    UILabel *userAccountLabel = [[UILabel alloc] init];
    userAccountLabel.textColor = [UIColor blackColor];
    userAccountLabel.lineBreakMode = NSLineBreakByWordWrapping;
    userAccountLabel.numberOfLines = 3;
    userAccountLabel.text = NSLocalizedString(@"UI_ACCOUNT_TYPE", nil);
    userAccountLabel.font = [UIFont systemFontOfSize:kMiniFontSize];
    [self.repoDetailView addSubview:userAccountLabel];
    self.accountTypeLabel = userAccountLabel;
   

    UILabel *repoTypeLabel = [[UILabel alloc] init];
    repoTypeLabel.textColor = [UIColor blackColor];
    repoTypeLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    repoTypeLabel.numberOfLines = 2;
    
//    NSString *title = NSLocalizedString(@"UI_REPO_TYPE", nil);
//    title = [title stringByAppendingString:@"\n"];
//    NSMutableAttributedString *titilAttributeStr = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kMiniFontSize]}];
//    NSAttributedString *typeAttributeStr = [[NSAttributedString alloc] initWithString:[NXCommonUtils convertRepoTypeToDisplayName:self.repo.service_type] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kNormalFontSize]}];
//    [titilAttributeStr appendAttributedString:typeAttributeStr];
//    repoTypeLabel.attributedText = titilAttributeStr;
//    [self.repoDetailView addSubview:repoTypeLabel];
//    self.repoTypeLabel = repoTypeLabel;

//    UILabel *storageDisplayView = [[UILabel alloc] init];
//    storageDisplayView.textColor = [UIColor blackColor];
//    storageDisplayView.numberOfLines = 2;
//    storageDisplayView.lineBreakMode = NSLineBreakByWordWrapping;
//    storageDisplayView.font = [UIFont systemFontOfSize:kMiniFontSize];
//    storageDisplayView.text = @"used / total";
//    [self.repoDetailView addSubview:storageDisplayView];
//    self.storageDisplayView = storageDisplayView;
//
    UIView *repoCacheView = [[UIView alloc] init];
    repoCacheView.backgroundColor = [UIColor whiteColor];
    
//    UIView *storageView = [[UIView alloc] init];
//    storageView.backgroundColor = [UIColor groupTableViewBackgroundColor];
//    storageView.clipsToBounds = YES;
//    [self.repoDetailView addSubview:storageView];
//    self.storageView = storageView;
//
//    UIView *progressView = [[UIView alloc] init];
//    progressView.backgroundColor = RMC_TINT_BLUE;
//    [self.storageView addSubview:progressView];
//    self.usedStorageView = progressView;
    
    
//    UIActivityIndicatorView *waitView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    waitView.backgroundColor = [UIColor clearColor];
//    waitView.hidesWhenStopped = YES;
//    [self.repoDetailView addSubview:waitView];
//    [waitView startAnimating];
//    self.waitView = waitView;
    
    [self.mainScrollView addSubview:repoCacheView];
    self.repoCacheView = repoCacheView;

    if (self.repo.service_type.integerValue != kServiceSkyDrmBox && ![self.repo.service_providerClass isEqualToString:NSLocalizedString(@"UI_PROVIDERCLASS_APPLICATION", nil)]) {
        UIButton *repoRemoveBtn = [[UIButton alloc] init];
        [repoRemoveBtn setTitle:NSLocalizedString(@"UI_DISCONNECT", nil) forState:UIControlStateNormal];
        [repoRemoveBtn borderColor:RMC_TINT_RED];
        [repoRemoveBtn borderWidth:1.5f];
        [repoRemoveBtn cornerRadian:2.0f];
        [repoRemoveBtn setTitleColor:RMC_TINT_RED forState:UIControlStateNormal];
        repoRemoveBtn.backgroundColor = [UIColor whiteColor];
        [self.mainScrollView addSubview:repoRemoveBtn];
        self.repoRemoveBtn = repoRemoveBtn;
        [self.repoRemoveBtn addTarget:self action:@selector(didClickRemoveRepo:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIView *offlineLocalCacheView = [[UIView alloc] init];
    self.offlineLocalCacheView = offlineLocalCacheView;
    [self.repoCacheView addSubview:offlineLocalCacheView];
    
    UILabel *localCacheSizeLab = [[UILabel alloc] init];
    localCacheSizeLab.numberOfLines = 2;
    self.localCachedSizeLab = localCacheSizeLab;
    [self.offlineLocalCacheView addSubview:localCacheSizeLab];
    
//    if (OFFLINE_ON) {
//        UILabel *OfflineSizeLab = [[UILabel alloc] init];
//        OfflineSizeLab.numberOfLines = 2;
//        self.offlineSizeLab = OfflineSizeLab;
//        [self.offlineLocalCacheView addSubview:OfflineSizeLab];
//
//        UILabel *localCacheSizeLab = [[UILabel alloc] init];
//        localCacheSizeLab.numberOfLines = 2;
//        self.localCachedSizeLab = localCacheSizeLab;
//        [self.offlineLocalCacheView addSubview:localCacheSizeLab];
//    }
    
    
//    UIView *totalCachedView = [[UIView alloc] init];
//    self.totalCacheView = totalCachedView;
//    [self.repoCacheView addSubview:totalCachedView];
//
//    UILabel *totalCachedLab = [[UILabel alloc] init];
//    totalCachedLab.numberOfLines = 2;
//    self.totalCachedSizeLab = totalCachedLab;
//    [self.totalCacheView addSubview:self.totalCachedSizeLab];
//
    UIButton *cleanCacheBtn = [[UIButton alloc] init];
    [cleanCacheBtn setTitle:NSLocalizedString(@"UI_CLEAN_CACHE", nil) forState:UIControlStateNormal];
    [cleanCacheBtn addTarget:self action:@selector(didClickCleanUpCache:) forControlEvents:UIControlEventTouchUpInside];
    [cleanCacheBtn setTitleColor:RMC_TINT_BLUE forState:UIControlStateNormal];
    self.cleanCacheBtn = cleanCacheBtn;
    [self.repoCacheView addSubview:cleanCacheBtn];

    [self.mainScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
        make.bottom.equalTo(self.mas_bottomLayoutGuide);
        make.width.equalTo(self.view);
        make.left.equalTo(self.view);
    }];
    
    [self.repoDetailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mainScrollView);
        make.top.equalTo(self.mainScrollView);
        make.width.equalTo(self.mainScrollView);
        make.height.equalTo(@155);
    }];
    
    [self.repoFaceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mainScrollView).offset(2*kMargin);
        make.left.equalTo(self.mainScrollView).offset(50);
        make.width.equalTo(@110);
        make.height.equalTo(@100);
    }];
    
    [self.repoIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.repoFaceView);
        make.top.equalTo(self.repoFaceView).offset(kMargin*2);
        make.width.height.equalTo(@40);
    }];
    
    [self.repoAliasLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.repoFaceView);
        make.top.equalTo(self.repoIconImageView.mas_bottom);
        make.bottom.equalTo(self.repoFaceView).offset(-kMargin);
        make.width.equalTo(self.repoFaceView);
    }];
    
    [self.editRepoAliasBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.repoFaceView.mas_bottom).offset(8);
        make.left.equalTo(self.repoFaceView);
        make.height.equalTo(@20);
        make.width.equalTo(self.repoFaceView);
    }];
    
    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.repoFaceView.mas_right).offset(3*kMargin);
        make.top.equalTo(self.repoFaceView);
        make.right.equalTo(self.view).offset(-kMargin);
    }];
    
    [self.accountTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.userNameLabel);
        make.right.equalTo(self.repoDetailView).offset(-2);
        make.top.equalTo(self.userNameLabel.mas_bottom).offset(kMargin);
    }];
    [self.repoCacheView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.repoDetailView.mas_bottom).offset(2*kMargin);
        make.left.equalTo(self.view).offset(2*kMargin);
        make.right.equalTo(self.view).offset(-2*kMargin);
        make.height.equalTo(@120);
    }];
    
//    if(OFFLINE_ON){
//        [self.repoCacheView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.repoDetailView.mas_bottom).offset(2*kMargin);
//            make.left.equalTo(self.view).offset(2*kMargin);
//            make.right.equalTo(self.view).offset(-2*kMargin);
//            make.height.equalTo(@240);
//        }];
//
//    }else{
//        [self.repoCacheView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.repoDetailView.mas_bottom).offset(2*kMargin);
//            make.left.equalTo(self.view).offset(2*kMargin);
//            make.right.equalTo(self.view).offset(-2*kMargin);
//            make.height.equalTo(@120);
//        }];
//
//    }
   
    [self.repoRemoveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.repoCacheView.mas_bottom).offset(5*kMargin);
        make.centerX.equalTo(self.mainScrollView);
        make.left.equalTo(self.view).offset(7*kMargin);
        make.right.equalTo(self.view).offset(-7*kMargin);
        make.height.equalTo(@60);
    }];
    
    [self.offlineLocalCacheView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.repoCacheView);
        make.centerX.equalTo(self.repoCacheView);
        make.width.equalTo(self.repoCacheView);
        make.height.equalTo(self.repoCacheView).multipliedBy(0.5);
    }];
    [self.localCachedSizeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.offlineLocalCacheView).offset(30);
        make.centerY.equalTo(self.offlineLocalCacheView);
    }];

//    if (OFFLINE_ON) {
//
//        [self.offlineSizeLab mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self.offlineLocalCacheView).offset(30);
//            make.centerY.equalTo(self.offlineLocalCacheView);
//        }];
//
//        [self.localCachedSizeLab mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self.offlineSizeLab.mas_right).offset(30);
//            make.centerY.equalTo(self.offlineSizeLab);
//        }];
//
//        [self.totalCacheView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.width.equalTo(self.repoCacheView);
//            make.height.equalTo(self.repoCacheView).multipliedBy(0.33);
//            make.top.equalTo(self.offlineLocalCacheView.mas_bottom).offset(2);
//            make.centerX.equalTo(self.repoCacheView);
//        }];
//    }else{
//
//        [self.totalCacheView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.width.equalTo(self.repoCacheView);
//            make.height.equalTo(self.repoCacheView).multipliedBy(0.5);
//            make.top.equalTo(self.offlineLocalCacheView).offset(2);
//            make.centerX.equalTo(self.offlineLocalCacheView);
//        }];
//
//
//    }
   
//    [self.totalCachedSizeLab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.totalCacheView).offset(30);
//        make.centerY.equalTo(self.totalCacheView);
//    }];
    [self.cleanCacheBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.repoCacheView);
        make.top.equalTo(self.offlineLocalCacheView.mas_bottom).offset(2);
        make.height.equalTo(self.repoCacheView).multipliedBy(0.5);
        make.width.equalTo(self.repoCacheView);
    }];
//    if(OFFLINE_ON){
//        [self.cleanCacheBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(self.repoCacheView);
//            make.top.equalTo(self.totalCacheView.mas_bottom).offset(2);
//            make.height.equalTo(self.repoCacheView).multipliedBy(0.33);
//            make.width.equalTo(self.repoCacheView);
//        }];
//    }else{
//        [self.cleanCacheBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(self.repoCacheView);
//            make.top.equalTo(self.totalCacheView.mas_bottom).offset(2);
//            make.height.equalTo(self.repoCacheView).multipliedBy(0.5);
//            make.width.equalTo(self.repoCacheView);
//        }];
//    }
  
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSString *CELL_IDENTIFY = @"CELL_IDENTIFY";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFY];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFY];
    }
    cell.textLabel.text = @"Click me";
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Action response
- (void)didClickRemoveRepo:(UIButton *)button
{
    NSString *info = NSLocalizedString(@"UI_DELETE_REPO_WARNING", NULL);
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:[NXCommonUtils currentBundleDisplayName] message:info delegate:self cancelButtonTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherButtonTitles:NSLocalizedString(@"UI_BOX_OK", NULL), nil];
    view.delegate = self;
    view.tag = DELETE_REPO_TAG;
    [view show];

}

-(void) deleteCacheFile
{
    NSURL *cacheURL = [NXCacheManager getLocalUrlForServiceCache:self.repo];
    [NXCommonUtils deleteFilesAtPath:cacheURL.path];
    [[NXWebFileManager sharedInstance] cleanCachedFileSizeForRepository:self.repo];
    [self updateCacheSizeContent];
    
}

-(void) deleteRepo
{
    [NXMBManager showLoadingToView:self.view];
    WeakObj(self);
    [[NXLoginUser sharedInstance].myRepoSystem deleteRepository:self.repo completion:^(NXRepositoryModel *repoModel, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            StrongObj(self);
            [NXMBManager hideHUDForView:self.view];
            if (!error) {
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }else{
                [NXCommonUtils showAlertViewInViewController:self title:[NXCommonUtils currentBundleDisplayName] message:NSLocalizedString(@"MSG_COM_DEL_REPO_ERROR", nil)];
            }
        });
    }];
}

- (void)didClickChangeRepoAlias:(UIButton *)button
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: [NXCommonUtils currentBundleDisplayName] message: @"" preferredStyle:UIAlertControllerStyleAlert];
    WeakObj(self);
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        StrongObj(self);
        textField.text = self.repo.service_alias;
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleNone;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) style:UIAlertActionStyleDefault  handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"UI_BOX_OK", NULL) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        StrongObj(self);
        NSArray * textfields = alertController.textFields;
        UITextField * displayNameTextField = textfields[0];
        NSString *displayName = displayNameTextField.text;
        displayName = [displayName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([self isEnableTextFieldNameWithStr:displayName]) {
            if (![self.repo.service_alias isEqualToString:displayName]) {
               
                [NXMBManager showLoadingToView:self.view];
               
                NXRepositoryModel *repoModel = [self.repo copy];
                repoModel.service_alias = displayName;
                [[NXLoginUser sharedInstance].myRepoSystem updateRepository:repoModel completion:^(NXRepositoryModel *repoModel, NSError *error) {
                    dispatch_main_async_safe(^{
                        [NXMBManager hideHUDForView:self.view];
                        if (error) {
                            [NXMBManager showMessage:error.localizedDescription?:NSLocalizedString(@"MSG_COM_UPDATE_REPO_INFO_ERROR", nil) toView:self.view hideAnimated:YES afterDelay:kDelay];
                        }else{
                            self.repo.service_alias = displayName;
                            self.repoAliasLabel.text = repoModel.service_alias;
                            [self updateUIContent];
                        }
                    });
                    
                }];
            }else{ // name do not changed
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
        
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (BOOL)isEnableTextFieldNameWithStr:(NSString *)str {
    if([str isEqualToString:@""])
    {
        [NXMBManager showMessage:NSLocalizedString(@"UI_COM_PLESASE_INPUT_NAME", NULL) hideAnimated:YES afterDelay:1.5];
        return NO;
    }else if(str.length>40)
    {
        [NXMBManager showMessage:NSLocalizedString(@"UI_COM_NAME_LENGTH_TOOLONG_WARNING_LIMIT_40", NULL) hideAnimated:YES afterDelay:1.5];
        return NO;
    }else if ([NXCommonUtils JudgeTheillegalCharacter:str withRegexExpression:@"^((?![\\~\\!\\@\\#\\$\\%\\^\\&\\*\\(\\)\\_\\+\\=\\[\\]\\{\\}\\;\\:\\\"\\\\\\/\\<\\>\\?]).)+$"]) {
        [NXMBManager showMessage:NSLocalizedString(@"UI_COM_NAME_CONTAIN_SPECIAL_WARNING", NULL) hideAnimated:YES afterDelay:1.5];
        return NO;
    }
    return YES;
}

- (void)didClickCleanUpCache:(UIButton *)button
{
    NSString *info = NSLocalizedString(@"UI_DELETE_CACEH_WARNING", NULL);
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:[NXCommonUtils currentBundleDisplayName] message:info delegate:self cancelButtonTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherButtonTitles:NSLocalizedString(@"UI_BOX_OK", NULL), nil];
    view.delegate = self;
    view.tag = DELETE_CACHE_TAG;
    [view show];
}

#pragma mark - Private
- (void)updateUIContent
{
    self.repoAliasLabel.text = self.repo.service_alias;
    self.repoIconImageView.image = [NXCommonUtils getRepoIconByRepoType:self.repo.service_type.integerValue];
//    if (self.quotaStr) {
//        self.storageDisplayView.text = self.quotaStr;
//    }
//    [self updateUserQuota];
    [self updateUserName];
    [self updateUserAccountType];
//    [self updateUserQuota];
    [self updateCacheSizeContent];
}

- (void)updateUserQuota
{
    if (self.usedQuotaNum && self.totalQuotaNum) {
        // update quota view
        [self.waitView stopAnimating];
        
        [self.storageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.storageDisplayView.mas_bottom).offset(4);
            make.left.equalTo(self.storageDisplayView);
            make.height.equalTo(@8);
            make.width.equalTo(self.storageDisplayView.mas_width).offset(kMargin);
        }];
    
        
        CGFloat ration = self.usedQuotaNum.floatValue / self.totalQuotaNum.floatValue;
        [self.usedStorageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.equalTo(self.storageView);
            make.width.equalTo(self.storageView).multipliedBy(ration);
        }];
    }
}

- (void)updateCacheSizeContent{
    NSNumber *offFileSize = [[NXWebFileManager sharedInstance] offlineFileSizeForRepository:self.repo];
    NSNumber *cacheFileSize = [[NXWebFileManager sharedInstance] cachedFileSizeForRepository:self.repo];
    long long totalCacheSize = offFileSize.longLongValue + cacheFileSize.longLongValue;
    
    NSByteCountFormatter *formatter = [[NSByteCountFormatter alloc] init];
    formatter.allowsNonnumericFormatting = NO;
    formatter.countStyle = NSByteCountFormatterCountStyleBinary;
    NSString *offlineSizeStr = [formatter stringFromByteCount:offFileSize.longLongValue];
    NSString *cacheFileSizeStr = [formatter stringFromByteCount:cacheFileSize.longLongValue];
    NSString *totalCacheSizeStr = [formatter stringFromByteCount:totalCacheSize];
    
    NSString *offlineSizeTitle = NSLocalizedString(@"UI_OFFLINE_SIZE", nil);
    offlineSizeTitle = [offlineSizeTitle stringByAppendingString:@"\n"];
    NSMutableAttributedString *offlineStr = [[NSMutableAttributedString alloc] initWithString:offlineSizeTitle attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kNormalFontSize]}];
    [offlineStr appendAttributedString:[[NSAttributedString alloc] initWithString:offlineSizeStr attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kMiniFontSize]}]];

    NSString *localCacheSizeTitle = NSLocalizedString(@"UI_CACHE_SIZE", nil);
    localCacheSizeTitle = [localCacheSizeTitle stringByAppendingString:@"\n"];
    NSMutableAttributedString *localStr = [[NSMutableAttributedString alloc] initWithString:localCacheSizeTitle attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kNormalFontSize]}];
    [localStr appendAttributedString:[[NSAttributedString alloc] initWithString:cacheFileSizeStr attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kMiniFontSize]}]];

    
    NSString *totalSizeTitle = NSLocalizedString(@"UI_TOTAL_SIZE", nil);
    totalSizeTitle = [totalSizeTitle stringByAppendingString:@"\n"];
    NSMutableAttributedString *totalStr = [[NSMutableAttributedString alloc] initWithString:totalSizeTitle attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kNormalFontSize]}];
    [totalStr appendAttributedString:[[NSAttributedString alloc] initWithString:totalCacheSizeStr attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kMiniFontSize]}]];
    
    self.localCachedSizeLab.attributedText = localStr;
//    if (OFFLINE_ON) {
//        self.offlineSizeLab.attributedText = offlineStr;
//        self.localCachedSizeLab.attributedText = localStr;
//    }
//
//    self.totalCachedSizeLab.attributedText = totalStr;
}

- (void)updateUserName
{
    self.userNameStr = self.repo.service_account;
    if (self.userNameStr && ![self.userNameStr isKindOfClass:[NSNull class]]) {
        NSString *title = NSLocalizedString(@"UI_USER_NAME", nil);
        title = [title stringByAppendingString:@"\n"];
        NSMutableAttributedString *titilAttributeStr = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kMiniFontSize]}];
        NSAttributedString *nameAttributeStr = [[NSAttributedString alloc] initWithString:self.userNameStr attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kNormalFontSize]}];
        [titilAttributeStr appendAttributedString:nameAttributeStr];
        self.userNameLabel.attributedText = titilAttributeStr;
    }
    if ([self.repo.service_providerClass isEqualToString:NSLocalizedString(@"UI_PROVIDERCLASS_APPLICATION", nil)]) {
        self.userNameLabel.hidden = YES;
        [self.accountTypeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.userNameLabel);
        }];
    }else{
        self.userNameLabel.hidden = NO;
    }
}

- (void)updateUserAccountType
{
    NSString *accountType;
    if (self.repo.service_providerClass) {
        accountType = [self.repo.service_providerClass capitalizedString];
       
    }else {
        accountType = @"Personal";
    }
    NSString *title = NSLocalizedString(@"UI_ACCOUNT_TYPE", nil);
    title = [title stringByAppendingString:@"\n"];
    NSMutableAttributedString *titilAttributeStr = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kMiniFontSize]}];
    NSAttributedString *accountAttributeStr = [[NSAttributedString alloc] initWithString:accountType attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kNormalFontSize]}];
    [titilAttributeStr appendAttributedString:accountAttributeStr];
    self.accountTypeLabel.attributedText = titilAttributeStr;
}

#pragma mark - UIAlertViewDelegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (alertView.tag == DELETE_CACHE_TAG) {
            [self deleteCacheFile];
        }
        
        if (alertView.tag == DELETE_REPO_TAG) {
            [self deleteRepo];
        }
    }
}

@end
