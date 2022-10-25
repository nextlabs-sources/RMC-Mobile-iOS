//
//  NXSharedWithMeFileListAPI.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 26/7/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXSharedWithMeFileListAPI.h"
#import "NXSharedWithMeFileListParameterModel.h"
#import "NXSharedWithMeFile.h"
@implementation NXSharedWithMeFileListAPIRequest
- (NSURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        if ([object isMemberOfClass:[NXSharedWithMeFileListParameterModel class]]) {
            NXSharedWithMeFileListParameterModel *parameterModel = (NXSharedWithMeFileListParameterModel *)object;

            NSString *orderBy = @"-sharedDate";
            switch (parameterModel.orderByType) {
                case NXSharedWithMeFileListOrderByNameAscending:
                    orderBy = @"name";
                    break;
                case NXSharedWithMeFileListOrderByNameDescending:
                    orderBy = @"-name";
                    break;
                case NXSharedWithMeFileListOrderBySizeAscending:
                    orderBy = @"size";
                    break;
                case NXSharedWithMeFileListOrderBySizeDescending:
                    orderBy = @"-size";
                    break;
                case NXSharedWithMeFileListOrderBySharedDateAscending:
                    orderBy = @"sharedDate";
                    break;
                case NXSharedWithMeFileListOrderBySharedDateDescending:
                    orderBy = @"-sharedDate";
                    break;
                case NXSharedWithMeFileListOrderBySharedByAscending:
                    orderBy = @"sharedBy,-sharedDate";
                    break;
                case NXSharedWithMeFileListOrderBySharedByDescending:
                    orderBy = @"-sharedBy,-sharedDate";
                    break;
            }
            
            NSString *searchBy = @"name";
            
            switch (parameterModel.searchByType) {
                case NXSharedWithMeFileListSearchFileByName:
                    searchBy = @"name";
                    break;
            }
            
        NSURL *apiUrl  = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/sharedWithMe/list?page=%lu&size=%lu&orderBy=%@&q=%@&searchString=%@",[NXCommonUtils currentRMSAddress],(unsigned long)parameterModel.page,(unsigned long)parameterModel.size,orderBy,searchBy,parameterModel.searchString]];
            
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiUrl];
            [request setHTTPMethod:@"GET"];
            self.reqRequest = request;
            
        }
    }
    return  self.reqRequest;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        NXSharedWithMeFileListAPIResponse *response = [[NXSharedWithMeFileListAPIResponse alloc] init];
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
                NXSharedWithMeFile *item = [[NXSharedWithMeFile alloc]initWithDictionary:fileDic];
                [itemsArray addObject:item];
            }
            response.itemsArray = itemsArray;
        }
        
        return response;

    };
    return analysis;
}

@end




@implementation NXSharedWithMeFileListAPIResponse

- (NSMutableArray *)itemsArray {
    if (!_itemsArray) {
        _itemsArray = [NSMutableArray array];
    }
    return _itemsArray;
}

@end
