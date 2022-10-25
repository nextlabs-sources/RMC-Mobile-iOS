//
//  NXFavoriteGetAllFavoriteFilesInRepoAPI.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 21/08/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXFavoriteGetAllFavoriteFilesInReposAPI.h"


@implementation NXFavoriteGetAllFavoriteFilesQuery

- (instancetype)init
{
    self = [super init];
    if (self) {
        _page = 1;
        _size = 1000;
        _orderByType = NXFavoriteOrderByTypeNameAscending;
        _q = nil;
    }
    return self;
}

@end

@implementation NXFavoriteGetAllFavoriteFilesInReposAPIRequest

-(NSURLRequest *)generateRequestObject:(id)object
{
    if (self.reqRequest == nil)
    {
//        NXFavoriteGetAllFavoriteFilesQuery *query = object[@"query"];
//        
//        NSString *orderType = @"";
//        switch (query.orderByType)
//        {
//            case NXFavoriteOrderByTypeNameAscending:
//                
//                orderType = @"name";
//                
//                break;
//                
//            case NXFavoriteOrderByTypeNameDescending:
//                orderType = @"-name";
//                break;
//                
//            case NXFavoriteOrderByTypeLastModifiedTimeAscending:
//                
//                orderType = @"lastModifiedTime";
//                break;
//                
//            case NXFavoriteOrderByTypeLastModifiedTimeDescending:
//                
//                orderType = @"-lastModifiedTime";
//                break;
//                
//            case NXFavoriteOrderByTypeFileSizeAscending:
//                orderType = @"fileSize";
//                break;
//            
//            case NXFavoriteOrderByTypeFileSizeDescending:
//                 orderType = @"-fileSize";
//                
//            default:
//                orderType = @"name";
//                
//                break;
//        }
        
     //   NSURL *apiURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/rs/favorite/list?page=%lu&size=%lu&orderBy=%@",[NXCommonUtils currentRMSAddress],(unsigned long)query.page,(unsigned long)query.size,orderType]];
        
        NSURL *apiURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/rs/favorite/list",[NXCommonUtils currentRMSAddress]]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        
        [request setHTTPMethod:@"GET"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        self.reqRequest = request;
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error){
        NXFavoriteGetAllFavoriteFilesInReposAPIResponse *response = [[NXFavoriteGetAllFavoriteFilesInReposAPIResponse alloc]init];
        NSData *resultData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (resultData) {
            [response analysisResponseStatus:resultData];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *resultsDic = dic[@"results"];
            NSArray *resultsDicArray = resultsDic[@"results"];
            
            NSNumber *loadMore = resultsDic[@"loadMore"];
            response.loadMore = loadMore.boolValue;
            
            NSMutableArray *itemsArray = [NSMutableArray new];
            if (resultsDicArray.count >= 1) {
                  for (NSDictionary *fileItemModelDic in resultsDicArray) {
                      if (fileItemModelDic.allKeys.count >=1) {
                          
                        NXFavoriteSpecificFileItemModel *specialModel = [[NXFavoriteSpecificFileItemModel alloc] init];
                          
                          NSString *repoId = fileItemModelDic[@"repoId"];
                          NSString *repoName = fileItemModelDic[@"repoName"];
                          NSNumber *repoType = fileItemModelDic[@"repoType"];
                          
                          [specialModel.repoModel setValue:repoId forKey:@"service_id"];
                          [specialModel.repoModel setValue:repoType forKey:@"service_type"];
                          specialModel.repoModel.service_alias = repoName;
                          
                          NSNumber *fromMyVault = fileItemModelDic[@"fromMyVault"];
                          if (fromMyVault.boolValue == YES) {
                              NXMyVaultFile *myvaultFile = [[NXMyVaultFile alloc] init];
                              
                              NSNumber *size = fileItemModelDic[@"fileSize"];
                              NSNumber *isDeleted = fileItemModelDic[@"deleted"];
                              NSString *fullServicePath = fileItemModelDic[@"fileId"];
                              NSNumber *lastModifiedTime = fileItemModelDic[@"lastModifiedTime"];
                              
                              myvaultFile.size = size.longLongValue;
                              myvaultFile.repoId = repoId;
                              myvaultFile.name = fileItemModelDic[@"name"];
                              myvaultFile.fullServicePath = fullServicePath;
                              myvaultFile.fullPath = fileItemModelDic[@"path"];
                              myvaultFile.serviceAlias = @"MyVaut";
                              myvaultFile.serviceType = repoType;
                              myvaultFile.sorceType = NXFileBaseSorceTypeMyVaultFile;
                              myvaultFile.lastModifiedTime = [NSString stringWithFormat:@"%lld",(lastModifiedTime.longLongValue/1000)];
                              myvaultFile.lastModifiedDate = [NSDate dateWithTimeIntervalSince1970:myvaultFile.lastModifiedTime.longLongValue];
                              myvaultFile.isDeleted = isDeleted.boolValue;
                              myvaultFile.isFavorite = YES;
                              specialModel.fileItem = myvaultFile;
                          }
                          else
                          {
                              NXFile *fileItem = [[NXFile alloc] init];
                              NSString *fullServicePath = fileItemModelDic[@"fileId"];
                              NSNumber *lastModifiedTime = fileItemModelDic[@"lastModifiedTime"];
                              
                              NSNumber *size = fileItemModelDic[@"fileSize"];
                              fileItem.size = size.longLongValue;
                              fileItem.name = fileItemModelDic[@"name"];
                              fileItem.repoId = repoId;
                              fileItem.fullServicePath = fullServicePath;
                              fileItem.fullPath = fileItemModelDic[@"path"];
                              fileItem.serviceAlias = repoName;
                              fileItem.serviceType = repoType;
                              fileItem.sorceType = NXFileBaseSorceTypeRepoFile;
                              fileItem.lastModifiedTime = [NSString stringWithFormat:@"%lld",(lastModifiedTime.longLongValue/1000)];
                              fileItem.lastModifiedDate = [NSDate dateWithTimeIntervalSince1970:fileItem.lastModifiedTime.longLongValue];

                              fileItem.isFavorite = YES;
                              specialModel.fileItem = fileItem;
                          }
                          
                          [itemsArray addObject:specialModel];
                      }
                  }
            }
            response.favoriteRepoModelArray = itemsArray;
        }
        return response;
    };
    return analysis;
}

@end

@implementation NXFavoriteGetAllFavoriteFilesInReposAPIResponse

-(instancetype)init
{
    self = [super init];
    if (self) {
        _loadMore = NO;
    }
    return self;
}

-(NSMutableArray*)favoriteRepoModelArray {
    if (!_favoriteRepoModelArray) {
        _favoriteRepoModelArray = [NSMutableArray array];
    }
    return _favoriteRepoModelArray;
}
@end
