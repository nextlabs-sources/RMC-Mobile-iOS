//
//  NXNXLFileSharingSelectVC.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/12/12.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXNXLFileSharingSelectVC.h"
#import "Masonry.h"
#import "NXRMCDef.h"
#import "NXFileBase.h"
#import "NXProjectModel.h"
#import "NXTargetPorjectsSelectVC.h"
#import "NXMBManager.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXSharingProjectFileToUserSelectVC.h"
@interface NXNXLFileSharingSelectVC ()<NXTargetPorjectsSelectVCDelegate>

@end

@implementation NXNXLFileSharingSelectVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back1"] style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    self.navigationItem.title = @"Add more";
    [self commonInit];
//    [self checkRightsFromTheFile:self.fileItem];
}
- (void)commonInit{
    NSMutableArray *optionArray = [NSMutableArray array];
    [optionArray addObject:[self commonInitShareToProjectItem]];
//    [optionArray addObject:[self commonInitShareToUsersItem]];
//    [optionArray addObject:[self commonInitShareToWorkSpaceViewItem]];
//
    UILabel *hintLabel = [[UILabel alloc] init];
    hintLabel.text = @"Share a protected file with";
    hintLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:hintLabel];
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            [hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(5);
                make.left.equalTo(self.view).offset(15);
                make.width.equalTo(@300);
                make.height.equalTo(@20);
            }];
        }
    }else {
        [hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuideBottom).offset(5);
            make.left.equalTo(self.view).offset(15);
            make.width.equalTo(@200);
            make.height.equalTo(@50);
        }];
    }
    UIView *lastView = nil;
    for (int i = 0; i<optionArray.count;i++) {
        UIView *operationView = optionArray[i];
        if (i == 0) {
            [operationView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(hintLabel.mas_bottom).offset(5);
                make.left.right.equalTo(self.view);
                make.height.equalTo(@60);
            }];
        }else{
            [operationView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(lastView.mas_bottom).offset(2);
                make.left.right.equalTo(self.view);
                make.height.equalTo(@60);
            }];
        }
        
        lastView = operationView;
    }
}
- (UIView *)commonInitShareToProjectItem {
    UIView *toProjectView = [[UIView alloc] init];
    toProjectView.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Black_project-icon"]];
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.text = @"Project(s)";
    [toProjectView addSubview:imageView];
    [toProjectView addSubview:textLabel];
    [self.view addSubview:toProjectView];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toSelectProjects:)];
    [toProjectView addGestureRecognizer:tapGesture];
    [self.view addSubview:toProjectView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(toProjectView).offset(15);
        make.left.equalTo(toProjectView).offset(10);
        make.height.equalTo(@30);
        make.width.equalTo(@35);
    }];
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageView.mas_right).offset(10);
        make.width.equalTo(@100);
        make.centerY.equalTo(imageView);
        make.height.equalTo(@30);
    }];
    return toProjectView;
}
- (UIView *)commonInitShareToUsersItem {
    UIView *toUsersView = [[UIView alloc] init];
    toUsersView.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Members"]];
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.text = @"User(s)";
    [toUsersView addSubview:imageView];
    [toUsersView addSubview:textLabel];
    [self.view addSubview:toUsersView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toSelectUsers:)];
    [toUsersView addGestureRecognizer:tapGesture];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(toUsersView).offset(15);
        make.left.equalTo(toUsersView).offset(10);
        make.height.equalTo(@30);
        make.width.equalTo(@35);
    }];
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageView.mas_right).offset(10);
        make.width.equalTo(@100);
        make.centerY.equalTo(imageView);
        make.height.equalTo(@30);
    }];
    return toUsersView;
}
- (UIView *)commonInitShareToWorkSpaceViewItem {
    UIView *toWorkSpaceView = [[UIView alloc] init];
    toWorkSpaceView.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Black-workspace-icon"]];
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.text = @"WorkSpace";
    [toWorkSpaceView addSubview:imageView];
    [toWorkSpaceView addSubview:textLabel];
    [self.view addSubview:toWorkSpaceView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toSelectWorkSpace:)];
    [toWorkSpaceView addGestureRecognizer:tapGesture];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(toWorkSpaceView).offset(15);
        make.left.equalTo(toWorkSpaceView).offset(10);
        make.height.equalTo(@30);
        make.width.equalTo(@35);
    }];
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageView.mas_right).offset(10);
        make.width.equalTo(@100);
        make.centerY.equalTo(imageView);
        make.height.equalTo(@30);
    }];
    return toWorkSpaceView;
}


- (void)toSelectProjects:(id)sender {
    NXTargetPorjectsSelectVC *targetVC = [[NXTargetPorjectsSelectVC alloc] init];
    targetVC.currentFile = self.fileItem;
    targetVC.delegate = self;
    targetVC.fromProjectModel = self.fromProjectModel;
    targetVC.sharedProjects = self.sharedProjects;
    [self.navigationController pushViewController:targetVC animated:YES];
}

- (void)toSelectUsers:(id)sender {
    NXSharingProjectFileToUserSelectVC *vc = [[NXSharingProjectFileToUserSelectVC alloc] init];
    vc.currentFile = self.fileItem;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)toSelectWorkSpace:(id)sender {
    
}
- (void)cancel:(id)sender{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)checkRightsFromTheFile:(NXFileBase *)fileItem {
    [NXMBManager showLoading];
    [[NXLoginUser sharedInstance].nxlOptManager getNXLFileRights:fileItem withWatermark:YES withCompletion:^(NSString *duid, NXLRights *rights, NSArray<NXClassificationCategory *> *classifications, NSArray<NXWatermarkWord *> *waterMarkWords, NSString *owner, BOOL isOwner, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
             [NXMBManager hideHUD];
            NSString *errorMessage = nil;
            if (!error) {
                if ([rights SharingRight]) {
                    [self commonInit];
                }else{
                    errorMessage = NSLocalizedString(@"MSG_NO_SHARE_RIGHT",NULL);
                }
            }else{
                errorMessage = error.localizedDescription;
            }
            if (errorMessage) {
                [NXCommonUtils showAlertView:[NXCommonUtils currentBundleDisplayName] message:errorMessage  style:UIAlertControllerStyleAlert OKActionTitle:NSLocalizedString(@"UI_BOX_OK", NULL) cancelActionTitle:nil OKActionHandle:^(UIAlertAction *action) {
                    [self cancel:nil];
                } cancelActionHandle:nil inViewController:self position:self.view];
            }
        });
        
    }];
}
- (void)successToShareProjects:(NSArray *)projects {
    if (projects.count) {
        if ([self.delegate respondsToSelector:@selector(successShareFileToTargets:)]) {
            [self.delegate successShareFileToTargets:projects];
        }
    }
    
}
@end
