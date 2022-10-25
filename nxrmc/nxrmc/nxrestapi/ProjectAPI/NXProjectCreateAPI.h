//
//  NXProjectCreatedAPI.h
//  nxrmc
//
//  Created by helpdesk on 18/1/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"
@interface NXProjectCreateParmetersMD :NSObject
@property (nonatomic, strong)NSString *projectName;
@property (nonatomic, strong)NSString *projectDescription;
@property (nonatomic, strong)NSArray *userEmails;
@property (nonatomic, strong)NSString *invitationMsg;
@end

@class NXProjectModel;
@interface NXProjectCreateAPIRequest : NXSuperRESTAPIRequest <NXRESTAPIScheduleProtocol>
-(NSURLRequest *)generateRequestObject:(id)object;
-(Analysis)analysisReturnData;

@end

@interface NXProjectCreateAPIResponse : NXSuperRESTAPIResponse
@property (nonatomic, strong)NXProjectModel *ProjectModel;

@end
