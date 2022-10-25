//
//  NXMyVaultFileListAPI.m
//  nxrmc
//
//  Created by helpdesk on 29/12/16.
//  Copyright © 2016年 nextlabs. All rights reserved.
//

#import "NXMyVaultFileListAPI.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXMyVaultFile.h"
#import "NXMyVaultListParModel.h"

@implementation NXMyVaultFileListAPIRequest

- (NSURLRequest *)generateRequestObject:(id)object {
    if (!self.reqRequest) {
        if ([object isKindOfClass:[NXMyVaultListParModel class]]) {
            NXMyVaultListParModel *parModel =(NXMyVaultListParModel*)object;
            
            NSURLComponents *componments = [NSURLComponents componentsWithString:[NSString stringWithFormat:@"%@%@", [NXCommonUtils currentRMSAddress], @"/rs/myVault"]];
            componments.queryItems = [self createQueryItems:parModel];
                
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:componments.URL];
            [request setHTTPMethod:@"GET"];
            self.reqRequest = request;
        }
    }
    return self.reqRequest;
}

- (NSArray<NSURLQueryItem *> *)createQueryItems:(NXMyVaultListParModel *)parModel {
    NSMutableArray<NSURLQueryItem *> *items = [NSMutableArray array];
    
    NSURLQueryItem *pageItem = [NSURLQueryItem queryItemWithName:@"page" value:parModel.page];
    [items addObject:pageItem];
    
    NSURLQueryItem *sizeItem = [NSURLQueryItem queryItemWithName:@"size" value:parModel.size];
    [items addObject:sizeItem];
    
    NSURLQueryItem *filterItem;
    switch (parModel.filterType) {
        case NXMyvaultListFilterTypeAllFiles:
        {
            filterItem = [NSURLQueryItem queryItemWithName:@"filter" value:@"allFiles"];
        }
            break;
        case NXMyvaultListFilterTypeProtected:
        {
            filterItem = [NSURLQueryItem queryItemWithName:@"filter" value:@"protected"];
        }
            break;
        case NXMyvaultListFilterTypeAllShared:
        {
            filterItem = [NSURLQueryItem queryItemWithName:@"filter" value:@"allShared"];
        }
            break;
        case NXMyvaultListFilterTypeActivedTransaction:
        {
            filterItem = [NSURLQueryItem queryItemWithName:@"filter" value:@"activeTransaction"];
        }
            break;
        case NXMyvaultListFilterTypeActivedRevoked:
            filterItem = [NSURLQueryItem queryItemWithName:@"filter" value:@"revoked"];
            break;
        case NXMyvaultListFilterTypeActivedDeleted:
            filterItem = [NSURLQueryItem queryItemWithName:@"filter" value:@"deleted"];
        default:
            break;
    }
    [items addObject:filterItem];
    
    NSMutableString *sortStr = [NSMutableString string];
    [parModel.sortOptions enumerateObjectsUsingBlock:^(NSNumber*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        switch (obj.integerValue) {
            case NXMyVaultListSortTypeSizeAscending:
                [sortStr appendString:@"size"];
                break;
            case NXMyVaultListSortTypeSizeDescending:
                [sortStr appendString:@"-size"];
                break;
            case NXMyVaultListSortTypeFileNameAscending:
                [sortStr appendString:@"fileName"];
                break;
            case NXMyVaultListSortTypeFileNameDescending:
                [sortStr appendString:@"-fileName"];
                break;
            case NXMyVaultListSortTypeCreateTimeAscending:
                [sortStr appendString:@"creationTime"];
                break;
            case NXMyVaultListSortTypeCreateTimeDescending:
                [sortStr appendString:@"-creationTime"];
                break;
            default:
                break;
        }
    }];
    NSURLQueryItem *sortItem = [NSURLQueryItem queryItemWithName:@"orderBy" value:sortStr];
    [items addObject:sortItem];
    if (parModel.searchString.length) {
        NSURLQueryItem *searchItem = [NSURLQueryItem queryItemWithName:@"q.fileName" value:parModel.searchString];
        [items addObject:searchItem];
    }
    
    return items;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        NXMyVaultFileListAPIResponse *response =[[NXMyVaultFileListAPIResponse alloc]init];
        if (returnData) {
            NSData *resultData=[returnData dataUsingEncoding:NSUTF8StringEncoding];
            returnData = nil;
            [response analysisResponseStatus:resultData];
            NSDictionary *returnDic = nil;
            @autoreleasepool {
                returnDic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
            }
            resultData = nil;
            if (response.rmsStatuCode == 200){
                if ([returnDic objectForKey:@"results"]) {
                    NSDictionary *resultDic = returnDic[@"results"];
                    if ([resultDic objectForKey:@"detail"]) {
                        NSDictionary *detail = resultDic[@"detail"];
                        if ([detail objectForKey:@"totalFiles"]) {
                            NSNumber *count = detail[@"totalFiles"];
                            response.totalCount = count.integerValue;
                        }
                        if ([detail objectForKey:@"files"]) {
                            NSMutableArray *files = [NSMutableArray array];
                            for (NSDictionary *fileDic in detail[@"files"]) {
                                @autoreleasepool {
                                    NXMyVaultFile *myVaultFile = [[NXMyVaultFile alloc]initWithDictory:fileDic];
                                    [files addObject:myVaultFile];
                                }
                            }
                            response.fileList = files;
                        }
                    }
                }
                returnDic = nil;
           }
       }
       return response;
   };
    return analysis;
}

@end

@implementation NXMyVaultFileListAPIResponse

- (NSMutableArray *)filelists {
    if (!_fileList) {
        _fileList=[NSMutableArray array];
    }
    return _fileList;
}

@end
