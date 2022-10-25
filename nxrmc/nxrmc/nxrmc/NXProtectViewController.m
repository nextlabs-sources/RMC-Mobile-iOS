//
//  NXProtectViewController.m
//  nxrmcUITest
//
//  Created by nextlabs on 11/10/16.
//  Copyright © 2016 zhuimengfuyun. All rights reserved.
//

#import "NXProtectViewController.h"
#import "NXTimeServerManager.h"

#import "Masonry.h"

#import "UIView+UIExt.h"
#import "NXMBManager.h"
#import "NXRightsSelectView.h"
#import "NXRightsDisplayView.h"
#import "UIImage+ColorToImage.h"
#import "NXMessageViewManager.h"

#import "NXRMCUIDef.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXServiceOperation.h"
#import "AppDelegate.h"
#import "NXWebFileManager.h"
#import "NXLFileValidateDateModel.h"
#import "NXLRights.h"
#define kTopMargin 16

@interface NXProtectViewController ()<NXRightsSelectViewDelegate, NXServiceOperationDelegate /*UIDocumentInteractionControllerDelegate*/>

@property(nonatomic, strong) NXRightsSelectView *rightsSelectView;
@property(nonatomic, strong) NXRightsDisplayView *rightsDisplayView;
@property(nonatomic, weak) UIButton *protectButton;

@property(nonatomic, strong) NXMBProgressView *progressView;

@property(nonatomic, strong) NXLRights *selectedRights;

@property(nonatomic, strong) NSProgress *uploadProgerss;
@property(nonatomic, strong) NSString *downloadId;

@property(nonatomic, strong) NSString *myRepoSysUploadOptIdentify;
@property(nonatomic, strong) NSString *myVaultUploadOptIdentify;

@property(nonatomic, strong) NSString *encryptFileOptIdentify;
@property(nonatomic, copy)NSString *currentFileOrginalName;


@end

@implementation NXProtectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.uploadProgerss = [[NSProgress alloc] init];
    [self.uploadProgerss addObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted)) options:NSKeyValueObservingOptionNew context:NULL];
    
    [self commonInit];
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)dealloc {
    DLog();
    [self.uploadProgerss removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
    [[NXWebFileManager sharedInstance] cancelDownload:self.downloadId];

}

- (void)viewDidLayoutSubviews {
    CGFloat height = CGRectGetHeight(self.rightsSelectView.bounds)+CGRectGetHeight(self.rightsDisplayView.bounds);
    CGFloat contentHeight = height + kMargin + kMargin;
    if (self.mainView.bounds.size.height > contentHeight) {
        self.mainView.contentSize = CGSizeMake(CGRectGetWidth(self.mainView.bounds), CGRectGetHeight(self.mainView.bounds) + 1);
    } else {
        self.mainView.contentSize = CGSizeMake(CGRectGetWidth(self.mainView.bounds), contentHeight + 1);
    }
    [self.rightsSelectView addShadow:UIViewShadowPositionBottom color:[UIColor lightGrayColor] width:1 Opacity:0.5];
}

#pragma mark - NSKeyValueObserving
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([object isKindOfClass:[NSProgress class]] && [keyPath isEqualToString:NSStringFromSelector(@selector(fractionCompleted))]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"upload progress %lf", self.uploadProgerss.fractionCompleted);
        });
    }
}

#pragma mark
- (void)closeButtonClicked:(id)sender {
    if (DELEGATE_HAS_METHOD(self.delegate, @selector(viewcontroller:didCancelOperationFile:))) {
        [self.delegate viewcontroller:self didCancelOperationFile:self.fileItem];
    }
    [[NXLoginUser sharedInstance].myRepoSystem cancelOperation:self.myRepoSysUploadOptIdentify];
    [[NXLoginUser sharedInstance].myVault cancelOperation:self.myVaultUploadOptIdentify];
    [[NXLoginUser sharedInstance].nxlOptManager cancelNXLOpt:self.encryptFileOptIdentify];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)protectButtonClicked:(id)sender {
    self.protectButton.enabled = NO;
    //1 have cache or not
    if (!self.fileItem.localPath) {
        self.protectButton.enabled = YES;
        return;
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.fileItem.localPath]) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_FILE_NOT_EXISTED", NULL) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
        self.protectButton.enabled = YES;
        return;
    }
    
    if (!self.selectedRights.getVaildateDateModel) {
                  [self.selectedRights setFileValidateDate:[NXLoginUser sharedInstance].userPreferenceManager.userPreference.preferenceFileValidateDate];
       }
    
    if (![NXCommonUtils checkIsLegalFileValidityDate:[self.selectedRights getVaildateDateModel]]) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_FILE_EXPIRETIME_INVALID", NULL) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
        self.protectButton.enabled = YES;
        return;
    }
    
