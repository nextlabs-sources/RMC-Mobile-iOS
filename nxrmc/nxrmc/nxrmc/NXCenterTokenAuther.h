//
//  NXCenterTokenAuther.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 12/26/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXRepoAuthWorkerBase.h"
@interface NXCenterTokenAuther : NSObject<NXRepoAutherBase>
@property(nonatomic, weak) id<NXRepoAutherDelegate> delegate;
@property(nonatomic) NSInteger repoType;
@property(nonatomic, strong) NSString *siteUrl;
@property(nonatomic, strong) UIViewController *authVC;
- (void) authRepoInViewController:(UIViewController *) vc;
@end
