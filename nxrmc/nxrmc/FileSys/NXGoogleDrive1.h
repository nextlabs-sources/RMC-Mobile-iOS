//
//  NXGoogleDriveNew.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 4/24/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTMAppAuth.h"
#import "NXServiceOperation.h"
#import "NXRepositoryModel.h"

@interface NXGoogleDrive1 : NSObject<NXServiceOperation>
@property(nonatomic, strong)NSString *alias;
@property(nonatomic, strong) NXRepositoryModel *repoModel;
- (id) initWithUserId: (NSString *)userId repoModel:(NXRepositoryModel *)repoModel;
@end
