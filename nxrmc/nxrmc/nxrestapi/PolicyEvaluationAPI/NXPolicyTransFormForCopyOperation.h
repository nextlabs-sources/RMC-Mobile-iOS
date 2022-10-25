//
//  NXPolicyTransFormForCopyOperation.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2022/5/20.
//  Copyright © 2022 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"
@class NXLRights;
@class NXFileBase;
NS_ASSUME_NONNULL_BEGIN
typedef void(^transFormPemissionsFinishCompletion)(NXLRights *rights,NSError *error);
@interface NXPolicyTransFormForCopyOperation : NXOperationBase
@property(nonatomic, copy)transFormPemissionsFinishCompletion transFormPemissionsFinishCompletion;
- (instancetype)initWithSourceFile:(NXFileBase *)fileItem andDestSpaceFolder:(NXFileBase *)destSpaceFolder andDestSpaceMembershipId:(NSString *)membershipId;
@end

NS_ASSUME_NONNULL_END
