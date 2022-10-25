//
//  NXProjectFileListModel.h
//  nxrmc
//
//  Created by helpdesk on 23/1/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, NXProjectFileListOrderByType) {
    NXProjectListSortTypeFileNameAscending = 0,
    NXProjectListSortTypeCreateTimeAscending,
    NXProjectListSortTypeFileNameDescending,
    NXProjectListSortTypeCreateTimeDescending
};
typedef NS_ENUM(NSInteger, NXProjectFileListFilterByType) {
    NXProjectFileListFilterByTypeAllFiles = 0,
    NXProjectFileListFilterByTypeAllShared,
    NXProjectFileListFilterByTypeRevoked
};
@interface NXProjectFileListParameterModel : NSObject
@property (nonatomic, strong) NSString *page;
@property (nonatomic, strong) NSString *size;
@property (nonatomic, strong) NSString *parentPath;
@property (nonatomic, assign) NXProjectFileListOrderByType orderByType;
@property (nonatomic, strong) NSNumber *projectId;
@property (nonatomic, assign) NXProjectFileListFilterByType filterType;
@end

