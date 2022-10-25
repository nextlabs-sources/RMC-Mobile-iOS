//
//  NXSharePointAuther.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 16/05/2018.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXRepoAuthWorkerBase.h"
@class NXRepositoryModel;

typedef void(^authRepositoryCompletion)(NXRepositoryModel *repoModel,NSError *error);

@interface NXSharePointAuther : NSObject<NXRepoAutherBase>
@property(nonatomic, weak) id<NXRepoAutherDelegate> delegate;
@property(nonatomic, weak) UIViewController *authViewController;
@property(nonatomic) NSInteger repoType;

- (void)authRepoInViewController:(UIViewController *)vc repostioryAlias:(NSString *)repoAlias isReAuth:(BOOL)isReAuth accountName:(NSString *)accountName repoId:(NSString *)repoId completBlock:(authRepositoryCompletion)compBlock;

@end
