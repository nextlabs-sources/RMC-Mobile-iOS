//
//  NXProjectFileSelectedPolicyVC.m
//  nxrmc
//
//  Created by Sznag on 2020/12/28.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXProtectFileSelectedPolicyVC.h"
#import "NXProtectedFileListView.h"
#import "DetailViewController.h"
#import "Masonry.h"
#import "NXProtectFileAfterSelectedLocationVC.h"
#import "NXCustomTitleView.h"
#import "NXMBManager.h"
#import "NXProject.h"
#import "NXLoginUser.h"
#import "NXDocumentClassificationView.h"
#import "NXRightsDisplayView.h"
#import "UIImage+ColorToImage.h"
#import "UIView+UIExt.h"
#import "NXProtectedResultVC.h"
#import "NXOriginalFilesTransfer.h"
#import "NXMessageViewManager.h"
#import "NXFolder.h"
#import "NXCommonUtils.h"
#import "NXTimeServerManager.h"
#import "NXNetworkHelper.h"
@interface NXProtectFileSelectedPolicyVC ()
@property (nonatomic, strong) NXRightsDisplayView *rightsDisplayView;
@property (nonatomic, strong) NXDocumentClassificationView *classificationView;
@property (nonatomic, strong) UIScrollView *mainView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *protectButton;
@property(nonatomic, strong)UIBarButtonItem *cancelItem;
@property(nonatomic, strong)NSMutableArray *downloadedFIlesArray;
@property(nonatomic ,strong)NSMutableArray *exsitArray;
@property(nonatomic, strong)NSMutableArray *needProtectFiles;
@property(nonatomic, strong)NXProtectedFileListView *selectFileListView;
@property(nonatomic, strong)NXSaveLocationInfoView *locationInfoView;
@end
static const CGFloat bottomviewHeight = 70.0;
@implementation NXProtectFileSelectedPolicyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self initNavigationBar];
    [self checkRightsFromClassifications];
}
- (void)initNavigationBar {
    NXCustomNavTitleView *titleView = [[NXCustomNavTitleView alloc] init];
    titleView.mainTitle = NSLocalizedString(@"UI_CREATE_A_PROTECTED_FILE", NULL);
    if (self.selectedFileArray.count>1) {
        titleView.subTitle = [NSString stringWithFormat:@"Selected files (%ld)",self.selectedFileArray.count];
        
    }else{
        titleView.subTitle = [NSString stringWithFormat:@"Selected file (%ld)",self.selectedFileArray.count];
    }
   
    self.navigationItem.titleView = titleView;
   
    self.navigationItem.titleView = titleView;
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClicked:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    leftItem.accessibilityValue = @"UI_BOX_CANCEL";
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    rightItem.accessibilityValue = @"UPLOAD_CANCEL";
    self.navigationItem.rightBarButtonItem = rightItem;
    self.cancelItem = rightItem;
   
}
- (void)checkRightsFromClassifications{
    if (!self.selectedFileArray) {
        return;
    }
    [NXMBManager showLoading];
    NSString *memberShipId = nil;
    if (self.targetProject) {
        if (!self.targetProject.membershipId) {
            
            [[NXLoginUser sharedInstance].myProject getMemberShipID:self.targetProject withCompletion:^(NXProjectModel *projectModel, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!error) {
                        self.targetProject.membershipId = projectModel.membershipId;
                        [self updateCenterPolicyUI:self.targetProject.membershipId];
                    }else{
                        [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:1.5];
                }
                });
            }];
            return;
        }
        memberShipId = self.targetProject.membershipId;
       
    }else{
        memberShipId = [NXLoginUser sharedInstance].profile.tenantMembership.ID;
    }

    [self updateCenterPolicyUI:memberShipId];
}
- (void)updateCenterPolicyUI:(NSString *)memberShipId {
    if (self.selectedClassifiations) {
        NXFileBase *fileItem = self.selectedFileArray.firstObject;
        [[NXLoginUser sharedInstance].nxlOptManager checkCenterPolicyFileRightsWithMemberShip:memberShipId classifications:self.selectedClassifiations fileName:fileItem.name withCompletion:^(NXLRights *rights, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [NXMBManager hideHUD];
                if (!error) {
                    [self commonInitUI];
                    self.rightsDisplayView.hidden = NO;
                    self.rightsDisplayView.rights = rights;
                    [self.view setNeedsLayout];
                    [self.view layoutIfNeeded];
                }else{
                     [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:1.5];
                }
            });
        }];
    }
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self setScrollViewContentSize];
}
- (void)setScrollViewContentSize {
    CGFloat height;
    height = CGRectGetHeight(self.selectFileListView.bounds) + CGRectGetHeight(self.locationInfoView.bounds) + CGRectGetHeight(self.classificationView.bounds) + CGRectGetHeight(self.rightsDisplayView.bounds);
    if (self.mainView.bounds.size.height - bottomviewHeight > height) {
        self.mainView.contentSize = CGSizeMake(CGRectGetWidth(self.mainView.bounds), CGRectGetHeight(self.mainView.bounds));
    } else {
        self.mainView.contentSize = CGSizeMake(CGRectGetWidth(self.mainView.bounds), height + kMargin * 3 + bottomviewHeight);
    }
}
- (void)commonInitUI {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    [self.view addSubview: scrollView];
    self.mainView = scrollView;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.backgroundColor = [UIColor whiteColor];
    UIView *bottomView = [[UIView alloc] init];
    [self.view addSubview:bottomView];
    self.bottomView = bottomView;
    bottomView.backgroundColor = [UIColor whiteColor];
    UIButton *protectButton = [[UIButton alloc] init];
    [self.bottomView addSubview:protectButton];
    [protectButton setTitle:NSLocalizedString(@"UI_CREATE_A_PROTECTED_FILE", NULL) forState:UIControlStateNormal];
    protectButton.accessibilityValue = @"PROTECT_BTN";
    [protectButton addTarget:self action:@selector(protect:) forControlEvents:UIControlEventTouchUpInside];
    [protectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [protectButton setBackgroundImage:[UIImage imageWithSize:CGSizeMake(200, 200) colors:@[RMC_GRADIENT_START_COLOR, RMC_GRADIENT_END_COLOR] gradientType:GradientTypeLeftToRight] forState:UIControlStateNormal];
    [protectButton cornerRadian:3];
    _protectButton = protectButton;
    NXProtectedFileListView *fileListView = [[NXProtectedFileListView alloc] initWithFileList:self.selectedFileArray];
    [self.mainView addSubview:fileListView];
    self.selectFileListView = fileListView;
    fileListView.fileClickedCompletion = ^(NXFileBase * _Nonnull file) {
      // preview this file
        DetailViewController *detailVC = [[DetailViewController alloc] init];
        [detailVC openFileForPreview:file];
        [self.navigationController pushViewController:detailVC animated:YES];
    };

    NXSaveLocationInfoView *locationView = [[NXSaveLocationInfoView alloc] initWithSavePathText:self.savePath];
    [locationView hideChangeSaveLocationButton];
    [self.mainView addSubview:locationView];
    if (self.selectedFileArray.count>1) {
        [locationView setHintMessage:NSLocalizedString(@"UI_FILES_WILL_BE_SAVED_TO1", NULL) andSavePath:[self getSaveLocationPath:self.saveFolder]];
    }else{
        [locationView setHintMessage:NSLocalizedString(@"UI_FILE_WILL_BE_SAVED_TO1", NULL) andSavePath:[self getSaveLocationPath:self.saveFolder]];
    }
    [locationView addShadow:UIViewShadowPositionBottom color:[UIColor groupTableViewBackgroundColor]];
    self.locationInfoView = locationView;
    NXDocumentClassificationView *classificationView = [[NXDocumentClassificationView alloc]init];
    classificationView.documentClassicationsArray = self.selectedClassifiations;
    [self.mainView addSubview:classificationView];
    self.classificationView = classificationView;
    NXRightsDisplayView *rightsDisplayView = [[NXRightsDisplayView alloc]init];
//    rightsDisplayView.isNeedTitle = NO;
    
    rightsDisplayView.hidden = YES;
    rightsDisplayView.noRightsMessage = NSLocalizedString(@"MSG_NO_PERMISSIONS_DETERMINED", NULL);
    [self.mainView addSubview:rightsDisplayView];
    self.rightsDisplayView = rightsDisplayView;
        
   
    if (@available(iOS 11.0, *)) {
       
       [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
           make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
           make.left.and.right.equalTo(self.view);
           make.height.equalTo(@(bottomviewHeight));
       }];
       
       [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
           make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
           make.bottom.equalTo(bottomView.mas_top);
           make.width.equalTo(self.view);
           make.centerX.equalTo(self.view);
       }];
    }else{
        [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view);
            make.left.and.right.equalTo(self.view);
            make.height.equalTo(@(bottomviewHeight));
        }];
        
        [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottomLayoutGuideTop);
            make.bottom.equalTo(bottomView.mas_top);
            make.width.equalTo(self.view);
            make.centerX.equalTo(self.view);
        }];
    }
    [protectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.bottomView);
        make.width.equalTo(@300);
        make.height.lessThanOrEqualTo(self.bottomView).multipliedBy(0.7);
        make.height.lessThanOrEqualTo(@(40));
    }];
    [fileListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mainView);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
    }];
    [locationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fileListView.mas_bottom).offset(kMargin/2);
        make.left.right.equalTo(fileListView);
    }];
    [classificationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(locationView.mas_bottom).offset(kMargin);
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(locationView).offset(-10);
        make.height.greaterThanOrEqualTo(@60);
    }];
    [rightsDisplayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(classificationView.mas_bottom);
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-kMargin);
        make.height.greaterThanOrEqualTo(@200);
    }];
}
- (void)protect:(id)sender {
    if (![[NXNetworkHelper sharedInstance] isNetworkAvailable]) {
        [NXMBManager showMessage:@"The internet connection appears to be offline" toView:self.view hideAnimated:YES afterDelay:kDelay];
        return;
    }
    self.protectButton.enabled = NO;
    self.cancelItem.enabled = NO;
    switch (self.locationType) {
        case NXProtectSaveLoactionTypeWorkSpace:
            [self protectMultipleFilesToWorkspace:self.selectedFileArray];
            break;
        case NXProjectSaveLocationTypeSharedWorkSpace:
        case NXProtectSaveLoactionTypeFileRepo:
            [self protectMultipleFilesToRepo:self.selectedFileArray];
            break;
        case NXProtectSaveLoactionTypeLocalFiles:
            [self protectFilesToLocalFiles:self.selectedFileArray];
            break;
        case NXProtectSaveLoactionTypeProject:
            [self protectMultipleFileToProject:self.selectedFileArray];
            break;
        case NXProtectSaveLoactionTypeMyVault:
            break;
    }
}
- (void)protectMultipleFileToProject:(NSArray *)fileArray{
    if (self.saveFolder == nil || !self.targetProject) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_SELECT_FOLDER", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
        return;
    }
    [NXMBManager showLoading];
    self.exsitArray = [self checkExistFilesFromProject:fileArray];
    if (self.exsitArray.count) {
        NSMutableArray *successArray = [NSMutableArray array];
        NSMutableArray *failArray = [NSMutableArray array];
        [[NXWebFileManager sharedInstance] downloadMultipleFiles:fileArray completed:^(NSArray *downloadFileArray, NSError *error) {
            if (error) {
                for (NXFileBase *fileItem in fileArray) {
                    fileItem.name = [NSString stringWithFormat:@"%@%@",fileItem.name,@".nxl"];
                    fileItem.localPath = error.localizedDescription;
                    [failArray addObject:fileItem];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NXMBManager hideHUD];
                    NXProtectedResultVC *VC = [[NXProtectedResultVC alloc] init];
                    VC.failFileArray = failArray;
                    VC.allFilesArray = fileArray;
                    VC.savePath = [self getSaveLocationPath:self.saveFolder];
                    VC.successFileArray = successArray;
                    [self.navigationController pushViewController:VC animated:YES];
                    
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NXWorkSpaceFile *fileItem =  self.exsitArray.firstObject;
                    [self showMessageAboutProjectFile:fileItem needProtectFileArray:downloadFileArray];
                   

                });
            }
           
        }];
        
    }else{
        [[NXLoginUser sharedInstance].nxlOptManager protectMultipleFilesToProject:fileArray classifications:self.selectedClassifiations membershipId:self.targetProject.membershipId inProject:self.targetProject.projectId intoFolder:(NXProjectFolder *)self.saveFolder andIsOverwrite:NO withCompletion:^(NSArray *successArray, NSArray *failArray, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [NXMBManager hideHUD];
                if (!failArray.count) {
                    [self dismissSelf];
                }else{
                    NXProtectedResultVC *VC = [[NXProtectedResultVC alloc] init];
                    VC.failFileArray = failArray;
                    VC.allFilesArray = fileArray;
                    VC.successFileArray = successArray;
                    VC.savePath = [self getSaveLocationPath:self.saveFolder];
                    [self.navigationController pushViewController:VC animated:YES];
                }
            });
                
        }];
        
    }
    
   
}
- (void)protectMultipleFilesToRepo:(NSArray *)fileArray{
    if (self.saveFolder == nil) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_SELECT_FOLDER", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
        return;
    }
    [NXMBManager showLoading];
    self.exsitArray = [self checkExistFilesFromRepo:fileArray];
    if (self.exsitArray.count) {
        NSMutableArray *successArray = [NSMutableArray array];
        NSMutableArray *failArray = [NSMutableArray array];
        [[NXWebFileManager sharedInstance] downloadMultipleFiles:fileArray completed:^(NSArray *downloadFileArray, NSError *error) {
            if (error) {
                for (NXFileBase *fileItem in fileArray) {
                    fileItem.name = [NSString stringWithFormat:@"%@%@",fileItem.name,@".nxl"];
                    fileItem.localPath = error.localizedDescription;
                    [failArray addObject:fileItem];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NXMBManager hideHUD];
                    NXProtectedResultVC *VC = [[NXProtectedResultVC alloc] init];
                    VC.failFileArray = failArray;
                    VC.allFilesArray = fileArray;
                    VC.savePath = [self getSaveLocationPath:self.saveFolder];
                    VC.successFileArray = successArray;
                    [self.navigationController pushViewController:VC animated:YES];
                    
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NXFileBase *fileItem =  self.exsitArray.firstObject;
                    [self showMessageRepoFile:fileItem needProtectFileArray:downloadFileArray];
                   

                });
            }
           
        }];
        
    }else{
        [[NXLoginUser sharedInstance].nxlOptManager downloadAndEncryptMultipleFile:fileArray classifications:self.selectedClassifiations membershipId:[NXLoginUser sharedInstance].profile.tenantMembership.ID withComplection:^(NSArray *successArray, NSArray *failArray, NSError *error) {
            if (failArray.count && failArray.count == fileArray.count) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NXMBManager hideHUD];
                    NXProtectedResultVC *VC = [[NXProtectedResultVC alloc] init];
                    VC.failFileArray = failArray;
                    VC.allFilesArray = fileArray;
                    VC.savePath = [self getSaveLocationPath:self.saveFolder];
                    VC.successFileArray = successArray;
                    [self.navigationController pushViewController:VC animated:YES];
                });
                return;
            }
            NSMutableArray *failuploadArray = [NSMutableArray arrayWithArray:failArray];
            NSMutableArray *successUploadArray = [NSMutableArray array];
            for (NXFileBase *file in successArray) {
                NXRepositorySysManagerUploadType uploadType = NXRepositorySysManagerUploadTypeNormal;
                [[NXLoginUser sharedInstance].myRepoSystem uploadFile:file.name toPath:self.saveFolder fromPath:file.localPath uploadType:uploadType overWriteFile:nil progress:nil completion:^(NXFileBase *fileItem, NXFileBase *parentFolder, NSError *error1) {
                    if (!error1) {
                        [successUploadArray addObject:fileItem];
                    }else{
                        file.localPath = error1.localizedDescription;
                        [failuploadArray addObject:file];
                    }
                    if (successUploadArray.count + failuploadArray.count == fileArray.count) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [NXMBManager hideHUD];
                            if (failuploadArray.count == 0) {
                                [self dismissSelf];
                            }else{
                                NXProtectedResultVC *VC = [[NXProtectedResultVC alloc] init];
                                VC.failFileArray = failuploadArray;
                                VC.allFilesArray = fileArray;
                                VC.savePath = [self getSaveLocationPath:nil];
                                VC.successFileArray = successUploadArray;
                                [self.navigationController pushViewController:VC animated:YES];
                            }

                        });
                        
                    }
                   
                }];
                
            }
                
        }];
        
    }
   
    
}
- (void)protectMultipleFilesToWorkspace:(NSArray *)array{
    if (self.saveFolder == nil) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_SELECT_FOLDER", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
        self.protectButton.enabled = YES;
        self.cancelItem.enabled = YES;
        return;
    }
    NSMutableDictionary *classificaitonDict = [[NSMutableDictionary alloc] init];
    for (NXClassificationCategory *classificationCategory in self.selectedClassifiations) {
       if (classificationCategory.selectedLabs.count > 0) {
           NSMutableArray *labs = [[NSMutableArray alloc] init];
           for (NXClassificationLab *classificationLab in classificationCategory.selectedLabs) {
               NSString *labName = classificationLab.name;
               [labs addObject:labName];
           }
           [classificaitonDict setObject:labs forKey:classificationCategory.name];
       }
    }
   
    
    [NXMBManager showLoading];
    
    NSMutableArray *existArray = [self checkExistFilesFromWrokspace:array];
    self.exsitArray = existArray;
    self.needProtectFiles = [NSMutableArray array];
    if (existArray.count > 0) {
        NSMutableArray *successArray = [NSMutableArray array];
        NSMutableArray *failArray = [NSMutableArray array];
        [[NXWebFileManager sharedInstance] downloadMultipleFiles:array completed:^(NSArray *downloadFileArray, NSError *error) {
            if (error) {
                for (NXFileBase *fileItem in array) {
                    fileItem.name = [NSString stringWithFormat:@"%@%@",fileItem.name,@".nxl"];
                    fileItem.localPath = error.localizedDescription;
                    [failArray addObject:fileItem];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NXMBManager hideHUD];
                    NXProtectedResultVC *VC = [[NXProtectedResultVC alloc] init];
                    VC.failFileArray = failArray;
                    VC.allFilesArray = array;
                    VC.savePath = [self getSaveLocationPath:self.saveFolder];
                    VC.successFileArray = successArray;
                    [self.navigationController pushViewController:VC animated:YES];
                    
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NXWorkSpaceFile *fileItem =  existArray.firstObject;
                    [self showMessageAboutWorkspaceFile:fileItem needProtectFileArray:downloadFileArray];
                   

                });
            }
           
        }];
       
    }else{
        [[NXLoginUser sharedInstance].nxlOptManager protectMultipleFilesToWorkspace:array membershipId:[NXLoginUser sharedInstance].profile.tenantMembership.ID  permissions:nil classifications:classificaitonDict intoFolder:(NXFolder *)self.saveFolder withCompletion:^(NSArray *successArray, NSArray *failArray, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [NXMBManager hideHUD];
                if (!error && failArray.count == 0) {
                    [self dismissSelf];
                }else{
                    NXProtectedResultVC *VC = [[NXProtectedResultVC alloc] init];
                    VC.failFileArray = failArray;
                    VC.allFilesArray = array;
                    VC.savePath = [self getSaveLocationPath:self.saveFolder];
                    VC.successFileArray = successArray;
                    [self.navigationController pushViewController:VC animated:YES];
                }

            });
        }];
        
    }
   
    
}
    - (void)protectFilesToLocalFiles:(NSArray *)filesArray {
       
        [NXMBManager showLoading];
        [[NXLoginUser sharedInstance].nxlOptManager downloadAndEncryptMultipleFile:filesArray classifications:self.selectedClassifiations membershipId:[NXLoginUser sharedInstance].profile.tenantMembership.ID  withComplection:^(NSArray *successArray, NSArray *failArray, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [NXMBManager hideHUD];
                self.protectButton.enabled = YES;
                self.cancelItem.enabled = YES;
                [self uploadFilesToLocalFiles:successArray wilthFailFiles:failArray];
            });
        }];
    }
