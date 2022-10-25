//
//  NXPojectFileSharingOperation.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/12/10.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"
#import "NXSharingProjectFileAPI.h"
typedef void(^projectFileSharingCompletion)(NSArray *aNewSharelist,NSArray *alreadySharedList,NSError *error);

@interface NXProjectFileSharingOperation : NXOperationBase
- (instancetype)initWithModel:(NXSharingProjectFileModel *)model;
@property (nonatomic, copy) projectFileSharingCompletion projectFileSharingCompletion;
@end

