//
//  NXMarkFileAsOfflineCombinedOperation.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2018/8/10.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXOperationBase.h"
#import "NXFileBase.h"
#import "NXOfflineFileManager.h"

//typedef void(^markFileAsOfflineCompletedBlock)(NSError *error);
//typedef void(^markFileAsOfflineCompletedBlock)(NXFileBase *fileItem, NSError *error);

@interface NXMarkFileAsOfflineCombinedOperation : NXOperationBase

-(instancetype)initWithFile:(NXFileBase *)file;

@property(nonatomic,strong,readonly) NSString *downloadOptIdentify;
@property(nonatomic,strong,readonly) NSString *queryRightsOptIdentify;

@property (nonatomic ,copy)markFileAsOfflineCompletedBlock markFileAsOfflineCompletedBlock;

@end
