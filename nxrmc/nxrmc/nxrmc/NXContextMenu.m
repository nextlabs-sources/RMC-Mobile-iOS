//
//  NXContextMenu.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 6/2/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXContextMenu.h"
#import "NXCustomActionSheetViewController.h"
#import "NXCommonUtils.h"
#import "NXLoginUser.h"

@implementation NXContextMenuHandler

- (instancetype)initWithType:(NXContextMenuType)type action:(NXContextMenuAction)action context:(id)data {
    if (self = [super init]) {
        self.type = type;
        self.action = action;
        self.data = data;
    }
    return self;
}

@end

@interface NXContextMenu ()

@property(nonatomic) NXContextMenuType type;
@property(nonatomic, strong) NXCustomActionSheetViewController *actionSheetVC;
@property(nonatomic, copy) void(^completeHandler)(NXContextMenuHandler *);

@end

@implementation NXContextMenu

+ (NXContextMenu *)showType:(NXContextMenuType)contextMenuType withHandler:(void (^)(NXContextMenuHandler *handler))completehandler {
    NXContextMenu *contextMenu = [[NXContextMenu alloc] initWithType:contextMenuType complete:completehandler];
    [contextMenu show];
    return contextMenu;
}
+ (NXContextMenu *)showType:(NXContextMenuType)contextMenuType andCurrentModel:(id)model withHandler:(void (^)(NXContextMenuHandler *handler))completehandler {
    NXContextMenu *contextMenu = [[NXContextMenu alloc] initWithType:contextMenuType andCurrentModel:model complete:completehandler];
    [contextMenu show];
    return contextMenu;
}
- (instancetype)initWithType:(NXContextMenuType)type complete:(void (^)(NXContextMenuHandler *handler))completehandler {
    if (self = [super init]) {
        self.type = type;
        self.completeHandler = completehandler;
        [self commonInit];
    }
    return self;
}
- (instancetype)initWithType:(NXContextMenuType)type andCurrentModel:(id)currentModel complete:(void (^)(NXContextMenuHandler *handler))completehandler {
    if (self = [super init]) {
        self.type = type;
        self.currentModel = currentModel;
        self.completeHandler = completehandler;
        [self commonInit];
    }
    return self;
}
- (void)show {
    [self.actionSheetVC show];
}

