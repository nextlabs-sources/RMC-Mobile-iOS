//
//  NXProjectDownloadFileAPI.h
//  nxrmc
//
//  Created by xx-huang on 18/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "NXSuperRESTAPI.h"

#define PROJECT_ID  @"projectId"
#define START       @"start"
#define LENGTH      @"length"
#define FILE_PATH   @"filePath"
#define DOWNLOAD_TYPE @"downloadType"

@interface  NXProjectDownloadFileAPIRequest : NXSuperRESTAPIRequest <NXRESTAPIScheduleProtocol>

-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;

@end

@interface  NXProjectDownloadFileAPIResponse : NXSuperRESTAPIResponse

@property (nonatomic,strong)NSData *resultData;

@end


