//
//  NXOneDriveAuther.h
//  nxrmc
//
//  Created by EShi on 8/5/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "NXRepoAuthWorkerBase.h"

typedef NS_ENUM(NSInteger, NXOneDriveAutherWorkType)
{
    NXOneDriveAutherWorkTypeBoundRepo = 1,
    NXOneDriveAutherWorkTypeAuthRepo = 2,
};
@interface NXOneDriveAuther : NSObject<NXRepoAutherBase>
@property(nonatomic, weak) id<NXRepoAutherDelegate> delegate;
@property(nonatomic, weak) UIViewController *authViewController;
@property(nonatomic) NSInteger repoType;
    @property(nonatomic, assign) NXOneDriveAutherWorkType workType;
@end
