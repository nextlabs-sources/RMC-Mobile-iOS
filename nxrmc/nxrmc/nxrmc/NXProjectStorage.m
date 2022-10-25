//
//  NXProjectStorage.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 12/9/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXProjectStorage.h"
#import "NXProjectItem+CoreDataClass.h"
#import "NXProjectMemberItem+CoreDataClass.h"
#import "NXPendingMemberItem+CoreDataClass.h"
#import "NXProjectFileItem+CoreDataClass.h"
#import "MagicalRecord.h"
#import "NXProjectModel.h"
#import "NXPendingProjectInvitationModel.h"
#import "NXLoginUser.h"
#import "NXProjectFolder.h"
#import "NXProjectFile.h"
#import "NXFile.h"
#import "NXCommonUtils.h"
#import "NXLProfile.h"
#import "NXFavoriteFile+CoreDataClass.h"
#import "NXOfflineFileItem+CoreDataClass.h"
NSInteger const summanyNumber = 9;

@implementation NXProjectStorage
#pragma mark ----> insert or update projectModel

+ (void)insertProjectModel:(NXProjectModel *)projectModel {
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NSNumber *projectId = projectModel.projectId;
        NXProjectItem *projectItem = [NXProjectItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"projectId==%@",projectId] inContext:localContext];
        if (!projectItem) {
            projectItem = [NXProjectItem MR_createEntityInContext:localContext];
        }
        projectItem.createdTime = projectModel.createdTime;
        projectItem.isOwnedByMe = projectModel.isOwnedByMe;
        projectItem.projectId = projectModel.projectId;
        projectItem.totalFiles = projectModel.totalFiles;
        projectItem.totalMembers = projectModel.totalMembers;
        projectItem.trialEndTime = projectModel.trialEndTime;
        projectItem.accountType = projectModel.accountType;
        projectItem.projectDescription = projectModel.projectDescription;
        projectItem.displayName = projectModel.displayName;
        projectItem.ownerInfo = projectModel.projectOwner;
        projectItem.invitationMsg = projectModel.invitationMsg?:projectItem.invitationMsg;
        projectItem.lastActionTime = projectModel.lastActionTime > projectItem.lastActionTime?projectModel.lastActionTime:projectItem.lastActionTime;
        projectItem.membershipId = projectModel.membershipId;
        projectItem.watermark = projectModel.watermark;
        projectItem.validateModel = projectModel.validateModel;
        projectItem.configurationModified = projectModel.configurationModified;
        projectItem.parentTenantName = projectModel.parentTenantName;
        projectItem.parentTenantId = projectModel.parentTenantId;
        projectItem.tokenGroupName = projectModel.tokenGroupName;
        for (NXProjectMemberModel *memberModel in projectModel.homeShowMembers) {
            NXProjectMemberItem *member = [NXProjectMemberItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"projectId==%@ and userId ==%@",memberModel.projectId,memberModel.userId] inContext:localContext];
            if (!member) {
                member = [NXProjectMemberItem MR_createEntityInContext:localContext];
            }
            member.projectId = memberModel.projectId;
            member.displayName = memberModel.displayName;
            member.userId = memberModel.userId;
            member.email = memberModel.email;
            member.joinTime = memberModel.joinTime;
            member.inviterEmail = memberModel.inviterEmail;
            member.inviterDisplayName = memberModel.inviterDisplayName;
            member.avatarUrl = memberModel.avatarUrl;
            member.avatarBase64 = memberModel.avatarBase64;
            [projectItem addProjectMembersObject:member];
        }
    }];
}

