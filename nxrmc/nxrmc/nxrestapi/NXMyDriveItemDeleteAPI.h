//
//  NXMyDriveItemDeleteAPI.h
//  nxrmc
//
//  Created by helpdesk on 9/12/16.
//  Copyright © 2016年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXSuperRESTAPI.h"
@interface NXMyDriveDeleteItem:NSObject
@property (nonatomic,strong) NSString *path;
@property (nonatomic,strong) NSString *usage;
@property (nonatomic,strong) NSString *name;
@end
@interface NXMyDriveItemDeleteAPI : NXSuperRESTAPIRequest <NXRESTAPIScheduleProtocol>
-(NSURLRequest *) generateRequestObject:(id) object;
- (Analysis)analysisReturnData;
@end
@interface NXMyDriveItemDeleteAPIResponse:NXSuperRESTAPIResponse
@property (nonatomic,strong)NXMyDriveDeleteItem *deleteItem;
@property (nonatomic,strong)NSError *errorR;
@end
