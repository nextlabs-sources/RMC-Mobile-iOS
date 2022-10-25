//
//  NXProjectFileManageShareVC.m
//  nxrmc
//
//  Created by Sznag on 2020/2/11.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXProjectFileManageShareVC.h"
#import "NXRMCUIDef.h"
#import "UIView+UIExt.h"
#import "UIImage+ColorToImage.h"
#import "Masonry.h"
#import "NXRightsDisplayView.h"
#import "NXLoginUser.h"
#import "NXMBManager.h"
#import "NXFileInfoView.h"
#import "NXDocumentClassificationView.h"
#import "NXShareWithView.h"
#import "NXNXLFileSharingSelectVC.h"
#import "NXPresentNavigationController.h"
#import "NXSharedWithProjectFile.h"
#import "NXCommonUtils.h"
@interface NXProjectFileManageShareVC ()<NXShareWithViewSelegate,NXNXLFileSharingSelectVCDelegate>
@property(nonatomic, strong)UIButton *updateButton;
@property(nonatomic, strong)UIButton *revokeButton;
@property(nonatomic, strong) NXRightsDisplayView *rightsView;
@property(nonatomic, strong) NXFileInfoView *infoView;
@property(nonatomic, strong) NXDocumentClassificationView *documentTagView;
@property(nonatomic, strong) NXShareWithView *shareWithView;
@property(nonatomic, strong) NSMutableArray *deteleItems;
@property(nonatomic, strong) NSMutableArray *shareProjectsList;
@end

