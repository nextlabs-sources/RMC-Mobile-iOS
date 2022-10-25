//
//  NXNewFolderViewController.m
//  nxrmc
//
//  Created by nextlabs on 12/15/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXNewFolderViewController.h"

#import "NXFileChooseFlowViewController.h"
#import "Masonry.h"
#import "NXMBManager.h"
#import "NXChooseDriveView.h"
#import "NXAccountInputTextField.h"

#import "NXRMCDef.h"
#import "NXCommonUtils.h"
#import "NXWorkSpaceItem.h"
#import "NXWorkSpaceCreateFolderAPI.h"
#import "NXRepositorySysManager.h"

@interface NXNewFolderViewController ()<UITextFieldDelegate, NXServiceOperationDelegate, NXFileChooseFlowViewControllerDelegate>

@property(nonatomic, weak) UITextField *textField;
@property(nonatomic, weak) UIBarButtonItem *rightBarButtonItem;
@property(nonatomic, weak) NXChooseDriveView *drivePathView;

@end

@implementation NXNewFolderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark
- (void)cancel:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NXLoginUser sharedInstance].myRepoSystem fileListForParentFolder:self.parentFolder readCache:NO delegate:nil];
}

- (void)create:(UIBarButtonItem *)sender {
    self.rightBarButtonItem.enabled = NO;
    
    [self.view endEditing:YES];
    NSString *displayName = self.textField.text;
    displayName = [displayName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([displayName isEqualToString:@""])
    {
        [NXMBManager showMessage:NSLocalizedString(@"UI_COM_PLESASE_INPUT_NAME", nil) toView:self.view hideAnimated:YES afterDelay:1.0];
        [self.textField becomeFirstResponder];
        self.rightBarButtonItem.enabled = YES;
        return;
    }else if(displayName.length>127)
    {
        [NXMBManager showMessage:NSLocalizedString(@"UI_COM_NAME_LENGTH_TOOLONG_WARNING_LIMIT_127",NULL) toView:self.view hideAnimated:YES afterDelay:1.5];
        self.rightBarButtonItem.enabled = YES;
        return;
    }else if ([NXCommonUtils JudgeTheillegalCharacter:displayName withRegexExpression:@"^[\\u00C0-\\u1FFF\\u2C00-\\uD7FF\\w \\x22\\x23\\x27\\x2C\\x2D]+$"]) {
        [NXMBManager showMessage:NSLocalizedString(@"UI_COM_NAME_CONTAIN_SPECIAL_WARNING", NULL) toView:self.view hideAnimated:YES afterDelay:1.5];
        self.rightBarButtonItem.enabled = YES;
        return;
    }
    
    NSString *folderName = self.textField.text;
    folderName = [folderName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSArray *child = [[NXLoginUser sharedInstance].myRepoSystem childForFileItem:self.parentFolder];
    for (NXFileBase *item in child) {
        if ([folderName caseInsensitiveCompare:item.name] == NSOrderedSame) {
            [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:NSLocalizedString(@"MSG_COM_NAME_ALREADY_EXISTED", NULL)  style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_OK", NULL) cancelActionTitle:nil OKActionHandle:^(UIAlertAction *action) {
                [self.textField becomeFirstResponder];
            } cancelActionHandle:nil inViewController:self position:self.view];
            self.rightBarButtonItem.enabled = YES;
            return;
        }
    }
    
    if (self.parentFolder.sorceType == NXFileBaseSorceTypeProject) {
         WeakObj(self);
    
        [NXMBManager showLoading:NSLocalizedString(@"UI_COM_CREATE_FOLDERING", nil) toView:self.view];
        [[NXLoginUser sharedInstance].myProject createProjectFolder:displayName isAutoRename:NO underFolder:(NXProjectFolder *)self.parentFolder withCompletion:^(NXProjectFolder *newProjectFolder, NSError *error) {
             StrongObj(self);
            if (!error) {
                DLog(@"create success %@",newProjectFolder.name);
                if (self.createFolderFinishedBlock) {
                    self.createFolderFinishedBlock(newProjectFolder, error);
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NXMBManager hideHUDForView:self.view];
                    [self cancel:nil];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NXMBManager hideHUDForView:self.view];
                    [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:error.localizedDescription?error.localizedDescription:NSLocalizedString(@"MSG_COM_CREATE_FOLDER_FAILED", NULL)  style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_OK", NULL) cancelActionTitle:nil OKActionHandle:^(UIAlertAction *action) {
                        
                    } cancelActionHandle:nil inViewController:self position:self.view];
                    DLog(@"ceater folder error is %@",error);
                    self.rightBarButtonItem.enabled = YES;
                });
                
            }
        }];
    }else if (self.parentFolder.sorceType == NXFileBaseSorceTypeWorkSpace){
        WeakObj(self);
        [NXMBManager showLoading:NSLocalizedString(@"UI_COM_CREATE_FOLDERING", nil) toView:self.view];
        NXWorkSpaceCreateFolderModel *model = [[NXWorkSpaceCreateFolderModel alloc]init];
        model.parentFolder = (NXFolder *)self.parentFolder;
        model.folderName = displayName;
        model.autoRename = NO;
        [[NXLoginUser sharedInstance].workSpaceManager createWorkSpaceFolder:model withCompletion:^(NXWorkSpaceFolder *spaceFolder, NXWorkSpaceCreateFolderModel *folderModel, NSError *error) {
            StrongObj(self);
            if (!error) {
                if (self.createFolderFinishedBlock) {
                    self.createFolderFinishedBlock(spaceFolder, error);
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NXMBManager hideHUDForView:self.view];
                    [self cancel:nil];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NXMBManager hideHUDForView:self.view];
                    [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:error.localizedDescription?error.localizedDescription:NSLocalizedString(@"MSG_COM_CREATE_FOLDER_FAILED", NULL)  style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_OK", NULL) cancelActionTitle:nil OKActionHandle:^(UIAlertAction *action) {
                        
                    } cancelActionHandle:nil inViewController:self position:self.view];
                    self.rightBarButtonItem.enabled = YES;
                });
            }
           
        }];
    }
    else
    {
        WeakObj(self);
        [NXMBManager showLoading:NSLocalizedString(@"UI_COM_CREATE_FOLDERING", nil) toView:self.view];
        [[NXLoginUser sharedInstance].myRepoSystem createFolder:folderName inParent:self.parentFolder completion:^(NXFileBase *fileItem, NXFileBase *parentFolder, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                StrongObj(self);
                [NXMBManager hideHUDForView:self.view];
                if (error==nil) {
                    if (self.createFolderFinishedBlock) {
                        self.createFolderFinishedBlock(fileItem, error);
                        [self cancel:nil];
                    }
                    
                } else {
                    [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:NSLocalizedString(@"MSG_COM_CREATE_FOLDER_FAILED", NULL)  style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_OK", NULL) cancelActionTitle:nil OKActionHandle:^(UIAlertAction *action) {
                        
                    } cancelActionHandle:nil inViewController:self position:self.view];
                    DLog(@"ceater folder error is %@",error);
                    self.rightBarButtonItem.enabled = YES;
                }
            });
        }];
    }
}

