//
//  NXProjectReclassifyFileAPI.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/5/8.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

@class NXProjectFile;
@interface NXProjectReclassifyFileAPIRequest : NXSuperRESTAPIRequest<NXRESTAPIScheduleProtocol>
-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;
@end
@interface NXProjectReclassifyFileAPIResponse : NXSuperRESTAPIResponse
@property (nonatomic,strong) NXProjectFile *fileItem;
@end
