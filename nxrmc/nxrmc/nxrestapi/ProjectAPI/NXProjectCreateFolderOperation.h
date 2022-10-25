//
//  NXProjectCreateFolderOperation.h
//  nxrmc
//
//  Created by xx-huang on 23/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXOperationBase.h"
#import "NXProjectModel.h"

typedef void(^projectCreateFolderCompletion)(NXProjectFolder *createdFolder,NSError *error);

@interface NXProjectCreateFolderOperation : NXOperationBase

-(instancetype)initWithProjectModel:(NXProjectModel *)projectModel parentPathId:(NSString *)filePath withNewFolderName:(NSString *)folderName autoRename:(NSString *)autoRename;

@property (nonatomic,strong) NXProjectModel *prjectModel;
@property (nonatomic,strong) NSString *filePath;
@property (nonatomic,assign) NSString *autoRename;

@property(nonatomic, copy) projectCreateFolderCompletion projectCreateFolderCompletion;

@end
