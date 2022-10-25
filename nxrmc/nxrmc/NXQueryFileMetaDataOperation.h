//
//  NXQueryFileMetaDataOperation.h
//  nxrmc
//
//  Created by EShi on 2/28/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"
#import "NXFileBase.h"
#import "NXRepositoryModel.h"

typedef void(^NXQueryFileMetaDataOperationCompletionBlock)(NXFileBase *fileMetaData, NSError *error);
@interface NXQueryFileMetaDataOperation : NXOperationBase
- (instancetype)initWithFile:(NXFileBase *)file repository:(NXRepositoryModel *)repoModel;

@property(nonatomic, copy) NXQueryFileMetaDataOperationCompletionBlock completion;
@end
