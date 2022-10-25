//
//  NXFilePropertyVC.m
//  nxrmcUITest
//
//  Created by nextlabs on 11/9/16.
//  Copyright © 2016 zhuimengfuyun. All rights reserved.
//

#import "NXFilePropertyVC.h"

#import "NXShareViewController.h"
#import "NXProtectViewController.h"

#import "Masonry.h"

#import "NXMBManager.h"
#import "UIView+UIExt.h"
#import "NXFileInfoView.h"
#import "NXRightsDisplayView.h"
#import "NXMarkFavOrOffView.h"
#import "NXButtonContainerView.h"
#import "NXShareView.h"

#import "NXRMCUIDef.h"

#import "NXCommonUtils.h"

#import "AppDelegate.h"
#import "NXFileBase.h"
#import "NXLRights.h"
#import "NXLoginUser.h"
#import "NXWebFileManager.h"
#import "NXDocumentClassificationView.h"
#import "NXClassificationLab.h"
#import "NXClassificationCategory.h"
#import "NXNXLOperationManager.h"
#import "NXAddToProjectVC.h"
#define kAnimationTime 0.5 //second

@interface NXFilePropertyVC ()<NXOperationVCDelegate>

@property(nonatomic, weak) NXRightsDisplayView *rightsView;
@property(nonatomic, weak) NXFileInfoView *infoView;
@property(nonatomic, strong) NXMBProgressView *progressView;
@property(nonatomic, strong) MASConstraint *rightsViewHeight;
@property(nonatomic, strong) NSString *downloadOptID;
@property(nonatomic, strong) NXDocumentClassificationView *documentTagView;

@property(nonatomic, assign) BOOL addToProjectFunctionON;
@end

