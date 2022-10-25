//
//  NXMyDriveFileListAPI.h
//  nxrmc
//
//  Created by helpdesk on 30/11/16.
//  Copyright © 2016年 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"
@interface NXMyDriveFileItem:NSObject
@property (nonatomic,strong) NSString *pathId;
@property (nonatomic,strong) NSString *pathDisplay;
@property (nonatomic,strong) NSString *size;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,assign) BOOL folder;
@property (nonatomic,strong) NSString *lastModified;
-(instancetype)initWithDictionary:(NSDictionary*)dictionary;
@end

@interface NXMyDriveFileListAPI : NXSuperRESTAPIRequest<NXRESTAPIScheduleProtocol>
-(NSURLRequest *) generateRequestObject:(id) object;
- (Analysis)analysisReturnData;
@end

@interface NXGetMyDriveFileListAPIResponse : NXSuperRESTAPIResponse
@property(nonatomic, strong) NSMutableArray * myDriveFileLists;
@property(nonatomic, strong) NSError *errorR;
@end
