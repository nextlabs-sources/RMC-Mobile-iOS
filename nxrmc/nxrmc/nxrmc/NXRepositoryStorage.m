//
//  NXRepositoryStorage.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 8/21/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXRepositoryStorage.h"
#import "MagicalRecord.h"
#import "NXCommonUtils.h"
#import "NXLProfile.h"

@implementation NXRepositoryStorage
+ (void) storeServiceIntoCoreData:(NXRMCRepoItem *) serviceObj
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    NXRepositoryModel *repoModel = [[NXRepositoryModel alloc] initWithRMCRepoModel:serviceObj];
    [NXRepositoryStorage stroreRepoIntoCoreData:repoModel];
}

+ (void) stroreRepoIntoCoreData:(NXRepositoryModel *)repoObj
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id=%@ AND service_id=%@", [NXCommonUtils converttoNumber:[NXLoginUser sharedInstance].profile.userId], repoObj.service_id];
    NSArray* objects = [NXBoundService MR_findAllWithPredicate:predicate];
    if (objects.count > 0) {
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
            NXBoundService *localService = [(NXBoundService *)[objects lastObject] MR_inContext:localContext];
            if (localService) {
                localService.service_id = repoObj.service_id;
                localService.service_account = repoObj.service_account;
                localService.service_account_token = repoObj.service_account_token;
                localService.service_selected = [NSNumber numberWithBool:YES]; // default service is selected when add service
                localService.service_alias = repoObj.service_alias;
                localService.service_isAuthed = repoObj.service_isAuthed;
                localService.service_providerClass = repoObj.service_providerClass;
            }
        }];
    }
    else
    {
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
            NXBoundService *localService = [NXBoundService MR_createEntityInContext:localContext];
            if (repoObj.service_id) {
                
                localService.service_id = repoObj.service_id;
            }else
            {
                localService.service_id = RMC_DEFAULT_SERVICE_ID_UNSET;
            }
            localService.user_id = [NXCommonUtils converttoNumber:[NXLoginUser sharedInstance].profile.userId];
            localService.service_type = repoObj.service_type;
            localService.service_account = repoObj.service_account;
            localService.service_account_id = repoObj.service_account_id;
            localService.service_account_token = repoObj.service_account_token;
            localService.service_alias = repoObj.service_alias;
            localService.service_selected = [NSNumber numberWithBool:YES]; // default service is selected when add service
            localService.service_isAuthed = repoObj.service_isAuthed;
            localService.service_providerClass = repoObj.service_providerClass;
        }];
    }
}

+ (void) updateBoundRepoInCoreData:(NXRepositoryModel *) repoModel
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id=%@ AND service_id=%@", [NXCommonUtils converttoNumber:[NXLoginUser sharedInstance].profile.userId], repoModel.service_id];
        NXBoundService *localService = [NXBoundService MR_findFirstWithPredicate:predicate inContext:localContext];
        if (localService) {
            localService.user_id = repoModel.user_id;
            localService.service_type = repoModel.service_type;
            localService.service_account = repoModel.service_account;
            localService.service_account_id = repoModel.service_account_id;
            localService.service_account_token = repoModel.service_account_token;
            localService.service_alias = repoModel.service_alias;
            localService.service_selected = repoModel.service_selected;
            localService.service_id = repoModel.service_id;
            localService.service_isAuthed = repoModel.service_isAuthed;
            localService.service_providerClass = repoModel.service_providerClass;
        }
    }];
}

+ (void) deleteRepoFromCoreData:(NXRepositoryModel*) repoModel
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return;
    }
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        NSPredicate *predicate = nil;
       
        predicate = [NSPredicate predicateWithFormat:@"user_id=%@ AND service_id=%@", [NXCommonUtils converttoNumber:[NXLoginUser sharedInstance].profile.userId], repoModel.service_id];
        
        NXBoundService *localService = [NXBoundService MR_findFirstWithPredicate:predicate inContext:localContext];
        [localService MR_deleteEntityInContext:localContext];
 
    }];
}

+ (NXBoundService *)getOneDriveBoundedCase
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return nil;
    }
    return [NXBoundService MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"service_type=%@", @(kServiceOneDrive)] inContext:[NSManagedObjectContext MR_defaultContext]];
}

+ (NXBoundService *)getBoundServiceByRepoModel:(NXRepositoryModel *)repoModel
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return nil;
    }
    return [NXBoundService MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"service_id=%@", repoModel.service_id] inContext:[NSManagedObjectContext MR_defaultContext]];
}

+ (NSArray *)loadAllBoundServices
{
    if (![NXLoginUser sharedInstance].isLogInState) {
        return nil;
    }
    NSNumber* uid = [NXCommonUtils converttoNumber:[NXLoginUser sharedInstance].profile.userId];
    // NOTE: THERE is A BUG!!!!!!!! NEED take tenantID into conside
    NSArray* objects = [NXBoundService MR_findAllWithPredicate: [NSPredicate predicateWithFormat:@"user_id=%@", uid]];
    
    return objects;
}


@end
