//
//  NXRepoSpaceUploadVC.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/3/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXRepoSpaceUploadVC.h"
#import "NXProtectViewController.h"
#import "NXShareViewController.h"
#import "NXFileChooseFlowViewController.h"

#import "NXPreviewFileView.h"
#import "NXMBManager.h"
#import "NXShareView.h"
#import "Masonry.h"
#import "NXCustomTitleView.h"
#import "NXLocalShareVC.h"
#import "NXProtectFileAfterSelectedLocationVC.h"
#import "NXCommonUtils.h"
#import "NXLoginUser.h"

@interface NXRepoSpaceUploadVC ()<NXFileChooseFlowViewControllerDelegate, NXOperationVCDelegate>

@property(nonatomic, weak, readonly) NXPreviewFileView *previewFileView;
@property(nonatomic, weak, readonly) NXShareView *protectView;
@property(nonatomic, weak, readonly) NXShareView *shareView;
@property(nonatomic, weak, readonly) UIButton *uploadButton;

@property(nonatomic, strong) NSString *myRepoSysUploadOptIdentify;

@end

@implementation NXRepoSpaceUploadVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self commonInit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[NXLoginUser sharedInstance].myRepoSystem fileListForParentFolder:self.folder readCache:NO delegate:nil];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat height = CGRectGetHeight(self.previewFileView.bounds) + CGRectGetHeight(self.protectView.bounds) + CGRectGetHeight(self.shareView.bounds) + CGRectGetHeight(self.uploadButton.bounds);
    CGFloat contentHeight = height + kMargin + 0.5 + kMargin;
    if (self.mainView.bounds.size.height > contentHeight) {
        self.mainView.contentSize = CGSizeMake(CGRectGetWidth(self.mainView.bounds), CGRectGetHeight(self.mainView.bounds) + 1);
    } else {
        self.mainView.contentSize = CGSizeMake(CGRectGetWidth(self.mainView.bounds), contentHeight);
    }
}

#pragma mark
- (void)cancel:(id)sender {
    [[NXLoginUser sharedInstance].myRepoSystem cancelOperation:_myRepoSysUploadOptIdentify];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)upload:(id)sender {
    self.uploadButton.enabled = NO;
    if (!self.folder) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_SELECT_FOLDER", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
        self.uploadButton.enabled = YES;
        return;
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.fileItem.localPath]) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_FILE_NOT_EXISTED", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
        self.uploadButton.enabled = YES;
        return;
    }
    
    NSURL *fileURL = [NSURL fileURLWithPath:self.fileItem.localPath];
    NSString *fileName = fileURL.lastPathComponent;

    NSArray *children = [[NXLoginUser sharedInstance].myRepoSystem childForFileItem:self.folder];
    for (NXFileBase *item in children) {
        if ([fileName caseInsensitiveCompare:item.name] == NSOrderedSame) {
            [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_NAME_ALREADY_EXISTED", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
            self.uploadButton.enabled = YES;
            return;
        }
    }

    
    [NXMBManager showLoading:NSLocalizedString(@"MSG_UPLOADING", NULL) toView:self.view];
    WeakObj(self);
    _myRepoSysUploadOptIdentify = [[NXLoginUser sharedInstance].myRepoSystem uploadFile:fileName toPath:self.folder fromPath:fileURL.path uploadType:NXRepositorySysManagerUploadTypeNormal overWriteFile:nil progress:nil completion:^(NXFileBase *fileItem, NXFileBase *parentFolder, NSError *error){
        StrongObj(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            [NXMBManager hideHUDForView:self.view];
            if (error) {
                [NXMBManager showMessage:error.localizedDescription toView:self.view hideAnimated:YES afterDelay:kDelay];
                self.uploadButton.enabled = YES;
            } else {
                [NXMBManager showMessage:NSLocalizedString(@"MSG_UPLOAD_SUCCESS", NULL)toView:self.view hideAnimated:YES afterDelay:kDelay];
                [self performSelector:@selector(cancel:) withObject:nil afterDelay:kDelay];
            }
        });
    }];
}

- (void)protect:(UIGestureRecognizer *)sender {
    if (!self.folder) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_SELECT_FOLDER", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
        return;
    }
    NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
    VC.filesArray = @[self.fileItem];
    VC.locationType = NXProtectSaveLoactionTypeMyVault;
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)share:(UIGestureRecognizer *)sender {
    NXLocalShareVC *vc = [[NXLocalShareVC alloc] init];
    vc.currentType = NXShareSelectRightsTypeDigital;
    vc.fileItem = self.fileItem;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)setFolder:(NXFileBase *)folder {
    _folder = folder;
    self.previewFileView.savedPath = [NSString stringWithFormat:@"%@%@", folder.serviceAlias?:@"", folder.fullPath?:@""];
}

#pragma mark - private method
- (void)chooseRepo:(NXRepositoryModel *)repoModel {
    NXFileChooseFlowViewController *vc = [[NXFileChooseFlowViewController alloc]initWithRepository:repoModel type:NXFileChooseFlowViewControllerTypeChooseDestFolder isSupportMultipleSelect:NO];
    vc.fileChooseVCDelegate = self;
    vc.repoModel = repoModel;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}

#pragma mark  - NXOperationVCDelegate
- (void)viewcontroller:(NXFileOperationPageBaseVC *)vc didfinishedOperationFile:(NXFileBase *)file toFile:(NXFileBase *)resultFile {
    [self cancel:nil];
}