@implementation NXFilePropertyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
    [self initData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLayoutSubviews {
    CGFloat height = CGRectGetHeight(self.infoView.bounds)+CGRectGetHeight(_documentTagView.bounds);
    CGFloat contentHeight = height + kMargin + kMargin + (_documentTagView?kMargin*2:0);
    if (self.mainView.bounds.size.height > contentHeight) {
        self.mainView.contentSize = CGSizeMake(CGRectGetWidth(self.mainView.bounds), CGRectGetHeight(self.mainView.bounds)+1);
    } else {
        self.mainView.contentSize = CGSizeMake(CGRectGetWidth(self.mainView.bounds), contentHeight);
    }
}

- (void)dealloc {
    DLog();
}

#pragma mark -

- (void)initData {
    BOOL isNxl = [[NXLoginUser sharedInstance].nxlOptManager isNXLFile:self.fileItem];
    if (isNxl) {
        [NXMBManager showLoadingToView:self.mainView];
        [[NXLoginUser sharedInstance].nxlOptManager getNXLFileRights:self.fileItem withWatermark:NO withCompletion:^(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray *watermark, NSString *owner, BOOL isOwner, NSError *error) {
            dispatch_main_async_safe((^{
                [NXMBManager hideHUDForView:self.mainView];
                self.isSteward = isOwner;
                [self updateUI:self.fileItem isNxlFile:YES rights:rights classifications:classifications message:error.localizedDescription];
            }));
        }];
        
    }
}

- (void)didFinishDownloadFile:(NXFileBase *)file error:(NSError *)error {
    self.fileItem.localPath = file.localPath;
    [self.progressView hide];
    [NXMBManager hideHUDForView:self.mainView];
    if (error) {
        [NXMBManager showMessage:error.localizedDescription toView:self.view hideAnimated:YES afterDelay:kDelay];
    } else {
        [self updateData:self.fileItem];
    }
}

- (void)updateData:(NXFileBase *)fileItem {
    if ([[NXLoginUser sharedInstance].nxlOptManager isNXLFile:fileItem]) {
        [NXMBManager showLoading:NSLocalizedString(@"MSG_COM_GETTING_RIGHTS", NULL)toView:self.mainView];

        WeakObj(self);
        [[NXLoginUser sharedInstance].nxlOptManager getNXLFileRights:fileItem withWatermark:NO withCompletion:^(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray *watermark, NSString *owner, BOOL isOwner, NSError *error) {
            dispatch_main_async_safe(^{
                StrongObj(self);
                [NXMBManager hideHUDForView:self.mainView];
                if (error) {
                    [self updateUI:self.fileItem nxlFile:YES rights:rights classifications:classifications message:NSLocalizedString(@"MSG_COM_GET_RIGHTS_FAILED", NULL)];
                } else {
                    self.isSteward = isOwner;
                    [self updateUI:self.fileItem nxlFile:YES rights:rights classifications:classifications message:nil];
                }
            });
        }];
    } else {
        [self updateUI:self.fileItem nxlFile:NO rights:nil classifications:nil message:nil];
    }
}
- (void)updateUI:(NXFileBase *)fileItem isNxlFile:(BOOL)nxl rights:(NXLRights *)rights classifications:(NSArray *)classifications message:(NSString *)noRightsMessage {
    self.infoView.model = fileItem;
    if (nxl) {
            NXRightsDisplayView *rightsView = [[NXRightsDisplayView alloc] init];
            rightsView.showLocalWatermarkStr = YES;
            [self.mainView addSubview:rightsView];
            self.rightsView = rightsView;
            self.rightsView.noRightsMessage = noRightsMessage;
        if (classifications){
            self.rightsView.noRightsMessage = NSLocalizedString(@"MSG_NO_PERMISSIONS_DETERMINED",NULL);
            self.documentTagView.documentClassicationsArray = classifications;
            [self.documentTagView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.infoView.mas_bottom).offset(10);
                make.left.equalTo(self.view).offset(kMargin);
                make.right.equalTo(self.view).offset(-kMargin);
            }];
            [rightsView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.documentTagView.mas_bottom).offset(kMargin);
                make.left.equalTo(self.view).offset(kMargin);
                make.right.equalTo(self.view).offset(-kMargin);
            }];
        }else {
            rightsView.isOwner = self.isSteward;
            [rightsView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.infoView.mas_bottom).offset(kMargin);
                make.left.equalTo(self.view).offset(kMargin);
                make.right.equalTo(self.view).offset(-kMargin);
            }];
        }
        
            self.rightsView.rights = rights;
            [self.rightsView showSteward:self.isSteward];
            [self.rightsView setNeedsLayout];
    }
}
- (void)updateUI:(NXFileBase *)fileItem nxlFile:(BOOL)nxl rights:(NXLRights *)rights classifications:(NSArray *)classifications message:(NSString *)norightsMessage {
    
    self.infoView.model = fileItem;
    
    if (nxl) {
        NXRightsDisplayView *rightsView = [[NXRightsDisplayView alloc] init];
        rightsView.showLocalWatermarkStr = YES;
        [self.mainView addSubview:rightsView];
        self.rightsView = rightsView;
        [rightsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.infoView.mas_bottom).offset(kMargin);
            make.left.equalTo(self.view).offset(kMargin);
            make.right.equalTo(self.view).offset(-kMargin);
        }];
        self.rightsView.noRightsMessage = norightsMessage;
        self.rightsView.rights = rights;
         rightsView.isOwner = self.isSteward;
        [self.rightsView showSteward:self.isSteward];
        
        [self.rightsView setNeedsLayout];
    }
}

- (void)updateSubViews {
    [self.rightsViewHeight uninstall];
    [self.view layoutIfNeeded];
    [self viewDidLayoutSubviews];
}

#pragma mark
- (void)closeButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [[NXWebFileManager sharedInstance] cancelDownload:self.downloadOptID];
    
    if (DELEGATE_HAS_METHOD(self.delegate, @selector(viewcontroller:didCancelOperationFile:))) {
        [self.delegate viewcontroller:self didCancelOperationFile:self.fileItem];
    }
    
    if (DELEGATE_HAS_METHOD(self.delegate, @selector(viewcontrollerWillDisappear:))) {
        [self.delegate viewcontrollerWillDisappear:self];
    }
}

