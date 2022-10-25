//
//  NXSharedWorkspace.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/9/9.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXServiceOperation.h"
NS_ASSUME_NONNULL_BEGIN
@class NXRepositoryModel;
@interface NXSharedWorkspace : NSObject<NXServiceOperation>
- (instancetype)initWithUserId:(NSString *)userId repoModel:(NXRepositoryModel *)repoModel;
@property(nonatomic, weak) id<NXServiceOperationDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
