//
//  NXMyDriveFileUploadAPI.h
//  nxrmc
//
//  Created by helpdesk on 5/12/16.
//  Copyright © 2016年 nextlabs. All rights reserved.
//


#import "NXSuperRESTAPI.h"
@interface NXMyDriveUploadFileItem:NSObject
@property (nonatomic,strong) NSString *pathId;
@property (nonatomic,strong) NSString *pathDisplay;
@property (nonatomic,strong) NSNumber *size;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,assign) NSTimeInterval lastModified;
-(instancetype)initWithDictionary:(NSDictionary*)dictionary;
@end
@interface NXMyDriveFileUploadAPI : NXSuperRESTAPIRequest <NXRESTAPIScheduleProtocol>
-(NSURLRequest *) generateRequestObject:(id) object;
- (Analysis)analysisReturnData;
@end
@interface NXMyDriveFileUploadAPIResponse : NXSuperRESTAPIResponse
@property (nonatomic,strong)NXMyDriveUploadFileItem *item;
@end
