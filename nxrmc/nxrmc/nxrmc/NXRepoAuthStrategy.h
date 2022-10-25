//
//  NXRepoAuthStrategy.h
//  nxrmc
//
//  Created by EShi on 11/1/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXRMCDef.h"
#import "NXRepoAuthWorkerBase.h"
#import "NXOneDriveAuther.h"
@interface NXRepoAuthStrategy : NSObject
+ (id<NXRepoAutherBase>) repoAutherByRepoType:(ServiceType) repoType;
@end
