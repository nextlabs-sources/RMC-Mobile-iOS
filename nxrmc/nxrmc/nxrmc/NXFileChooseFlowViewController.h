//
//  NXFileChooseFlowViewController.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 5/2/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXBaseNavigationController.h"
#import "NXRepositoryModel.h"
#import "NXProjectModel.h"

@class NXFileChooseFlowViewController;
@protocol NXFileChooseFlowViewControllerDelegate <NSObject>

- (void)fileChooseFlowViewController:(NXFileChooseFlowViewController *)vc didChooseFile:(NSArray *)choosedFiles;
- (void)fileChooseFlowViewControllerDidCancelled:(NXFileChooseFlowViewController *)vc;

@end

typedef NS_ENUM(NSInteger, NXFileChooseFlowViewControllerType)
{
    NXFileChooseFlowViewControllerTypeChooseFile = 1,
    NXFileChooseFlowViewControllerTypeNormalFile = 2,
    NXFileChooseFlowViewControllerTypeChooseDestFolder = 3,
    NXFileChooseFlowViewControllerTypeNxlFile
};

@interface NXFileChooseFlowViewController : NXBaseNavigationController
- (instancetype) initWithAnchorFolder:(NXFileBase *)anchorFolder fromPath:(NSString *)fromPath type:(NXFileChooseFlowViewControllerType)type;
- (instancetype) initWithRepository:(NXRepositoryModel *)repoModel type:(NXFileChooseFlowViewControllerType)type isSupportMultipleSelect:(BOOL)supportMultiple;
- (instancetype) initWithProject:(NXProjectModel *)project type:(NXFileChooseFlowViewControllerType)type;
- (instancetype) initWithWorkSpaceType:(NXFileChooseFlowViewControllerType)type;
- (instancetype) initWithMyVaultType:(NXFileChooseFlowViewControllerType)type;
@property(nonatomic, weak)id<NXFileChooseFlowViewControllerDelegate> fileChooseVCDelegate;
@property(nonatomic, assign)NXFileChooseFlowViewControllerType type;
@property(nonatomic, strong) NXRepositoryModel *repoModel;
@property(nonatomic, strong) NXProjectModel *projectModel;
@property(nonatomic, assign) BOOL supportMultipleSelect;
@end
