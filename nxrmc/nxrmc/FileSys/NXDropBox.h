//
//  NXDropBox.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 26/12/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXServiceOperation.h"
#import "NXRepositoryModel.h"
@interface NXDropBox : NSObject<NXServiceOperation>
- (instancetype)initWithUserId:(NSString *)userId repoModel:(NXRepositoryModel *)repoModel;
@property(nonatomic, weak) id<NXServiceOperationDelegate> delegate;
@end
