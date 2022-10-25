//
//  NXFile.h
//  nxrmc
//
//  Created by Kevin on 15/5/7.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXFileBase.h"

@protocol NXFileGetNXLHeaderProtocol <NSObject>
typedef void(^NXFileGetNXLHeaderCompletedBlock)(NXFileBase *file, NSData *fileData, NSError *error);
@required
- (NSString *)getNXLHeader:(NXFileGetNXLHeaderCompletedBlock)compBlock;
@end

@interface NXFile : NXFileBase<NXFileGetNXLHeaderProtocol>

@end
