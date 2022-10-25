//
//  NXProjectUploadFileAPI.h
//  nxrmc
//
//  Created by helpdesk on 18/1/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

@class NXProjectFile;
@interface NXProjectUploadFileAPIRequest : NXSuperRESTAPIRequest<NXRESTAPIScheduleProtocol>
-(NSURLRequest *)generateRequestObject:(id)object;
-(Analysis)analysisReturnData;

@end

@interface  NXProjectUploadFileAPIResponse:NXSuperRESTAPIResponse
@property (nonatomic,strong) NXProjectFile *fileItem;

@end