#pragma mark
- (void)commonInit {
    NXCustomActionSheetViewController *actionSheetVC = [[NXCustomActionSheetViewController alloc]init];
    self.actionSheetVC = actionSheetVC;
    switch (self.type) {
        case NXContextMenuTypeMySkyDRMHome:
        {
            [actionSheetVC addItem:[self protectAction]];
            [actionSheetVC addItem:[self shareItem]];
            [actionSheetVC addItem:[ self addNXlFileToOtherSpace]];
            [actionSheetVC addItem:[self viewLocalFile]];
            [actionSheetVC addItem:[self connectItem]];
    
            if ([self shouldShowCreateProjectItem]) {
                [actionSheetVC addItem:[self newProject]];
            }
        }
            break;
        case  NXContextMenuTypeRepositories:
        {
            [actionSheetVC addItem:[self protectAction]];
            [actionSheetVC addItem:[self connectItem]];
        }
            break;
        case NXContextMenuTypeRepositoryDetailFiles:
        {
            [actionSheetVC addItem:[self protectAction]];
        }
            break;
        case NXContextMenuTypeMySpaceMyVault:
        {
            [actionSheetVC addItem:[self protectAction]];
            [actionSheetVC addItem:[self shareItem]];
           
        }
            break;
        case NXContextMenuTypeMySpaceRootPage:
        {
            [actionSheetVC addItem:[self protectAction]];
            [actionSheetVC addItem:[self shareItem]];
            
        }
            break;
        case NXContextMenuTypeMySpaceMyDriveAll: //protect, share, connect, add file, create new folder, scan document.
        {
//            [actionSheetVC addItem:[self shareItem]];
            [actionSheetVC addItem:[self protectAction]];
//            [actionSheetVC addItem:[self divideLineItem]];

            [actionSheetVC addItem:[self createNewFolder]];
            [actionSheetVC addItem:[self addFileItem]];
//            [actionSheetVC addItem:[self scanDocumentItem]];
        }
            break;
        case NXContextMenuTypeProjectHome: //go to all Project,  Add file, invite member, create new folder, scan document
        {
            [actionSheetVC addItem:[self goToAllProject]];
            [actionSheetVC addItem:[self divideLineItem]];
            [actionSheetVC addItem:[self protectAction]];
            [actionSheetVC addItem:[ self addNXlFileToOtherSpace]];
            [actionSheetVC addItem:[self inviteMember]];
//            [actionSheetVC addItem:[self createNewFolder]];
//            [actionSheetVC addItem:[self scanDocumentItem]];
        }
            break;
        case NXContextMenuTypeProjectByMeFiles:
            [actionSheetVC addItem:[self protectAction]];
            [actionSheetVC addItem:[ self addNXlFileToOtherSpace]];
            [actionSheetVC addItem:[self createProjectFolder]];
            [actionSheetVC addItem:[self divideLineItem]];
            [actionSheetVC addItem:[self configurationProject]];
            [actionSheetVC addItem:[self inviteMember]];
            [actionSheetVC addItem:[self viewMembers]];
            
            break;
        case NXContextMenuTypeProjectByOthersFiles:
            [actionSheetVC addItem:[self protectAction]];
            [actionSheetVC addItem:[ self addNXlFileToOtherSpace]];
            [actionSheetVC addItem:[self createProjectFolder]];
            [actionSheetVC addItem:[self divideLineItem]];

            [actionSheetVC addItem:[self inviteMember]];
            [actionSheetVC addItem:[self viewMembers]];
            
            break;
        case NXContextMenuTypeProjectSummary: //Add file, create new folder, scan document.
        {
            [actionSheetVC addItem:[self protectAction]];
            [actionSheetVC addItem:[ self addNXlFileToOtherSpace]];
            [actionSheetVC addItem:[self createNewFolder]];
//            [actionSheetVC addItem:[self scanDocumentItem]];
        }
            break;
        case NXContextMenuTypeProjectPeople: //invite people.
        {
            [actionSheetVC addItem:[self inviteMember]];
        }
            break;
        case NXContextMenuTypeWorkSpaceAllTenantAdmin:
            [actionSheetVC addItem:[self protectAction]];
            [actionSheetVC addItem:[self addNXLFileDefaultToWorkspace]];
            [actionSheetVC addItem:[self createNewFolderFromWorkSpace]];
            break;
        case NXContextMenuTypeWorkSpaceAllUsual:
            [actionSheetVC addItem:[self protectAction]];
            [actionSheetVC addItem:[self addNXLFileDefaultToWorkspace]];
            break;
        case NXContextMenuTypeAllProjects:
            [actionSheetVC addItem:[self protectAction]];;
            break;
        default:
            break;
    }
}

#pragma mark
- (NXActionSheetItem *)protectActionButUnable {
    //Protect sub menu items.
    NSMutableArray *subProtectItems = [NSMutableArray array];
    [subProtectItems addObject:[self uploadFromLibraryItemWithType:NXContextMenuActionProtect]];;
    [subProtectItems addObject:[self scanDocumentItemForProtecting]];
    [subProtectItems addObject:[self uploadFromFilesItemWithType:NXContextMenuActionProtect]];
    [subProtectItems addObject:[self descriptionItem:NSLocalizedString(@"UI_CHOOSE_REPO_TO_SELECT_FILE", NULL)]];
    [subProtectItems addObjectsFromArray:[self repoActionItemswithType:NXContextMenuActionProtect]];
    
    NXActionSheetItem *sheetItem = [NXActionSheetItem initWithTitle:NSLocalizedString(@"UI_CREATE_A_PROTECTED_FILE", NULL) image:[UIImage imageNamed:@"Protect"] subItems:subProtectItems action:nil];
    sheetItem.isUnable = YES;
    return  sheetItem;
}
- (NXActionSheetItem *)protectAction {
    //Protect sub menu items.
    NSMutableArray *subProtectItems = [NSMutableArray array];
    [subProtectItems addObject:[self uploadFromLibraryItemWithType:NXContextMenuActionProtect]];;
    [subProtectItems addObject:[self scanDocumentItemForProtecting]];
    [subProtectItems addObject:[self uploadFromFilesItemWithType:NXContextMenuActionProtect]];
    [subProtectItems addObject:[self selectFilesFromMyDrvieForProtecting]];
    [subProtectItems addObjectsFromArray:[self repoActionItemswithType:NXContextMenuActionProtect]];
    
    return [NXActionSheetItem initWithTitle:NSLocalizedString(@"UI_CREATE_A_PROTECTED_FILE", NULL) image:[UIImage imageNamed:@"Protect"] subItems:subProtectItems action:nil];
}

