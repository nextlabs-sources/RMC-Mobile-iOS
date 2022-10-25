//
//  NXSyncREPOOperation.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 9/1/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"
typedef void(^NXSyncREPOOperationCompletion)(NSError *error);

@interface NXSyncREPOOperation : NXOperationBase
- (instancetype)initWithRESTAPICacheURL:(NSURL *)cachedURL;

@property(nonatomic, copy)NXSyncREPOOperationCompletion complete;
@end