#pragma mark ----> insert projectModels
+ (void)insertProjectModels:(NSArray *)projectItemModels {
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    NSString *key = [NXLoginUser sharedInstance].profile.userId;
    if (![[NSUserDefaults standardUserDefaults]valueForKey:key]) {
         [[NSUserDefaults standardUserDefaults] setValue:@"isExistStroage" forKey:key];
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NSMutableSet *projectModelIdSet = [NSMutableSet set];
        for (NXProjectModel *projectModel in projectItemModels) {
            NSNumber *projectId = projectModel.projectId;
            [projectModelIdSet addObject:projectId];
            NXProjectItem *projectItem = [NXProjectItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"projectId==%@",projectId] inContext:localContext];
            if (!projectItem) {
                projectItem = [NXProjectItem MR_createEntityInContext:localContext];
            }
            projectItem.createdTime = projectModel.createdTime;
            projectItem.isOwnedByMe = projectModel.isOwnedByMe;
            projectItem.projectId = projectModel.projectId;
            projectItem.totalFiles = projectModel.totalFiles;
            projectItem.totalMembers = projectModel.totalMembers;
            projectItem.trialEndTime = projectModel.trialEndTime;
            projectItem.accountType = projectModel.accountType;
            projectItem.projectDescription = projectModel.projectDescription;
            projectItem.displayName = projectModel.displayName;
            projectItem.name = projectModel.name;
            projectItem.ownerInfo = projectModel.projectOwner;
            projectItem.invitationMsg = projectModel.invitationMsg?:projectItem.invitationMsg;
            projectItem.lastActionTime = projectModel.lastActionTime > projectItem.lastActionTime?projectModel.lastActionTime:projectItem.lastActionTime;
            projectItem.parentTenantId = projectModel.parentTenantId;
            projectItem.parentTenantName = projectModel.parentTenantName;
            projectItem.membershipId = projectModel.membershipId;
            projectItem.watermark = projectModel.watermark;
            projectItem.validateModel = projectModel.validateModel;
            projectItem.configurationModified = projectModel.configurationModified;
            projectItem.parentTenantName = projectModel.parentTenantName;
            projectItem.parentTenantId = projectModel.parentTenantId;
            projectItem.tokenGroupName = projectModel.tokenGroupName;
            
            for (NXProjectMemberModel *memberModel in projectModel.homeShowMembers) {
                NXProjectMemberItem *member = [NXProjectMemberItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"projectId==%@ and userId ==%@",memberModel.projectId,memberModel.userId] inContext:localContext];
                if (!member) {
                    member = [NXProjectMemberItem MR_createEntityInContext:localContext];
                }
                member.projectId = memberModel.projectId;
                member.displayName = memberModel.displayName;
                member.userId = memberModel.userId;
                member.email = memberModel.email;
                member.joinTime = memberModel.joinTime;
                member.inviterEmail = memberModel.inviterEmail;
                member.inviterDisplayName = memberModel.inviterDisplayName;
                member.avatarUrl = memberModel.avatarUrl;
                member.avatarBase64 = memberModel.avatarBase64;
                member.isProjectOwner = memberModel.isProjectOwner;
                [projectItem addProjectMembersObject:member];
            }
            
           

        }
        // delete storage exist but server is not exist.
        NSMutableSet *projectItemIdsSet = [self queryAllProjectIdListFromStorage];
        [projectItemIdsSet minusSet:projectModelIdSet];
        for (NSNumber *itemId in projectItemIdsSet) {
            [NXProjectItem MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"projectId == %@",itemId] inContext:localContext];
        }
    }];
}
#pragma mark -----> query project list
+ (NSMutableArray *)queryProjectListFromStorageWhichType:(NXProjectListType)byType {
    if (![NXLoginUser sharedInstance].isLogInState) {
        return [NSMutableArray array];
    }
    NSString *key = [NXLoginUser sharedInstance].profile.userId;
    if (![[NSUserDefaults standardUserDefaults] valueForKey:key]) {
        return nil;
    }

    NSPredicate *predicate;
    switch (byType) {
        case NXProjectListTypeByAll:
            predicate = nil;
            break;
        case NXProjectListTypeByMe:
            predicate = [NSPredicate predicateWithFormat:@"isOwnedByMe == %@",[NSNumber numberWithBool:YES]];
            break;
        case NXProjectListTypeByOther:
            predicate = [NSPredicate predicateWithFormat:@"isOwnedByMe == %@",[NSNumber numberWithBool:NO]];
        default:
            break;
    }
    NSFetchRequest *request = [NXProjectItem MR_createFetchRequestInContext:[NSManagedObjectContext MR_defaultContext]];
    [request setPredicate:predicate];
    [request setIncludesSubentities:YES];
    [request setReturnsDistinctResults:NO];
    [request setIncludesPendingChanges:YES];
    
    NSArray *fetchedObjects = [NXProjectItem MR_executeFetchRequest:request inContext:[NSManagedObjectContext MR_defaultContext]];
    NSMutableArray *projectArray = [NSMutableArray array];
    for (NXProjectItem *item in fetchedObjects) {
        NXProjectModel *model = [[NXProjectModel alloc]init];
        model.createdTime = item.createdTime;
        model.isOwnedByMe = item.isOwnedByMe;
        model.totalMembers = item.totalMembers;
        model.totalFiles = item.totalFiles;
        model.projectId = item.projectId;
        model.trialEndTime = item.trialEndTime;
        model.accountType = item.accountType;
        model.projectDescription = item.projectDescription;
        model.displayName = item.displayName;
        model.invitationMsg = item.invitationMsg;
        model.name = item.name;
        model.projectOwner = (NXProjectOwnerItem *)item.ownerInfo;
        model.lastActionTime = item.lastActionTime;
        model.homeShowMembers = (NSMutableArray*)[[self queryMemberByProjectId:item.projectId] allObjects];
        model.parentTenantId = item.parentTenantId;
        model.parentTenantName = item.parentTenantName;
        model.membershipId = item.membershipId;
        model.watermark = item.watermark;
        model.validateModel = (NXLFileValidateDateModel *)item.validateModel;
        model.configurationModified = item.configurationModified;
        model.parentTenantId = item.parentTenantId;
        model.parentTenantName = item.parentTenantName;
        model.tokenGroupName = item.tokenGroupName;
        [projectArray addObject:model];
    }
    return projectArray;
};

+ (NXProjectModel *)queryProjectModelByProjectModel:(NXProjectModel *)projectModel {
    if (![NXLoginUser sharedInstance].isLogInState) {
        return nil;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"projectId==%@",projectModel.projectId];
    NSFetchRequest *request = [NXProjectItem MR_createFetchRequestInContext:[NSManagedObjectContext MR_defaultContext]];
    
    [request setPredicate:predicate];
    [request setIncludesSubentities:YES];
    [request setReturnsDistinctResults:NO];
    [request setIncludesPendingChanges:YES];
    
    NSArray *fetchedObjects = [NXProjectItem MR_executeFetchRequest:request inContext:[NSManagedObjectContext MR_defaultContext]];
    if (fetchedObjects.count) {
        NXProjectItem *item = fetchedObjects.firstObject;
        NXProjectModel *model = [[NXProjectModel alloc]init];
        model.createdTime = item.createdTime;
        model.isOwnedByMe = item.isOwnedByMe;
        model.totalMembers = item.totalMembers;
        model.totalFiles = item.totalFiles;
        model.projectId = item.projectId;
        model.trialEndTime = item.trialEndTime;
        model.accountType = item.accountType;
        model.projectDescription = item.projectDescription;
        model.displayName = item.displayName;
        model.invitationMsg = item.invitationMsg;
        model.name = item.name;
        model.projectOwner = (NXProjectOwnerItem *)item.ownerInfo;
        model.homeShowMembers = (NSMutableArray *)item.homeShowMembers;
        model.parentTenantId = item.parentTenantId;
        model.parentTenantName = item.parentTenantName;
        model.membershipId = item.membershipId;
        model.watermark = item.watermark;
        model.validateModel = (NXLFileValidateDateModel *)item.validateModel;
        model.configurationModified = item.configurationModified;
        model.parentTenantId = item.parentTenantId;
        model.parentTenantName = item.parentTenantName;
        model.tokenGroupName = item.tokenGroupName;
        return model;
    }
    return nil;
    
}

