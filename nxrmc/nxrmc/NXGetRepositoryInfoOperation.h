//
//  NXGetRepositoryInfoOperation.h
//  nxrmc
//
//  Created by EShi on 1/18/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "NXRepositoryModel.h"
typedef void(^getRepositoryInfoCompletion)(NXRepositoryModel *repoModel, NSString *userName, NSString *userEmail, NSNumber *totalQuota, NSNumber *usedQuota, NSError *error);
@interface NXGetRepositoryInfoOperation : NSOperation
- (instancetype)initWithRepository:(NXRepositoryModel *)repoModel;
@property(nonatomic, copy) getRepositoryInfoCompletion getRepoInfoCompletion;
@end