//    WeakObj(self);
//    if (self.fileItem.sorceType == NXFileBaseSorceTypeLocal) {
//        if (!self.folder) {
//            [NXMBManager showMessage:NSLocalizedString(@"MSG_SELECT_FOLDER", NULL) hideAnimated:YES afterDelay:kDelay];
//            return;
//        }
//
//        NSArray *children = [[NXLoginUser sharedInstance].myRepoSystem childForFileItem:self.folder];
//        for (NXFileBase *item in children) {
//            if ([self.fileItem.name caseInsensitiveCompare:item.name] == NSOrderedSame) {
//                [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_NAME_ALREADY_EXISTED", NULL) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
//                self.protectButton.enabled = YES;
//                return;
//            }
//        }
//
//        [NXMBManager showLoading:NSLocalizedString(@"MSG_UPLOADING", NULL) toView:self.mainView];
//        self.myRepoSysUploadOptIdentify = [[NXLoginUser sharedInstance].myRepoSystem uploadFile:self.fileItem.name toPath:self.folder fromPath:self.fileItem.localPath uploadType:NXRepositorySysManagerUploadTypeNormal overWriteFile:nil progress:nil completion:^(NXFileBase *fileItem, NXFileBase *parentFolder, NSError *error) {
//            StrongObj(self);
//            dispatch_main_sync_safe(^{
//                [NXMBManager hideHUDForView:self.mainView];
//                if (error) {
//                    [NXMBManager showMessage:error.localizedDescription ?error.localizedDescription :   NSLocalizedString(@"MSG_UPLOAD_FAILED", NULL) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
//                    self.protectButton.enabled = YES;
//                } else {
//                    [self protectAction];
//                }
//            });
//        }];
//    } else {
        [self protectAction];
//    }
}

- (void)protectAction {
    
    [NXMBManager showLoading:NSLocalizedString(@"MSG_COM_PROTECT_AND_UPLOADING", NULL) toView:self.mainView];
    WeakObj(self);
    
    NSArray *allMyvaltFileInDB = [[NXLoginUser sharedInstance].myVault getAllMyVaultFileInCoreData];
       if (allMyvaltFileInDB.count > 0) {
           for (NXMyVaultFile *myvaultFile in allMyvaltFileInDB) {
               if ([[myvaultFile.name stringByDeletingPathExtension] isEqualToString:self.fileItem.name]) {
                   dispatch_main_sync_safe((^{
                       NSString *message = [NSString stringWithFormat:NSLocalizedString(@"ALERTVIEW_MESSAGE_OVERWRITE", NULL), myvaultFile.name];
                       
                       if (myvaultFile.sharedWith.count > 0) {
                           NSString *member = @"";
                           for (NSString *email in myvaultFile.sharedWith) {
                              member = [member stringByAppendingFormat:@"%@,",email];
                           }
                           message = [NSString stringWithFormat:NSLocalizedString(@"ALERTVIEW_MESSAGE_OVERWRITE_SHARE_CASE", NULL),myvaultFile.name,member];
                       }
                       
                       [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_REPLACE", NULL) cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherTitle:NSLocalizedString(@"UI_BOX_NO_REPLACE", NULL) OKActionHandle:^(UIAlertAction *action) {
                           StrongObj(self);
                           NXFileState state = [[NXOfflineFileManager sharedInstance] currentState:myvaultFile];
                           if (state != NXFileStateNormal)
                           {
                               [[NXOfflineFileManager sharedInstance] unmarkFileAsOffline:myvaultFile withCompletion:^(NXFileBase *fileItem, NSError *error) {
                               }];
                           }
                           [self protectOperation];
                       } cancelActionHandle:^(UIAlertAction *action) {
                           self.protectButton.enabled = YES;
                           [NXMBManager hideHUDForView:self.mainView];
                           [self closeButtonClicked:nil];
                       } otherActionHandle:^(UIAlertAction *action) {
                           //no replace
                           NSMutableArray *currentFolderFilesNameArray = [[NSMutableArray alloc] init];
                           for (NXWorkSpaceFile *file in allMyvaltFileInDB) {
                               if (file.name.length > 0) {
                                   [currentFolderFilesNameArray addObject:file.name];
                               }
                           }
                           NSUInteger index = 2;
                           NSUInteger MaxIndex = [NXCommonUtils getMaxIndexForFile:self.fileItem.name fileNameArray:currentFolderFilesNameArray];
                           NSString *newFileName = self.fileItem.name;
                           if (MaxIndex == 0) {
                               newFileName = [NXCommonUtils addIndexForFile:index fileName:newFileName];
                           }else{
                               MaxIndex += 1;
                               newFileName = [NXCommonUtils addIndexForFile:MaxIndex fileName:newFileName];
                           }
                           self.currentFileOrginalName = self.fileItem.name;
                           self.fileItem.name = newFileName;
                           [self protectOperation];
                       } inViewController:self position:self.view];
                   }));
                   return;
               }
           }
    }
    
    [self protectOperation];
  
}

