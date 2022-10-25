//
//  NXAddToProjectVC.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/3/13.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NXFileBase;
@class NXProjectModel;
@class NXRepositoryModel;
typedef NS_ENUM(NSUInteger, NXFileOperationType) {
    NXFileOperationTypeAddProjectFileToProject = 1,
    NXFileOperationTypeAddWorkSpaceFileToProject,
    NXFileOperationTypeAddProjectFileToWorkSpace,
    NXFileOperationTypeProjectFileReclassify,
    NXFileOperationTypeWorkSpaceFileReclassify,
    NXFileOperationTypeAddLocalProtectedFileToOther,
    NXFileOperationTypeAddRepoProtectedFileToOther,
    NXFileOperationTypeAddMyVaultFileToOther,
    NXFileOperationTypeAddWorkSPaceFileToOther,
    NXFileOperationTypeAddFileToSharedWorkspace,
    NXFileOperationTypeAddNXLFileToWorkSpace,
    NXFileOperationTypeAddNXLFileToProject,
    NXFileOperationTypeAddNXLFileToRepo,
    NXFileOperationTypeAddSharedWithMeFileToOther,
    NXFileOperationTypeAddNXLFileToMySpace,
};
@interface NXAddToProjectVC : UIViewController
@property(nonatomic, strong,nonnull)NXFileBase *currentFile;
@property(nonatomic, strong,nullable)NXProjectModel *fromProjectModel;
@property(nonatomic, strong,nullable)NXRepositoryModel *fromRepoModel;
@property(nonatomic, assign) NXFileOperationType fileOperationType;
@property(nonatomic, assign) BOOL isLocalFile;
@end
