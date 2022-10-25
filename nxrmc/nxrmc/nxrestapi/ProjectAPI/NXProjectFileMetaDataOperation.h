//
//  NXProjectFileMetaDataOperation.h
//  nxrmc
//
//  Created by xx-huang on 23/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXOperationBase.h"
#import "NXProjectModel.h"
#import "NXProjectFileMetaDataAPI.h"
@class NXProjectFile;
typedef void(^getProjectFileMetadataCompletion)(NXProjectFile *fileInfo,NSString *filePath,NSError *error);

@interface NXProjectFileMetaDataOperation : NXOperationBase

-(instancetype)initWithProjectModel:(NXProjectModel *)projectModel filePath:(NSString *)filePath;

@property (nonatomic,strong) NXProjectModel *prjectModel;
@property (nonatomic,strong) NSString *filePath;

@property(nonatomic, copy) getProjectFileMetadataCompletion getProjectFileMetadataCompletion;

@end
