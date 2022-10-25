//
//  NXProtectFileSelectSaveLocationSecondVC.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/5/26.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXProtectFileSelectSaveLocationSecondVC.h"
#import "NXCustomTitleView.h"
#import "Masonry.h"
#import "NXCommonUtils.h"
#import "NXTargetPorjectsSelectVC.h"
#import "NXProtectFileAfterSelectedLocationVC.h"
#import "NXFileChooseFlowViewController.h"
@interface NXProtectFileSelectSaveLocationSecondVC ()<NXFileChooseFlowViewControllerDelegate>
@property(nonatomic, strong)NXFileBase *targetFolder;
@end

@implementation NXProtectFileSelectSaveLocationSecondVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initNavigationBar];
    [self commonInit];
}
- (void)commonInit{
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    NSMutableArray *optionArray = [NSMutableArray array];
    [optionArray addObject:[self commonInitSaveToMyVaultViewItem]];
    if ([NXCommonUtils isSupportWorkspace]) {
        [optionArray addObject:[self commonInitSaveToWorkSpaceViewItem]];
    }
    [optionArray addObject:[self commonInitSaveToProjectItem]];
    UIView *lastView = nil;
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *)) {
            for (int i = 0; i<optionArray.count;i++) {
                UIView *operationView = optionArray[i];
                if (i == 0) {
                    [operationView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(20);
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
    }else {
        for (int i = 0; i<optionArray.count;i++) {
               UIView *operationView = optionArray[i];
               if (i == 0) {
                   [operationView mas_makeConstraints:^(MASConstraintMaker *make) {
                       make.top.equalTo(self.mas_topLayoutGuideBottom).offset(20);
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
    
}
- (void)initNavigationBar {
    NXCustomTitleView *titleView = [[NXCustomTitleView alloc] init];
    titleView.text = NSLocalizedString(@"UI_SAVE_FILE_LOCATION", NULL);
    self.navigationItem.titleView = titleView;
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClicked:)];
    leftItem.accessibilityValue = @"UI_BOX_CANCEL";
    self.navigationItem.leftBarButtonItem = leftItem;
    self.automaticallyAdjustsScrollViewInsets = NO;
}
- (void)cancelButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (UIView *)commonInitSaveToProjectItem {
    UIView *toProjectView = [[UIView alloc] init];
    toProjectView.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Black_project-icon"]];
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.text = @"Project(s)";
    UIImageView *rightImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessoryIcon"]];
    [toProjectView addSubview:imageView];
    [toProjectView addSubview:textLabel];
    [toProjectView addSubview:rightImage];
    [self.view addSubview:toProjectView];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toSelectProjects:)];
    [toProjectView addGestureRecognizer:tapGesture];
    [self.view addSubview:toProjectView];
    [rightImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(toProjectView);
        make.right.equalTo(toProjectView).offset(-15);
        make.height.width.equalTo(@20);
    }];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(toProjectView).offset(15);
        make.left.equalTo(toProjectView).offset(15);
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
- (UIView *)commonInitSaveToWorkSpaceViewItem {
    UIView *toWorkSpaceView = [[UIView alloc] init];
    toWorkSpaceView.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Black-workspace-icon"]];
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.text = @"WorkSpace";
    UIImageView *rightImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessoryIcon"]];
    [toWorkSpaceView addSubview:rightImage];
    [toWorkSpaceView addSubview:imageView];
    [toWorkSpaceView addSubview:textLabel];
    [self.view addSubview:toWorkSpaceView];
    if (![NXCommonUtils isSupportWorkspace]) {
        toWorkSpaceView.userInteractionEnabled = NO;
        toWorkSpaceView.backgroundColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1.0];
    }else{
        toWorkSpaceView.userInteractionEnabled = YES;
        toWorkSpaceView.backgroundColor = [UIColor whiteColor];
    }
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toSelectWorkSpace:)];
    [toWorkSpaceView addGestureRecognizer:tapGesture];
    [rightImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(toWorkSpaceView);
        make.right.equalTo(toWorkSpaceView).offset(-15);
        make.height.width.equalTo(@20);
    }];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(toWorkSpaceView).offset(15);
        make.left.equalTo(toWorkSpaceView).offset(15);
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
- (UIView *)commonInitSaveToMyVaultViewItem {
    UIView *toWorkSpaceView = [[UIView alloc] init];
    toWorkSpaceView.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"myVault-icon"]];
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.text = @"MyVault";
    [toWorkSpaceView addSubview:imageView];
    [toWorkSpaceView addSubview:textLabel];
    [self.view addSubview:toWorkSpaceView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toSelectMyVault:)];
    [toWorkSpaceView addGestureRecognizer:tapGesture];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(toWorkSpaceView).offset(15);
        make.left.equalTo(toWorkSpaceView).offset(15);
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
    targetVC.isForProtect = YES;
    [self.navigationController pushViewController:targetVC animated:YES];
}
- (void)toSelectMyVault:(id)sender {
    NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
    VC.fileItem = self.fileItem;
    VC.locationType = NXProtectSaveLoactionTypeMyVault;
    [self.navigationController pushViewController:VC animated:YES];
}
- (void)toSelectWorkSpace:(id)sender {
    NXFileChooseFlowViewController *VC = [[NXFileChooseFlowViewController alloc] initWithWorkSpaceType:NXFileChooseFlowViewControllerTypeChooseDestFolder];
    VC.fileChooseVCDelegate = self;
    VC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:VC animated:YES completion:nil];
}
#pragma mark ------> fileChooseDelegate
- (void)fileChooseFlowViewController:(NXFileChooseFlowViewController *)vc didChooseFile:(NSArray *)choosedFiles {
    if (choosedFiles.count) {
        self.targetFolder = choosedFiles.lastObject;
    }
    NXProtectFileAfterSelectedLocationVC *VC = [[NXProtectFileAfterSelectedLocationVC alloc] init];
    VC.fileItem = self.fileItem;
    VC.saveFolder = self.targetFolder;
    VC.locationType = NXProtectSaveLoactionTypeWorkSpace;
    [self.navigationController pushViewController:VC animated:NO];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)fileChooseFlowViewControllerDidCancelled:(NXFileChooseFlowViewController *)vc {
    //
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
