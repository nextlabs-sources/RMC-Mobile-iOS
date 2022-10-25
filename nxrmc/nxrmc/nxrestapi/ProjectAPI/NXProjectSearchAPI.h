//
//  NXProjectSearchAPI.h
//  nxrmc
//
//  Created by xx-huang on 16/01/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXSuperRESTAPI.h"

#define QUERY      @"query"
#define PROJECT_ID @"projectId"

@interface NXProjectMatchedFileItem : NSObject

@property (nonatomic,strong) NSString *filePathDisplay;
@property (nonatomic,strong) NSString *filePath;
@property (nonatomic,strong) NSString *fileName;
@property (nonatomic,strong) NSString *fileSize;
@property (nonatomic,strong) NSString *folder;

-(instancetype)initWithDictionary:(NSDictionary*)dictionary;
@end

@interface NXProjectSearchAPIRequest : NXSuperRESTAPIRequest <NXRESTAPIScheduleProtocol>

-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;

@end

@interface NXProjectSearchAPIResponse : NXSuperRESTAPIResponse

@property (nonatomic,strong) NSMutableArray *matchedFileList;

@end


