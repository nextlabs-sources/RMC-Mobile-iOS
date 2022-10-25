//
//  NXFavoriteGetAllFavoriteFilesInRepoAPI.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 21/08/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXFavoriteSpecificFileItemModel.h"
#import "NXSuperRESTAPI.h"

typedef NS_ENUM(NSInteger, NXFavoriteOrderByType) {
    NXFavoriteOrderByTypeNameAscending = 0,
    NXFavoriteOrderByTypeNameDescending,
    NXFavoriteOrderByTypeLastModifiedTimeAscending,
    NXFavoriteOrderByTypeLastModifiedTimeDescending,
    NXFavoriteOrderByTypeFileSizeAscending,
    NXFavoriteOrderByTypeFileSizeDescending
};

@interface NXFavoriteGetAllFavoriteFilesQuery : NSObject

@property (nonatomic,assign) NSUInteger page;
@property (nonatomic,assign) NSUInteger size;
@property (nonatomic,assign) NXFavoriteOrderByType orderByType;
@property (nonatomic,strong) NSString *q;

@end

@interface NXFavoriteGetAllFavoriteFilesInReposAPIRequest : NXSuperRESTAPIRequest <NXRESTAPIScheduleProtocol>
-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;
@end

@interface NXFavoriteGetAllFavoriteFilesInReposAPIResponse : NXSuperRESTAPIResponse
@property (nonatomic,strong) NSMutableArray *favoriteRepoModelArray;
@property (nonatomic,assign) BOOL loadMore;
@end

