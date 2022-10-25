//
//  NXMyVaultFileDownloadAPI.h
//  nxrmc
//
//  Created by xx-huang on 29/12/2016.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"


#define PATH @"pathId"
#define START @"start"
#define LENGTH @"length"
#define DOWNLOAD_TYPE @"type"
@interface NXMyVaultFileDownloadAPIRequest : NXSuperRESTAPIRequest<NXRESTAPIScheduleProtocol>

-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;

@end

@interface NXMyVaultFileDownloadAPIResponse : NXSuperRESTAPIResponse

@property (nonatomic,strong)NSData *fileData;
@property (nonatomic,strong)NSString *fileName;
@end