- (NXActionSheetItem *)shareItem {
    NSMutableArray *subShareItems = [NSMutableArray array];
    [subShareItems addObject:[self uploadFromLibraryItemWithType:NXContextMenuActionShare]];
    [subShareItems addObject:[self scanDocumentItemForSharing]];
    [subShareItems addObject:[self uploadFromFilesItemWithType:NXContextMenuActionShare]];
    [subShareItems addObject:[self selectFilesFromMyDrvieForSharing]];
//    [subShareItems addObject:[self descriptionItem:NSLocalizedString(@"UI_CHOOSE_REPO_TO_SELECT_FILE", NULL)]];
    [subShareItems addObjectsFromArray:[self repoActionItemswithType:NXContextMenuActionShare]];
    return [NXActionSheetItem initWithTitle:NSLocalizedString(@"UI_SHARE_A_PROTEDTED_FILE", NULL) image:[UIImage imageNamed:@"Share1"] subItems:subShareItems action:nil];
}
- (NXActionSheetItem *)addNxlFileFromFilesAndRepoToOtherSpace{
    NSMutableArray *subAddItems = [NSMutableArray array];
    [subAddItems addObject:[self addnxlFileToOtherFromFiles]];
    [subAddItems addObjectsFromArray:[self repoActionNXlItemswithType:NXContextMenuActionAddNXLFileToOtherSpaceFromRepo]];
    return [NXActionSheetItem initWithTitle:NSLocalizedString(@"UI_ADD_PROTECTED_FILE", NULL) image:[UIImage imageNamed:@"Add File"] subItems:subAddItems action:nil];
}
- (NXActionSheetItem *)addNXlFileToOtherSpace {
    NSMutableArray *subAddItems = [NSMutableArray array];
    [subAddItems addObject:[self descriptionItem:@"Choose a protected file (.nxl) from the source directory below"]];
    [subAddItems addObject:[self addnxlFileToOtherFromFiles]];
    if ([NXCommonUtils isSupportWorkspace]){
        [subAddItems addObject:[self addNXLFileFromWorkSpace]];
    }
    [subAddItems addObject:[self addNXLFileFromMySpace]];
    [subAddItems addObjectsFromArray:[self repoActionItemswithType:NXContextMenuActionAddNXLFileFromRepo]];
    [subAddItems addObjectsFromArray:[self addNXlFromProjects]];
    return [NXActionSheetItem initWithTitle:@"Add protected file" image:[UIImage imageNamed:@"Add File"] subItems:subAddItems action:nil];
}
- (NXActionSheetItem *)viewLocalFile {
    WeakObj(self);
    return [NXActionSheetItem initWithTitle:@"View local file" image:[UIImage imageNamed:@"view local file-black"] subItems:nil action:^(NXCustomActionSheetWindow *window) {
        StrongObj(self);
        if (self.completeHandler) {
            self.completeHandler([[NXContextMenuHandler alloc]initWithType:self.type action:NXContextMenuActionViewLocalFile context:nil]);
        }
    }];
   
}
- (NXActionSheetItem *)addNXLFileDefaultToWorkspace {
    NSMutableArray *subAddItems = [NSMutableArray array];
    [subAddItems addObject:[self descriptionItem:@"Choose a protected file (.nxl) from the source directory below"]];
    [subAddItems addObject:[self addnxlFileToOtherFromFiles]];
    [subAddItems addObject:[self addNXLFileFromMySpace]];
    [subAddItems addObjectsFromArray:[self repoActionItemswithType:NXContextMenuActionAddNXLFileFromRepo]];
    [subAddItems addObjectsFromArray:[self addNXlFromProjects]];
    return [NXActionSheetItem initWithTitle:@"Add protected file" image:[UIImage imageNamed:@"Add File"] subItems:subAddItems action:nil];
    
}
- (NXActionSheetItem *)addNXLFileFromWorkSpace {
    WeakObj(self);
    return   [NXActionSheetItem initWithTitle:NSLocalizedString(@"UI_WORKSPACE_ITEM", NULL) image:[UIImage imageNamed:@"Black-workspace-icon"] subItems:nil action:^(NXCustomActionSheetWindow *window) {
        StrongObj(self);
        if(self.completeHandler){
            self.completeHandler([[NXContextMenuHandler alloc] initWithType:self.type action:NXContextMenuActionAddNXLFileFromWorkSpace context:nil]);
        }
    }];
}
- (NXActionSheetItem *)addNXLFileFromMySpace {
    WeakObj(self);
    return [NXActionSheetItem initWithTitle:@"MySpace" image:[UIImage imageNamed:@"MyDrive"] subItems:nil action:^(NXCustomActionSheetWindow *window) {
        StrongObj(self);
        if (self.completeHandler) {
            self.completeHandler([[NXContextMenuHandler alloc]initWithType:self.type action:NXContextMenuActionAddNXLFileFromMySpace context:nil]);
        }
    }];
    
}
- (NXActionSheetItem *)connectItem {
    WeakObj(self);
    return [NXActionSheetItem initWithTitle:NSLocalizedString(@"UI_CONNECT", NULL) image:[UIImage imageNamed:@"Connect1"] subItems:nil action:^(NXCustomActionSheetWindow *window) {
        StrongObj(self);
        if (self.completeHandler) {
            self.completeHandler([[NXContextMenuHandler alloc]initWithType:self.type action:NXContextMenuActionConnect context:nil]);
        }
    }];
}