+ (NSMutableSet *)queryAllProjectIdListFromStorage {
    if (![NXLoginUser sharedInstance].isLogInState) {
        return [NSMutableSet set];
    }
    NSMutableSet *storageProjectIdSet = [NSMutableSet set];
    NSFetchRequest *request = [NXProjectItem MR_createFetchRequestInContext:[NSManagedObjectContext MR_defaultContext]];

    [request setIncludesSubentities:YES];
    [request setReturnsDistinctResults:NO];
    [request setIncludesPendingChanges:YES];
    
    NSArray *fetchedObjects = [NXProjectItem MR_executeFetchRequest:request inContext:[NSManagedObjectContext MR_defaultContext]];
    for (NXProjectItem *item in fetchedObjects) {
        [storageProjectIdSet addObject:item.projectId];
    }
    return storageProjectIdSet;
}
#pragma mark -----> delete project
+ (void)deleteProjectModel:(NXProjectModel *)projectModel {
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
   [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
       [NXProjectItem MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"projectId==%@",projectModel.projectId] inContext:localContext];
   }];
}

#pragma mark -----> insert member to project
+ (void)insertMenber:(NXProjectMemberModel *)memberModel toProject:(NXProjectModel *)projectModel {
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NXProjectMemberItem *member = [NXProjectMemberItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"projectId == %@ and userId == %@",projectModel.projectId,memberModel.userId] inContext:localContext];
        if (!member) {
            member = [NXProjectMemberItem MR_createEntityInContext:localContext];
        }
        member.projectId = memberModel.projectId;
        member.displayName = memberModel.displayName;
        member.userId = memberModel.userId;
        member.email = memberModel.email;
        member.joinTime = memberModel.joinTime;
        member.inviterEmail = memberModel.inviterEmail;
        member.inviterDisplayName = memberModel.inviterDisplayName;
        member.avatarUrl = memberModel.avatarUrl;
        member.avatarBase64 = memberModel.avatarBase64;
    }];
}


+ (void)insertMembers:(NSArray *)members toProject:(NXProjectModel *)projectModel {
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NSMutableSet *membersSet = [NSMutableSet set];
        for (NXProjectMemberModel *memberModel in members) {
            [membersSet addObject:memberModel.userId];
            NXProjectMemberItem *member = [NXProjectMemberItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"projectId == %@ and userId == %@",projectModel.projectId,memberModel.userId] inContext:localContext];
            if (!member) {
                member = [NXProjectMemberItem MR_createEntityInContext:localContext];
            }
            member.projectId = memberModel.projectId;
            member.displayName = memberModel.displayName;
            member.userId = memberModel.userId;
            member.email = memberModel.email;
            member.joinTime = memberModel.joinTime;
            member.inviterEmail = memberModel.inviterEmail;
            member.inviterDisplayName = memberModel.inviterDisplayName;
            member.avatarUrl = memberModel.avatarUrl;
            member.avatarBase64 = memberModel.avatarBase64;
            // add relationShip for projectItem
            NXProjectItem *projectItem = [NXProjectItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"projectId==%@",projectModel.projectId] inContext:localContext];
            if (projectItem) {
                member.projectPartner = projectItem;
                [projectItem addProjectMembersObject:member];
            }
        }
        // sync for server
        NSMutableSet *itemsSet = [self queryMemberUserIdByProjectId:projectModel.projectId];
        [itemsSet minusSet:membersSet];
        for (NSNumber *userId in itemsSet) {
            [NXProjectMemberItem MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"projectId == %@ and userId == %@",projectModel.projectId,userId] inContext:localContext];
        }
        
    }];
}

#pragma mark ----->  query member by projectId
+ (NSMutableSet *)queryMemberByProjectId:(NSNumber *)projectId {
    if (![NXLoginUser sharedInstance].isLogInState) {
        return [NSMutableSet set];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"projectId==%@",projectId];
    NSFetchRequest *request = [NXProjectMemberItem MR_createFetchRequestInContext:[NSManagedObjectContext MR_defaultContext]];
    
    [request setPredicate:predicate];
    [request setIncludesSubentities:YES];
    [request setReturnsDistinctResults:NO];
    [request setIncludesPendingChanges:YES];
    NSMutableSet *memberSet = [NSMutableSet set];
    NSArray *fetchedObjects = [NXProjectMemberItem MR_executeFetchRequest:request inContext:[NSManagedObjectContext MR_defaultContext]];
    for (NXProjectMemberItem *item in fetchedObjects) {
        NXProjectMemberModel *member = [[NXProjectMemberModel alloc]init];
        member.projectId = item.projectId;
        member.displayName = item.displayName;
        member.email = item.email;
        member.inviterEmail = item.inviterEmail;
        member.inviterDisplayName = item.inviterDisplayName;
        member.joinTime = item.joinTime;
        member.avatarUrl = item.avatarUrl;
        member.avatarBase64 = item.avatarBase64;
        member.isProjectOwner = item.isProjectOwner;
        member.userId = item.userId;
        [memberSet addObject:member];
    }
    return memberSet;
}

