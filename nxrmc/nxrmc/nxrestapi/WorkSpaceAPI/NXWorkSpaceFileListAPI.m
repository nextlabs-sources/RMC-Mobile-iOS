//
//  NXWorkSpaceFileListAPI.m
//  nxrmc
//
//  Created by Eren on 2019/8/28.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXWorkSpaceFileListAPI.h"
#import "NXWorkSpaceItem.h"
#import "NSString+Utility.h"

@implementation NXWorkSpaceFileListRequest
-(NSURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NSAssert([object isKindOfClass:[NXFolder class]], @"NXWorkSpaceFileListRequest object should be NXWorkSpaceFile");
        NXWorkSpaceFolder *folder = (NXWorkSpaceFolder *)object;
        self.reqRequest = [[NSMutableURLRequest alloc] init];
        
        if (folder.fullServicePath) {
            [self.reqRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/enterprisews/files?pathId=%@",  [NXCommonUtils currentRMSAddress], [folder.fullServicePath toHTTPURLString]]]];
        }else{
            [self.reqRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/enterprisews/files",  [NXCommonUtils currentRMSAddress]]]];
        }
       
        [self.reqRequest setHTTPMethod:@"GET"];
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error){
        NXWorkSaceFileListResponse *response = [[NXWorkSaceFileListResponse alloc] init];
        NSData *data = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (data) {
            [response analysisResponseData:data];
        }
        return response;
    };
    return analysis;
}
@end


@implementation NXWorkSaceFileListResponse
- (NSMutableArray *)workSpaceFileList {
    if (_workSpaceFileList == nil) {
        _workSpaceFileList = [[NSMutableArray alloc] init];
    }
    return _workSpaceFileList;
}

- (void)analysisResponseData:(NSData *)responseData {
    [self analysisResponseStatus:responseData];
    if (self.rmsStatuCode == 200) {
        NSError *error = nil;
        NSDictionary *responseDict = [responseData toJSONDict:&error];
        if (error == nil) {
            NSDictionary *resultsDict = responseDict[@"results"];
            if (resultsDict) {
                NSNumber  *usage = (NSNumber*)resultsDict[@"usage"];
                NSNumber  *quota = (NSNumber*)resultsDict[@"quota"];
                self.usage = usage;
                self.quota = quota;
                NSDictionary *detailDict = resultsDict[@"detail"];
                if (detailDict) {
                    NSNumber *totalFiles = (NSNumber *)detailDict[@"totalFiles"];
                    self.totalFiles = totalFiles;
                    NSArray *fileListArray = detailDict[@"files"];
                    for (NSDictionary *fileInfoDict in fileListArray) {
                        BOOL isFolder = ((NSNumber *)fileInfoDict[@"folder"]).boolValue;
                        NXFileBase *fileItem = isFolder?[[NXWorkSpaceFolder alloc] initWithDictionary:fileInfoDict] : [[NXWorkSpaceFile alloc] initWithDictionary:fileInfoDict];
                        [self.workSpaceFileList addObject:fileItem];

                    }
                }
            }
        }
    }
}
@end