- (NXActionSheetItem *)newProject {
    WeakObj(self);
    return [NXActionSheetItem initWithTitle:NSLocalizedString(@"Create New Project", NULL) image:[UIImage imageNamed:@"add - black"] subItems:nil action:^(NXCustomActionSheetWindow *window) {
        StrongObj(self);
        if (self.completeHandler) {
            self.completeHandler([[NXContextMenuHandler alloc]initWithType:self.type action:NXContextMenuActionNewProject context:nil]);
        }
    }];
}

- (NXActionSheetItem *)addFileItem {
    NSMutableArray *subAddFileItems = [NSMutableArray array];
    [subAddFileItems addObject:[self addPhotoFileItem]];
    [subAddFileItems addObject:[self scanDocumentItem]];
    [subAddFileItems addObject:[self addFilesAppFileItem]];
    WeakObj(self);
    return [NXActionSheetItem initWithTitle:NSLocalizedString(@"UI_ADD_FILE", NULL) image:[UIImage imageNamed:@"Add File"] subItems:subAddFileItems action:^(NXCustomActionSheetWindow *window) {
        StrongObj(self);
        if (self.completeHandler) {
            self.completeHandler([[NXContextMenuHandler alloc]initWithType:self.type action:NXContextMenuActionAddFile context:nil]);
        }
    }];
}

