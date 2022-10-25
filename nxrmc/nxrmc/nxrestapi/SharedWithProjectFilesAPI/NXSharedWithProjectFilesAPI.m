//
//  NXSharedFilesWithProjectAPI.m
//  nxrmc
//
//  Created by 时滕 on 2019/12/11.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXSharedWithProjectFilesAPI.h"
@interface NXSharedWithProjectFilesRequest()
@property(nonatomic, strong) NXProjectModel *project;
@end

@implementation NXSharedWithProjectFilesRequest
- (NSURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NSAssert([object isMemberOfClass:[NXProjectModel class]], @"NXSharedWithProjectFilesRequest modle should be NXProjectModel");
        NSURL *apiUrl  = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/sharedWithMe/list?fromSpace=1&spaceId=%@",[NXCommonUtils currentRMSAddress],((NXProjectModel *)object).projectId]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiUrl];
        [request setHTTPMethod:@"GET"];
        self.reqRequest = request;
        self.project = object;
    }
    return  self.reqRequest;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        NXSharedWithProjectFilesResponse *response = [[NXSharedWithProjectFilesResponse alloc] init];
        NSData *contentData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (contentData)
        {
            [response analysisResponseStatus:contentData];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:contentData options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *resultsDic = dic[@"results"];
            NSDictionary *detailDic = resultsDic[@"detail"];
            NSArray *filesArray = detailDic[@"files"];
            NSMutableArray *itemsArray = [NSMutableArray array];
            for (NSDictionary *fileDic in filesArray) {
                NXSharedWithProjectFile *item = [[NXSharedWithProjectFile alloc] initWithDictionary:fileDic];
                item.spaceId = self.project.projectId.stringValue;
                item.sharedProject = self.project;
                [itemsArray addObject:item];
            }
            response.itemsArray = itemsArray;
        }
        
        return response;

    };
    return analysis;
}
@end

@implementation NXSharedWithProjectFilesResponse

@end