- (void)tap:(UIGestureRecognizer *)sender {
    [self.view endEditing:YES];

}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.rightBarButtonItem.enabled = newStr.length;
    return YES;
}
#pragma mark - NXFileChooseFlowViewControllerDelegate 
- (void)fileChooseFlowViewController:(NXFileChooseFlowViewController *)vc didChooseFile:(NSArray *)choosedFiles {
    if (!choosedFiles.count) {
        return;
    }
    NSString *fullPath = nil;
    _parentFolder = choosedFiles.lastObject;
    if ([_parentFolder isKindOfClass:[NXProjectFolder class]]) {
        NXProjectModel *projectModel = [[NXLoginUser sharedInstance].myProject getProjectModelForProjectId:((NXProjectFolder *)_parentFolder).projectId];
        fullPath = [NSString stringWithFormat:@"%@%@", projectModel.displayName?:@"", _parentFolder.fullPath?:@""];
    } else {
        fullPath = [NSString stringWithFormat:@"%@%@", _parentFolder.serviceAlias?:@"", _parentFolder.fullPath?:@""];
    }
    _drivePathView.model = fullPath;
}

- (void)fileChooseFlowViewControllerDidCancelled:(NXFileChooseFlowViewController *)vc {
    //
}
#pragma mark - private method
- (void)chooseNewFolder {
    WeakObj(self);
    if (_parentFolder.sorceType == NXFileBaseSorceTypeProject) {
        StrongObj(self);
        NXProjectModel *projectModel = [[NXLoginUser sharedInstance].myProject getProjectModelForProjectId:((NXProjectFolder *)self.parentFolder).projectId];
        NXFileChooseFlowViewController *chooseVC = [[NXFileChooseFlowViewController alloc]initWithProject:projectModel type:NXFileChooseFlowViewControllerTypeChooseDestFolder];
        chooseVC.fileChooseVCDelegate = self;
        chooseVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:chooseVC animated:YES completion:nil];
    }else if(_parentFolder.sorceType == NXFileBaseSorceTypeWorkSpace){
        NXFileChooseFlowViewController *chooseVC = [[NXFileChooseFlowViewController alloc]initWithWorkSpaceType:NXFileChooseFlowViewControllerTypeChooseDestFolder];
        chooseVC.fileChooseVCDelegate = self;
        chooseVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:chooseVC animated:YES completion:nil];
    }
    else {
        NXRepositoryModel *myDriveRepoModel = [[NXLoginUser sharedInstance].myRepoSystem getNextLabsRepository];
        NXFileChooseFlowViewController *chooseVC = [[NXFileChooseFlowViewController alloc] initWithRepository:myDriveRepoModel type:NXFileChooseFlowViewControllerTypeChooseDestFolder isSupportMultipleSelect:NO];
        chooseVC.fileChooseVCDelegate = self;
        chooseVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:chooseVC animated:YES completion:nil];
    }
}

