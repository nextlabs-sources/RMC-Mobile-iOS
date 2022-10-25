//
//  NXBox.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 1/11/18.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXServiceOperation.h"
#import "NXRepositoryModel.h"
@interface NXBox : NSObject <NXServiceOperation>
- (instancetype)initWithUserId:(NSString *)userId repoModel:(NXRepositoryModel *)repoModel;
@property(nonatomic, weak) id<NXServiceOperationDelegate> delegate;
@end