#pragma mark - NXOperationVCDelegate
- (void)viewcontroller:(NXFileOperationPageBaseVC *)vc didfinishedOperationFile:(NXFileBase *)file toFile:(NXFileBase *)resultFile {
    if (self.shouldOpen && [vc isKindOfClass:[NXProtectViewController class]]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    if (self.shouldOpen && [vc isKindOfClass:[NXShareViewController class]]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)viewcontroller:(NXFileOperationPageBaseVC *)vc didCancelOperationFile:(NXFileBase *)file {
    if (self.shouldOpen && [vc isKindOfClass:[NXShareViewController class]]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -
- (void)commonInit {
    WeakObj(self);
    self.topView.model = self.fileItem;
    _addToProjectFunctionON = NO;
    
    NSString *filePath = nil;
    if (self.fileItem.fullPath) {
        filePath = [[NSURL fileURLWithPath:self.fileItem.fullPath] URLByDeletingLastPathComponent].path;
        if (![filePath hasSuffix:@"/"]) {
            filePath = [filePath stringByAppendingString:@"/"];
        }
    }
    if ([filePath isEqualToString:@"/"] && self.fileItem.sorceType == NXFileBaseSorceTypeProject) {
        filePath = nil;
    }
    NSString *service = nil;
    switch (self.fileItem.sorceType) {
        case NXFileBaseSorceTypeProject:
            if ([self.fileItem isKindOfClass:[NXOfflineFile class]]) {
                NXOfflineFile *offlineFile = (NXOfflineFile *)self.fileItem;
                NXProjectFile * projectFile = [[NXOfflineFileManager sharedInstance] getProjectFilePartner:offlineFile];
                service = [[NXLoginUser sharedInstance].myProject getProjectModelForFile:((NXProjectFile*)(projectFile))].displayName;
            }else{
                service = [[NXLoginUser sharedInstance].myProject getProjectModelForFile:((NXProjectFile*)(self.fileItem))].displayName;
            }
       
            break;
        case NXFileBaseSorceTypeRepoFile:
            service = self.fileItem.serviceAlias;
            break;
        case NXFileBaseSorceTypeLocal:
        case NXFileBaseSorceType3rdOpenIn:
            service = NSLocalizedString(@"UI_LOCAL", NULL);
            break;
        case NXFileBaseSorceTypeMyVaultFile:
        {
            if ([self.fileItem isKindOfClass:[NXOfflineFile class]]) {
                NXOfflineFile *offlineFile = (NXOfflineFile *)self.fileItem;
                NXMyVaultFile * myVaultFile = [[NXOfflineFileManager sharedInstance] getMyVaultFilePartner:offlineFile];
                
                if (!myVaultFile.metaData) {
                    service = myVaultFile.metaData.sourceRepoName;
                    filePath = myVaultFile.metaData.sourceFilePathDisplay;
                }else{
                    filePath = NSLocalizedString(@"UI_MY_SPACE", NULL);
                }
                if (![filePath hasPrefix:@"/"]) {
                    filePath = [NSString stringWithFormat:@"/%@", filePath];
                }
                
            }else{
                NXMyVaultFile *myVaultFile = (NXMyVaultFile *)self.fileItem;
                
                if (!myVaultFile.metaData) {
                    service = myVaultFile.metaData.sourceRepoName;
                    filePath = myVaultFile.metaData.sourceFilePathDisplay;
                }else{
                    filePath = NSLocalizedString(@"UI_MY_SPACE", NULL);
                }
                if (![filePath hasPrefix:@"/"]) {
                    filePath = [NSString stringWithFormat:@"/%@", filePath];
                }
            }
        }
            break;
        default:
            break;
    }
    if ([service isEqualToString:@"local"]) {
        filePath = @"";  // just remove the local last '/', because no local path in iphone
    }
    self.topView.operationTitle = [NSString stringWithFormat:@"%@%@", service?:@"",filePath?:@""];
    self.topView.backClickAction = ^(id sender) {
        StrongObj(self);
        [self closeButtonClicked:nil];
    };

    [self.bottomView removeFromSuperview];
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottomLayoutGuideBottom);
    }];
    
    [self.infoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mainView).offset(kMargin);
        make.left.equalTo(self.view).offset(kMargin);
        make.right.equalTo(self.view).offset(-kMargin);
    }];
    
//    [self.buttonView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.infoView.mas_bottom).offset(kMargin);
//        make.left.equalTo(self.view).offset(kMargin);
//        make.right.equalTo(self.view).offset(-kMargin);
//        self.rightsViewHeight = make.height.equalTo(@130);
//    }];
    
