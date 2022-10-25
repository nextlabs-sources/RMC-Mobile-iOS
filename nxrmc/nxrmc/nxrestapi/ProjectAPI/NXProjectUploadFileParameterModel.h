//
//  NXProjectUploadFileParameterModel.h
//  nxrmc
//
//  Created by helpdesk on 23/1/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface NXProjectUploadFileParameterModel : NSObject
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSArray *rights;
@property (nonatomic, strong) NSString *destFilePathId;
@property (nonatomic, strong) NSString *destFilePathDisplay;
@property (nonatomic, strong) NSNumber *projectId;
@property (nonatomic, strong) NSData *fileData;
@property (nonatomic, strong) NSDictionary *tags;
@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, assign) BOOL isoverWrite;
@property (nonatomic, strong) NSString  *duid;
@end

