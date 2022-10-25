//
//  NXOneDriveDownloadFileAPI.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 25/12/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//


#import "NX3rdRepoRESTAPI.h"
@interface NXOneDriveDownloadFileAPIRequest : NX3rdRepoRESTAPIRequest<NXRESTAPIScheduleProtocol>
-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;
@end
@interface NXOneDriveDownloadFileAPIResponse:NX3rdRepoRESTAPIResponse
@property (nonatomic, strong)NSData *fileData;
@end
