//
//  NXProjectGetClassificationProfileOperation.h
//  nxrmc
//
//  Created by Eren on 23/03/2018.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"
#import "NXClassificationCategory.h"
#import "NXProjectModel.h"
typedef void(^getProjectClassificaionOperationCompletion)(NSArray<NXClassificationCategory *> *classificaitons, NSError *error);
@interface NXProjectGetClassificationProfileOperation : NXOperationBase
- (instancetype)initWithProject:(NXProjectModel *)project;
- (instancetype)initWithDeflautTokenGroup:(id)tokenGroup;
@property(nonatomic, copy)getProjectClassificaionOperationCompletion optCompletion;
@end
