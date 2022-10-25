//
//  NXSharePointOnlineAuther.h
//  nxrmc
//
//  Created by EShi on 11/1/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXRepoAuthWorkerBase.h"

@interface NXSharePointOnlineAuther : NSObject<NXRepoAutherBase>
@property(nonatomic, weak) id<NXRepoAutherDelegate> delegate;
@property(nonatomic, weak) UIViewController *authViewController;
@property(nonatomic) NSInteger repoType;
@end