+ (NSMutableSet *)queryMemberUserIdByProjectId:(NSNumber *)projectId {
    if (![NXLoginUser sharedInstance].isLogInState) {
        return [NSMutableSet set];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"projectId==%@",projectId];
    NSFetchRequest *request = [NXProjectMemberItem MR_createFetchRequestInContext:[NSManagedObjectContext MR_defaultContext]];
    [request setPredicate:predicate];
    [request setIncludesSubentities:YES];
    [request setReturnsDistinctResults:NO];
    [request setIncludesPendingChanges:YES];
    NSMutableSet *memberSet = [NSMutableSet set];
    NSArray *fetchedObjects = [NXProjectMemberItem MR_executeFetchRequest:request inContext:[NSManagedObjectContext MR_defaultContext]];
    for (NXProjectMemberItem *item in fetchedObjects) {
        [memberSet addObject:item.userId];
    }
    return memberSet;
 
}
#pragma mark  ------> delete project member from project
+ (void)deleteProjectMember:(NXProjectMemberModel *)member fromProject:(NXProjectModel *)projectModel {
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        [NXProjectMemberItem MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"projectId == %@ and userId == %@",projectModel.projectId,member.userId] inContext:localContext];
    }];
}

#pragma mark -----> Insert pending member for project
+ (void)insertPendingMembers:(NSArray *)pendingMembers toProject:(NXProjectModel *)projectModel {
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NSMutableSet *pendingMemberSet = [NSMutableSet set];
        for (NXPendingProjectInvitationModel *pendingMember in pendingMembers) {
            [pendingMemberSet addObject:pendingMember.invitationId];
            NXPendingMemberItem *item = [NXPendingMemberItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"projectId == %@ and invitationId == %@",projectModel.projectId,pendingMember.invitationId] inContext:localContext];
            if (!item) {
                item = [NXPendingMemberItem MR_createEntityInContext:localContext];
            }
            item.code = pendingMember.code;
            item.createdTime = pendingMember.createdTime;
            item.displayName = pendingMember.displayName;
            item.invitationId = pendingMember.invitationId;
            item.invitationMsg = pendingMember.invitationMsg;
            item.inviteeEmail = pendingMember.inviteeEmail;
            item.inviterEmail = pendingMember.inviterEmail;
            item.inviteTime = pendingMember.inviteTime;
            item.projectId = projectModel.projectId;
            item.inviterDisplayName = pendingMember.inviterDisplayName;
        }
        // sync from server
        NSMutableSet *pendingItemsSet = [self qureyAllPendingMemberInvationIdFromProject:projectModel];
        [pendingItemsSet minusSet:pendingMemberSet];
        for (NSNumber *itemInvitationId in pendingItemsSet) {
            [NXPendingMemberItem MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"projectId == %@ and invitationId == %@",projectModel.projectId,itemInvitationId] inContext:localContext];
        }
    }];
    
}
#pragma mark -----> Query pending member for project

+ (NSMutableSet *)qureyAllPendingMemberInvationIdFromProject:(NXProjectModel *)projectModel {
    if (![NXLoginUser sharedInstance].isLogInState) {
        return [NSMutableSet set];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"projectId==%@",projectModel.projectId];
    NSFetchRequest *request = [NXPendingMemberItem MR_createFetchRequestInContext:[NSManagedObjectContext MR_defaultContext]];
    
    [request setPredicate:predicate];
    [request setIncludesSubentities:YES];
    [request setReturnsDistinctResults:NO];
    [request setIncludesPendingChanges:YES];
    NSMutableSet *memberSet = [NSMutableSet set];
    NSArray *fetchedObjects = [NXPendingMemberItem MR_executeFetchRequest:request inContext:[NSManagedObjectContext MR_defaultContext]];
    for (NXPendingMemberItem *item in fetchedObjects) {
        [memberSet addObject:item.invitationId];
    }
    return memberSet;

}


+(NSMutableArray *)quertAllPendingMembersFromProject:(NXProjectModel *)projectModel {
    if (![NXLoginUser sharedInstance].isLogInState) {
        return [NSMutableArray array];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"projectId==%@",projectModel.projectId];
    NSFetchRequest *request = [NXPendingMemberItem MR_createFetchRequestInContext:[NSManagedObjectContext MR_defaultContext]];
    
    [request setPredicate:predicate];
    [request setIncludesSubentities:YES];
    [request setReturnsDistinctResults:NO];
    [request setIncludesPendingChanges:YES];
    NSMutableArray *membersArray = [NSMutableArray array];
    NSArray *fetchedObjects = [NXPendingMemberItem MR_executeFetchRequest:request inContext:[NSManagedObjectContext MR_defaultContext]];
    for (NXPendingMemberItem *item in fetchedObjects) {
        NXPendingProjectInvitationModel *model = [[NXPendingProjectInvitationModel alloc]init];
        model.projectId = item.projectId;
        model.code = item.code;
        model.createdTime = item.createdTime;
        model.displayName = item.displayName;
        model.invitationId = item.invitationId;
        model.invitationMsg = item.invitationMsg;
        model.inviteeEmail = item.inviteeEmail;
        model.inviterEmail = item.inviterEmail;
        model.inviterDisplayName = item.inviterDisplayName;
        model.inviteTime = item.inviteTime;
        
        [membersArray addObject:model];
    }
    return membersArray;
}

#pragma mark -----> Delete pending member for project
+ (void)deletePendingMember:(NXPendingProjectInvitationModel *)member fromProject:(NXProjectModel *)projectModel {
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
     [NXPendingMemberItem MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"projectId==%@ and invitationId == %@",projectModel.projectId,member.invitationId] inContext:localContext];
    }];
}

