//
//  NXContextMenu.h
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 6/2/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXRMCDef.h"

typedef void(^ClickActionBlock)(id sender);

typedef NS_ENUM(NSUInteger, NXContextMenuType) {
    NXContextMenuTypeMySkyDRMHome,
    NXContextMenuTypeWorkSpaceHome,
    NXContextMenuTypeMySpaceRootPage,
    NXContextMenuTypeRepositories,
    NXContextMenuTypeAllProjects,
    NXContextMenuTypeWorkSpaceAllUsual,
    NXContextMenuTypeWorkSpaceAllTenantAdmin,
    NXContextMenuTypeRepositoryDetailFiles,
    NXContextMenuTypeMySpaceMyDriveAll,
    NXContextMenuTypeMySpaceMyVault,
    
    NXContextMenuTypeProjectHome,
    NXContextMenuTypeProjectByMeFiles,
    NXContextMenuTypeProjectByOthersFiles,
  
    NXContextMenuTypeProjectSummary,
    NXContextMenuTypeProjectPeople,
};

typedef NS_ENUM(NSUInteger, NXContextMenuAction) {
    NXContextMenuActionProtect,
    NXContextMenuActionShare,
    NXContextMenuActionConnect,
    NXContextMenuActionNewProject,
    NXContextMenuActionScanDocument,
    NXContextMenuActionActionScanDocumentForProtecting,
    NXContextMenuActionSelectFileFromMyDriveForProtecting,
    NXContextMenuActionActionScanDocumentForSharing,
    NXContextMenuActionActionMyDriveForSharing,
    NXContextMenuActionScanDocumentToProject,
    NXContextMenuActionScanDocumentToWorkspace,
    NXContextMenuActionCreateFolder,
    NXContextMenuActionCreateProjectFolder,
    NXContextMenuActionCreateFolderFromWorkspace,
    NXContextMenuActionAddFile,
    NXContextMenuActionAddFileFromRepo,
    NXContextMenuActionAddFileToWorkSpaceFromRepo,
    NXContextMenuActionGoToAllProject,
    NXContextMenuActionAddFileToProjectFromLocal,
    NXContextMenuActionAddFileToProjectFromFilesApp,
    NXContextMenuActionAddFileToProjectFromRepo,
    NXContextMenuActionAddNXLFileToProjectOrWorkSpaceFromFiles,
    NXContextMenuActionAddFileToWorkSpaceFromLocal,
    NXContextMenuActionAddNXLFileToOtherSpaceFromRepo,
    NXContextMenuActionAddNXLFileFromWorkSpace,
    NXContextMenuActionAddNXLFileFromMySpace,
    NXContextMenuActionAddNXLFileFromProject,
    NXContextMenuActionAddNXLFileFromRepo,
    NXContextMenuActionViewLocalFile,
    
    
    NXContextMenuActionInviteMember,
    NXContextMenuActionViewMembers,
    NXContextMenuActionProjectConfiguration,
};

@interface NXContextMenuHandler : NSObject

@property(nonatomic) NXContextMenuType type;
@property(nonatomic) NXContextMenuAction action;
@property(nonatomic, strong) id data;

- (instancetype)initWithType:(NXContextMenuType)type action:(NXContextMenuAction)action context:(id)data;

@end

@interface NXContextMenu : NSObject
@property(nonatomic, strong)id currentModel;
+ (NXContextMenu *)showType:(NXContextMenuType)contextMenuType withHandler:(void (^)(NXContextMenuHandler *handler))completehandler;
+ (NXContextMenu *)showType:(NXContextMenuType)contextMenuType andCurrentModel:(id)model withHandler:(void (^)(NXContextMenuHandler *handler))completehandler;
- (void)show;
@end
