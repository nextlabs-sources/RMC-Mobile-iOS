//
//  NXRepoAuthStrategy.m
//  nxrmc
//
//  Created by EShi on 11/1/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXRepoAuthStrategy.h"

#import "NXGoogleDriveAuther.h"
#import "NXDropBoxAuther.h"
#import "NXSharePointOnlineAuther.h"
#import "NXCenterTokenAuther.h"
#import "NXSharePointAuther.h"
@implementation NXRepoAuthStrategy
+(id<NXRepoAutherBase>) repoAutherByRepoType:(ServiceType) repoType
{
    id<NXRepoAutherBase> auther = nil;
    switch (repoType) {
        case kServiceGoogleDrive:
        case kServiceDropbox:
        case kServiceOneDrive:
        case kServiceSharepointOnline:
        case kServiceBOX:
        {
             auther = [[NXCenterTokenAuther alloc] init];
             auther.repoType = repoType;
        }
              break;
        case kServiceSharepoint:
        {
            auther = [[NXSharePointAuther alloc] init];
            auther.repoType = repoType;
        }
            break;
        default:
            break;
    }
    return auther;
}
@end
