//
//  NXVaultListParModel.h
//  nxrmc
//
//  Created by helpdesk on 29/12/16.
//  Copyright © 2016年 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NXMyVaultListSortType) {
    NXMyVaultListSortTypeFileNameAscending = 0,
    NXMyVaultListSortTypeCreateTimeAscending,
    NXMyVaultListSortTypeSizeAscending,
    NXMyVaultListSortTypeFileNameDescending,
    NXMyVaultListSortTypeCreateTimeDescending,
    NXMyVaultListSortTypeSizeDescending,
};

typedef NS_ENUM(NSInteger, NXMyvaultListFilterType) {
    NXMyvaultListFilterTypeAllShared = 1,
    NXMyvaultListFilterTypeAllFiles,
    NXMyvaultListFilterTypeProtected,
    NXMyvaultListFilterTypeActivedTransaction,
    NXMyvaultListFilterTypeActivedRevoked,
    NXMyvaultListFilterTypeActivedDeleted
};

@interface NXMyVaultListParModel : NSObject

@property (nonatomic, strong)NSString *page;
@property (nonatomic, strong)NSString *size;
@property (nonatomic, assign)NXMyvaultListFilterType filterType;
@property (nonatomic, strong)NSArray *sortOptions;
@property (nonatomic, strong)NSString *searchString;//optional, search string

@end
