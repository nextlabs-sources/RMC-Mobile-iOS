//
//  NXProjectCreateFolderAPI.h
//  nxrmc
//
//  Created by xx-huang on 18/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXSuperRESTAPI.h"

#define PROJECT_ID  @"projectId"
#define FILE_PATH  @"parentPathId"
#define AUTO_RENAME @"autorename"
#define FOLDER_NAME @"name"

@interface  NXProjectCreateFolderAPIRequest : NXSuperRESTAPIRequest <NXRESTAPIScheduleProtocol>

-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;

@end

@interface  NXProjectCreateFolderAPIResponse : NXSuperRESTAPIResponse

@property (nonatomic,strong) NSString *folderName;
@property (nonatomic,strong) NXProjectFolder *createFolder;
@end
