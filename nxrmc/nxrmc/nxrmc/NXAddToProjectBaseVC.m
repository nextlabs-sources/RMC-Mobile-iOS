//
//  NXAddToProejctBaseVC.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/4/2.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXAddToProjectBaseVC.h"
#import "NXMBManager.h"
#import "NXLoginUser.h"
#import "NXLProfile.h"
#import "NXWebFileManager.h"
#import "NXCommonUtils.h"
#import "NXRMCDef.h"
#import "UIImage+ColorToImage.h"
#import "UIView+UIExt.h"
#import "Masonry.h"
#import "NXPreviewFileView.h"
#import "NXFileChooseFlowViewController.h"
#import "NXCardStyleView.h"
#import "NXLeftImageButton.h"
#import "NXRightsSelectView.h"
#import "NXClassificationSelectView.h"
#import "NSString+NXExt.h"
#import "NXFileBase.h"
#import "NXProtectedFileListView.h"
#import "NXAddFileSavePathView.h"
#define PREVIEWFOLDHEIGHT 98

@interface NXAddToProjectBaseVC ()<NXFileChooseFlowViewControllerDelegate>
@property (nonatomic, assign) BOOL isShowPreview;
@end

@implementation NXAddToProjectBaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configurationNavigation];
    [self commonInit];
}

