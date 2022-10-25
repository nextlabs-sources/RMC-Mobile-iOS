//
//  NXMyVaultFileUploadAPI.h
//  nxrmc
//
//  Created by xx-huang on 29/12/2016.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXSuperRESTAPI.h"
#import "NXMyVaultFile.h"

@interface NXMyVaultFileUploadAPIRequest : NXSuperRESTAPIRequest <NXRESTAPIScheduleProtocol>

-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;

@end

@interface NXMyVaultFileUploadAPIResponse : NXSuperRESTAPIResponse

@property (nonatomic,strong) NXMyVaultFile *fileItem;

@end
