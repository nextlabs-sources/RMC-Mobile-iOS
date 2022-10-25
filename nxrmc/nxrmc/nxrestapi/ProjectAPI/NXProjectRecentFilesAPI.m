//
//  NXProjectRecentFilesAPI.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 15/5/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXProjectRecentFilesAPI.h"
#import "NSString+Utility.h"
@interface NXProjectRecentFilesAPIRequest ()
@property (nonatomic,strong) NSNumber *projectId;
@end
@implementation NXProjectRecentFilesAPIRequest
-(NSURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        if ([object isKindOfClass:[NXProjectFileListParameterModel class]]) {
            NXProjectFileListParameterModel *parModel = (NXProjectFileListParameterModel*)object;
            self.projectId = parModel.projectId;
            
            NSString *urlStr = [NSString stringWithFormat:@"%@/rs/project/%@/files?page=%@&size=%@&orderBy=%@&t=0", [NXCommonUtils currentRMSAddress],parModel.projectId,parModel.page,parModel.size,@"-creationTime"];
            NSString *encodedString = encodedString = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:encodedString]];
            
            [request setHTTPMethod:@"GET"];
            self.reqRequest = request;
        }
    }
    return self.reqRequest;
}
-(Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        NXProjectRecentFilesAPIResponse *response =[[NXProjectRecentFilesAPIResponse alloc]init];
        NSData *resultData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (resultData) {
            [response analysisResponseStatus:resultData];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *resultsDic = dic[@"results"];
            if (!error && response.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) {
                NSNumber *usageNum = resultsDic[@"usage"];
                NSNumber *quotaNum = resultsDic[@"quota"];
                NSDictionary *spaceDict = @{@"usage":usageNum,@"quota":quotaNum}.copy;
                response.spaceDict = spaceDict;
            }
            NSDictionary *detailDic = resultsDic[@"detail"];
            NSArray *filesArr = detailDic[@"files"];
            NSMutableArray *fileItemsArray = [NSMutableArray array];
            for (NSDictionary *fileItemDic in filesArr) {
               
                    NXProjectFile *fileItem = [[NXProjectFile alloc]initFileFromResultProjectFileListDic:fileItemDic];
                    fileItem.projectId = self.projectId;
                    [fileItemsArray addObject:fileItem];
                
            }
            response.fileItems = fileItemsArray;
        }
        return response;
    };
    return analysis;
}

@end
@implementation NXProjectRecentFilesAPIResponse

-(NSMutableArray*)fileItems {
    if (!_fileItems) {
        _fileItems=[NSMutableArray array];
    }
    return _fileItems;
}

@end
