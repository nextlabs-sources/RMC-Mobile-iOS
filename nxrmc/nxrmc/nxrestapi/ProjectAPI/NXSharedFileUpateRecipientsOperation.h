//
//  NXProjectSharedFileUpateRecipientsOperation.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/12/10.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"
#import "NXUpdateProjectSharingRecipientsAPI.h"

typedef void(^projectFileUpdateRecipientsCompletion)(NSArray *aNewSharelist,NSArray *alreadySharedList,NSArray *removeSharedList,NSError *error);
@interface NXSharedFileUpateRecipientsOperation : NXOperationBase
- (instancetype)initWithModel:(NXUpdateSharingRecipientsModel *)model;
@property (nonatomic, copy) projectFileUpdateRecipientsCompletion projectFileUpdateRecipientsCompletion;
@end