#pragma mark -------> Insert files for project
+ (void)insertProjectFiles:(NSArray *)files toFolder:(NSString *)folderPath toProject:(NXProjectModel *)projectModel {
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NSNumber *projectId = projectModel.projectId;
        for (NXFileBase *fileModel in files) {
            NSString *fileKey = [NXCommonUtils fileKeyForFile:fileModel];
            NXProjectFileItem *fileItem = [NXProjectFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"projectId==%@ and fileKey==%@",projectId,fileKey] inContext:localContext];
            if (!fileItem) {
                fileItem = [NXProjectFileItem MR_createEntityInContext:localContext];
            }
            if ([fileModel isKindOfClass:[NXProjectFolder class]]) {
                NXProjectFolder *folder = (NXProjectFolder *)fileModel;
                fileItem.folder = [NSNumber numberWithBool:folder.folder];
                fileItem.idid = folder.Id;
                fileItem.projectId = folder.projectId;
                fileItem.parentPath = folder.parentPath;
                fileItem.creationTime = folder.creationTime;
                fileItem.projectFileOwner = folder.projectFileOwner;
            } else if([fileModel isKindOfClass:[NXProjectFile class]]) {
                NXProjectFile *projectFile = (NXProjectFile *)fileModel;
                fileItem.duid = projectFile.duid;
                fileItem.idid = projectFile.Id;
                fileItem.folder = [NSNumber numberWithBool:NO];
                fileItem.projectId = projectFile.projectId;
              
                fileItem.creationTime = projectFile.creationTime;
                fileItem.projectFileOwner = projectFile.projectFileOwner;
                fileItem.fileType = projectFile.fileType;
                if (folderPath == nil ) {
                    // save summany file not parentPath return
                    NSString *parentPath = [fileModel.fullServicePath stringByDeletingLastPathComponent];
                    if (![parentPath isEqualToString:@"/"]) {
                        parentPath = [parentPath stringByAppendingString:@"/"];
                    }
                    fileItem.parentPath = parentPath;
                } else {
                    fileItem.parentPath = projectFile.parentPath;
                }
                fileItem.isShared = [NSNumber numberWithBool:projectFile.isShared];
                fileItem.sharedWithProject = projectFile.sharedWithProjectList;
                
                  // check if project file is off
                  NXOfflineFileItem *offlineFile = [NXOfflineFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fileKey==%@", fileKey] inContext:localContext];
                  if (offlineFile) {
                      fileItem.isOffline = [NSNumber numberWithBool:YES];
                      offlineFile.myProjectFilePartner = fileItem;
                      fileItem.offlineFilePartner = offlineFile;
                  }
            }
            fileItem.fullPath = fileModel.fullPath;
            fileItem.fullServicePath = fileModel.fullServicePath;
            fileItem.lastModifiedDate = fileModel.lastModifiedDate;
            fileItem.name = fileModel.name;
            fileItem.size = [NSNumber numberWithLongLong:fileModel.size];
            fileItem.lastModifiedTime = fileModel.lastModifiedTime;
            fileItem.fileKey = fileKey;
            
            // add relationShip for projectItem
            NXProjectItem *projectItem = [NXProjectItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"projectId==%@",projectModel.projectId] inContext:localContext];
            if (projectItem) {
                fileItem.projectPartner = projectItem;
                [projectItem addProjectFileObject:fileItem];
            }
        }
    }];
}
+ (void)insertProjectFile:(NXFileBase *)fileModel toParentFolder:(NSString *)folderPath toProjectModel:(NXProjectModel *)projectModel {
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    NSArray *fileList = @[fileModel];
    [self insertProjectFiles:fileList toFolder:folderPath toProject:projectModel];
}