#pragma mark
- (void)commonInit {
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.navigationItem.title = NSLocalizedString(@"UI_COM_NEW_FOLDER", NULL);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back1"] style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"UI_COM_SAVE", NULL) style:UIBarButtonItemStylePlain target:self action:@selector(create:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    NXAccountInputTextField *textField = [[NXAccountInputTextField alloc] init];
    [self.view addSubview:textField];
    textField.offset = kMargin/4;
    textField.delegate = self;
    textField.placeholder = NSLocalizedString(@"UI_COM_ENTER_FOLDER_NAME", NULL);
    
    textField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"folder - black"]];
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.clearButtonMode = UITextFieldViewModeAlways;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [self.view addGestureRecognizer:tap];
    [tap addTarget:self action:@selector(tap:)];
    
    self.textField = textField;
    self.rightBarButtonItem = rightItem;
    self.rightBarButtonItem.enabled = NO;
    
    UILabel *warnLabel = [[UILabel alloc] init];
    warnLabel.text = NSLocalizedString(@"UI_COM_TEXTFIELD_REQUEST_WARNING", nil);
    [warnLabel setFont:[UIFont systemFontOfSize:12.0]];
    warnLabel.numberOfLines = 0;
    [warnLabel setTextColor:[UIColor grayColor]];
    [self.view addSubview:warnLabel];
    
    NXChooseDriveView *driveView = [[NXChooseDriveView alloc] init];
    [self.view addSubview:driveView];
    _drivePathView = driveView;
    driveView.isForNewFolder = YES;
    driveView.promptMessage = NSLocalizedString(@"UI_COM_FOLDER_WILL_SAVED_TO", NULL);
    driveView.enabled = YES;
    WeakObj(self);
    driveView.clickActionBlock = ^(id sender) {
        StrongObj(self);
        [self chooseNewFolder];
    };
    
    if (self.parentFolder.repoId == nil && ![_parentFolder isKindOfClass:[NXProjectFolder class]] &&![_parentFolder isKindOfClass:[NXWorkSpaceFolder class]]) {
        _parentFolder = [NXCommonUtils createRootFolderByRepoType:kServiceSkyDrmBox];
    }
    
    NSString *fullPath = nil;
    if ([_parentFolder isKindOfClass:[NXProjectFolder class]]) {
        NXProjectModel *projectModel = [[NXLoginUser sharedInstance].myProject getProjectModelForProjectId:((NXProjectFolder *)_parentFolder).projectId];
        fullPath = [NSString stringWithFormat:@"%@%@", projectModel.displayName?:@"", _parentFolder.fullPath?:@""];
    }else if ([_parentFolder isKindOfClass:[NXWorkSpaceFolder class]]) {
        fullPath = [NSString stringWithFormat:@"%@%@",@"WorkSpace",_parentFolder.fullPath?:@""];
    }else {
        fullPath = [NSString stringWithFormat:@"%@%@", _parentFolder.serviceAlias?:@"", _parentFolder.fullPath?:@""];
    }
    
    driveView.model = fullPath;
    
    
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [warnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).offset(kMargin);
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).offset(-kMargin);
                make.top.equalTo(textField.mas_bottom);
                make.height.equalTo(@60);
            }];
            
            [driveView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.mas_topLayoutGuideBottom).offset(kMargin * 2);
                make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).offset(kMargin);
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).offset(-kMargin);
            }];
            
            [textField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(driveView.mas_bottom).offset(kMargin * 2);
                make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).offset(kMargin);
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).offset(-kMargin);
                make.height.equalTo(@44);
            }];
        }
    }
    else
    {
        [warnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset(kMargin);
            make.right.equalTo(self.view.mas_right).offset(-kMargin);
            make.top.equalTo(textField.mas_bottom);
            make.height.equalTo(@60);
        }];
        
        [driveView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuideBottom).offset(kMargin * 2);
            make.left.equalTo(self.view).offset(kMargin);
            make.right.equalTo(self.view).offset(-kMargin);
        }];
        
        [textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(driveView.mas_bottom).offset(kMargin * 2);
            make.left.equalTo(self.view).offset(kMargin);
            make.right.equalTo(self.view).offset(-kMargin);
            make.height.equalTo(@44);
        }];
    }
}

#pragma mark ----->NXServiceOperationDelegate

- (void)addFolderFinished:(NXFileBase *)fileItem error:(NSError *)error{
    //    [NXMBManager hideHUDForView:self.view];
    if (error==nil) {
        if (self.createFolderFinishedBlock) {
            self.createFolderFinishedBlock(fileItem, error);
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
        
    } else {
        [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:NSLocalizedString(@"MSG_COM_CREATE_FOLDER_FAILED", NULL)  style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_OK", NULL) cancelActionTitle:nil OKActionHandle:^(UIAlertAction *action) {
            
        } cancelActionHandle:nil inViewController:self position:self.view];
        DLog(@"ceater folder error is %@",error);
    }
}
@end
