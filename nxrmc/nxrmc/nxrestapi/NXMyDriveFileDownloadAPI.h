//
//  NXMyDriveFileDownloadAPI.h
//  nxrmc
//
//  Created by helpdesk on 2/12/16.
//  Copyright © 2016年 nextlabs. All rights reserved.
//


#import "NXSuperRESTAPI.h"
@interface NXMyDriveFileDownloadAPI : NXSuperRESTAPIRequest<NXRESTAPIScheduleProtocol>
-(NSURLRequest *) generateRequestObject:(id) object;
- (Analysis)analysisReturnData;
@end
@interface NXMyDriveFileDownloadAPIResponse : NXSuperRESTAPIResponse
@property (nonatomic,strong)NSData *resultData;
@end
