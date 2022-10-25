//
//  NXOfflineFile.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2018/8/10.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXFile.h"
#import "NXRMCDef.h"

@interface NXOfflineFile : NXFile

@property(nonatomic, copy) NSString *sourcePath;
@property(nonatomic, assign) NXFileState state;
@property(nonatomic, strong) NSString *duid;
@property(nonatomic, strong) NSString *fileKey;
@property(nonatomic, assign) BOOL isCenterPolicyEncrypted;
@property(nonatomic, strong) NSDate *markAsOfflineDate;

@end