- (NXActionSheetItem *)addLocalFileItem {
    WeakObj(self);
    return [NXActionSheetItem initWithTitle:NSLocalizedString(@"UI_PHOTO_LIBRARY", NULL) image:[UIImage imageNamed:@"Photo-library"] subItems:nil action:^(NXCustomActionSheetWindow *window) {
        StrongObj(self);
        if (self.completeHandler) {
            self.completeHandler([[NXContextMenuHandler alloc]initWithType:self.type action:NXContextMenuActionAddFileToProjectFromLocal context:nil]);
        }
    }];
}
- (NXActionSheetItem *)addPhotoFileItem {
    WeakObj(self);
    return [NXActionSheetItem initWithTitle:NSLocalizedString(@"UI_PHOTO_LIBRARY", NULL) image:[UIImage imageNamed:@"Photo-library"] subItems:nil action:^(NXCustomActionSheetWindow *window) {
        StrongObj(self);
        if (self.completeHandler) {
            self.completeHandler([[NXContextMenuHandler alloc]initWithType:self.type action:NXContextMenuActionAddFile context:nil]);
        }
    }];
}
- (NXActionSheetItem *)addFilesAppFileItem {
    WeakObj(self);
    return [NXActionSheetItem initWithTitle:NSLocalizedString(@"UI_ADD_FROM_FILES", NULL) image:[UIImage imageNamed:@"FilesIcon"] subItems:nil action:^(NXCustomActionSheetWindow *window) {
        StrongObj(self);
        if (self.completeHandler) {
            self.completeHandler([[NXContextMenuHandler alloc]initWithType:self.type action:NXContextMenuActionAddFile context:@"Files"]);
        }
    }];
}
- (NXActionSheetItem *)createNewFolderFromWorkSpace {
    return [NXActionSheetItem initWithTitle:NSLocalizedString(@"UI_COM_CREATE_NEW_FOLDER", NULL) image:[UIImage imageNamed:@"folder-add"] subItems:nil action:^(NXCustomActionSheetWindow *window) {
        if (self.completeHandler) {
            self.completeHandler([[NXContextMenuHandler alloc]initWithType:self.type action:NXContextMenuActionCreateFolderFromWorkspace context:nil]);
        }
    }];
}
- (NXActionSheetItem *)addLocalFileItemToWorkSpace {
    WeakObj(self);
    return [NXActionSheetItem initWithTitle:NSLocalizedString(@"UI_PHOTO_LIBRARY", NULL) image:[UIImage imageNamed:@"Photo-library"] subItems:nil action:^(NXCustomActionSheetWindow *window) {
        StrongObj(self);
        if (self.completeHandler) {
            self.completeHandler([[NXContextMenuHandler alloc]initWithType:self.type action:NXContextMenuActionAddFileToWorkSpaceFromLocal context:nil]);
        }
    }];
}

- (NXActionSheetItem *)addLocalFileItemToProject {
    WeakObj(self);
    return [NXActionSheetItem initWithTitle:NSLocalizedString(@"UI_PHOTO_LIBRARY", NULL) image:[UIImage imageNamed:@"Photo-library"] subItems:nil action:^(NXCustomActionSheetWindow *window) {
        StrongObj(self);
        if (self.completeHandler) {
            self.completeHandler([[NXContextMenuHandler alloc]initWithType:self.type action:NXContextMenuActionAddFileToProjectFromLocal context:nil]);
        }
    }];
}

- (NXActionSheetItem *)createNewFolder {
    return [NXActionSheetItem initWithTitle:NSLocalizedString(@"UI_COM_CREATE_NEW_FOLDER", NULL) image:[UIImage imageNamed:@"folder-add"] subItems:nil action:^(NXCustomActionSheetWindow *window) {
        if (self.completeHandler) {
            self.completeHandler([[NXContextMenuHandler alloc]initWithType:self.type action:NXContextMenuActionCreateFolder context:nil]);
        }
    }];
}
- (NXActionSheetItem *)createProjectFolder {
    return [NXActionSheetItem initWithTitle:NSLocalizedString(@"UI_COM_CREATE_NEW_FOLDER", NULL) image:[UIImage imageNamed:@"folder-add"] subItems:nil action:^(NXCustomActionSheetWindow *window) {
        if (self.completeHandler) {
            self.completeHandler([[NXContextMenuHandler alloc]initWithType:self.type action:NXContextMenuActionCreateProjectFolder context:nil]);
        }
    }];
}
- (NXActionSheetItem *)scanDocumentItem {
    WeakObj(self);
    return [NXActionSheetItem initWithTitle:NSLocalizedString(@"UI_COM_CAMERA", NULL) image:[UIImage imageNamed:@"camera - black"] subItems:nil action:^(NXCustomActionSheetWindow *window) {
        StrongObj(self);
        if (self.completeHandler) {
            self.completeHandler([[NXContextMenuHandler alloc]initWithType:self.type action:NXContextMenuActionScanDocument context:nil]);
        }
    }];
}
- (NXActionSheetItem *)selectFilesFromMyDrvieForProtecting {
    WeakObj(self);
    return [NXActionSheetItem initWithTitle:@"MySpace" image:[UIImage imageNamed:@"MyDrive"] subItems:nil action:^(NXCustomActionSheetWindow *window) {
        StrongObj(self);
        if (self.completeHandler) {
            self.completeHandler([[NXContextMenuHandler alloc]initWithType:self.type action:NXContextMenuActionSelectFileFromMyDriveForProtecting context:nil]);
        }
    }];
    
}
- (NXActionSheetItem *)selectFilesFromMyDrvieForSharing {
    WeakObj(self);
    return [NXActionSheetItem initWithTitle:@"MySpace" image:[UIImage imageNamed:@"MyDrive"] subItems:nil action:^(NXCustomActionSheetWindow *window) {
        StrongObj(self);
        if (self.completeHandler) {
            self.completeHandler([[NXContextMenuHandler alloc]initWithType:self.type action:NXContextMenuActionActionMyDriveForSharing context:nil]);
        }
    }];
    
}
- (NXActionSheetItem *)scanDocumentItemForProtecting {
    WeakObj(self);
    return [NXActionSheetItem initWithTitle:NSLocalizedString(@"UI_COM_CAMERA", NULL) image:[UIImage imageNamed:@"camera - black"] subItems:nil action:^(NXCustomActionSheetWindow *window) {
        StrongObj(self);
        if (self.completeHandler) {
            self.completeHandler([[NXContextMenuHandler alloc]initWithType:self.type action:NXContextMenuActionActionScanDocumentForProtecting context:nil]);
        }
    }];
}
- (NXActionSheetItem *)scanDocumentItemForSharing {
    WeakObj(self);
    return [NXActionSheetItem initWithTitle:NSLocalizedString(@"UI_COM_CAMERA", NULL) image:[UIImage imageNamed:@"camera - black"] subItems:nil action:^(NXCustomActionSheetWindow *window) {
        StrongObj(self);
        if (self.completeHandler) {
            self.completeHandler([[NXContextMenuHandler alloc]initWithType:self.type action:NXContextMenuActionActionScanDocumentForSharing context:nil]);
        }
    }];
}


