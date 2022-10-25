//
//  NXAddToProjectLastVC.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/4/2.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXAddToProjectLastVC.h"
#import "NXPreviewFileView.h"
#import "NXProjectFolder.h"
#import "NXDocumentClassificationView.h"
#import "NXRightsDisplayView.h"
#import "Masonry.h"
#import "NXProjectModel.h"
#import "NXMBManager.h"
#import "NXLoginUser.h"
#import "NXMessageViewManager.h"
#import "NXMBManager.h"
#import "NXWorkSpaceReclassifyFileAPI.h"
#import "NXUserDefinedPermissionView.h"
#import "NXProtectedFileListView.h"
#import "NXAddFileSavePathView.h"
#define OTHER_HEIGHT 100

@interface NXAddToProjectLastVC ()
@property (nonatomic, strong) NXRightsDisplayView *rightsDisplayView;
@property (nonatomic, strong) NXDocumentClassificationView *classificationView;
@property (nonatomic, strong) NXUserDefinedPermissionView *userDefinedView;
@property (nonatomic, assign) BOOL isFromProjectAndAdmin;

@end

@implementation NXAddToProjectLastVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.isFromDefaultPath) {
        [self checkRightsFromTheFile:self.currentFile];
    }else{
        [self commonInitUI];
        [self checkRightsFromClassifications];
    }
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    if (self.isFromDefaultPath) {
//        [self checkRightsFromTheFile:self.currentFile];
//    }else{
//        [self checkRightsFromClassifications];
//    }
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self setScrollViewContentSize];
}
- (void)checkRightsFromTheFile:(NXFileBase *)fileItem {
    if (self.fileOperationType == NXFileOperationTypeAddProjectFileToProject || self.fileOperationType == NXFileOperationTypeAddProjectFileToWorkSpace || [fileItem isKindOfClass:[NXProjectFile class]]) {
        if ([[NXLoginUser sharedInstance] isProjectAdmin]) {
            self.isFromProjectAndAdmin = YES;
        }
    }
    [NXMBManager showLoading];
    [[NXLoginUser sharedInstance].nxlOptManager getNXLFileRights:fileItem withWatermark:YES withCompletion:^(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray<NXWatermarkWord *> *waterMarkWords, NSString *owner, BOOL isOwner, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NXMBManager hideHUD];
            NSString *errorMessage = nil;
            if (!error) {
                self.fileRights = rights;
                if (classifications) {
                    self.currentClassifiations = classifications;
                    self.isAdhocEncrypted = NO;
                }else{
                    self.isAdhocEncrypted = YES;
                }
                if (self.fileOperationType == NXFileOperationTypeAddProjectFileToProject || self.fileOperationType == NXFileOperationTypeAddProjectFileToWorkSpace || [fileItem isKindOfClass:[NXProjectFile class]]) {
                    if ([rights DecryptRight] || self.isFromProjectAndAdmin) {
                       
                    }else{
                        errorMessage = NSLocalizedString(@"MSG_NO_ACCESS_RIGHT",NULL);
                    }
                }else{
                
                }
                
            }else{
                errorMessage = error.localizedDescription;
            }
            if (errorMessage) {
                [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:errorMessage  style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_OK", NULL) cancelActionTitle:nil OKActionHandle:^(UIAlertAction *action) {
                    [self dismissSelf];
                } cancelActionHandle:nil inViewController:self position:self.view];
            }else{
                [self commonInitUI];
                [self checkRightsFromClassifications];
            }
        });
        
    }];
}
- (void)checkRightsFromClassifications{
    [NXMBManager showLoading];
    if (self.isAdhocEncrypted) {
        [NXMBManager hideHUD];
        [self.classificationView removeFromSuperview];
        self.classificationView = nil;
        self.userDefinedView.hidden = NO;
        self.rightsDisplayView.hidden = NO;
        self.rightsDisplayView.rights = self.fileRights;
        [self.rightsDisplayView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.userDefinedView.mas_bottom);
        }];
        return;
    }
    NSString *memberShip = nil;
    if (self.fileOperationType == NXFileOperationTypeWorkSpaceFileReclassify || self.fileOperationType == NXFileOperationTypeAddNXLFileToWorkSpace || self.fileOperationType == NXFileOperationTypeAddFileToSharedWorkspace || self.fileOperationType == NXFileOperationTypeAddNXLFileToRepo) {
        memberShip = [NXLoginUser sharedInstance].profile.tenantMembership.ID;
    }else{
        memberShip = self.toProject.membershipId;
    }
    if (self.fileOperationType == NXFileOperationTypeProjectFileReclassify || self.fileOperationType == NXFileOperationTypeWorkSpaceFileReclassify) {
        [[NXLoginUser sharedInstance].nxlOptManager checkCenterPolicyFileRightsWithMemberShip:memberShip classifications:self.currentClassifiations fileName:self.currentFile.name withCompletion:^(NXLRights *rights, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [NXMBManager hideHUD];
                if (!error) {
                    self.rightsDisplayView.hidden = NO;
                    self.rightsDisplayView.rights = rights;
                    self.fileRights = rights;
                    [self.view setNeedsLayout];
                    [self.view layoutIfNeeded];
                }else{
                     [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:1.5];
                }
            });
        
        }];
        return;
    }
    if (self.currentClassifiations) {
        self.userDefinedView.hidden = YES;
        if (!self.toProject.membershipId && !memberShip && self.toProject) {
               [[NXLoginUser sharedInstance].myProject getMemberShipID:self.toProject withCompletion:^(NXProjectModel *projectModel, NSError *error) {
                   if (!error && projectModel.membershipId) {
                       [[NXLoginUser sharedInstance].nxlOptManager checkCenterPolicyFileRightsForNXLFile:self.currentFile copyToDestPathFolder:self.folder withDestMemberShip:memberShip withCompletion:^(NXLRights *rights, NSError *error) {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               [NXMBManager hideHUD];
                               if (!error) {
                                   self.rightsDisplayView.hidden = NO;
                                   self.rightsDisplayView.rights = rights;
                                   [self.view setNeedsLayout];
                                   [self.view layoutIfNeeded];
                               }else{
                                    [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:1.5];
                               }
                           });
                       }];
//                           [[NXLoginUser sharedInstance].nxlOptManager checkCenterPolicyFileRightsWithMemberShip: projectModel.membershipId classifications:self.currentClassifiations fileName:self.currentFile.name withCompletion:^(NXLRights *rights, NSError *error) {
//                               dispatch_async(dispatch_get_main_queue(), ^{
//                                   [NXMBManager hideHUD];
//                                   if (!error) {
//                                       self.rightsDisplayView.hidden = NO;
//                                       self.rightsDisplayView.rights = rights;
//                                       [self.view setNeedsLayout];
//                                       [self.view layoutIfNeeded];
//                                   }else{
//                                        [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:1.5];
//                                   }
//                               });
//
//                           }];
                           
                    
                       
                   }else{
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [NXMBManager hideHUD];
                           [NXMBManager showMessage:error.localizedDescription?:NSLocalizedString(@"MSG_COM_PROTECT_FILE_FAILED", NULL) hideAnimated:YES afterDelay:1.5];
                       });
                   }
               }];
        }else if(memberShip){
            [[NXLoginUser sharedInstance].nxlOptManager checkCenterPolicyFileRightsForNXLFile:self.currentFile copyToDestPathFolder:self.folder withDestMemberShip:memberShip withCompletion:^(NXLRights *rights, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NXMBManager hideHUD];
                    if (!error) {
                        self.rightsDisplayView.hidden = NO;
                        self.rightsDisplayView.rights = rights;
                        [self.view setNeedsLayout];
                        [self.view layoutIfNeeded];
                    }else{
                         [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:1.5];
                    }
                });
            }];
