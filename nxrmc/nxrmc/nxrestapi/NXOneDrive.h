//
//  NXOneDrive.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 26/12/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXServiceOperation.h"
#import "NXRepositoryModel.h"
@interface NXOneDrive : NSObject <NXServiceOperation>
@property(nonatomic, strong)NSString *alias;
- (id) init;
- (id) initWithUserId: (NSString *)userId repoModel:(NXRepositoryModel *)repoModel;
@property(nonatomic, strong) NXRepositoryModel *boundService;
@end