- (NXActionSheetItem *)addnxlFileToOtherFromFiles {
    WeakObj(self);
          return [NXActionSheetItem initWithTitle:NSLocalizedString(@"UI_ADD_FROM_FILES", NULL)  image:[UIImage imageNamed:@"FilesIcon"] subItems:nil action:^(NXCustomActionSheetWindow *window) {
              StrongObj(self);
              if (self.completeHandler) {
                  self.completeHandler([[NXContextMenuHandler alloc]initWithType:self.type action:NXContextMenuActionAddNXLFileToProjectOrWorkSpaceFromFiles context:nil]);
              }
          }];
    
}
- (NXActionSheetItem *)goToAllProject {
    WeakObj(self);
    return [NXActionSheetItem initWithTitle:NSLocalizedString(@"UI_GO_TO_ALL_PROJECTS", NULL) image:[UIImage imageNamed:@"AllProjects_P"] subItems:nil action:^(NXCustomActionSheetWindow *window) {
        StrongObj(self);
        if (self.completeHandler) {
            self.completeHandler([[NXContextMenuHandler alloc]initWithType:self.type action:NXContextMenuActionGoToAllProject context:nil]);
        }
    }];
}
- (NXActionSheetItem *)inviteMember {
    WeakObj(self);
    return [NXActionSheetItem initWithTitle:NSLocalizedString(@"UI_COM_INVITE_MEMBERS", NULL) image:[UIImage imageNamed:@"Add Member"] subItems:nil action:^(NXCustomActionSheetWindow *window) {
        StrongObj(self);
        if (self.completeHandler) {
            self.completeHandler([[NXContextMenuHandler alloc]initWithType:self.type action:NXContextMenuActionInviteMember context:nil]);
        }
    }];
}
- (NXActionSheetItem *)configurationProject {
    WeakObj(self);
    return [NXActionSheetItem initWithTitle:NSLocalizedString(@"UI_PROJECT_CONFIGURATION", NULL) image:[UIImage imageNamed:@"Settings.png"] subItems:nil action:^(NXCustomActionSheetWindow *window) {
        StrongObj(self);
        if (self.completeHandler) {
            self.completeHandler([[NXContextMenuHandler alloc]initWithType:self.type action:NXContextMenuActionProjectConfiguration context:nil]);
        }
    }];
    
}
- (NXActionSheetItem *)viewMembers {
    WeakObj(self);
    return [NXActionSheetItem initWithTitle:NSLocalizedString(@"UI_COM_VIEW_MEMBERS", NULL) image:[UIImage imageNamed:@"View_members"] subItems:nil action:^(NXCustomActionSheetWindow *window) {
        StrongObj(self);
        if (self.completeHandler) {
            self.completeHandler([[NXContextMenuHandler alloc]initWithType:self.type action:NXContextMenuActionViewMembers context:nil]);
        }
    }];
}
#pragma mark
- (NXActionSheetItem *) divideLineItem {
    NXActionSheetItem *divideLineItem = [NXActionSheetItem initWithTitle:@"" image:nil subItems:nil action:nil];
    divideLineItem.shouldDisplayDividerLine = YES;
    return divideLineItem;
}
- (NXActionSheetItem *)descriptionItem:(NSString *)message {
    NXActionSheetItem *description = [[NXActionSheetItem alloc]init];
    description.promptTitle = message;
    return description;
}

