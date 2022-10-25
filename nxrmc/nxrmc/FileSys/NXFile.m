//
//  NXFile.m
//  nxrmc
//
//  Created by Kevin on 15/5/7.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import "NXFile.h"
#import "NXWebFileManager.h"
#import "NXRMCDef.h"

@implementation NXFile
- (NSString *)getNXLHeader:(NXFileGetNXLHeaderCompletedBlock)compBlock {
    [[NXWebFileManager sharedInstance] downloadFile:[(NXFileBase *)self copy] toSize:NXL_FILE_HEAD_LENGTH completed:^(NXFileBase *file, NSData *fileData, NSError *error) {
        compBlock(file, fileData, error);
    }];
    return @"";
}
@end