#pragma mark -------> Query all file id from project
+ (NSMutableSet *)queryAllFilesIDFormParentFolder:(NSString *)folderPath ProjectModelId:(NSNumber *)projectId {
    if (![NXLoginUser sharedInstance].isLogInState) {
        return [NSMutableSet set];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"projectId==%@ and parentPath==%@",projectId,folderPath];
    NSFetchRequest *request = [NXProjectFileItem MR_createFetchRequestInContext:[NSManagedObjectContext MR_defaultContext]];
    [request setPredicate:predicate];
    NSMutableSet *memberSet = [NSMutableSet set];
    NSArray *fetchedObjects = [NXProjectFileItem MR_executeFetchRequest:request inContext:[NSManagedObjectContext MR_defaultContext]];
    for (NXProjectFileItem *item in fetchedObjects) {
        [memberSet addObject:item.fileKey];
    }
    return memberSet;
}
#pragma mark --------> query all file under folder from project
+ (NSMutableArray *)queryProjectFilesUnderFolder:(NSString *)folderPath fromProject:(NXProjectModel *)projectModel {
    if (![NXLoginUser sharedInstance].isLogInState) {
        return [NSMutableArray array];
    }
    NSMutableArray *fileArray = [NSMutableArray array];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"projectId==%@ and parentPath==%@",projectModel.projectId,folderPath];
    NSFetchRequest *request = [NXProjectFileItem MR_createFetchRequestInContext:[NSManagedObjectContext MR_defaultContext]];

    [request setPredicate:predicate];
    [request setIncludesPropertyValues:YES];
    [request setReturnsObjectsAsFaults:NO];
    [request setIncludesPendingChanges:YES];
    
     NSArray *fetchedObjects = [NXProjectFileItem MR_executeFetchRequest:request inContext:[NSManagedObjectContext MR_defaultContext]];
    for (NXProjectFileItem *fileItem in fetchedObjects) {
        if ([fileItem.folder boolValue]) {
            NXProjectFolder *projectFolder = [[NXProjectFolder alloc]init];
            projectFolder.folder = YES;
            projectFolder.fullServicePath = fileItem.fullServicePath;
            projectFolder.fullPath = fileItem.fullPath;
            projectFolder.name = fileItem.name;
            projectFolder.Id = fileItem.idid;
            projectFolder.creationTime = fileItem.creationTime;
            projectFolder.lastModifiedDate = fileItem.lastModifiedDate;
            projectFolder.size = [fileItem.size longLongValue];
            projectFolder.projectFileOwner = (NXProjectFileOwnerModel *)fileItem.projectFileOwner;
            projectFolder.projectId = fileItem.projectId;
            projectFolder.parentPath = fileItem.parentPath;
            projectFolder.lastModifiedTime = fileItem.lastModifiedTime;
            [fileArray addObject:projectFolder];
        } else {
            NXProjectFile *projectfile = [[NXProjectFile alloc]init];
            projectfile.fullServicePath = fileItem.fullServicePath;
            projectfile.fullPath = fileItem.fullPath;
            projectfile.name = fileItem.name;
            projectfile.Id = fileItem.idid;
            projectfile.creationTime = fileItem.creationTime;
            projectfile.lastModifiedDate = fileItem.lastModifiedDate;
            projectfile.size = [fileItem.size longLongValue];
            projectfile.projectFileOwner = (NXProjectFileOwnerModel *)fileItem.projectFileOwner;
            projectfile.projectId = fileItem.projectId;
            projectfile.parentPath = fileItem.parentPath;
            projectfile.duid = fileItem.duid;
            projectfile.lastModifiedTime = fileItem.lastModifiedTime;
            projectfile.isOffline = fileItem.isOffline.boolValue;
            projectfile.isShared = fileItem.isShared.boolValue;
            projectfile.sharedWithProjectList = (NSMutableArray *)fileItem.sharedWithProject;
            [fileArray addObject:projectfile];
        }
    }
    return fileArray;
}
#pragma mark ------> query summany file list from project (default number 10)
+ (NSMutableArray *)querySummanyProjectFile:(NXProjectModel *)projectModel {
    if (![NXLoginUser sharedInstance].isLogInState) {
           return [NSMutableArray array];
       }
       NSMutableArray *fileArray = [NSMutableArray array];
       NSPredicate *predicate = [NSPredicate predicateWithFormat:@"projectId==%@ and folder==%@", projectModel.projectId,[NSNumber numberWithBool:NO]];
       NSString *sortKey = @"lastModifiedDate";
        NSFetchRequest *request = [NXProjectFileItem MR_createFetchRequestInContext:[NSManagedObjectContext MR_defaultContext]];
       [request setIncludesPropertyValues:YES];
       [request setReturnsObjectsAsFaults:NO];
       [request setIncludesPendingChanges:YES];
       [request setPredicate:predicate];
       NSSortDescriptor *descriptor = [[NSSortDescriptor alloc]initWithKey:sortKey ascending:NO];
       request.sortDescriptors = @[descriptor];
       request.fetchLimit = 10;
       NSArray *fetArray = [NXProjectFileItem MR_executeFetchRequest:request inContext:[NSManagedObjectContext MR_defaultContext]];
       [fetArray enumerateObjectsUsingBlock:^(NXProjectFileItem *fileItem, NSUInteger idx, BOOL * _Nonnull stop) {
           NXProjectFile *projectfile = [[NXProjectFile alloc]init];
           projectfile.fullServicePath = fileItem.fullServicePath;
           projectfile.fullPath = fileItem.fullPath;
           projectfile.name = fileItem.name;
           projectfile.Id = fileItem.idid;
           projectfile.creationTime = fileItem.creationTime;
           projectfile.lastModifiedDate = fileItem.lastModifiedDate;
           projectfile.size = [fileItem.size longLongValue];
           projectfile.projectFileOwner = (NXProjectFileOwnerModel *)fileItem.projectFileOwner;
           projectfile.projectId = fileItem.projectId;
           projectfile.parentPath = fileItem.parentPath;
           projectfile.duid = fileItem.duid;
           projectfile.lastModifiedTime = fileItem.lastModifiedTime;
           projectfile.isOffline = fileItem.isOffline.boolValue;
           projectfile.isShared = fileItem.isShared.boolValue;
           projectfile.sharedWithProjectList = (NSMutableArray *)fileItem.sharedWithProject;
           [fileArray addObject:projectfile];
       }];
       return fileArray;
}
+ (NSMutableArray *)queryAllSharedByProjectFile:(NXProjectModel *)projectModel;{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return [NSMutableArray array];
    }
    
    NSMutableArray *fileArray = [NSMutableArray array];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"projectId==%@ and isShared==%@",projectModel.projectId,[NSNumber numberWithBool:YES]];
    NSFetchRequest *request = [NXProjectFileItem MR_createFetchRequestInContext:[NSManagedObjectContext MR_defaultContext]];

    [request setPredicate:predicate];
    [request setIncludesPropertyValues:YES];
    [request setReturnsObjectsAsFaults:NO];
    [request setIncludesPendingChanges:YES];
    NSArray *fetArray = [NXProjectFileItem MR_executeFetchRequest:request inContext:[NSManagedObjectContext MR_defaultContext]];
    [fetArray enumerateObjectsUsingBlock:^(NXProjectFileItem *fileItem, NSUInteger idx, BOOL * _Nonnull stop) {
        NXProjectFile *projectfile = [[NXProjectFile alloc]init];
        projectfile.fullServicePath = fileItem.fullServicePath;
        projectfile.fullPath = fileItem.fullPath;
        projectfile.name = fileItem.name;
        projectfile.Id = fileItem.idid;
        projectfile.creationTime = fileItem.creationTime;
        projectfile.lastModifiedDate = fileItem.lastModifiedDate;
        projectfile.size = [fileItem.size longLongValue];
        projectfile.projectFileOwner = (NXProjectFileOwnerModel *)fileItem.projectFileOwner;
        projectfile.projectId = fileItem.projectId;
        projectfile.parentPath = fileItem.parentPath;
        projectfile.duid = fileItem.duid;
        projectfile.lastModifiedTime = fileItem.lastModifiedTime;
        projectfile.isOffline = fileItem.isOffline.boolValue;
        projectfile.isShared = fileItem.isShared.boolValue;
        projectfile.sharedWithProjectList = (NSMutableArray *)fileItem.sharedWithProject;
        [fileArray addObject:projectfile];
    }];
    return fileArray;
}

