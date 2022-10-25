//
//  NXProjectUploadFileParameterModel.m
//  nxrmc
//
//  Created by helpdesk on 23/1/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXProjectUploadFileParameterModel.h"

@implementation NXProjectUploadFileParameterModel
- (NSArray*)rights {
    if (!_rights) {
        _rights=[NSArray array];
    }
    return _rights;
}
- (NSData*)fileData {
    if (!_fileData) {
        _fileData=[[NSData alloc]init];
    }
    return _fileData;
}

- (NSNumber *)type {
    if (!_type) {
        _type = [NSNumber numberWithInteger:0];
    }
    return _type;
}
@end

