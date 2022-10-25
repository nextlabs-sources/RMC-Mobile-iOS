//
//  NXQueryFileRightsOperation.h
//  nxrmc
//
//  Created by Eren on 2018/8/10.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"
#import "NXFileBase.h"
#import "NXOfflineFileRightsManager.h"

@interface NXQueryFileRightsOperation : NXOperationBase
- (instancetype)initWithFile:(NXFileBase *)file;

@property(nonatomic, copy) queryNXLFileRightsCompletedBlock completed;
@end
