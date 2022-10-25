//
//  NXRepoAuthWorkerBase.h
//  nxrmc
//
//  Created by EShi on 8/5/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NXRMCDef.h"




@protocol NXRepoAutherBase;

@protocol NXRepoAutherDelegate <NSObject>
@required
-(void) repoAuther:(id<NXRepoAutherBase>) repoAuther didFinishAuth:(NSDictionary *) authInfo;
-(void) repoAuther:(id<NXRepoAutherBase>) repoAuther authFailed:(NSError *) error;
-(void) repoAuthCanceled:(id<NXRepoAutherBase>) repoAuther;
@end

@protocol NXRepoAutherBase <NSObject>
@property(nonatomic, weak) id<NXRepoAutherDelegate> delegate;
@property(nonatomic) NSInteger repoType;
- (void)authRepoWithRepostioryAlias:(NSString *)repoAlias;
- (void)authRepoInViewController:(UIViewController *) vc repostioryAlias:(NSString *)repoAlias;
@required
- (void) authRepoInViewController:(UIViewController *) vc;

@end