- (NSArray<NXActionSheetItem *> *)repoActionItemswithType:(NXContextMenuAction)action {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSArray *repoArray = nil;
   
    if (action == NXContextMenuActionShare) {
        // Now it only support presonal repositories
        repoArray = [[NXLoginUser sharedInstance].myRepoSystem allAuthReposioriesExceptApplicationRepos];
    }else{
        repoArray = [[NXLoginUser sharedInstance].myRepoSystem allAuthReposioriesExceptMyDrive];
    }
    if (repoArray.count) {
        if (action == NXContextMenuActionShare || action == NXContextMenuActionProtect) {
            [array addObject:[self descriptionItem:NSLocalizedString(@"UI_CHOOSE_REPO_TO_SELECT_FILE", NULL)]];
        }else if(action == NXContextMenuActionAddNXLFileFromRepo){
            [array addObject:[self descriptionItem:@"Repositories"]];
        }
       
    }
    for (NXRepositoryModel *repositoryModel in repoArray) {
       
          UIImage *image = [self repoTypeImage:repositoryModel];
                WeakObj(self);
        NXActionSheetItem *repoItem = [NXActionSheetItem initWithTitle:repositoryModel.service_alias image:image subItems:nil andRightImage:[NXCommonUtils getProviderIconByRepoProviderClass:repositoryModel.service_providerClass]  action:^(NXCustomActionSheetWindow *window) {
                    StrongObj(self);
                    if (self.completeHandler && repositoryModel) {
                        self.completeHandler([[NXContextMenuHandler alloc]initWithType:self.type action:action context:repositoryModel]);
                    }
                }];
                // just for entereprise not support third repo
        //        if (buildFromSkyDRMEnterpriseTarget && [NXCommonUtils isCompanyAccountLogin]) {
        //            if (repositoryModel.service_type.integerValue == kServiceSkyDrmBox) {
        //                [array addObject:repoItem];
        //            }
        //        }else {
                    [array addObject:repoItem];
        //        }
    }
    return array;
}
- (NSArray<NXActionSheetItem *> *)addNXlFromProjects{
    __block NSMutableArray *array = [[NSMutableArray alloc] init];
    __block NSMutableArray *allArray = [[NSMutableArray alloc] init];
    NSMutableArray *projectItems = [NSMutableArray array];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [[NXLoginUser sharedInstance].myProject allMyProjectsWithCompletion:^(NSArray *projectsCreatedByMe, NSArray *projectsInvitedByOthers, NSArray *pendingProjects, NSError *error) {
        
            if (!error) {
                [allArray addObjectsFromArray:projectsCreatedByMe];
                [allArray addObjectsFromArray:projectsInvitedByOthers];
            }
            dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if (!allArray.count) {
        return nil;
    }
    for (NXProjectModel *projectModel in allArray) {
        if (self.currentModel && [self.currentModel isKindOfClass:[NXProjectModel class]]) {
            NXProjectModel *currentModel = (NXProjectModel *)self.currentModel;
            if (![projectModel.projectId isEqualToNumber:currentModel.projectId]) {
                [array addObject:projectModel];
            }
        }else{
            array = [allArray copy];
        }
    }
    if (array.count) {
       [projectItems addObject:[self descriptionItem:@"Projects"]];
    }
   
        for (NXProjectModel *projectModel in array) {
            WeakObj(self);
            UIImage *image = nil;
            if (projectModel.isOwnedByMe) {
                image = [UIImage imageNamed:@"CreatedbyMe"];
            }else {
                image = [UIImage imageNamed:@"InvitedbyOthers"];
       
            }
           
            NXActionSheetItem *projectItem = [NXActionSheetItem initWithTitle:projectModel.name image:image subItems:nil action:^(NXCustomActionSheetWindow *window) {
                StrongObj(self);
                if (self.completeHandler && projectModel) {
                    self.completeHandler([[NXContextMenuHandler alloc]initWithType:self.type action:NXContextMenuActionAddNXLFileFromProject context:projectModel]);
                }
                
            }];
            
            [projectItems addObject:projectItem];
        }
    return projectItems;
}
- (NSArray<NXActionSheetItem *> *)repoActionNXlItemswithType:(NXContextMenuAction)action {
    NSMutableArray *array = [[NSMutableArray alloc] init];;
    for (NXRepositoryModel *repositoryModel in [[NXLoginUser sharedInstance].myRepoSystem allAuthReposioriesExceptMyDrive]) {
       
          UIImage *image = [self repoTypeImage:repositoryModel];
                WeakObj(self);
                NXActionSheetItem *repoItem = [NXActionSheetItem initWithTitle:repositoryModel.service_alias image:image subItems:nil action:^(NXCustomActionSheetWindow *window) {
                    StrongObj(self);
                    if (self.completeHandler && repositoryModel) {
                        self.completeHandler([[NXContextMenuHandler alloc]initWithType:self.type action:action context:repositoryModel]);
                    }
                }];
                // just for entereprise not support third repo
        //        if (buildFromSkyDRMEnterpriseTarget && [NXCommonUtils isCompanyAccountLogin]) {
        //            if (repositoryModel.service_type.integerValue == kServiceSkyDrmBox) {
        //                [array addObject:repoItem];
        //            }
        //        }else {
                    [array addObject:repoItem];
        //        }
    }
    return array;
}
- (NXActionSheetItem *)uploadFromLibraryItemWithType:(NXContextMenuAction)action {
    WeakObj(self);
    return [NXActionSheetItem initWithTitle:NSLocalizedString(@"UI_PHOTO_LIBRARY", NULL) image:[UIImage imageNamed:@"Photo-library"] subItems:nil action:^(NXCustomActionSheetWindow *window) {
        StrongObj(self);
        if (self.completeHandler) {
            self.completeHandler([[NXContextMenuHandler alloc]initWithType:self.type action:action context:nil]);
        }
    }];
}
- (NXActionSheetItem *)uploadFromFilesItemWithType:(NXContextMenuAction)action {
    WeakObj(self);
    return [NXActionSheetItem initWithTitle:NSLocalizedString(@"UI_ADD_FROM_FILES", NULL) image:[UIImage imageNamed:@"FilesIcon"] subItems:nil action:^(NXCustomActionSheetWindow *window) {
        StrongObj(self);
        if (self.completeHandler) {
            self.completeHandler([[NXContextMenuHandler alloc]initWithType:self.type action:action context:@"Files"]);
        }
    }];
}

#pragma mark
- (UIImage *)repoTypeImage:(NXRepositoryModel *)repoModel {
    UIImage *image = [UIImage imageNamed:@""];
    switch (repoModel.service_type.integerValue) {
        case kServiceSkyDrmBox:
            image = [UIImage imageNamed:@"MyDrive"];
            break;
        case kServiceDropbox:
            image = [UIImage imageNamed:@"dropbox - black"];
            break;
        case kServiceGoogleDrive:
            image = [UIImage imageNamed:@"google-drive-color"];
            break;
        case kServiceOneDrive:
            image = [UIImage imageNamed:@"onedrive - black"];
            break;
        case kServiceSharepoint:
            image = [UIImage imageNamed:@"sharepoint - black"];
            break;
        case kServiceSharepointOnline:
        case KServiceSharepointOnlineApplication:
            image = [UIImage imageNamed:@"sharepoint - black"];
            break;
        case kServiceBOX:
            image = [UIImage imageNamed:@"box - black"];
            break;
        case kServiceOneDriveApplication:
             image = [UIImage imageNamed:@"onedrive - black"];
            break;
        default:
            break;
    }
    return image;
}

- (BOOL)shouldShowCreateProjectItem {
   
    if (buildFromSkyDRMEnterpriseTarget && [NXCommonUtils isCompanyAccountLogin]) {
        return NO;
    }else {
       
        return YES;
    }
}

@end
