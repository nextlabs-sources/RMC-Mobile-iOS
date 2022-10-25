//
//  NX3DFileConvertOperation.h
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 7/4/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NXFileBase.h"
#import "NXOperationBase.h"

@interface NX3DFileConvertOperation : NXOperationBase

- (instancetype)initWithFile:(NSString *)fileName data:(NSData *)data name:(NXFileBase *)fileItem;

@property(nonatomic, copy) void (^completion)(NXFileBase *fileItem, NSData *data, NSError *error);
@property(nonatomic, strong) NSProgress *progerss;

@end