@implementation NXProjectFileManageShareVC
- (NSMutableArray *)shareProjectsList {
    if (!_shareProjectsList) {
        _shareProjectsList = [NSMutableArray array];
    }
    return _shareProjectsList;
}
- (UIButton *)updateButton {
    if (!_updateButton) {
        _updateButton = [[UIButton alloc] init];
        [self.bottomView addSubview:_updateButton];
        _updateButton.enabled = NO;
        [_updateButton setTitle:NSLocalizedString(@"UI_UPDATE", NULL) forState:UIControlStateNormal];
        [_updateButton addTarget:self action:@selector(updateButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        //    [shareButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
        [_updateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_updateButton setBackgroundImage:[UIImage imageWithSize:CGSizeMake(200, 200) colors:@[RMC_GRADIENT_START_COLOR, RMC_GRADIENT_END_COLOR] gradientType:GradientTypeLeftToRight] forState:UIControlStateNormal];
        [_updateButton cornerRadian:3];
       
        _updateButton.accessibilityValue = @"UPDATING_BUTTON";
    }
    return _updateButton;
}
- (NXShareWithView *)shareWithView {
    if (!_shareWithView) {
        _shareWithView = [[NXShareWithView alloc] init];
        _shareWithView.delegate = self;
        [self.mainView addSubview:_shareWithView];
    }
    return _shareWithView;
}
- (UIButton *)revokeButton{
    if (!_revokeButton) {
        UIButton *revokeButton = [[UIButton alloc] init];
        [revokeButton setTitle:@"Revoke all rights" forState:UIControlStateNormal];
        [revokeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        revokeButton.titleLabel.font = [UIFont systemFontOfSize:15];
        revokeButton.titleLabel.textAlignment = NSTextAlignmentRight;
        revokeButton.hidden = YES;
        [self.mainView addSubview:revokeButton];
        [revokeButton addTarget:self action:@selector(revokeAllRights:) forControlEvents:UIControlEventTouchUpInside];
        _revokeButton = revokeButton;
    }
    return _revokeButton;
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
- (NXDocumentClassificationView *)documentTagView {
    if (!_documentTagView) {
         _documentTagView = [[NXDocumentClassificationView alloc]init];
        [self.mainView addSubview: _documentTagView];
    }
    return _documentTagView;
}
- (void)viewDidLayoutSubviews {
    CGFloat height = CGRectGetHeight(self.infoView.bounds)+CGRectGetHeight(_documentTagView.bounds)+CGRectGetHeight(_shareWithView.bounds)+CGRectGetHeight(_rightsView.bounds);
    CGFloat contentHeight = height + kMargin + kMargin + (_documentTagView?kMargin*2:0)+120;
    if (self.mainView.bounds.size.height > contentHeight) {
        self.mainView.contentSize = CGSizeMake(CGRectGetWidth(self.mainView.bounds), CGRectGetHeight(self.mainView.bounds)+1);
    } else {
        self.mainView.contentSize = CGSizeMake(CGRectGetWidth(self.mainView.bounds), contentHeight);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.;
    [self commonInit];
    [self initData];
}
- (void)commonInit {
    self.topView.model = self.fileItem;
       self.topView.operationTitle = NSLocalizedString(@"UI_SHARE_A_PROTEDTED_FILE", NULL);
       WeakObj(self);
       self.topView.backClickAction = ^(id sender) {
           StrongObj(self);
           [self backButtonClicked:nil];
       };
    self.infoView.hidden = YES;
}

- (void)initData {
    BOOL isNxl = [[NXLoginUser sharedInstance].nxlOptManager isNXLFile:self.fileItem];
    if (isNxl) {
        [NXMBManager showLoadingToView:self.mainView];
        [[NXLoginUser sharedInstance].nxlOptManager getNXLFileRights:self.fileItem withWatermark:NO withCompletion:^(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray *watermark, NSString *owner, BOOL isOwner, NSError *error) {
            dispatch_main_async_safe((^{
                [NXMBManager hideHUDForView:self.mainView];
                [self updateUI:self.fileItem isNxlFile:YES rights:rights classifications:classifications message:error.localizedDescription];
            }));
        }];
        
    }
}
- (void)updateUI:(NXFileBase *)fileItem isNxlFile:(BOOL)nxl rights:(NXLRights *)rights classifications:(NSArray *)classifications message:(NSString *)noRightsMessage {
    // project admin allow share any files
    if ([[NXLoginUser sharedInstance] isProjectAdmin]) {
        
    }else{
        if (![rights SharingRight]) {
            [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:@"You are not allowed to share this file."  style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_OK", NULL) cancelActionTitle:nil OKActionHandle:^(UIAlertAction *action) {
                              [self backButtonClicked:nil];
            } cancelActionHandle:nil inViewController:self position:self.view];
            return;
        }
    }
    
    self.infoView.model = fileItem;
    self.infoView.hidden = NO;
    [self.infoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mainView).offset(kMargin/2);
        make.left.equalTo(self.view).offset(kMargin);
        make.right.equalTo(self.view).offset(-kMargin);
    }];
    [self.updateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.bottomView);
        make.width.equalTo(@200);
        make.height.lessThanOrEqualTo(self.bottomView).multipliedBy(0.7);
        make.height.lessThanOrEqualTo(@(40));
    }];
    if (nxl) {
        NXRightsDisplayView *rightsView = [[NXRightsDisplayView alloc] init];
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
            [rightsView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.infoView.mas_bottom).offset(kMargin);
                make.left.equalTo(self.view).offset(kMargin);
                make.right.equalTo(self.view).offset(-kMargin);
            }];
        }
        
        self.rightsView.rights = rights;
        [self.rightsView setNeedsLayout];
        if ([fileItem isKindOfClass:[NXProjectFile class]]) {
            NXProjectFile *currentFile = (NXProjectFile *)fileItem;
           
            if ([[NXLoginUser sharedInstance] isProjectAdmin] && currentFile.isShared) {
                self.revokeButton.hidden = NO;
            }
            
            UILabel *shareWithLabel = [[UILabel alloc] init];
            shareWithLabel.text = @"Share with";
            shareWithLabel.textColor = [UIColor grayColor];
            [self.mainView addSubview:shareWithLabel];
            
            UIButton *addMoreBtn = [[UIButton alloc] init];
            [addMoreBtn setTitle:@"Add more" forState:UIControlStateNormal];
            [addMoreBtn setTitleColor:RMC_TINT_BTN_BLUE forState:UIControlStateNormal];
            [addMoreBtn addTarget:self action:@selector(addMore:) forControlEvents:UIControlEventTouchUpInside];
            [self.mainView addSubview:addMoreBtn];
            
            [shareWithLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.rightsView.mas_bottom).offset(kMargin * 2);
                make.left.right.equalTo(self.rightsView);
                make.height.equalTo(@20);
            }];
            [self.revokeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(shareWithLabel.mas_bottom).offset(kMargin/2);
                make.right.equalTo(self.rightsView);
                make.height.equalTo(@40);
                make.width.equalTo(@150);
            }];
            self.shareProjectsList = currentFile.sharedWithProjectList;
            NSDictionary *dict = @{@"1":[self getProjects:currentFile.sharedWithProjectList]};
            NSArray *dataArray = @[dict];
            self.shareWithView.dataArray = dataArray;
            [self.shareWithView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.revokeButton.mas_bottom).offset(kMargin/4);
                make.left.right.equalTo(self.rightsView);
            }];
            [addMoreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.shareWithView.mas_bottom).offset(kMargin/2);
                make.left.equalTo(self.rightsView);
                make.height.equalTo(@40);
                make.width.equalTo(@100);
            }];
            
        }
        
    }
}
- (void)revokeAllRights:(id)sender {
    NSString *message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"MSG_COM_REVOKE_FILE_WARNING", NULL), self.fileItem.name];
    WeakObj(self);
        [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message: message style:UIAlertControllerStyleAlert cancelActionTitle:NSLocalizedString(@"UI_BOX_CANCEL", NULL) otherActionTitles:@[NSLocalizedString(@"UI_BOX_OK", NULL)] inViewController:self position:self.view tapBlock:^(UIAlertAction *action, NSInteger index) {
            StrongObj(self);
            if (index == 1) { // user desire to delete this file
                [NXMBManager showLoadingToView:self.view];
                [[NXLoginUser sharedInstance].nxlOptManager revokeSharedFileByFileDuid:((NXProjectFile*)self.fileItem).duid wtihCompletion:^(NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [NXMBManager hideHUDForView:self.view];
                        if (error) {
                            [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_REVOKE_FILE_FAILED", NULL) hideAnimated:YES afterDelay:kDelay];
                        }else{
                            [NXMBManager showMessage:@"Revoked successfully" hideAnimated:YES afterDelay:kDelay];
                            self.shareWithView.dataArray = nil;
                        }
                    });
                }];
                
               
            }
        }];

}
- (void)updateButtonClicked:(id)sender {
    if (!self.shareWithView.deleteProjectArray.count) {
        return;
    }
    [NXMBManager showLoading];
    self.updateButton.enabled = NO;
    NSMutableArray *deleteArray = [NSMutableArray array];
    for (NXProjectModel *model in self.shareWithView.deleteProjectArray) {
        NSDictionary *dict = @{@"projectId":model.projectId};
        [deleteArray addObject:dict];
    }
    [[NXLoginUser sharedInstance].nxlOptManager updateSharedFile:self.fileItem fromProject:self.fromProjectModel addRecipients:nil removeRecipients:deleteArray comment:nil withCompletion:^(NSArray *newRecipients, NSArray *removedRecipients, NSArray *alreadyRecipients, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NXMBManager hideHUD];
            if (!error) {
                [NXMBManager showMessage:@"Updated successfully" hideAnimated:YES afterDelay:kDelay];
                NSMutableSet *originalSet = [NSMutableSet setWithArray:self.shareProjectsList];
                NSMutableSet *removeSet = [NSMutableSet setWithArray:removedRecipients];
                [originalSet minusSet:removeSet];
                self.shareProjectsList = (NSMutableArray *)[originalSet allObjects];
                
            }else{
                [NXMBManager showMessage:error.localizedDescription hideAnimated:YES afterDelay:kDelay*2];
                self.updateButton.enabled = YES;
            }
        });
        
    }];
}
- (void)addMore:(id)sender {
    NXNXLFileSharingSelectVC *vc = [[NXNXLFileSharingSelectVC alloc] init];
    vc.delegate = self;
    vc.fileItem = self.fileItem;
    vc.fromProjectModel = self.fromProjectModel;
    vc.sharedProjects = [self getProjects:self.shareProjectsList];
    NXPresentNavigationController *nav = [[NXPresentNavigationController alloc] initWithRootViewController:vc];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
    

    
}
-(NSArray *)getProjects:(NSArray *)array{
    NSMutableArray *projectnames = [NSMutableArray array];
    for (NSNumber *projectId in array) {
     NXProjectModel *project =  [[NXLoginUser sharedInstance].myProject getProjectModelFromAllProjectForProjectId:projectId];
        if (project) {
            [projectnames addObject:project];
        }
    }
    return projectnames;
}
- (void)backButtonClicked:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)theShareWithViewHasChanged {
    self.updateButton.enabled = YES;
}
#pragma mark -------> delegate
- (void)successShareFileToTargets:(NSArray *)array {
    if (array.count) {
        NSMutableSet *originalSet = [NSMutableSet setWithArray:self.shareProjectsList];
        NSMutableSet *addSet = [NSMutableSet setWithArray:array];
        [originalSet unionSet:addSet];
        self.shareProjectsList = (NSMutableArray *)[originalSet allObjects];
        NSDictionary *dict = @{@"1":[self getProjects:self.shareProjectsList]};
        NSArray *dataArray = @[dict];
        self.shareWithView.dataArray = dataArray;
        if ([[NXLoginUser sharedInstance] isProjectAdmin]) {
            self.revokeButton.hidden = NO;
        }
    }
       
    
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
