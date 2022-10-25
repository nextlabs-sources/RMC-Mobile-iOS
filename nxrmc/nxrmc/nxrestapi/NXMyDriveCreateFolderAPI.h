//
//  NXMyDriveCreateFolderAPI.h
//  nxrmc
//
//  Created by helpdesk on 9/12/16.
//  Copyright © 2016年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXSuperRESTAPI.h"
@interface NXMyDriveCreateFolderAPI : NXSuperRESTAPIRequest <NXRESTAPIScheduleProtocol>

-(NSURLRequest *) generateRequestObject:(id) object;
- (Analysis)analysisReturnData;
@end
@interface NXMyDriveCreateFolderAPIResponse : NXSuperRESTAPIResponse
@property (nonatomic,strong)NSString *name;
@property(nonatomic, strong) NSString *pathId;
@property(nonatomic, strong) NSString *pathDisplay;
@property(nonatomic, assign) NSTimeInterval lastModified;
@property (nonatomic,strong)NSError  *errorR;
@end
