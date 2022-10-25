//
//  NXProjectUpdateAPI.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 21/8/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"
@interface NXProjectUpdateParmetersMD :NSObject
@property (nonatomic, strong)NSString *projectName;
@property (nonatomic, strong)NSString *projectDescription;
@property (nonatomic, strong)NSNumber *projectId;
@property (nonatomic, strong)NSString *invitationMsg;
@end

@interface NXProjectUpdateAPIRequest : NXSuperRESTAPIRequest<NXRESTAPIScheduleProtocol>
-(NSURLRequest *)generateRequestObject:(id)object;
-(Analysis)analysisReturnData;
@end

@interface NXProjectUpdateAPIResponse : NXSuperRESTAPIResponse
@property (nonatomic, strong)NXProjectModel *ProjectModel;
@end
