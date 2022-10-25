//
//  NXMyVaultFileListAPI.h
//  nxrmc
//
//  Created by helpdesk on 29/12/16.
//  Copyright © 2016年 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

@interface NXMyVaultFileListAPIRequest : NXSuperRESTAPIRequest<NXRESTAPIScheduleProtocol>
-(NSURLRequest *) generateRequestObject:(id) object;
- (Analysis)analysisReturnData;
@end
@interface NXMyVaultFileListAPIResponse : NXSuperRESTAPIResponse
@property (nonatomic,strong)NSMutableArray *fileList;
@property (nonatomic,assign)NSInteger totalCount;
@end
