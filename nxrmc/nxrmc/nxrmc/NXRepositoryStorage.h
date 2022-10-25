//
//  NXRepositoryStorage.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 8/21/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXRMCStruct.h"
#import "NXRepositoryModel.h"

@interface NXRepositoryStorage : NSObject
+ (void) storeServiceIntoCoreData:(NXRMCRepoItem *) serviceObj;
+ (void) stroreRepoIntoCoreData:(NXRepositoryModel *)repoObj;
+ (void) updateBoundRepoInCoreData:(NXRepositoryModel *) repoModel;
+ (void) deleteRepoFromCoreData: (NXRepositoryModel*) repoModel;
+ (NXBoundService *)getOneDriveBoundedCase;
+ (NXBoundService *)getBoundServiceByRepoModel:(NXRepositoryModel *)repoModel;
+ (NSArray *)loadAllBoundServices;
@end