- (void)uploadFilesToLocalFiles:(NSArray *)filesArray wilthFailFiles:(NSArray *)failArray{
        [[NXOriginalFilesTransfer sharedIInstance] exportMultipleFiles:filesArray toOriginalFilesFromVC:self];
        
        [NXOriginalFilesTransfer sharedIInstance].exprotMultipleFilesCompletion = ^(UIViewController *currentVC, NSArray *fileUrls, NSError *error) {
        [NXMBManager hideHUD];
            if ([currentVC isMemberOfClass:[self class]]) {
                if (!error && failArray.count == 0) {
                    [self dismissSelf];
                }else{
                    NXProtectedResultVC *VC = [[NXProtectedResultVC alloc] init];
                    VC.failFileArray = failArray;
                    VC.allFilesArray = filesArray;
                    VC.savePath = [self getSaveLocationPath:nil];
                    VC.successFileArray = @[];
                    [self.navigationController pushViewController:VC animated:YES];
                }
            }
        };
       
    }

- (NSString *)getSaveLocationPath:(NXFileBase *)fileItem {
    NSString *savePath;
    switch (self.locationType) {
        case NXProtectSaveLoactionTypeWorkSpace:
            savePath = [NSString stringWithFormat:@"%@%@",@"SkyDRM://WorkSpace",self.saveFolder.fullPath];
            break;
        case NXProtectSaveLoactionTypeMyVault:
            savePath = @"SkyDRM://MySpace";
            break;
        case NXProjectSaveLocationTypeSharedWorkSpace:
        case NXProtectSaveLoactionTypeFileRepo:
        {
            NXRepositoryModel *model = [[NXLoginUser sharedInstance].myRepoSystem getRepositoryModelByRepoId:self.saveFolder.repoId];
            savePath = [NSString stringWithFormat:@"%@%@%@",@"SkyDRM://Repositories/",model.service_alias,self.saveFolder.fullPath];
        }
            break;
        case NXProtectSaveLoactionTypeLocalFiles:
            savePath = @"Device://Files";
            break;
        case NXProtectSaveLoactionTypeProject:
            savePath = [NSString stringWithFormat:@"%@%@%@",@"SkyDRM://Projects/",self.targetProject.name,self.saveFolder.fullPath];
            break;
    }
    return savePath;
}
- (void)showMessageAboutWorkspaceFile:(NXFileBase *)fileItem needProtectFileArray:(NSArray *)downloadArray {
    if (self.exsitArray.count) {
        self.needProtectFiles = [NSMutableArray arrayWithArray:downloadArray];
        if (fileItem && [self.exsitArray containsObject:fileItem]) {
            [self.exsitArray removeObject:fileItem];
            dispatch_async(dispatch_get_main_queue(), ^{

                                for (NXFileBase *file in self.needProtectFiles) {
                
                                if ([fileItem.name.stringByDeletingPathExtension isEqualToString:file.name]) {
                                    if ([self isHaveOverwritePerssion:fileItem]) {
                                        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MSG_REPLACEANDKEEPBOTH_SELECT_MESSAGE", NULL), fileItem.name];
                                        [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_REPLACE", NULL) cancelActionTitle:NSLocalizedString(@"UI_BOX_SKIP", NULL) otherTitle:NSLocalizedString(@"UI_BOX_NO_REPLACE", NULL) OKActionHandle:^(UIAlertAction *action) {
                                            [self showMessageAboutWorkspaceFile:self.exsitArray.firstObject needProtectFileArray:self.needProtectFiles];
            
                                                               } cancelActionHandle:^(UIAlertAction *action) {
                                                                   [self.needProtectFiles removeObject:file];
                                                                   [self showMessageAboutWorkspaceFile:self.exsitArray.firstObject needProtectFileArray:self.needProtectFiles];
                                                                  
                                                               } otherActionHandle:^(UIAlertAction *action) {
                                                                   NSArray *currentFolderFiles = [[NXLoginUser sharedInstance].workSpaceManager getWorkSpaceFileListUnderFolderInCoreData:(NXWorkSpaceFolder *)self.saveFolder];
                                                                   NSMutableArray *currentFolderFilesNameArray = [[NSMutableArray alloc] init];
                                                                     for (NXWorkSpaceFile *tmpfile in currentFolderFiles) {
                                                                                             if (tmpfile.name.length > 0) {
                                                                                                 [currentFolderFilesNameArray addObject:tmpfile.name];
                                                                                             }
                                                                                         }
                                                                                         NSUInteger index = 2;
                                                                                         NSUInteger MaxIndex = [NXCommonUtils getMaxIndexForFile:file.name fileNameArray:currentFolderFilesNameArray];
                                                                                         NSString *newFileName = file.name;
                                                                                         if (MaxIndex == 0) {
                                                                                             newFileName = [NXCommonUtils addIndexForFile:index fileName:newFileName];
                                                                                         }else{
                                                                                             MaxIndex += 1;
                                                                                             newFileName = [NXCommonUtils addIndexForFile:MaxIndex fileName:newFileName];
                                                                                         }
                                  
                                                                                         file.name = newFileName;
                                                                   NXFileBase *newFile = [file copy];
                                                                   newFile.name = newFileName;
                                                                  
                                                                   [self.needProtectFiles removeObject:file];
                                                                   [self.needProtectFiles addObject:newFile];
                                                                   [self showMessageAboutWorkspaceFile:self.exsitArray.firstObject needProtectFileArray:self.needProtectFiles];
                                                                  
                                                               } inViewController:self position:self.view];
                                        
                                    }else{
                                        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MSG_KEEPBOTH_SELECT_MESSAGE", NULL), fileItem.name];
                                        [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message style:UIAlertControllerStyleAlert OKActionTitle:nil cancelActionTitle:NSLocalizedString(@"UI_BOX_SKIP", NULL) otherTitle:NSLocalizedString(@"UI_BOX_NO_REPLACE", NULL) OKActionHandle:^(UIAlertAction *action) {
    //                                        [self.needProtectFiles addObject:file];
    //                                        [self showMessageAboutFile:self.downloadedFIlesArray.firstObject needProtectFileArray:downloadArray];
    //
                                                               } cancelActionHandle:^(UIAlertAction *action) {
                                                                   [self.needProtectFiles removeObject:file];
                                                                   [self showMessageAboutWorkspaceFile:self.exsitArray.firstObject needProtectFileArray:self.needProtectFiles];
                                                                  
                                                               } otherActionHandle:^(UIAlertAction *action) {
                                                                   NSArray *currentFolderFiles = [[NXLoginUser sharedInstance].workSpaceManager getWorkSpaceFileListUnderFolderInCoreData:(NXWorkSpaceFolder *)self.saveFolder];
                                                                   NSMutableArray *currentFolderFilesNameArray = [[NSMutableArray alloc] init];
                                                                     for (NXWorkSpaceFile *tmpfile in currentFolderFiles) {
                                                                                             if (tmpfile.name.length > 0) {
                                                                                                 [currentFolderFilesNameArray addObject:tmpfile.name];
                                                                                             }
                                                                                         }
                                                                                         NSUInteger index = 2;
                                                                                         NSUInteger MaxIndex = [NXCommonUtils getMaxIndexForFile:file.name fileNameArray:currentFolderFilesNameArray];
                                                                                         NSString *newFileName = file.name;
                                                                                         if (MaxIndex == 0) {
                                                                                             newFileName = [NXCommonUtils addIndexForFile:index fileName:newFileName];
                                                                                         }else{
                                                                                             MaxIndex += 1;
                                                                                             newFileName = [NXCommonUtils addIndexForFile:MaxIndex fileName:newFileName];
                                                                                         }

                                                                   NXFileBase *newFile = [file copy];
                                                                   newFile.name = newFileName;

                                                                   [self.needProtectFiles removeObject:file];
                                                                   [self.needProtectFiles addObject:newFile];
                                                                   [self showMessageAboutWorkspaceFile:self.exsitArray.firstObject needProtectFileArray:self.needProtectFiles];
                                                                  
                                                               } inViewController:self position:self.view];
                                        
                                    }
                                  
                                }
                            }
                            
            });
           
        }
        
    }else{
        if (!self.needProtectFiles.count) {
            [NXMBManager hideHUD];
            self.cancelItem.enabled = YES;
            self.protectButton.enabled = YES;
            [self dismissSelf];
            return;
        }
        NSMutableDictionary *classificaitonDict = [[NSMutableDictionary alloc] init];
        for (NXClassificationCategory *classificationCategory in self.selectedClassifiations) {
           if (classificationCategory.selectedLabs.count > 0) {
               NSMutableArray *labs = [[NSMutableArray alloc] init];
               for (NXClassificationLab *classificationLab in classificationCategory.selectedLabs) {
                   NSString *labName = classificationLab.name;
                   [labs addObject:labName];
               }
               [classificaitonDict setObject:labs forKey:classificationCategory.name];
           }
        }
        [[NXLoginUser sharedInstance].nxlOptManager protectMultipleAlreadyDownloadFilesToWorkspace:self.needProtectFiles membershipLid:[NXLoginUser sharedInstance].profile.tenantMembership.ID permissions:nil classifications:classificaitonDict inFolder:self.saveFolder withCompletion:^(NSArray *successArray, NSArray *failArray, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [NXMBManager hideHUD];
                if (!error && failArray.count == 0) {
                    [self dismissSelf];
                }else{
                    NXProtectedResultVC *VC = [[NXProtectedResultVC alloc] init];
                    VC.failFileArray = failArray;
                    VC.allFilesArray = downloadArray;
                    VC.savePath = [self getSaveLocationPath:self.saveFolder];
                    VC.successFileArray = successArray;
                    [self.navigationController pushViewController:VC animated:YES];
                }
                
            });
        }];
    }
    
}
- (void)showMessageRepoFile:(NXFileBase *)fileItem needProtectFileArray:(NSArray *)downloadArray {
    if (self.exsitArray.count) {
        self.needProtectFiles = [NSMutableArray arrayWithArray:downloadArray];
        if (fileItem && [self.exsitArray containsObject:fileItem]) {
            [self.exsitArray removeObject:fileItem];
            dispatch_async(dispatch_get_main_queue(), ^{

                                for (NXFileBase *file in self.needProtectFiles) {
                
                                if ([fileItem.name.stringByDeletingPathExtension isEqualToString:file.name]) {
                                    if ([self isHaveOverwritePerssion:fileItem]) {
                                        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MSG_REPLACEANDKEEPBOTH_SELECT_MESSAGE", NULL), fileItem.name];
                                        [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_REPLACE", NULL) cancelActionTitle:NSLocalizedString(@"UI_BOX_SKIP", NULL) otherTitle:NSLocalizedString(@"UI_BOX_NO_REPLACE", NULL) OKActionHandle:^(UIAlertAction *action) {
                                            [self showMessageRepoFile:self.exsitArray.firstObject needProtectFileArray:self.needProtectFiles];
            
                                                               } cancelActionHandle:^(UIAlertAction *action) {
                                                                   [self.needProtectFiles removeObject:file];
                                                                   [self showMessageRepoFile:self.exsitArray.firstObject needProtectFileArray:self.needProtectFiles];
                                                                  
                                                               } otherActionHandle:^(UIAlertAction *action) {
                                                                   NSArray *currentFolderFiles = [[NXLoginUser sharedInstance].myRepoSystem childForFileItem:self.saveFolder];
                                                                   NSMutableArray *currentFolderFilesNameArray = [[NSMutableArray alloc] init];
                                                                     for (NXFile *tmpfile in currentFolderFiles) {
                                                                                             if (tmpfile.name.length > 0) {
                                                                                                 [currentFolderFilesNameArray addObject:tmpfile.name];
                                                                                             }
                                                                                         }
                                                                                         NSUInteger index = 2;
                                                                                         NSUInteger MaxIndex = [NXCommonUtils getMaxIndexForFile:file.name fileNameArray:currentFolderFilesNameArray];
                                                                                         NSString *newFileName = file.name;
                                                                                         if (MaxIndex == 0) {
                                                                                             newFileName = [NXCommonUtils addIndexForFile:index fileName:newFileName];
                                                                                         }else{
                                                                                             MaxIndex += 1;
                                                                                             newFileName = [NXCommonUtils addIndexForFile:MaxIndex fileName:newFileName];
                                                                                         }
                                  
                                                                                         file.name = newFileName;
                                                                   NXFileBase *newFile = [file copy];
                                                                   newFile.name = newFileName;
//                                                                   newFile.localPath = file.localPath;
                                                                   [self.needProtectFiles removeObject:file];
                                                                   [self.needProtectFiles addObject:newFile];
                                                                   [self showMessageRepoFile:self.exsitArray.firstObject needProtectFileArray:self.needProtectFiles];
                                                                  
                                                               } inViewController:self position:self.view];
                                        
                                    }else{
                                        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MSG_KEEPBOTH_SELECT_MESSAGE", NULL), fileItem.name];
                                        [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message style:UIAlertControllerStyleAlert OKActionTitle:nil cancelActionTitle:NSLocalizedString(@"UI_BOX_SKIP", NULL) otherTitle:NSLocalizedString(@"UI_BOX_NO_REPLACE", NULL) OKActionHandle:^(UIAlertAction *action) {
  
                                                               } cancelActionHandle:^(UIAlertAction *action) {
                                                                   [self.needProtectFiles removeObject:file];
                                                                   [self showMessageRepoFile:self.exsitArray.firstObject needProtectFileArray:self.needProtectFiles];
                                                                  
                                                               } otherActionHandle:^(UIAlertAction *action) {
                                                                   NSArray *currentFolderFiles = [[NXLoginUser sharedInstance].myRepoSystem childForFileItem:self.saveFolder];
                                                                   NSMutableArray *currentFolderFilesNameArray = [[NSMutableArray alloc] init];
                                                                     for (NXFile *tmpfile in currentFolderFiles) {
                                                                                             if (tmpfile.name.length > 0) {
                                                                                                 [currentFolderFilesNameArray addObject:tmpfile.name];
                                                                                             }
                                                                                         }
                                                                                         NSUInteger index = 2;
                                                                                         NSUInteger MaxIndex = [NXCommonUtils getMaxIndexForFile:file.name fileNameArray:currentFolderFilesNameArray];
                                                                                         NSString *newFileName = file.name;
                                                                                         if (MaxIndex == 0) {
                                                                                             newFileName = [NXCommonUtils addIndexForFile:index fileName:newFileName];
                                                                                         }else{
                                                                                             MaxIndex += 1;
                                                                                             newFileName = [NXCommonUtils addIndexForFile:MaxIndex fileName:newFileName];
                                                                                         }
                                  
                                                                                         file.name = newFileName;
                                                                   NXFileBase *newFile = [file copy];
                                                                   newFile.name = newFileName;

                                                                   [self.needProtectFiles removeObject:file];
                                                                   [self.needProtectFiles addObject:newFile];
                                                                   [self showMessageRepoFile:self.exsitArray.firstObject needProtectFileArray:self.needProtectFiles];
                                                                  
                                                               } inViewController:self position:self.view];
                                        
                                    }
                                  
                                }
                            }
                            
            });
           
        }
        
    }else{
        if (!self.needProtectFiles.count) {
            [NXMBManager hideHUD];
            self.cancelItem.enabled = YES;
            self.protectButton.enabled = YES;
            [self dismissSelf];
            return;
        }
        
            [[NXLoginUser sharedInstance].nxlOptManager encryptAndUploadMultipleFilesToRepo:self.needProtectFiles toPath:self.saveFolder classifications:self.selectedClassifiations membershipId:[NXLoginUser sharedInstance].profile.tenantMembership.ID withComplection:^(NSArray *successArray, NSArray *failArray, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NXMBManager hideHUD];
                    if (!error && failArray.count == 0) {
                        [self dismissSelf];
                    }else{
                        NXProtectedResultVC *VC = [[NXProtectedResultVC alloc] init];
                        VC.failFileArray = failArray;
                        VC.allFilesArray = downloadArray;
                        VC.savePath = [self getSaveLocationPath:self.saveFolder];
                        VC.successFileArray = successArray;
                        [self.navigationController pushViewController:VC animated:YES];
                    }
                    
                });
                            
            }];
            
        
    }
    
}
- (void)showMessageAboutProjectFile:(NXFileBase *)fileItem needProtectFileArray:(NSArray *)downloadArray {
    if (self.exsitArray.count) {
        self.needProtectFiles = [NSMutableArray arrayWithArray:downloadArray];
        if (fileItem && [self.exsitArray containsObject:fileItem]) {
            [self.exsitArray removeObject:fileItem];
            dispatch_async(dispatch_get_main_queue(), ^{

                                for (NXFileBase *file in self.needProtectFiles) {
                
                                if ([fileItem.name.stringByDeletingPathExtension isEqualToString:file.name]) {
                                    if ([self isHaveOverwritePerssion:fileItem]) {
                                        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MSG_REPLACEANDKEEPBOTH_SELECT_MESSAGE", NULL), fileItem.name];
                                        [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_REPLACE", NULL) cancelActionTitle:NSLocalizedString(@"UI_BOX_SKIP", NULL) otherTitle:NSLocalizedString(@"UI_BOX_NO_REPLACE", NULL) OKActionHandle:^(UIAlertAction *action) {
                                            [self showMessageAboutProjectFile:self.exsitArray.firstObject needProtectFileArray:self.needProtectFiles];
            
                                                               } cancelActionHandle:^(UIAlertAction *action) {
                                                                   [self.needProtectFiles removeObject:file];
                                                                   [self showMessageAboutProjectFile:self.exsitArray.firstObject needProtectFileArray:self.needProtectFiles];
                                                                  
                                                               } otherActionHandle:^(UIAlertAction *action) {
                                                                   NSArray *currentFolderFiles = [[NXLoginUser sharedInstance].myProject getFileListUnderParentFolderInCoreData:(NXProjectFolder *)self.saveFolder];
                                                                   NSMutableArray *currentFolderFilesNameArray = [[NSMutableArray alloc] init];
                                                                     for (NXFileBase *tmpfile in currentFolderFiles) {
                                                                                             if (tmpfile.name.length > 0) {
                                                                                                 [currentFolderFilesNameArray addObject:tmpfile.name];
                                                                                             }
                                                                                         }
                                                                                         NSUInteger index = 2;
                                                                                         NSUInteger MaxIndex = [NXCommonUtils getMaxIndexForFile:file.name fileNameArray:currentFolderFilesNameArray];
                                                                                         NSString *newFileName = file.name;
                                                                                         if (MaxIndex == 0) {
                                                                                             newFileName = [NXCommonUtils addIndexForFile:index fileName:newFileName];
                                                                                         }else{
                                                                                             MaxIndex += 1;
                                                                                             newFileName = [NXCommonUtils addIndexForFile:MaxIndex fileName:newFileName];
                                                                                         }
                                  
                                                                                         file.name = newFileName;
                                                                   NXFileBase *newFile = [file copy];
                                                                   newFile.name = newFileName;
//                                                                   newFile.localPath = file.localPath;
                                                                   [self.needProtectFiles removeObject:file];
                                                                   [self.needProtectFiles addObject:newFile];
                                                                   [self showMessageAboutProjectFile:self.exsitArray.firstObject needProtectFileArray:self.needProtectFiles];
                                                                  
                                                               } inViewController:self position:self.view];
                                        
                                    }else{
                                        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MSG_KEEPBOTH_SELECT_MESSAGE", NULL), fileItem.name];
                                        [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message style:UIAlertControllerStyleAlert OKActionTitle:nil cancelActionTitle:NSLocalizedString(@"UI_BOX_SKIP", NULL) otherTitle:NSLocalizedString(@"UI_BOX_NO_REPLACE", NULL) OKActionHandle:^(UIAlertAction *action) {
  
                                                               } cancelActionHandle:^(UIAlertAction *action) {
                                                                   [self.needProtectFiles removeObject:file];
                                                                   [self showMessageAboutProjectFile:self.exsitArray.firstObject needProtectFileArray:self.needProtectFiles];
                                                                  
                                                               } otherActionHandle:^(UIAlertAction *action) {
                                                                   NSArray *currentFolderFiles = [[NXLoginUser sharedInstance].myProject getFileListUnderParentFolderInCoreData:(NXProjectFolder *)self.saveFolder];
                                                                   NSMutableArray *currentFolderFilesNameArray = [[NSMutableArray alloc] init];
                                                                     for (NXFileBase *tmpfile in currentFolderFiles) {
                                                                                             if (tmpfile.name.length > 0) {
                                                                                                 [currentFolderFilesNameArray addObject:tmpfile.name];
                                                                                             }
                                                                                         }
                                                                                         NSUInteger index = 2;
                                                                                         NSUInteger MaxIndex = [NXCommonUtils getMaxIndexForFile:file.name fileNameArray:currentFolderFilesNameArray];
                                                                                         NSString *newFileName = file.name;
                                                                                         if (MaxIndex == 0) {
                                                                                             newFileName = [NXCommonUtils addIndexForFile:index fileName:newFileName];
                                                                                         }else{
                                                                                             MaxIndex += 1;
                                                                                             newFileName = [NXCommonUtils addIndexForFile:MaxIndex fileName:newFileName];
                                                                                         }
                                  
                                                                                         file.name = newFileName;
                                                                   NXFileBase *newFile = [file copy];
                                                                   newFile.name = newFileName;

                                                                   [self.needProtectFiles removeObject:file];
                                                                   [self.needProtectFiles addObject:newFile];
                                                                   [self showMessageAboutProjectFile:self.exsitArray.firstObject needProtectFileArray:self.needProtectFiles];
                                                                  
                                                               } inViewController:self position:self.view];
                                        
                                    }
                                  
                                }
                            }
                            
            });
           
        }
        
    }else{
        if (!self.needProtectFiles.count) {
            [NXMBManager hideHUD];
            self.cancelItem.enabled = YES;
            self.protectButton.enabled = YES;
            [self dismissSelf];
            return;
        }
        NSMutableArray *successArray = [NSMutableArray array];
        NSMutableArray *failArray = [NSMutableArray array];
        for (NXFileBase *fileItem in self.needProtectFiles) {
            
            [[NXLoginUser sharedInstance].nxlOptManager protectToNXLFile:fileItem toPath:[NXCommonUtils createNewNxlTempFile:fileItem.name] classifications:self.selectedClassifiations   membershipId:self.targetProject.membershipId inProject:self.targetProject.projectId intoFolder:(NXProjectFolder *)self.saveFolder createDate:[NXTimeServerManager sharedInstance].currentServerTime andIsOverwrite:YES withCompletion:^(NXProjectFolder *parentFolder, NXProjectFile *newProjectFile, NSError *error) {
            
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!error) {
                        [successArray addObject:newProjectFile];
                    }else{
                        fileItem.name = [NSString stringWithFormat:@"%@%@",fileItem.name,@".nxl"];
                        fileItem.localPath = error.localizedDescription;
                        [failArray addObject:fileItem];
                    }
                    if (successArray.count + failArray.count == self.needProtectFiles.count) {
                        [NXMBManager hideHUD];
                        if (failArray.count >0) {
                           
                            NXProtectedResultVC *VC = [[NXProtectedResultVC alloc] init];
                            VC.failFileArray = failArray;
                            VC.allFilesArray = downloadArray;
                            VC.savePath = [self getSaveLocationPath:self.saveFolder];
                            VC.successFileArray = successArray;
                            [self.navigationController pushViewController:VC animated:YES];
                        }else{
                            [self dismissSelf];
                        }
                    }
                    
                });

            }];
        }
    }
    
}
- (NSMutableArray *)checkExistFilesFromWrokspace:(NSArray *)filesArray {
    NSArray *currentFolderFiles = [[NXLoginUser sharedInstance].workSpaceManager getWorkSpaceFileListUnderFolderInCoreData:(NXWorkSpaceFolder *)self.saveFolder];
    NSMutableArray *exsitFileArray = [NSMutableArray array];
    if (currentFolderFiles.count) {
        for (NXWorkSpaceFile *fileItem in currentFolderFiles) {
            for (NXFileBase *fileModel in filesArray) {
                if ([fileItem.name.stringByDeletingPathExtension isEqualToString:fileModel.name]) {
                    [exsitFileArray addObject:fileItem];
                }
            }
        }
    }
    return exsitFileArray;
}
- (NSMutableArray *)checkExistFilesFromRepo:(NSArray *)fileArray {
    NSArray *currentFolderFiles = [[NXLoginUser sharedInstance].myRepoSystem childForFileItem:self.saveFolder];
    NSMutableArray *existArray = [NSMutableArray array];
    if (currentFolderFiles.count) {
        for (NXMyVaultFile *fileItem in currentFolderFiles) {
            for (NXFileBase *fileModel in fileArray) {
                if ([fileItem.name.stringByDeletingPathExtension isEqualToString:fileModel.name]) {
                    [existArray addObject:fileItem];
                }
            }
        }
    }
    return existArray;
}
- (NSMutableArray *)checkExistFilesFromProject:(NSArray *)fileArray {
    NSArray *currentFolderFiles = [[NXLoginUser sharedInstance].myProject getFileListUnderParentFolderInCoreData:(NXProjectFolder *)self.saveFolder];
    NSMutableArray *existArray = [NSMutableArray array];
    if (currentFolderFiles.count) {
        for (NXMyVaultFile *fileItem in currentFolderFiles) {
            for (NXFileBase *fileModel in fileArray) {
                if ([fileItem.name.stringByDeletingPathExtension isEqualToString:fileModel.name]) {
                    [existArray addObject:fileItem];
                }
            }
        }
    }
    return existArray;
}
- (BOOL)isHaveOverwritePerssion:(NXFileBase *)file {
//  __block  BOOL isCanOverwrite = NO;
    if (self.saveFolder.serviceType && (self.saveFolder.serviceType == [NSNumber numberWithInteger:kServiceBOX] || self.saveFolder.serviceType == [NSNumber numberWithInteger:kServiceGoogleDrive])) {
        return  NO;
    }
    return YES;
//    if ([[NXLoginUser sharedInstance] isTenantAdmin]) {
//        isCanOverwrite = YES;
//    }else{
//        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//        [[NXLoginUser sharedInstance].nxlOptManager getNXLFileRights:file withWatermark:NO withCompletion:^(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray<NXWatermarkWord *> *waterMarkWords, NSString *owner, BOOL isOwner, NSError *error) {
//            if (!error) {
//                if ([rights EditRight]) {
//                    isCanOverwrite = YES;
//                }else{
//                    isCanOverwrite = NO;
//                }
//            }else{
//                isCanOverwrite = NO;
//            }
//            dispatch_semaphore_signal(semaphore);
//        }];
//        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//    }
//    return isCanOverwrite;
}
- (void)cancel:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)dismissSelf {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
