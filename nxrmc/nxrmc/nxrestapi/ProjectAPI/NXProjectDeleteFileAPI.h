//
//  NXProjectDeleteFileAPI.h
//  nxrmc
//
//  Created by xx-huang on 16/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXSuperRESTAPI.h"

#define FILE_PATH  @"filePath"
#define PROJECT_ID @"projectId"

@interface NXProjectDeleteFileAPIRequest : NXSuperRESTAPIRequest <NXRESTAPIScheduleProtocol>

-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;

@end

@interface NXProjectDeleteFileAPIResponse : NXSuperRESTAPIResponse

@property (nonatomic,strong) NSString *path;
@property (nonatomic,strong) NSString *name;

@end

