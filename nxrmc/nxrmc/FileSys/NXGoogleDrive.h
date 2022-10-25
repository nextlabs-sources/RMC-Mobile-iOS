//
//  NXGoogleDrive.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 27/12/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTMAppAuth.h"
#import "NXServiceOperation.h"
#import "NXRepositoryModel.h"

@interface NXGoogleDrive : NSObject<NXServiceOperation>
@property(nonatomic, strong)NSString *alias;
@property(nonatomic, strong) NXRepositoryModel *repoModel;
@property (nonatomic, weak)id<NXServiceOperationDelegate> delegate;
- (id) initWithUserId: (NSString *)userId repoModel:(NXRepositoryModel *)repoModel;
@end

