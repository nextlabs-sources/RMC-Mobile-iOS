//
//  NX3DFileConverter.h
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 7/4/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NXFileBase;

@interface NX3DFileConverter : NSObject
//for now only support one task.
- (NSString *)convertFile:(NXFileBase *)fileItem data:(NSData *)data progress:(void (^)(NSNumber *progress))progressBlock completion:(void (^)(NXFileBase *fileItem, NSData *data, NSError *error))completion;
- (void)cancelConvertFile:(NXFileBase *)fileItem;
- (void)cancelOperation:(NSString *)operationIdentify;

- (void)quaryCachedFile:(NXFileBase *)fileItem completion:(void (^)(NXFileBase *fileItem, NSData *data))completion;

//- (BOOL)isFileConvertCache:(NXFileBase *)fileItem;


@end