- (void)protectOperation{
      WeakObj(self);
    NXFile *fakeFile = [self.fileItem copy];
    fakeFile.fullServicePath = [NSString stringWithFormat:@"/%@",self.fileItem.name];
    fakeFile.fullPath = [NSString stringWithFormat:@"/%@",self.fileItem.name];
    self.encryptFileOptIdentify = [[NXLoginUser sharedInstance].nxlOptManager protectToNXLFile:self.fileItem toPath:[NXCommonUtils createNewNxlTempFile:self.fileItem.name] permissions:self.selectedRights membershipId:nil createDate:[NXTimeServerManager sharedInstance].currentServerTime withCompletion:^(NSString *filePath, NSError *error) {
          dispatch_main_async_safe(^{
              StrongObj(self);
              [NXMBManager hideHUDForView:self.mainView];
              if (error) {
                  [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_ENCRYPT_FILE_FAILED", NULL) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
                  self.protectButton.enabled = YES;
              } else {
                  if (error) {
                      [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_PROTECT_FILE_FAILED", NULL) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
                      if (self.currentFileOrginalName) {
                          self.fileItem.name = self.currentFileOrginalName;
                      }
                      self.protectButton.enabled = YES;
                  }else{
                      if (DELEGATE_HAS_METHOD(self.delegate, @selector(viewcontroller:didfinishedOperationFile:toFile:))) {
                          [self.delegate viewcontroller:self didfinishedOperationFile:self.fileItem toFile:self.fileItem];
                      }
                      
                      if (self.fileItem.sorceType == NXFileBaseSorceTypeLocal) {
                          [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                      } else {
                          [self.navigationController popViewControllerAnimated:YES];
                      }
                      
                      [NXMessageViewManager showMessageViewWithTitle:self.fileItem.name details:NSLocalizedString(@"MSG_COM_SUCCESS_PROTECT", NULL) appendInfo:nil appendInfo2:NSLocalizedString(@"MSG_COM_FILE_HAS_BEEN_SAVED_TO_MYVAULT", NULL) image:[UIImage imageNamed:@"Success - White tick"] dismissAfter:kDelay*2 type:NXMessageViewManagerTypeGreen];
                  }
              }
          });
      }];
}

#pragma mark
- (void)initData {
    if (!self.fileItem) {
        return;
    }
    
    if (self.fileItem.localPath || [self.fileItem isKindOfClass:[NXMyVaultFile class]] || [self.fileItem isKindOfClass:[NXProjectFile   class]]) {
        [self updateData:self.fileItem];
    } else {
        self.progressView = [NXMBManager showLoading:NSLocalizedString(@"MSG_COM_DOWNLOADING", NULL) progress:0 mode:NXMBProgressModeDeterminateHorizontalBar toView:self.mainView];
        
        WeakObj(self);
        NXWebFileDownloaderProgressBlock progressBlock = ^(int64_t receivedSize, int64_t totalCount, double fractionCompleted){
            StrongObj(self);
            self.progressView.progress = fractionCompleted;
        };
        self.downloadId = [[NXWebFileManager sharedInstance] downloadFile:(NXFileBase<NXWebFileDownloadItemProtocol>*)self.fileItem withProgress:progressBlock completed:^(NXFileBase *file, NSData *fileData, NSError *error) {
            StrongObj(self);
            if (self) {
                [NXMBManager hideHUDForView:self.mainView];
                [self.progressView hide];
                if (error) {
                    [NXMBManager showMessage:error.localizedDescription toView:self.mainView hideAnimated:YES afterDelay:kDelay];
                    self.protectButton.enabled = NO;
                    return;
                }
                self.fileItem = file;
                [self updateData:self.fileItem];
            }
        }];
    }
}

- (void)updateData:(NXFileBase *)localFile {
    self.topView.model = localFile;
    BOOL ret = [[NXLoginUser sharedInstance].nxlOptManager isNXLFile:localFile];
    if (ret) {
        self.protectButton.enabled = NO;
        [NXMBManager showLoading:NSLocalizedString(@"MSG_COM_GETTING_RIGHTS", NULL) toView:self.mainView];
        [[NXLoginUser sharedInstance].nxlOptManager getNXLFileRights:localFile withWatermark:NO withCompletion:^(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray *watermark, NSString *owner, BOOL isOwner, NSError *error) {
            dispatch_main_async_safe(^{
                [NXMBManager hideHUDForView:self.mainView];
                if (error) {
                    [NXMBManager showMessage:error.localizedDescription toView:self.mainView hideAnimated:YES afterDelay:kDelay];
                }
                [self updateUI:self.fileItem nxl:YES rights:rights isSteward:isOwner];
            });
        }];
    } else {
        [self updateUI:self.fileItem nxl:NO rights:nil isSteward:NO];
    }
}

- (void)updateUI:(NXFileBase *)fileItem nxl:(BOOL)isNXL rights:(NXLRights *)rights isSteward:(BOOL)isSteward{
    if (isNXL) {
        self.rightsDisplayView.rights = rights;
        self.selectedRights = rights;
        
        [self.rightsDisplayView showSteward:isSteward];
        [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_NO_PROTECT_NXL_FILE", NULL) toView:self.mainView hideAnimated:YES afterDelay:kDelay];
        
        [self.mainView addSubview:self.rightsDisplayView];
        [self.rightsDisplayView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mainView).offset(kMargin);
            make.left.equalTo(self.view).offset(kMargin);
            make.right.equalTo(self.view).offset(-kMargin);
        }];
        
        self.protectButton.enabled = NO;
    } else {
        NXLRights *rights = [[NXLRights alloc] init];
        [rights setRight:NXLRIGHTVIEW value:YES];
        [rights setFileValidateDate:[NXLoginUser sharedInstance].userPreferenceManager.userPreference.preferenceFileValidateDate];
        self.rightsSelectView.rights = rights;
        self.rightsSelectView.enabled = YES;
        self.selectedRights = rights;
        self.protectButton.enabled = YES;
        
        [self.mainView addSubview:self.rightsSelectView];
        [self.rightsSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mainView).offset(kMargin);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
        }];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.mainView layoutIfNeeded];
    }];
}

