//
//  NXRevokeSharingFileOperation.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/12/10.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"

@class  NXFileBase;
typedef void(^revokeSharedFileCompletion)(NSError *error);
@interface NXRevokingSharedFileOperation : NXOperationBase
- (instancetype)initWithFileDuid:(NSString *)fileDuid;
@property(nonatomic, copy)revokeSharedFileCompletion revokeSharedFileCompletion;
@end