//            [[NXLoginUser sharedInstance].nxlOptManager checkCenterPolicyFileRightsWithMemberShip:memberShip classifications:self.currentClassifiations fileName:self.currentFile.name withCompletion:^(NXLRights *rights, NSError *error) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [NXMBManager hideHUD];
//                    if (!error) {
//                        self.rightsDisplayView.hidden = NO;
//                        self.rightsDisplayView.rights = rights;
//                        self.fileRights = rights;
//                        [self.view setNeedsLayout];
//                        [self.view layoutIfNeeded];
//                    }else{
//                         [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:1.5];
//                    }
//                });
//
//            }];
        }
        
       
        
    }
   
}
- (void)commonInitUI {
   
   
//    [locationView addShadow:UIViewShadowPositionBottom color:[UIColor groupTableViewBackgroundColor]];
//    locationView.changeSaveLocationCompletion = ^{
//      // change save location
//        [self changeSaveLocationion];
//    };
//    NXFile *previewFile = [[NXFile alloc]init];
//    previewFile.name = self.currentFile.name;
//    self.preview.fileItem = previewFile;
//    if (self.fileOperationType == NXFileOperationTypeAddNXLFileToWorkSpace) {
//        self.preview.savedPath = [NSString stringWithFormat:@"%@:%@",@"WorkSpace", self.folder.fullPath?:@""];
//    }else if(self.fileOperationType == NXFileOperationTypeAddFileToSharedWorkspace){
//        self.preview.savedPath = [NSString stringWithFormat:@"%@:%@",self.toRepoModel.service_alias, self.folder.fullPath?:@""];
//    }
//    else{
//        self.preview.savedPath = [NSString stringWithFormat:@"%@:%@", self.toProject.displayName?:@"", self.folder.fullPath?:@""];
//    }
    [self.bottomBtn setTitle:NSLocalizedString(@"UI_BUTTON_ADD_FILE", NULL) forState:UIControlStateNormal];
    self.bottomBtn.enabled = YES;
    if (self.fileOperationType == NXFileOperationTypeWorkSpaceFileReclassify || self.fileOperationType == NXFileOperationTypeProjectFileReclassify) {
        self.preview.enabled = NO;
        NSString *parentPath = [self.currentFile.fullServicePath stringByDeletingLastPathComponent];
        if (![parentPath isEqualToString:@"/"]) {
           parentPath = [parentPath stringByAppendingString:@"/"];
        }
        self.preview.savedPath = parentPath;
        [self.bottomBtn setTitle:NSLocalizedString(@"UI_BUTTON_MODIFY_RIGHTS", NULL) forState:UIControlStateNormal];
        self.navigationItem.title = NSLocalizedString(@"UI_RECLASSIFY", NULL);
    }else{
        self.navigationItem.title = NSLocalizedString(@"UI_ADD_PROTECTED_FILE", NULL);
    }
   
//    UILabel *messageLabel = [[UILabel alloc]init];
//    messageLabel.numberOfLines = 0;
//    [self.specifyView addSubview:messageLabel];
//    if (self.fileOperationType == NXFileOperationTypeWorkSpaceFileReclassify || self.fileOperationType == NXFileOperationTypeAddNXLFileToWorkSpace) {
//       messageLabel.attributedText = [self createAttributeString:@"Permissions granted for WorkSpace " subTitle1:@""];
//    }else if(self.fileOperationType == NXFileOperationTypeAddFileToSharedWorkspace){
//        messageLabel.attributedText = [self createAttributeString:@"Permissions granted for Repository " subTitle1:@""];
//    }
//    else{
//         messageLabel.attributedText = [self createAttributeString:@"Permissions granted for the project " subTitle1:self.toProject.displayName];
//    }
   
    NXDocumentClassificationView *classificationView = [[NXDocumentClassificationView alloc]init];
    classificationView.documentClassicationsArray = self.currentClassifiations;
    [self.specifyView addSubview:classificationView];
    self.classificationView = classificationView;
    NXRightsDisplayView *rightsDisplayView = [[NXRightsDisplayView alloc]init];
//    rightsDisplayView.isNeedTitle = NO;
    
    rightsDisplayView.hidden = YES;
    rightsDisplayView.noRightsMessage = NSLocalizedString(@"MSG_NO_PERMISSIONS_DETERMINED", NULL);
    [self.specifyView addSubview:rightsDisplayView];
    self.rightsDisplayView = rightsDisplayView;

    NXUserDefinedPermissionView *userDefinedView = [[NXUserDefinedPermissionView alloc] init];
    [self.specifyView addSubview:userDefinedView];
    self.userDefinedView = userDefinedView;
    userDefinedView.hidden = YES;
//    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.specifyView).offset(kMargin);
//        make.left.equalTo(self.specifyView).offset(10);
//        make.right.equalTo(self.specifyView).offset(-kMargin);
//    }];
    
    [classificationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.specifyView).offset(kMargin);
        make.left.equalTo(self.specifyView).offset(10);
        make.right.equalTo(self.specifyView).offset(-kMargin);
        make.height.greaterThanOrEqualTo(@60);
    }];
    [userDefinedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.specifyView).offset(kMargin);
        make.left.equalTo(self.specifyView).offset(10);
        make.right.equalTo(self.specifyView).offset(-kMargin);
        make.height.greaterThanOrEqualTo(@120);
    }];
    [rightsDisplayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(classificationView.mas_bottom);
        make.left.equalTo(self.specifyView).offset(10);
        make.right.equalTo(self.specifyView).offset(-kMargin);
        make.height.greaterThanOrEqualTo(@200);
    }];
}
#pragma mark -------> add file button click
- (void)nextOperation:(id)sender {
    self.bottomBtn.enabled = NO;
    [NXMBManager showLoadingToView:self.view];
    switch (self.fileOperationType) {
        case NXFileOperationTypeWorkSpaceFileReclassify:
        {
            [self reclassifyWorkSpaceFile];
        }
            break;
        case NXFileOperationTypeProjectFileReclassify:
        {
            [self reclassifyProjectFile];
           }
            break;
        case NXFileOperationTypeAddNXLFileToProject:
        case NXFileOperationTypeAddProjectFileToProject:
        {
            [self checkforduplicateNameForProject];
        }
            break;
        case NXFileOperationTypeAddNXLFileToWorkSpace:
        {
            [self checkforduplicateNameForWorkSpace];
        }
            break;
        case NXFileOperationTypeAddFileToSharedWorkspace:
        {
            [self checkforduplicateNameForSharedWorkSpace];
        }
            break;
        case NXFileOperationTypeAddNXLFileToRepo:
        {
            [self checkforduplicateNameForRepository];
        }
            break;
        case NXFileOperationTypeAddNXLFileToMySpace:
        {
            [self checkforduplicateNameForMySpace];
        }
            break;
        default:
            [NXMBManager hideHUDForView:self.view];
            self.bottomBtn.enabled = NO;
            break;
    }
}
- (void)checkforduplicateNameForMySpace{
   
        NSArray *currentFolderFiles = [[NXLoginUser sharedInstance].myVault getAllMyVaultFileInCoreData];;
        if (currentFolderFiles.count > 0) {
            for (NXMyVaultFile *myvaultFile in currentFolderFiles) {
                if ([myvaultFile.name isEqualToString:self.currentFile.name]) {
                    dispatch_main_sync_safe((^{
                        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MSG_REPLACEANDKEEPBOTH_SELECT_MESSAGE", NULL), self.currentFile.name];
                        [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_REPLACE", NULL) cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherTitle:NSLocalizedString(@"UI_BOX_NO_REPLACE", NULL) OKActionHandle:^(UIAlertAction *action) {
                            [self addNxlFileTomySpace:self.currentFile shouldRename:NO newName:nil];
                        } cancelActionHandle:^(UIAlertAction *action) {
                            [NXMBManager hideHUDForView:self.view];
                            self.bottomBtn.enabled = YES;
                            [self dismissSelf];
                        } otherActionHandle:^(UIAlertAction *action) {
                           //no replace
                            NSMutableArray *currentFolderFilesNameArray = [[NSMutableArray alloc] init];
                            for (NXMyVaultFile *file in currentFolderFiles) {
                                if (file.name.length > 0) {
                                    [currentFolderFilesNameArray addObject:file.name];
                                }
                            }
                            NSUInteger index = 2;
                            NSUInteger MaxIndex = [NXCommonUtils getMaxIndexForFile:self.currentFile.name fileNameArray:currentFolderFilesNameArray];
                            NSString *newFileName = self.currentFile.name;
                            if (MaxIndex == 0) {
                                newFileName = [NXCommonUtils addIndexForFile:index fileName:newFileName];
                            }else{
                                MaxIndex += 1;
                                newFileName = [NXCommonUtils addIndexForFile:MaxIndex fileName:newFileName];
                            }
                           
                           
                            [self addNxlFileTomySpace:self.currentFile shouldRename:YES newName:newFileName];
                        } inViewController:self position:self.view];
                    }));
                    return;
                }
            }
        }
        [self addNxlFileTomySpace:self.currentFile shouldRename:NO newName:nil];

}
- (void)checkforduplicateNameForRepository{
   
        NSArray *currentFolderFiles = [[NXLoginUser sharedInstance].myRepoSystem childForFileItem:self.folder];;
        if (currentFolderFiles.count > 0) {
            for (NXWorkSpaceFile *workSpacefile in currentFolderFiles) {
                if ([workSpacefile.name isEqualToString:self.currentFile.name]) {
                    dispatch_main_sync_safe((^{
                        
                        if ([self isHaveOverwritePerssion:self.currentFile]) {
                            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MSG_REPLACEANDKEEPBOTH_SELECT_MESSAGE", NULL), self.currentFile.name];
                            [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_REPLACE", NULL) cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherTitle:NSLocalizedString(@"UI_BOX_NO_REPLACE", NULL) OKActionHandle:^(UIAlertAction *action) {

                                [self addNxlFileToRepository:self.currentFile shouldRename:NO newName:nil];
                               
                            } cancelActionHandle:^(UIAlertAction *action) {
                                [NXMBManager hideHUDForView:self.view];
                                self.bottomBtn.enabled = YES;
                                [self dismissSelf];
                            } otherActionHandle:^(UIAlertAction *action) {
                               //no replace
                                NSMutableArray *currentFolderFilesNameArray = [[NSMutableArray alloc] init];
                                for (NXWorkSpaceFile *file in currentFolderFiles) {
                                    if (file.name.length > 0) {
                                        [currentFolderFilesNameArray addObject:file.name];
                                    }
                                }
                                NSUInteger index = 2;
                                NSUInteger MaxIndex = [NXCommonUtils getMaxIndexForFile:self.currentFile.name fileNameArray:currentFolderFilesNameArray];
                                NSString *newFileName = self.currentFile.name;
                                if (MaxIndex == 0) {
                                    newFileName = [NXCommonUtils addIndexForFile:index fileName:newFileName];
                                }else{
                                    MaxIndex += 1;
                                    newFileName = [NXCommonUtils addIndexForFile:MaxIndex fileName:newFileName];
                                }
                              
                               
                                [self addNxlFileToRepository:self.currentFile shouldRename:YES newName:newFileName];
                            } inViewController:self position:self.view];
                        }else{
                            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MSG_KEEPBOTH_SELECT_MESSAGE", NULL), self.currentFile.name];
                            [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message style:UIAlertControllerStyleAlert OKActionTitle:nil cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherTitle:NSLocalizedString(@"UI_BOX_NO_REPLACE", NULL) OKActionHandle:^(UIAlertAction *action) {

                                                   } cancelActionHandle:^(UIAlertAction *action) {
                                                       [NXMBManager hideHUDForView:self.view];
                                                       self.bottomBtn.enabled = YES;
                                                       [self dismissSelf];
                                                      
                                                   } otherActionHandle:^(UIAlertAction *action) {
                                                       NSMutableArray *currentFolderFilesNameArray = [[NSMutableArray alloc] init];
                                                       for (NXWorkSpaceFile *file in currentFolderFiles) {
                                                           if (file.name.length > 0) {
                                                               [currentFolderFilesNameArray addObject:file.name];
                                                           }
                                                       }
                                                       NSUInteger index = 2;
                                                       NSUInteger MaxIndex = [NXCommonUtils getMaxIndexForFile:self.currentFile.name fileNameArray:currentFolderFilesNameArray];
                                                       NSString *newFileName = self.currentFile.name;
                                                       if (MaxIndex == 0) {
                                                           newFileName = [NXCommonUtils addIndexForFile:index fileName:newFileName];
                                                       }else{
                                                           MaxIndex += 1;
                                                           newFileName = [NXCommonUtils addIndexForFile:MaxIndex fileName:newFileName];
                                                       }
                                                     
                                                      
                                                       [self addNxlFileToRepository:self.currentFile shouldRename:YES newName:newFileName];
                                                   } inViewController:self position:self.view];
                            
                        }
                        
                        return;
                    }));
                    return;
                }
            }
        }
        [self addNxlFileToRepository:self.currentFile shouldRename:NO newName:nil];
   
}