- (void)viewcontroller:(NXFileOperationPageBaseVC *)vc didCancelOperationFile:(NXFileBase *)file {
    //
}

#pragma mark - NXFileChooseFlowViewControllerDelegate
- (void)fileChooseFlowViewController:(NXFileChooseFlowViewController *)vc didChooseFile:(NSArray *)choosedFiles {
    if (choosedFiles.count) {
        self.folder = choosedFiles.lastObject;
        self.previewFileView.savedPath = [NSString stringWithFormat:@"%@%@", _folder.serviceAlias?:@"", self.folder.fullPath?:@""];
        [[NXLoginUser sharedInstance].myRepoSystem fileListForParentFolder:self.folder readCache:NO delegate:nil];
    }
}

- (void)fileChooseFlowViewControllerDidCancelled:(NXFileChooseFlowViewController *)vc {
    
}

#pragma mark
- (void)commonInit {
    self.mainView.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    NXCustomTitleView *titleView = [[NXCustomTitleView alloc] init];
    titleView.text = self.fileItem.localPath.lastPathComponent;
    self.navigationItem.titleView = titleView;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    rightItem.accessibilityValue = @"UPLOAD_CANCEL";
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self.topView removeFromSuperview];
    [self.bottomView removeFromSuperview];
    [self.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.bottom.equalTo(self.mas_bottomLayoutGuideBottom);
    }];
    
    NXPreviewFileView *previewFileView = [[NXPreviewFileView alloc] init];
    [self.mainView addSubview:previewFileView];
    _previewFileView = previewFileView;
    _previewFileView.fileItem = self.fileItem;
    _previewFileView.savedPath = [NSString stringWithFormat:@"%@%@", self.folder.serviceAlias?:@"", self.folder.fullPath?:@""];
    WeakObj(self);
    _previewFileView.changePathClick = ^(id sender) {
        StrongObj(self);
        NXRepositoryModel *myDriveRepoModel = [[NXLoginUser sharedInstance].myRepoSystem getNextLabsRepository];
        NXFileChooseFlowViewController *chooseVC = [[NXFileChooseFlowViewController alloc] initWithRepository:myDriveRepoModel type:NXFileChooseFlowViewControllerTypeChooseDestFolder isSupportMultipleSelect:NO];
        chooseVC.fileChooseVCDelegate = self;
        chooseVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:chooseVC animated:YES completion:nil];
    };
    
    NXShareView *protectView = [[NXShareView alloc] init];
    protectView.backgroundColor = [UIColor whiteColor];
    protectView.titleLabel.text = NSLocalizedString(@"UI_CREATE_A_PROTECTED_FILE", NULL);
    protectView.titleLabel.accessibilityValue = @"UPLOADFILE_PAGE_PROTECT_FILE";
    protectView.imageView.image = [UIImage imageNamed:@"protect - black"];
    protectView.enable = YES;
    protectView.buttonClickBlock = ^(id sender) {
        StrongObj(self);
        [self protect:nil];
    };
    
    [self.mainView addSubview:protectView];
    _protectView = protectView;
    
    NXShareView *shareView = [[NXShareView alloc] init];
    shareView.titleLabel.text = NSLocalizedString(@"UI_SHARE_A_PROTEDTED_FILE", NULL);
    shareView.titleLabel.accessibilityValue = @"UPLOADFILE_PAGE_SHARE_FILE";
    shareView.imageView.image = [UIImage imageNamed:@"share - black"];
    shareView.buttonClickBlock = ^(id sender) {
        StrongObj(self);
        [self share:nil];
    };
    shareView.enable = YES;
    shareView.backgroundColor = [UIColor whiteColor];
    [self.mainView addSubview:shareView];
    _shareView = shareView;
    
    UIButton *uploadButton = [[UIButton alloc] init];
    [uploadButton addTarget:self action:@selector(upload:) forControlEvents:UIControlEventTouchUpInside];
    uploadButton.backgroundColor = [UIColor clearColor];
    [uploadButton setTitle:NSLocalizedString(@"UI_JUST_UPLOAD", NULL) forState:UIControlStateNormal];
    [uploadButton setTitleColor:[UIColor colorWithHexString:@"#a9eafe"] forState:UIControlStateNormal];
    uploadButton.accessibilityValue = @"JUST_UPLOAD";
    _uploadButton = uploadButton;
    
    [self.mainView addSubview:uploadButton];
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [previewFileView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.mainView);
                make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).offset(kMargin);
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).offset(-kMargin);
                make.height.equalTo(self.view.mas_safeAreaLayoutGuideHeight).multipliedBy(0.6);
            }];
        }
    }
    else
    {
        [previewFileView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mainView);
            make.left.equalTo(self.view).offset(kMargin);
            make.right.equalTo(self.view).offset(-kMargin);
            make.height.equalTo(self.view).multipliedBy(0.6);
        }];
    }
    
    [protectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(previewFileView.mas_bottom).offset(kMargin);
        make.left.and.right.equalTo(previewFileView);
        make.height.equalTo(@(44));
    }];
    
    [shareView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(protectView.mas_bottom).offset(0.5);
        make.left.and.right.equalTo(previewFileView);
        make.height.equalTo(@44);
    }];
    
    [uploadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(shareView.mas_bottom).offset(kMargin);
        make.left.and.right.equalTo(previewFileView);
        make.height.equalTo(@80);
    }];
    
#if 0
    self.mainView.backgroundColor = [UIColor redColor];
    previewFileView.backgroundColor = [UIColor greenColor];
#endif
}

@end