+ (NXFileBase *)queryParentFolderForProjectFolder:(NXProjectFolder *)projectFolder fromProject:(NXProjectModel *)projectModel {
    if (![NXLoginUser sharedInstance].isLogInState) {
           return nil;
    }
    NXProjectFileItem *fileItem = [NXProjectFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"projectId==%@ and fileKey==%@",projectModel.projectId,[NXCommonUtils fileKeyForFile:projectFolder]] inContext:[NSManagedObjectContext MR_defaultContext]];
    NXFileBase *parentFolder = nil;
    if ([fileItem.parentPath stringByDeletingLastPathComponent]) {
        fileItem = [NXProjectFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"projectId==%@ and fullPath==%@",projectModel.projectId, [fileItem.parentPath stringByDeletingLastPathComponent]] inContext:[NSManagedObjectContext MR_defaultContext]];
        parentFolder = [[NXProjectFolder alloc]init];
        ((NXProjectFolder *)parentFolder).folder = YES;
        parentFolder.fullServicePath = fileItem.fullServicePath;
        parentFolder.fullPath = fileItem.fullPath;
        parentFolder.name = fileItem.name;
        ((NXProjectFolder *)parentFolder).Id = fileItem.idid;
        ((NXProjectFolder *)parentFolder).creationTime = fileItem.creationTime;
        parentFolder.lastModifiedDate = fileItem.lastModifiedDate;
        parentFolder.size = [fileItem.size longLongValue];
        ((NXProjectFolder *)parentFolder).projectFileOwner = (NXProjectFileOwnerModel *)fileItem.projectFileOwner;
        ((NXProjectFolder *)parentFolder).projectId = fileItem.projectId;
        ((NXProjectFolder *)parentFolder).parentPath = fileItem.parentPath;
        parentFolder.lastModifiedTime = fileItem.lastModifiedTime;
        
    }else {
        parentFolder = [NXMyProjectManager rootFolderForProject:projectModel];
    }
    return parentFolder;
    
    
}

#pragma mark ------> delete file from project
+ (void)deleteProjectFile:(NXFileBase *)file fromProjectModel:(NXProjectModel *)projectModel {
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    NSString *fileKey = [NXCommonUtils fileKeyForFile:file];
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        if ([file isKindOfClass:[NXProjectFile class]]) {
            [NXProjectFileItem MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"projectId==%@ and fileKey==%@",projectModel.projectId,fileKey] inContext:localContext];
        } else if ([file isKindOfClass:[NXProjectFolder class]]){
            [NXProjectFileItem MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"projectId==%@ and fileKey==%@",projectModel.projectId,fileKey] inContext:localContext];
            [NXProjectFileItem MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"projectId==%@ and parentPath beginswith %@",projectModel.projectId,file.fullServicePath] inContext:localContext];
        }
    }];
}
+ (void)deleteAllProjectFilesFromProject:(NXProjectModel *)projectModel {
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        [NXProjectFileItem MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"projectId==%@",projectModel.projectId] inContext:localContext];
    }];
}
#pragma mark ----->Query project for project file
+ (NXProjectModel *)queryProjectModelByProjectFile:(NXFileBase *)fileBase {
    NXProjectModel *model;
    NSNumber *projectId;
    NSString *fileKey = [NXCommonUtils fileKeyForFile:fileBase];
    if ([fileBase isKindOfClass:[NXProjectFile class]]) {
        NXProjectFile *projectFile = (NXProjectFile*)fileBase;
        projectId = projectFile.projectId;
    }else if ([fileBase isKindOfClass:[NXProjectFolder class]] ){
        NXProjectFolder *projectFolder = (NXProjectFolder *)fileBase;
        projectId = projectFolder.projectId;
    }
    if (projectId) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"projectId==%@ and fileKey==%@",projectId,fileKey];
        NSFetchRequest *request = [NXProjectFileItem MR_createFetchRequestInContext:[NSManagedObjectContext MR_defaultContext]];
        
        [request setPredicate:predicate];
        NSArray *fetchedObjects = [NXProjectFileItem MR_executeFetchRequest:request inContext:[NSManagedObjectContext MR_defaultContext]];
        [fetchedObjects enumerateObjectsUsingBlock:^(NXProjectFileItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NXProjectItem *item = obj.projectPartner;
            model.createdTime = item.createdTime;
            model.isOwnedByMe = item.isOwnedByMe;
            model.totalMembers = item.totalMembers;
            model.totalFiles = item.totalFiles;
            model.projectId = item.projectId;
            model.trialEndTime = item.trialEndTime;
            model.accountType = item.accountType;
            model.projectDescription = item.projectDescription;
            model.displayName = item.displayName;
            model.invitationMsg = item.invitationMsg;
            model.name = item.name;
            model.projectOwner = (NXProjectOwnerItem *)item.ownerInfo;
            model.lastActionTime = item.lastActionTime;
            model.homeShowMembers = (NSMutableArray*)[[self queryMemberByProjectId:item.projectId] allObjects];
            model.parentTenantId = item.parentTenantId;
            model.parentTenantName = item.parentTenantName;
            model.membershipId = item.membershipId;
            model.watermark = item.watermark;
            model.validateModel = (NXLFileValidateDateModel *)item.validateModel;
            model.configurationModified = item.configurationModified;
            *stop = YES;
        }];
    }
    return model;
}

#pragma mark ----->update projectFileItem
+(void)updateProjectFileItem:(NXProjectFile *)projectFile
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NXProjectFileItem *fileItem = [NXProjectFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"projectId==%@ and fileKey==%@",projectFile.projectId,[NXCommonUtils fileKeyForFile:projectFile]] inContext:localContext];
        if (fileItem) {
            NSLog(@"attention please!!!! ====== %f",[projectFile.lastModifiedDate timeIntervalSince1970]);
            fileItem.lastModifiedDate = projectFile.lastModifiedDate;
            fileItem.lastModifiedTime = projectFile.lastModifiedTime;
        }
    }];
}


