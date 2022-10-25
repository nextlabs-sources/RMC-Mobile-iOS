//
//  NXProjectSearchOpearation.h
//  nxrmc
//
//  Created by xx-huang on 23/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXOperationBase.h"
#import "NXProjectModel.h"

typedef void(^projectSearchCompletion)(NSArray *matchesFileList,NSError *error);

@interface NXProjectSearchOpearation : NXOperationBase

-(instancetype)initWithProjectModel:(NXProjectModel *)projectModel queryKeyword:(NSString *)keyword;

@property (nonatomic,strong) NXProjectModel *prjectModel;
@property (nonatomic,strong) NSString *queryKeyword;

@property(nonatomic, copy) projectSearchCompletion projectSearchCompletion;

@end
