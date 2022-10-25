//
//  NXAllProjectListOperation.h
//  nxrmc
//
//  Created by Sznag on 2020/3/12.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^getAllProjectListCompletion)(NSArray *projectList,NSError *error);

@interface NXAllProjectListOperation : NXOperationBase
@property(nonatomic, copy) getAllProjectListCompletion getProjectListCompletion;

@end

NS_ASSUME_NONNULL_END