- (void)configurationNavigation {
    self.navigationItem.title = NSLocalizedString(@"UI_ADD_FILE_TO", NULL);
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
}
- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)commonInit {
    self.isShowPreview = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    UIScrollView *bgScrollView = [[UIScrollView alloc]init];
    bgScrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:bgScrollView];
    self.bgScrollView = bgScrollView;
    UIView *bottomView = [[UIView alloc]init];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    UIView *specifyView = [[UIView alloc]init];
    [bgScrollView addSubview:specifyView];
    self.specifyView = specifyView;
    self.specifyView.backgroundColor = [UIColor blueColor];
    UIButton *bottomBtn = [[UIButton alloc] init];
    [bottomView addSubview:bottomBtn];
    bottomBtn.enabled = NO;
    [bottomBtn addTarget:self action:@selector(nextOperation:) forControlEvents:UIControlEventTouchUpInside];
    [bottomBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [bottomBtn setBackgroundImage:[UIImage imageWithSize:CGSizeMake(200, 200) colors:@[RMC_GRADIENT_START_COLOR, RMC_GRADIENT_END_COLOR] gradientType:GradientTypeLeftToRight] forState:UIControlStateNormal];
    [bottomBtn cornerRadian:3];
    self.bottomBtn = bottomBtn;
    NXProtectedFileListView *fileListView = [[NXProtectedFileListView alloc] initWithFileList:@[self.currentFile]];
    [self.bgScrollView addSubview:fileListView];
    self.fileListView = fileListView;
    if (!(self.fileOperationType == NXFileOperationTypeWorkSpaceFileReclassify || self.fileOperationType == NXFileOperationTypeProjectFileReclassify)) {
        NXAddFileSavePathView *locationView = [[NXAddFileSavePathView alloc] initWithSavePathText: [self getSaveLocationPath:self.currentFile]];
        [locationView setHintMessage:@"The protected file will be added to" andSavePath:[self getSaveLocationPath:self.folder]];
        [self.bgScrollView addSubview:locationView];
        self.locationView = locationView;
        
    }
   
   
//    NXPreviewFileView *previewFileView = [[NXPreviewFileView alloc] init];
//    [self.bgScrollView addSubview:previewFileView];
//    [self.bgScrollView sendSubviewToBack:previewFileView];
//    self.preview = previewFileView;
////    previewFileView.showPreviewClick = ^(id sender) {
////        [self changePreviewSize];
////    };
//    previewFileView.promptMessage = NSLocalizedString(@"UI_FILE_WILL_BE_SAVED_TO", NULL);
//    previewFileView.enabled = YES;
//    WeakObj(self);
//    previewFileView.changePathClick = ^(id sender) {
//        StrongObj(self);
//        NXFileChooseFlowViewController *vc = nil;
//        if (self.fileOperationType == NXFileOperationTypeAddProjectFileToWorkSpace) {
//            vc = [[NXFileChooseFlowViewController alloc] initWithWorkSpaceType:NXFileChooseFlowViewControllerTypeChooseDestFolder];
//        }else if (self.fileOperationType == NXFileOperationTypeAddFileToSharedWorkspace){
//            vc = [[NXFileChooseFlowViewController alloc] initWithRepository:self.toRepoModel type:NXFileChooseFlowViewControllerTypeChooseDestFolder isSupportMultipleSelect:NO];
//        }else{
//            vc = [[NXFileChooseFlowViewController alloc] initWithProject:self.toProject type:NXFileChooseFlowViewControllerTypeChooseDestFolder];
//        }
//        vc.type = NXFileChooseFlowViewControllerTypeChooseDestFolder;
//        vc.fileChooseVCDelegate = self;
//        vc.modalPresentationStyle = UIModalPresentationFullScreen;
//        [self.navigationController presentViewController:vc animated:YES completion:nil];
//    };
    self.specifyView.backgroundColor = [UIColor whiteColor];
//
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.view);
        make.height.equalTo(self.view).multipliedBy(0.12);
    }];
    
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [bgScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
                make.left.right.equalTo(self.view);
                make.bottom.equalTo(bottomView.mas_top);
            }];

        }
    }else{
        [bgScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuideBottom);
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(bottomView.mas_top);
        }];

    }
    if (!(self.fileOperationType == NXFileOperationTypeWorkSpaceFileReclassify || self.fileOperationType == NXFileOperationTypeProjectFileReclassify)){
        [self.fileListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bgScrollView);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
        }];
        [self.locationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.fileListView.mas_bottom).offset(kMargin);
            make.left.equalTo(self.fileListView).offset(kMargin);
            make.right.equalTo(self.fileListView).offset(-kMargin);
        }];

        [specifyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.locationView.mas_bottom).offset(kMargin);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.height.greaterThanOrEqualTo(@100);
        }];
        
    }else{
        [self.fileListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bgScrollView);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
        }];
        [specifyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.fileListView.mas_bottom).offset(kMargin);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.height.greaterThanOrEqualTo(@100);
        }];
        
    }
   
   
    [bottomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(bottomView);
        make.width.equalTo(@300);
        make.height.lessThanOrEqualTo(@(40));
    }];
}
- (void)nextOperation:(id)sender {
    
}
- (void)changePreviewSize {
    if (self.isShowPreview) {
        [self.specifyView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.preview).offset(PREVIEWFOLDHEIGHT);
            make.left.equalTo(self.preview);
            make.right.equalTo(self.preview);
            make.height.greaterThanOrEqualTo(self.preview.mas_height);
        }];
    }else{
        [self.specifyView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.preview.mas_bottom).offset(kMargin);
            make.left.equalTo(self.preview);
            make.right.equalTo(self.preview);
            make.height.greaterThanOrEqualTo(self.preview.mas_height);
        }];
    }
    self.isShowPreview = !self.isShowPreview;
    [UIView animateWithDuration:0.7 animations:^{
        [self.bgScrollView layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self setScrollViewContentSize];
    }];
}
- (void)setScrollViewContentSize {
     CGFloat height;
     height = (self.isShowPreview ? CGRectGetHeight(self.preview.bounds) : PREVIEWFOLDHEIGHT)+CGRectGetHeight(self.specifyView.bounds);
     self.bgScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bgScrollView.bounds), height + 10);
    
    if (self.bgScrollView.bounds.size.height > height) {
        self.bgScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bgScrollView.bounds), CGRectGetHeight(self.bgScrollView.bounds));
    } else {
        self.bgScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bgScrollView.bounds), height + 10);
    }
    
}
- (NSString *)getSaveLocationPath:(NXFileBase *)fileItem {
    NSString *savePath;
    switch (self.fileOperationType) {
        case NXFileOperationTypeAddNXLFileToWorkSpace:
            savePath = [NSString stringWithFormat:@"%@%@",@"SkyDRM://WorkSpace",self.folder.fullPath];
            break;
        case NXFileOperationTypeAddNXLFileToRepo:
        case NXFileOperationTypeAddFileToSharedWorkspace:
        {
            NXRepositoryModel *model = [[NXLoginUser sharedInstance].myRepoSystem getRepositoryModelByRepoId:self.folder.repoId];
            savePath = [NSString stringWithFormat:@"%@%@%@",@"SkyDRM://Repositories/",model.service_alias,self.folder.fullPath];
        }
            break;
        case NXFileOperationTypeAddNXLFileToProject:
        case NXFileOperationTypeAddProjectFileToProject:
            savePath = [NSString stringWithFormat:@"%@%@%@",@"SkyDRM://Projects/",self.toProject.name,self.folder.fullPath];
            break;
        case NXFileOperationTypeAddNXLFileToMySpace:
            savePath = @"SkyDRM://MySpace";
        default:
            break;
    }
    return savePath;
}
#pragma mark ------> fileChooseDelegate
- (void)fileChooseFlowViewController:(NXFileChooseFlowViewController *)vc didChooseFile:(NSArray *)choosedFiles {
    if (choosedFiles.count) {
        self.folder = choosedFiles.lastObject;
//        if (self.fileOperationType == NXFileOperationTypeAddProjectFileToWorkSpace) {
//            self.preview.savedPath = [NSString stringWithFormat:@"%@:%@",@"WorkSpace",self.folder.fullPath];
//        }else if(self.fileOperationType == NXFileOperationTypeAddFileToSharedWorkspace){
//            self.preview.savedPath = [NSString stringWithFormat:@"%@:%@",self.toRepoModel.service_alias, self.folder.fullPath?:@""];
//        }else{
//            self.preview.savedPath = [NSString stringWithFormat:@"%@:%@", vc.projectModel.displayName, self.folder.fullPath];
//        }
//        
    }
}
- (void)fileChooseFlowViewControllerDidCancelled:(NXFileChooseFlowViewController *)vc {
    //
}
@end
