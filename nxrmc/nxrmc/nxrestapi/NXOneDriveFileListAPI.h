//
//  NXOneDriveFileListAPI.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 25/12/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "NX3rdRepoRESTAPI.h"

@interface NXOneDriveFileListAPIRequest : NX3rdRepoRESTAPIRequest <NXRESTAPIScheduleProtocol>
-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;
@end
@interface NXOneDriveFileListAPIResponse : NX3rdRepoRESTAPIResponse
@property (nonatomic,strong)NSMutableArray *fileList;
@end