- (void)checkforduplicateNameForSharedWorkSpace{
   
        NSArray *currentFolderFiles = [[NXLoginUser sharedInstance].myRepoSystem childForFileItem:self.folder];;
        if (currentFolderFiles.count > 0) {
            for (NXWorkSpaceFile *workSpacefile in currentFolderFiles) {
                if ([workSpacefile.name isEqualToString:self.currentFile.name]) {
                    dispatch_main_sync_safe((^{
                        if ([self isHaveOverwritePerssion:self.currentFile]) {
                            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MSG_REPLACEANDKEEPBOTH_SELECT_MESSAGE", NULL), self.currentFile.name];
                            [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_REPLACE", NULL) cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherTitle:NSLocalizedString(@"UI_BOX_NO_REPLACE", NULL) OKActionHandle:^(UIAlertAction *action) {
                              
                                [self addNxlFileToSharedWorkspace:self.currentFile shouldRename:NO newName:nil];

                            } cancelActionHandle:^(UIAlertAction *action) {
                                [NXMBManager hideHUDForView:self.view];
                                self.bottomBtn.enabled = YES;
                                [self dismissSelf];
                            } otherActionHandle:^(UIAlertAction *action) {
                               //no replace
                                NSMutableArray *currentFolderFilesNameArray = [[NSMutableArray alloc] init];
                                for (NXWorkSpaceFile *file in currentFolderFiles) {
                                    if (file.name.length > 0) {
                                        [currentFolderFilesNameArray addObject:file.name];
                                    }
                                }
                                NSUInteger index = 2;
                                NSUInteger MaxIndex = [NXCommonUtils getMaxIndexForFile:self.currentFile.name fileNameArray:currentFolderFilesNameArray];
                                NSString *newFileName = self.currentFile.name;
                                if (MaxIndex == 0) {
                                    newFileName = [NXCommonUtils addIndexForFile:index fileName:newFileName];
                                }else{
                                    MaxIndex += 1;
                                    newFileName = [NXCommonUtils addIndexForFile:MaxIndex fileName:newFileName];
                                }
                               
                                [self addNxlFileToSharedWorkspace:self.currentFile shouldRename:YES newName:newFileName];
                            } inViewController:self position:self.view];
                            
                        }else{
                            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MSG_KEEPBOTH_SELECT_MESSAGE", NULL), self.currentFile.name];
                            [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message style:UIAlertControllerStyleAlert OKActionTitle:nil cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherTitle:NSLocalizedString(@"UI_BOX_NO_REPLACE", NULL) OKActionHandle:^(UIAlertAction *action) {

                            } cancelActionHandle:^(UIAlertAction *action) {
                               [NXMBManager hideHUDForView:self.view];
                               self.bottomBtn.enabled = YES;
                               [self dismissSelf];
                              
                            } otherActionHandle:^(UIAlertAction *action) {
                               NSMutableArray *currentFolderFilesNameArray = [[NSMutableArray alloc] init];
                               for (NXWorkSpaceFile *file in currentFolderFiles) {
                                   if (file.name.length > 0) {
                                       [currentFolderFilesNameArray addObject:file.name];
                                   }
                               }
                               NSUInteger index = 2;
                               NSUInteger MaxIndex = [NXCommonUtils getMaxIndexForFile:self.currentFile.name fileNameArray:currentFolderFilesNameArray];
                               NSString *newFileName = self.currentFile.name;
                               if (MaxIndex == 0) {
                                   newFileName = [NXCommonUtils addIndexForFile:index fileName:newFileName];
                               }else{
                                   MaxIndex += 1;
                                   newFileName = [NXCommonUtils addIndexForFile:MaxIndex fileName:newFileName];
                               }
                                  
                                   [self addNxlFileToSharedWorkspace:self.currentFile shouldRename:YES newName:newFileName];
                            } inViewController:self position:self.view];
                        }
                    }));
                    return;
                }
            }
        }
        [self addNxlFileToSharedWorkspace:self.currentFile shouldRename:NO newName:nil];
   
}
- (void)checkforduplicateNameForWorkSpace {
    
            NSArray *currentFolderFiles = [[NXLoginUser sharedInstance].workSpaceManager getWorkSpaceFileListUnderFolderInCoreData:(NXWorkSpaceFolder *)self.folder];
            if (currentFolderFiles.count > 0) {
                for (NXWorkSpaceFile *workSpacefile in currentFolderFiles) {
                    if ([workSpacefile.name isEqualToString:self.currentFile.name]) {
                        dispatch_main_sync_safe((^{
                            if ([self isHaveOverwritePerssion:self.currentFile]) {
                                NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MSG_REPLACEANDKEEPBOTH_SELECT_MESSAGE", NULL), self.currentFile.name];
                                [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_REPLACE", NULL) cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherTitle:NSLocalizedString(@"UI_BOX_NO_REPLACE", NULL) OKActionHandle:^(UIAlertAction *action) {

                                    [self addNxlFileToWorkSpace:self.currentFile shouldReName:NO newName:nil];
                                } cancelActionHandle:^(UIAlertAction *action) {
                                    [NXMBManager hideHUDForView:self.view];
                                    self.bottomBtn.enabled = YES;
                                    [self dismissSelf];
                                } otherActionHandle:^(UIAlertAction *action) {
                                   //no replace
                                    NSMutableArray *currentFolderFilesNameArray = [[NSMutableArray alloc] init];
                                    for (NXWorkSpaceFile *file in currentFolderFiles) {
                                        if (file.name.length > 0) {
                                            [currentFolderFilesNameArray addObject:file.name];
                                        }
                                    }
                                    NSUInteger index = 2;
                                    NSUInteger MaxIndex = [NXCommonUtils getMaxIndexForFile:self.currentFile.name fileNameArray:currentFolderFilesNameArray];
                                    NSString *newFileName = self.currentFile.name;
                                    if (MaxIndex == 0) {
                                        newFileName = [NXCommonUtils addIndexForFile:index fileName:newFileName];
                                    }else{
                                        MaxIndex += 1;
                                        newFileName = [NXCommonUtils addIndexForFile:MaxIndex fileName:newFileName];
                                    }
                                   
                                    [self addNxlFileToWorkSpace:self.currentFile shouldReName:YES newName:newFileName];
                                    
                                } inViewController:self position:self.view];
                                
                            }else{
                                NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MSG_KEEPBOTH_SELECT_MESSAGE", NULL), self.currentFile.name];
                                [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message style:UIAlertControllerStyleAlert OKActionTitle:nil cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherTitle:NSLocalizedString(@"UI_BOX_NO_REPLACE", NULL) OKActionHandle:^(UIAlertAction *action) {

                                } cancelActionHandle:^(UIAlertAction *action) {
                                   [NXMBManager hideHUDForView:self.view];
                                   self.bottomBtn.enabled = YES;
                                   [self dismissSelf];
                                  
                                } otherActionHandle:^(UIAlertAction *action) {
                                    NSMutableArray *currentFolderFilesNameArray = [[NSMutableArray alloc] init];
                                    for (NXWorkSpaceFile *file in currentFolderFiles) {
                                        if (file.name.length > 0) {
                                            [currentFolderFilesNameArray addObject:file.name];
                                        }
                                    }
                                    NSUInteger index = 2;
                                    NSUInteger MaxIndex = [NXCommonUtils getMaxIndexForFile:self.currentFile.name fileNameArray:currentFolderFilesNameArray];
                                    NSString *newFileName = self.currentFile.name;
                                    if (MaxIndex == 0) {
                                        newFileName = [NXCommonUtils addIndexForFile:index fileName:newFileName];
                                    }else{
                                        MaxIndex += 1;
                                        newFileName = [NXCommonUtils addIndexForFile:MaxIndex fileName:newFileName];
                                    }
                                
                                    [self addNxlFileToWorkSpace:self.currentFile shouldReName:YES newName:newFileName];
                                    
                                } inViewController:self position:self.view];
                                
                            }
                            
                          
                        }));
                        return;
                    }
                }
            }
            [self addNxlFileToWorkSpace:self.currentFile shouldReName:NO newName:nil];
       
}
- (void)checkforduplicateNameForProject {
        NSArray *currentFolderFiles = [[NXLoginUser sharedInstance].myProject getFileListUnderParentFolderInCoreData:(NXProjectFolder *)self.folder];
        if (currentFolderFiles.count > 0) {
            for (NXProjectFile *projectFile in currentFolderFiles) {
                if ([projectFile.name isEqualToString:self.currentFile.name]) {
                    dispatch_main_async_safe((^{
                        if ([self isHaveOverwritePerssion:self.currentFile]) {
                            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MSG_REPLACEANDKEEPBOTH_SELECT_MESSAGE", NULL), self.currentFile.name];
                            [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_REPLACE", NULL) cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherTitle:NSLocalizedString(@"UI_BOX_NO_REPLACE", NULL) OKActionHandle:^(UIAlertAction *action) {
                               
                                [self addNxlFileToProject:self.currentFile shouldReName:NO newName:nil];
                                
                            } cancelActionHandle:^(UIAlertAction *action) {
                                self.bottomBtn.enabled = YES;
                                [NXMBManager hideHUDForView:self.view];
                                [self dismissSelf];
                            } otherActionHandle:^(UIAlertAction *action) {
                                   //no replace
                                NSMutableArray *currentFolderFilesNameArray = [[NSMutableArray alloc] init];
                                for (NXProjectFile *file in currentFolderFiles) {
                                    if (file.name.length > 0) {
                                        [currentFolderFilesNameArray addObject:file.name];
                                    }
                                }
                                NSUInteger index = 2;
                                NSUInteger MaxIndex = [NXCommonUtils getMaxIndexForFile:self.currentFile.name fileNameArray:currentFolderFilesNameArray];
                                NSString *newFileName = self.currentFile.name;
                                if (MaxIndex == 0) {
                                    newFileName = [NXCommonUtils addIndexForFile:index fileName:newFileName];
                                }else{
                                    MaxIndex += 1;
                                    newFileName = [NXCommonUtils addIndexForFile:MaxIndex fileName:newFileName];
                                }
                               
                                [self addNxlFileToProject:self.currentFile shouldReName:YES newName:newFileName];
                                
                            } inViewController:self position:self.view];
                            
                        }else{
                            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MSG_KEEPBOTH_SELECT_MESSAGE", NULL), self.currentFile.name];
                            [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:message style:UIAlertControllerStyleAlert OKActionTitle:nil cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherTitle:NSLocalizedString(@"UI_BOX_NO_REPLACE", NULL) OKActionHandle:^(UIAlertAction *action) {

                            } cancelActionHandle:^(UIAlertAction *action) {
                               [NXMBManager hideHUDForView:self.view];
                               self.bottomBtn.enabled = YES;
                               [self dismissSelf];
                              
                            } otherActionHandle:^(UIAlertAction *action) {
                                NSMutableArray *currentFolderFilesNameArray = [[NSMutableArray alloc] init];
                                for (NXProjectFile *file in currentFolderFiles) {
                                    if (file.name.length > 0) {
                                        [currentFolderFilesNameArray addObject:file.name];
                                    }
                                }
                                NSUInteger index = 2;
                                NSUInteger MaxIndex = [NXCommonUtils getMaxIndexForFile:self.currentFile.name fileNameArray:currentFolderFilesNameArray];
                                NSString *newFileName = self.currentFile.name;
                                if (MaxIndex == 0) {
                                    newFileName = [NXCommonUtils addIndexForFile:index fileName:newFileName];
                                }else{
                                    MaxIndex += 1;
                                    newFileName = [NXCommonUtils addIndexForFile:MaxIndex fileName:newFileName];
                                }
                               
                                [self addNxlFileToProject:self.currentFile shouldReName:YES newName:newFileName];
                                
                            } inViewController:self position:self.view];
                        }
                        
                    }));
                    return;
                }
            }
        }
        [self addNxlFileToProject:self.currentFile shouldReName:NO newName:nil];
        
}
- (void)addNxlFileToRepository:(NXFileBase *)fileBase shouldRename:(BOOL)shouldRename newName:(NSString *)newName {
    if (shouldRename && newName) {
        fileBase.name = newName;
    }
    if (self.isLocalFile) {
        [[NXLoginUser sharedInstance].nxlOptManager uploadNXLFromLocal:fileBase shouldOverwrite:!shouldRename toSpaceType:[NXCommonUtils rmcToRMSRepoType:self.folder.serviceType] andDestPathFolder:self.folder withCompletion:^(NXFileBase *file, NSError *error) {
           
            WeakObj(self);
            dispatch_main_async_safe((^{
                [NXMBManager hideHUDForView:self.view];
                StrongObj(self);
                if (error) {
                    [NXMBManager showMessage:error.localizedDescription?:NSLocalizedString(@"MSG_COM_PROTECT_FILE_FAILED", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
                    self.bottomBtn.enabled = YES;
                }else{
                    [self dismissSelf];
    //                  [NXMessageViewManager showMessageViewWithTitle:file.name details:NSLocalizedString(@"MSG_COM_SUCCESS_ADD", NULL) appendInfo:nil appendInfo2:[NSString stringWithFormat:@"The file has been saved to WorkSpace"] image:[UIImage imageNamed:@"Success - White tick"] dismissAfter:kDelay*2 type:NXMessageViewManagerTypeGreen];
    //                  [self performSelector:@selector(dismissSelf) withObject:nil afterDelay:kDelay*2 + 0.5];
                }
            }));
           
        }];
        return;
    }
    
    [[NXLoginUser sharedInstance].nxlOptManager copyNXLFile:fileBase shouldOverwrite:!shouldRename toSpaceType:[NXCommonUtils rmcToRMSRepoType:self.folder.serviceType] andDestPathFolder:self.folder withCompletion:^(NXFileBase *file, NSError *error) {
       
        WeakObj(self);
        dispatch_main_async_safe((^{
            [NXMBManager hideHUDForView:self.view];
            StrongObj(self);
            if (error) {
                [NXMBManager showMessage:error.localizedDescription?:NSLocalizedString(@"MSG_COM_PROTECT_FILE_FAILED", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
                self.bottomBtn.enabled = YES;
            }else{
                [self dismissSelf];
//                  [NXMessageViewManager showMessageViewWithTitle:file.name details:NSLocalizedString(@"MSG_COM_SUCCESS_ADD", NULL) appendInfo:nil appendInfo2:[NSString stringWithFormat:@"The file has been saved to WorkSpace"] image:[UIImage imageNamed:@"Success - White tick"] dismissAfter:kDelay*2 type:NXMessageViewManagerTypeGreen];
//                  [self performSelector:@selector(dismissSelf) withObject:nil afterDelay:kDelay*2 + 0.5];
            }
        }));
       
    }];
//    [[NXLoginUser sharedInstance].nxlOptManager addNXLFile:fileBase intoDestFolder:self.folder shouldRename:shouldRename newName:newName completion:^(NXFileBase *file, NSError *error) {
//    WeakObj(self);
//     dispatch_main_async_safe((^{
//         [NXMBManager hideHUDForView:self.view];
//         StrongObj(self);
//         if (error) {
//             [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_PROTECT_FILE_FAILED", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
//             self.bottomBtn.enabled = YES;
//         }else{
////             [NXMessageViewManager showMessageViewWithTitle:file.name details:NSLocalizedString(@"MSG_COM_SUCCESS_ADD", NULL) appendInfo:nil appendInfo2:[NSString stringWithFormat:@"The file has been saved to repository %@",self.toRepoModel.service_alias] image:[UIImage imageNamed:@"Success - White tick"] dismissAfter:kDelay*2 type:NXMessageViewManagerTypeGreen];
////             [self performSelector:@selector(dismissSelf) withObject:nil afterDelay:kDelay*2 + 0.5];
//             [self dismissSelf];
//         }
//     }));
//   }];
    
}
- (void)addNxlFileTomySpace:(NXFileBase *)fileBase shouldRename:(BOOL)shouldRename newName:(NSString *)newName {
    
    if (shouldRename && newName) {
        fileBase.name = newName;
    }
    
    if (self.isLocalFile) {
        [[NXLoginUser sharedInstance].nxlOptManager uploadNXLFromLocal:fileBase shouldOverwrite:!shouldRename toSpaceType:@"MY_VAULT" andDestPathFolder:self.folder withCompletion:^(NXFileBase *file, NSError *error) {
           
            WeakObj(self);
            dispatch_main_async_safe((^{
                [NXMBManager hideHUDForView:self.view];
                StrongObj(self);
                if (error) {
                    [NXMBManager showMessage:error.localizedDescription?:NSLocalizedString(@"MSG_COM_PROTECT_FILE_FAILED", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
                    self.bottomBtn.enabled = YES;
                }else{
                    [self dismissSelf];
   
                }
            }));
           
        }];
        return;
    }
   
    [[NXLoginUser sharedInstance].nxlOptManager copyNXLFile:fileBase shouldOverwrite:!shouldRename toSpaceType:@"MY_VAULT" andDestPathFolder:self.folder withCompletion:^(NXFileBase *file, NSError *error) {
       
        WeakObj(self);
        dispatch_main_async_safe((^{
            [NXMBManager hideHUDForView:self.view];
            StrongObj(self);
            if (error) {
                [NXMBManager showMessage:error.localizedDescription?:NSLocalizedString(@"MSG_COM_PROTECT_FILE_FAILED", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
                self.bottomBtn.enabled = YES;
            }else{
                [self dismissSelf];

            }
        }));
       
    }];

    
}
- (void)addNxlFileToSharedWorkspace:(NXFileBase *)fileBase shouldRename:(BOOL)shouldRename newName:(NSString *)newName {
    if (shouldRename && newName) {
        fileBase.name = newName;
    }

    if (self.isLocalFile) {
        [[NXLoginUser sharedInstance].nxlOptManager uploadNXLFromLocal:fileBase shouldOverwrite:!shouldRename toSpaceType:@"SHAREPOINT_ONLINE" andDestPathFolder:self.folder withCompletion:^(NXFileBase *file, NSError *error) {
           
            WeakObj(self);
            dispatch_main_async_safe((^{
                [NXMBManager hideHUDForView:self.view];
                StrongObj(self);
                if (error) {
                    [NXMBManager showMessage:error.localizedDescription?:NSLocalizedString(@"MSG_COM_PROTECT_FILE_FAILED", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
                    self.bottomBtn.enabled = YES;
                }else{
                    [self dismissSelf];
   
                }
            }));
           
        }];
        return;
    }
    
    [[NXLoginUser sharedInstance].nxlOptManager copyNXLFile:fileBase shouldOverwrite:!shouldRename toSpaceType:@"SHAREPOINT_ONLINE" andDestPathFolder:self.folder withCompletion:^(NXFileBase *file, NSError *error) {
       
        WeakObj(self);
        dispatch_main_async_safe((^{
            [NXMBManager hideHUDForView:self.view];
            StrongObj(self);
            if (error) {
                [NXMBManager showMessage:error.localizedDescription?:NSLocalizedString(@"MSG_COM_PROTECT_FILE_FAILED", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
                self.bottomBtn.enabled = YES;
            }else{
                [self dismissSelf];

            }
        }));
       
    }];

    
}
- (void)addNxlFileToProject:(NXFileBase *)fileBase shouldReName:(BOOL)shouldRename newName:(NSString *)newName{
    if (shouldRename && newName) {
        fileBase.name = newName;
    }
    
    if (self.isLocalFile) {
        [[NXLoginUser sharedInstance].nxlOptManager uploadNXLFromLocal:fileBase shouldOverwrite:!shouldRename toSpaceType:@"PROJECT" andDestPathFolder:self.folder withCompletion:^(NXFileBase *file, NSError *error) {
           
            WeakObj(self);
            dispatch_main_async_safe((^{
                [NXMBManager hideHUDForView:self.view];
                StrongObj(self);
                if (error) {
                    [NXMBManager showMessage:error.localizedDescription?:NSLocalizedString(@"MSG_COM_PROTECT_FILE_FAILED", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
                    self.bottomBtn.enabled = YES;
                }else{
                    [self dismissSelf];
                }
            }));
           
        }];
        return;
    }
    
    [[NXLoginUser sharedInstance].nxlOptManager copyNXLFile:fileBase shouldOverwrite:!shouldRename toSpaceType:@"PROJECT" andDestPathFolder:self.folder withCompletion:^(NXFileBase *file, NSError *error) {
       
        WeakObj(self);
        dispatch_main_async_safe((^{
            [NXMBManager hideHUDForView:self.view];
            StrongObj(self);
            if (error) {
                [NXMBManager showMessage:error.localizedDescription?:NSLocalizedString(@"MSG_COM_PROTECT_FILE_FAILED", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
                self.bottomBtn.enabled = YES;
            }else{
                [self dismissSelf];
            }
        }));
       
    }];

}

- (void)addNxlFileToWorkSpace:(NXFileBase *)fileBase shouldReName:(BOOL)shouldRename newName:(NSString *)newName {
    if (shouldRename && newName) {
        fileBase.name = newName;
    }
    if (self.isLocalFile) {
        [[NXLoginUser sharedInstance].nxlOptManager uploadNXLFromLocal:fileBase shouldOverwrite:!shouldRename toSpaceType:@"ENTERPRISE_WORKSPACE" andDestPathFolder:self.folder withCompletion:^(NXFileBase *file, NSError *error) {
           
            WeakObj(self);
            dispatch_main_async_safe((^{
                [NXMBManager hideHUDForView:self.view];
                StrongObj(self);
                if (error) {
                    [NXMBManager showMessage:error.localizedDescription?:NSLocalizedString(@"MSG_COM_PROTECT_FILE_FAILED", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
                    self.bottomBtn.enabled = YES;
                }else{
                    [self dismissSelf];
   
                }
            }));
           
        }];
        return;
    }
    

    
    [[NXLoginUser sharedInstance].nxlOptManager copyNXLFile:fileBase shouldOverwrite:true toSpaceType:@"ENTERPRISE_WORKSPACE" andDestPathFolder:self.folder withCompletion:^(NXFileBase *file, NSError *error) {
           
            WeakObj(self);
            dispatch_main_async_safe((^{
                [NXMBManager hideHUDForView:self.view];
                StrongObj(self);
                if (error) {
                    [NXMBManager showMessage:error.localizedDescription?:NSLocalizedString(@"MSG_COM_PROTECT_FILE_FAILED", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
                    self.bottomBtn.enabled = YES;
                }else{
                    [self dismissSelf];

                }
            }));
       }];
}

- (void)reclassifyProjectFile {
    NSMutableDictionary *classificaitonDict = [[NSMutableDictionary alloc] init];
    for (NXClassificationCategory *classificationCategory in self.currentClassifiations) {
        if (classificationCategory.selectedLabs.count > 0) {
            NSMutableArray *labs = [[NSMutableArray alloc] init];
            for (NXClassificationLab *classificationLab in classificationCategory.selectedLabs) {
                NSString *labName = classificationLab.name;
                [labs addObject:labName];
            }
            [classificaitonDict setObject:labs forKey:classificationCategory.name];
        }
    }
     WeakObj(self);
    [[NXLoginUser sharedInstance].myProject reclassifyFileWithParameterModel:(NXProjectFile *)self.currentFile withNewTags:classificaitonDict withCompletion:^(NXProjectFile *file, NSError *error) {
            StrongObj(self);
            dispatch_main_async_safe(^{
                [NXMBManager hideHUDForView:self.view];
                if (error) {
                    [NXMBManager showMessage:error.localizedDescription?:NSLocalizedString(@"MSG_COM_PROTECT_FILE_FAILED", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
                    self.bottomBtn.enabled = YES;
                }else{
                    [[NXLoginUser sharedInstance].nxlOptManager cleanCachedRight:file];
                    [NXMessageViewManager showMessageViewWithTitle:file.name details:NSLocalizedString(@"MSG_COM_SUCCESS_MODIFY_RIGHTS", NULL) appendInfo:nil appendInfo2:nil image:[UIImage imageNamed:@"Success - White tick"] dismissAfter:kDelay*2 type:NXMessageViewManagerTypeGreen];
                    [self performSelector:@selector(dismissSelf) withObject:nil afterDelay:kDelay*2 + 0.5];
                }
                   
            });
    }];
    
}
- (void)reclassifyWorkSpaceFile {
    NSMutableDictionary *classificaitonDict = [[NSMutableDictionary alloc] init];
    for (NXClassificationCategory *classificationCategory in self.currentClassifiations) {
        if (classificationCategory.selectedLabs.count > 0) {
            NSMutableArray *labs = [[NSMutableArray alloc] init];
            for (NXClassificationLab *classificationLab in classificationCategory.selectedLabs) {
                NSString *labName = classificationLab.name;
                [labs addObject:labName];
            }
            [classificaitonDict setObject:labs forKey:classificationCategory.name];
        }
    }
    NXWorkSpaceReclassifyFileModel *model = [[NXWorkSpaceReclassifyFileModel alloc]init];
    model.file = (NXFile *)self.currentFile;
    model.fileTags = classificaitonDict;
    NSString *parentPath = [self.currentFile.fullServicePath stringByDeletingLastPathComponent];
    if (![parentPath isEqualToString:@"/"]) {
       parentPath = [parentPath stringByAppendingString:@"/"];
    }
    model.parentPathId = parentPath;
     WeakObj(self);
    [[NXLoginUser sharedInstance].workSpaceManager reclassifyWorkSpaceFile:model withCompletion:^(NXWorkSpaceFile *spaceFile, NXWorkSpaceReclassifyFileModel *reclassifyModel, NSError *error) {
        StrongObj(self);
        dispatch_main_async_safe(^{
            [NXMBManager hideHUDForView:self.view];
            if (error) {
                [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_PROTECT_FILE_FAILED", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
                self.bottomBtn.enabled = YES;
            }else{
                [[NXLoginUser sharedInstance].nxlOptManager cleanCachedRight:spaceFile];
                [NXMessageViewManager showMessageViewWithTitle:spaceFile.name details:NSLocalizedString(@"MSG_COM_SUCCESS_MODIFY_RIGHTS", NULL) appendInfo:nil appendInfo2:nil image:[UIImage imageNamed:@"Success - White tick"] dismissAfter:kDelay*2 type:NXMessageViewManagerTypeGreen];
                [self performSelector:@selector(dismissSelf) withObject:nil afterDelay:kDelay*2 + 0.5];
             }
        });
    }];
}

- (void)setScrollViewContentSize {
    CGFloat height;
    height = OTHER_HEIGHT+CGRectGetHeight(self.classificationView.bounds) + CGRectGetHeight(self.rightsDisplayView.bounds)+CGRectGetHeight(self.userDefinedView.bounds)+CGRectGetHeight(self.fileListView.bounds)+CGRectGetHeight(self.locationView.bounds);
    if (self.bgScrollView.bounds.size.height > height) {
        self.bgScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bgScrollView.bounds), CGRectGetHeight(self.bgScrollView.bounds));
    } else {
        self.bgScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bgScrollView.bounds), height + 10);
    }
}

- (void)dismissSelf {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)back:(id)sender {
    if (self.isFromDefaultPath) {
        [self dismissSelf];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (BOOL)isHaveOverwritePerssion:(NXFileBase *)file {
    
    
    if (self.folder.serviceType && (self.folder.serviceType == [NSNumber numberWithInteger:kServiceBOX] || self.folder.serviceType == [NSNumber numberWithInteger:kServiceGoogleDrive])) {
           return  NO;
       }
       return YES;
    
//    switch (self.fileOperationType) {
//        case NXFileOperationTypeAddNXLFileToMySpace:
//            return YES;
//            break;
//        case NXFileOperationTypeAddNXLFileToProject:
//        {
//            if ((self.fileRights && [self.fileRights EditRight]) || [[NXLoginUser sharedInstance] isProjectAdmin]) {
//                return YES;
//            }else{
//                return NO;
//            }
//        }
//            break;
//        case NXFileOperationTypeAddFileToSharedWorkspace:
//        case NXFileOperationTypeAddNXLFileToWorkSpace:
//        {
//            if ((self.fileRights && [self.fileRights EditRight]) || [[NXLoginUser sharedInstance] isTenantAdmin]) {
//                return YES;
//            }else{
//                return NO;
//            }
//        }
//            break;
//        case NXFileOperationTypeAddNXLFileToRepo:
//        {
//            if (self.folder.serviceType && (self.folder.serviceType == [NSNumber numberWithInteger:kServiceBOX] || self.folder.serviceType == [NSNumber numberWithInteger:kServiceGoogleDrive])) {
//                   return  NO;
//               }
//            if ((self.fileRights && [self.fileRights EditRight]) || [[NXLoginUser sharedInstance] isTenantAdmin]) {
//                return YES;
//            }else{
//                return NO;
//            }
//        }
//            break;
//        default:
//            return NO;
//            break;
//    }
    
//  __block  BOOL isCanOverwrite = NO;
//    if (self.saveFolder.serviceType && (self.saveFolder.serviceType == [NSNumber numberWithInteger:kServiceBOX] || self.saveFolder.serviceType == [NSNumber numberWithInteger:kServiceGoogleDrive])) {
//        return  NO;
//    }
//    return YES;
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
//
//    return isCanOverwrite;
}

#pragma mark   ----》NSAttributedString
- (NSAttributedString *)createAttributeString:(NSString *)title subTitle1:(NSString *)subtitle1 {
    NSMutableAttributedString *myprojects = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:16]}];
    if (subtitle1) {
        NSAttributedString *sub1 = [[NSMutableAttributedString alloc] initWithString:subtitle1 attributes:@{NSForegroundColorAttributeName :[UIColor blackColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:17]}];
        [myprojects appendAttributedString:sub1];
    }

    
    return myprojects;
}

@end
