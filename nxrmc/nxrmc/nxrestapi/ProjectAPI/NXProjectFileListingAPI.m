//
//  NXProjectFileListingAPI.m
//  nxrmc
//
//  Created by helpdesk on 18/1/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXProjectFileListingAPI.h"
#import "NXCommonUtils.h"
#import "NXProjectModel.h"
#import "NXProjectFileListParameterModel.h"
#import "NXProjectFile.h"
#import "NXProjectFolder.h"
// api requset
@interface NXProjectFileListingAPIRequest ()
@property (nonatomic,strong) NSNumber *projectId;
@property (nonatomic,strong) NSString *parentPath;
@end
@implementation NXProjectFileListingAPIRequest
-(NSURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        if ([object isKindOfClass:[NXProjectFileListParameterModel class]]) {
             NXProjectFileListParameterModel *parModel = (NXProjectFileListParameterModel*)object;
            self.projectId = parModel.projectId;
            self.parentPath = parModel.parentPath;
            NSString *orderType = @"";
            NSString *filterType = nil;
            switch (parModel.filterType) {
                case NXProjectFileListFilterByTypeAllFiles:
                    filterType = @"allFiles";
                    break;
                case NXProjectFileListFilterByTypeAllShared:
                    filterType = @"allShared";
                    break;
                case NXProjectFileListFilterByTypeRevoked:
                    filterType = @"revoked";
                default:
                    break;
            }
            switch (parModel.orderByType)
            {
                case NXProjectListSortTypeFileNameAscending:
                    
                    orderType = @"name";
                   
                    break;
                    
                case NXProjectListSortTypeCreateTimeAscending:
                    orderType = @"creationTime";
                    break;
                    
                case NXProjectListSortTypeFileNameDescending:
                    
                     orderType = @"-name";
                    break;
                    
                case NXProjectListSortTypeCreateTimeDescending:
                    
                    orderType = @"-creationTime";
                    break;
                    
                default:
                     orderType = @"creationTime";
                
                    break;
            }
            NSString *urlStr = nil;
            if (parModel.filterType == NXProjectFileListFilterByTypeAllFiles) {
              urlStr = [NSString stringWithFormat:@"%@/rs/project/%@/files?page=%@&size=%@&orderBy=%@&pathId=%@&filter=%@", [NXCommonUtils currentRMSAddress],parModel.projectId,parModel.page,parModel.size,orderType,parModel.parentPath,filterType];
               
            }else{
               urlStr = [NSString stringWithFormat:@"%@/rs/project/%@/files?page=%@&size=%@&orderBy=%@&filter=%@", [NXCommonUtils currentRMSAddress],parModel.projectId,parModel.page,parModel.size,orderType,filterType];
               
            }

           
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
        NXProjectFileListingAPIResponse *response =[[NXProjectFileListingAPIResponse alloc]init];
        NSData *resultData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (resultData) {
            [response analysisResponseStatus:resultData];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *resultsDic = dic[@"results"];
            NSDictionary *detailDic = resultsDic[@"detail"];
            NSArray *filesArr = detailDic[@"files"];
            NSMutableArray *fileItemsArray = [NSMutableArray array];
            for (NSDictionary *fileItemDic in filesArr) {
                BOOL isFolder = [fileItemDic[@"folder"] boolValue];
                if (isFolder) {
                    NXProjectFolder *folderItem = [[NXProjectFolder alloc]initFileFromResultProjectFileListDic:fileItemDic];
                    folderItem.projectId = [NSNumber numberWithInteger:[self.projectId integerValue]];
                    NSString *parentPath = [folderItem.fullServicePath stringByDeletingLastPathComponent];
                    if (![parentPath isEqualToString:@"/"]) {
                        parentPath = [parentPath stringByAppendingString:@"/"];
                    }
                    folderItem.parentPath = parentPath;
                    [fileItemsArray addObject:folderItem];
                    
                } else {
                    NXProjectFile *fileItem = [[NXProjectFile alloc] initFileFromResultProjectFileListDic:fileItemDic];
                    fileItem.projectId = self.projectId;
                    NSString *parentPath = [fileItem.fullServicePath stringByDeletingLastPathComponent];
                    if (![parentPath isEqualToString:@"/"]) {
                        parentPath = [parentPath stringByAppendingString:@"/"];
                    }
                    fileItem.parentPath = parentPath;
                    [fileItemsArray addObject:fileItem];
                    
                }
               
            }
             response.fileItems = fileItemsArray;
        }
        return response;
    };
    return analysis;
}
- (NSArray<NSURLQueryItem *> *)createQueryItems:(NXProjectFileListParameterModel *)parModel{
    NSMutableArray<NSURLQueryItem *> *items = [NSMutableArray array];
    
    NSURLQueryItem *pageItem = [NSURLQueryItem queryItemWithName:@"page" value:parModel.page];
    [items addObject:pageItem];
    
    NSURLQueryItem *sizeItem = [NSURLQueryItem queryItemWithName:@"size" value:parModel.size];
    [items addObject:sizeItem];
    
    NSURLQueryItem *filterItem;
    switch (parModel.orderByType) {
        case NXProjectListSortTypeFileNameAscending:
        {
            filterItem = [NSURLQueryItem queryItemWithName:@"orderBy" value:@"name"];
        }
            break;
        case NXProjectListSortTypeCreateTimeAscending:
        {
            filterItem = [NSURLQueryItem queryItemWithName:@"orderBy" value:@"creationTime"];
        }
            break;
        case NXProjectListSortTypeFileNameDescending:
        {
            filterItem = [NSURLQueryItem queryItemWithName:@"orderBy"
                value:@"-name"];
        }
            break;
        case NXProjectListSortTypeCreateTimeDescending:
        {
            filterItem = [NSURLQueryItem queryItemWithName:@"orderNy"
                value:@"-creationTime"];
        }
            break;
        default:
            break;
    }
    [items addObject:filterItem];
    
    NSURLQueryItem *parentPathItem = [NSURLQueryItem queryItemWithName:@"pathId" value:parModel.parentPath];
    
    [items addObject:parentPathItem];
    return items;
}

@end
// api response
@implementation NXProjectFileListingAPIResponse
-(NSMutableArray*)fileItems {
    if (!_fileItems) {
        _fileItems = [NSMutableArray array];
    }
    return _fileItems;
}
@end
