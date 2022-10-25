//
//  NXQueryFileTokenOperation.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2018/8/14.
//  Copyright © 2018年 nextlabs. All rights reserved.
//

#import "NXOperationBase.h"
@class NXFileBase;
typedef void(^queryFileTokenOperationCompletionBlock)(NXFileBase *file, NSString *token, NSError *tokeError);
@interface NXQueryFileTokenOperation : NXOperationBase
- (instancetype)initWithFile:(NXFileBase *)file;

@property(nonatomic, copy) queryFileTokenOperationCompletionBlock operationCompleted;
@end
