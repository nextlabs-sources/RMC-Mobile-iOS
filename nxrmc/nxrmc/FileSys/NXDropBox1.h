//
//  NXDropBox.h
//  DropbBoxV2Test
//
//  Created by Eren (Teng) Shi on 5/18/17.
//  Copyright © 2017 Eren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXServiceOperation.h"
#import "NXRepositoryModel.h"
@interface NXDropBox1 : NSObject<NXServiceOperation>
- (instancetype)initWithUserId:(NSString *)userId repoModel:(NXRepositoryModel *)repoModel;
@property(nonatomic, weak) id<NXServiceOperationDelegate> delegate;
@end