#pragma mark - NXRightsSelectViewDelegate

- (void)rightsSelectView:(NXRightsSelectView *)selectView didRightsSelected:(NXLRights *)rights {
 if (self.selectedRights.getVaildateDateModel) {
      [rights setFileValidateDate:self.selectedRights.getVaildateDateModel];
  }
  self.selectedRights = rights;
}

- (void)rightsSelectView:(NXRightsSelectView *)selectView didHeightChanged:(CGFloat)height {
    [self viewDidLayoutSubviews];
}

#pragma mark -
- (void)commonInit {
    self.topView.model = self.fileItem;
    self.topView.operationTitle = NSLocalizedString(@"UI_CREATE_A_PROTECTED_FILE", NULL);
    
    WeakObj(self);
    self.topView.backClickAction = ^(id sender) {
        StrongObj(self);
        [self closeButtonClicked:nil];
    };
    
    [self.protectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.bottomView);
        make.width.equalTo(@300);
        make.height.lessThanOrEqualTo(self.bottomView).multipliedBy(0.7);
        make.height.lessThanOrEqualTo(@(40));
    }];
    
#if 0
    self.mainView.backgroundColor = [UIColor redColor];
    self.rightsSelectView.backgroundColor = [UIColor greenColor];
    self.bottomView.backgroundColor = [UIColor orangeColor];
#endif
}

- (NXRightsSelectView *)rightsSelectView {
    if (!_rightsSelectView) {
        NXRightsSelectView *rightsSelectView = [[NXRightsSelectView alloc] init];
        rightsSelectView.delegate = self;
        WeakObj(self);
        rightsSelectView.fileValidityChagedBlock = ^(NXLFileValidateDateModel *model) {
            StrongObj(self);
            [self.selectedRights setFileValidateDate:model];
        };
        _rightsSelectView = rightsSelectView;
    }
    return _rightsSelectView;
}

- (NXRightsDisplayView *)displayView {
    if (!_rightsDisplayView) {
        NXRightsDisplayView *displayView = [[NXRightsDisplayView alloc]  init];
        _rightsDisplayView = displayView;
    }
    return _rightsDisplayView;
}

- (UIButton *)protectButton {
    if (!_protectButton) {
        UIButton *protectButton = [[UIButton alloc] init];
        [self.bottomView addSubview:protectButton];
        protectButton.enabled = NO;
        [protectButton setTitle:NSLocalizedString(@"UI_CREATE_A_PROTECTED_FILE", NULL) forState:UIControlStateNormal];
        protectButton.accessibilityValue = @"PROTECT_BTN";
        [protectButton addTarget:self action:@selector(protectButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [protectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [protectButton setBackgroundImage:[UIImage imageWithSize:CGSizeMake(200, 200) colors:@[RMC_GRADIENT_START_COLOR, RMC_GRADIENT_END_COLOR] gradientType:GradientTypeLeftToRight] forState:UIControlStateNormal];
        [protectButton cornerRadian:3];
        _protectButton = protectButton;
    }
    return _protectButton;
}


@end