//    BOOL isMyDrive = self.fileItem.serviceType.integerValue == kServiceSkyDrmBox;
//    if (isMyDrive || self.fileItem.sorceType == NXFileBaseSorceTypeMyVaultFile) {
////        if (OFFLINE_ON || FAVORITE_ON) {
////            NXMarkFavOrOffView *favOffView = [[NXMarkFavOrOffView alloc] initWithFrame:CGRectZero];
////            [self.mainView addSubview:favOffView];
////            self.favOrOffView = favOffView;
////            [favOffView mas_makeConstraints:^(MASConstraintMaker *make) {
////                make.top.equalTo(self.buttonView.mas_bottom).offset(kMargin);
////                make.left.equalTo(self.view).offset(kMargin);
////                make.right.equalTo(self.view).offset(-kMargin);
////                make.height.equalTo(@((OFFLINE_ON||FAVORITE_ON)?90:0));
////            }];
////            self.favOrOffView = favOffView;
////            self.favOrOffView.isFromFavoritePage = self.isFromFavPage;
////            self.favOrOffView.model = self.fileItem;
////
////            if (self.fileItem.sorceType == NXFileBaseSorceTypeMyVaultFile) {
////                [self.favOrOffView setHidden:YES];
////            }
////        }
//    }
    
//    [self.shareView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.view).offset(kMargin);
//        make.right.equalTo(self.view).offset(-kMargin);
//        make.height.equalTo(@44);
//        if (self.favOrOffView) {
//            make.top.equalTo(self.favOrOffView.mas_bottom).offset(kMargin);
//        } else {
//            make.top.equalTo(self.buttonView.mas_bottom).offset(kMargin);
//        }
//    }];
    
#if 0
    self.infoView.backgroundColor = [UIColor orangeColor];
#endif
    
}

- (NXFileInfoView *)infoView {
    if (!_infoView) {
        NXFileInfoView *infoView = [[NXFileInfoView alloc] init];
        [self.mainView addSubview:infoView];
        _infoView = infoView;
        _infoView.model = self.fileItem;
    }
    return _infoView;
}

//- (NXButtonContainerView *)buttonView {
//    if (!_buttonView) {
//        NXButtonContainerView *buttonView = [[NXButtonContainerView alloc] initWithFrame:CGRectZero];
//        [self.mainView addSubview:buttonView];
//        WeakObj(self);
//        buttonView.buttonClickBlock = ^(id sender) {
//            StrongObj(self);
//            NXProtectViewController *vc = [[NXProtectViewController alloc] init];
//            vc.fileItem = self.fileItem;
//            vc.delegate = self;
//            [self.navigationController pushViewController:vc animated:YES];
//        };
//        _buttonView = buttonView;
//    }
//    return _buttonView;
//}

//- (NXShareView *)shareView {
//    if (!_shareView) {
//        NXShareView *shareView = [[NXShareView alloc] init];
//        [self.mainView addSubview:shareView];
//        WeakObj(self);
//        shareView.buttonClickBlock = ^(id sender) {
//            StrongObj(self);
//            if (_addToProjectFunctionON == YES) {
//                if ([self.fileItem isKindOfClass:[NXProjectFile class]]) {
//                    NXProjectFile *projectFile = (NXProjectFile *)self.fileItem;
//                    NXProjectModel *projectModel = [[NXLoginUser sharedInstance].myProject getProjectModelForProjectId:projectFile.projectId];
//                    if (projectModel) {
//                        NXAddToProjectVC *VC = [[NXAddToProjectVC alloc]init];
//                        VC.currentFile = self.fileItem;
//                        VC.fromProjectModel = projectModel;
//
//                        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:VC];
//                        [self presentViewController:nav animated:YES completion:nil];
//                    }
//                }else{
//                    NXAddToProjectVC *VC = [[NXAddToProjectVC alloc]init];
//                    VC.currentFile = self.fileItem;
//                    VC.fromProjectModel = nil;
//
//                    if ([self.fileItem isKindOfClass:[NXOfflineFile class]] && self.fileItem.sorceType == NXFileBaseSorceTypeProject) {
//                        VC.currentFile = [[NXOfflineFileManager sharedInstance] getProjectFilePartner:(NXOfflineFile *)self.fileItem];
//                    }
//
//                    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:VC];
//                    [self presentViewController:nav animated:YES completion:nil];
//                }
//            }else{
//                NXShareViewController *vc = [[NXShareViewController alloc] init];
//                vc.fileItem = self.fileItem;
//                vc.delegate = self;
//                [self.navigationController pushViewController:vc animated:YES];
//            }
//        };
//
//        shareView.hidden = YES;
//        shareView.enable = NO;
//
//        _shareView = shareView;
//        [_shareView setEnable:YES];
//    }
//    return _shareView;
//}
- (NXDocumentClassificationView *)documentTagView {
    if (!_documentTagView) {
         _documentTagView = [[NXDocumentClassificationView alloc]init];
        [self.mainView addSubview: _documentTagView];
    }
    return _documentTagView;
}


@end