#pragma mark ----->Shared by project file list
+ (NSMutableArray *)querySharedByProjectFile:(NXProjectModel *)projectModel {
    NSFetchRequest *request = [NXProjectFileItem MR_createFetchRequest];
    [request setPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"isShared==%@", [NSNumber numberWithBool:YES]]]];
    [request setIncludesPropertyValues:YES];
    [request setReturnsObjectsAsFaults:NO];
    [request setIncludesPendingChanges:YES];
    NSArray *fetchObjs = [NXProjectFileItem MR_executeFetchRequest:request inContext:[NSManagedObjectContext MR_defaultContext]];
    NSMutableArray *retArray = [NSMutableArray array];
    for (NXProjectFileItem *fileItem in fetchObjs) {
        NXProjectFile *projectfile = [[NXProjectFile alloc]init];
        projectfile.fullServicePath = fileItem.fullServicePath;
        projectfile.fullPath = fileItem.fullPath;
        projectfile.name = fileItem.name;
        projectfile.Id = fileItem.idid;
        projectfile.creationTime = fileItem.creationTime;
        projectfile.lastModifiedDate = fileItem.lastModifiedDate;
        projectfile.size = [fileItem.size longLongValue];
        projectfile.projectFileOwner = (NXProjectFileOwnerModel *)fileItem.projectFileOwner;
        projectfile.projectId = fileItem.projectId;
        projectfile.parentPath = fileItem.parentPath;
        projectfile.duid = fileItem.duid;
        projectfile.lastModifiedTime = fileItem.lastModifiedTime;
        projectfile.isOffline = fileItem.isOffline.boolValue;
        projectfile.isShared = fileItem.isShared.boolValue;
        projectfile.sharedWithProjectList = (NSMutableArray *)fileItem.sharedWithProject;
        [retArray addObject:projectfile];
    }
    return retArray;
}
+ (void)updateSharedByProjectFileItems:(NXProjectModel *)projectModel withSharedByFileList:(NSArray<NXProjectFile *> *)sharedByFileList {
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NSSet *newSharedByFileSet = [NSSet setWithArray:sharedByFileList];
        NSArray *fetchObjects = [NXProjectItem MR_findAllWithPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@""]] inContext:localContext];
        NSMutableSet *oldSharedByFileSet = [NSMutableSet new];
        for (NXProjectFileItem *fileItem in fetchObjects) {
            NXProjectFile *projectfile = [[NXProjectFile alloc]init];
            projectfile.fullServicePath = fileItem.fullServicePath;
            projectfile.fullPath = fileItem.fullPath;
            projectfile.name = fileItem.name;
            projectfile.Id = fileItem.idid;
            projectfile.creationTime = fileItem.creationTime;
            projectfile.lastModifiedDate = fileItem.lastModifiedDate;
            projectfile.size = [fileItem.size longLongValue];
            projectfile.projectFileOwner = (NXProjectFileOwnerModel *)fileItem.projectFileOwner;
            projectfile.projectId = fileItem.projectId;
            projectfile.parentPath = fileItem.parentPath;
            projectfile.duid = fileItem.duid;
            projectfile.lastModifiedTime = fileItem.lastModifiedTime;
            projectfile.isOffline = fileItem.isOffline.boolValue;
            projectfile.isShared = fileItem.isShared.boolValue;
            projectfile.sharedWithProjectList = (NSMutableArray *)fileItem.sharedWithProject;
            [oldSharedByFileSet addObject:projectfile];
        }
        [oldSharedByFileSet minusSet:newSharedByFileSet];
        // update old shared by but now not shared by files
        for (NXProjectFile *projectFile in oldSharedByFileSet) {
            NSArray *filterArray = [fetchObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self.duid == %@", projectFile.duid]]];
            NXProjectFileItem *fileItem = filterArray.firstObject;
            fileItem.isShared = [NSNumber numberWithBool:NO];
            fileItem.sharedWithProject = @"";
        }
        // update new shared by info
        for (NXProjectFile *projectFile in newSharedByFileSet) {
            NSString *fileKey = [NXCommonUtils fileKeyForFile:projectFile];
            NXProjectFileItem *fileItem = [NXProjectFileItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"projectId==%@ and fileKey==%@",projectFile.projectId,fileKey] inContext:localContext];
            if (!fileItem) {
                fileItem = [NXProjectFileItem MR_createEntityInContext:localContext];
                fileItem.duid = projectFile.duid;
                fileItem.idid = projectFile.Id;
                fileItem.folder = [NSNumber numberWithBool:NO];
                fileItem.projectId = projectFile.projectId;
                fileItem.creationTime = projectFile.creationTime;
                fileItem.projectFileOwner = projectFile.projectFileOwner;
                fileItem.fileType = projectFile.fileType;
                NSString *parentPath = [projectFile.fullServicePath stringByDeletingLastPathComponent];
                if (![parentPath isEqualToString:@"/"]) {
                   parentPath = [parentPath stringByAppendingString:@"/"];
                }
                fileItem.parentPath = parentPath;
                
            }
            fileItem.fullPath = projectFile.fullPath;
            fileItem.fullServicePath = projectFile.fullServicePath;
            fileItem.lastModifiedDate = projectFile.lastModifiedDate;
            fileItem.name = projectFile.name;
            fileItem.size = [NSNumber numberWithLongLong:projectFile.size];
            fileItem.lastModifiedTime = projectFile.lastModifiedTime;
            fileItem.fileKey = fileKey;
            fileItem.isShared = [NSNumber numberWithBool:projectFile.isShared];
            fileItem.sharedWithProject = projectFile.sharedWithProjectList;
            // add relationShip for projectItem
            NXProjectItem *projectItem = [NXProjectItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"projectId==%@",projectModel.projectId] inContext:localContext];
            if (projectItem) {
                fileItem.projectPartner = projectItem;
                [projectItem addProjectFileObject:fileItem];
            }
        }
        
    }];
    return;
}
@end
