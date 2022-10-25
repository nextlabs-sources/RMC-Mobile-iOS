//
//  NXSharedWithMeFileListParameterModel.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 26/7/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NXSharedWithMeFileListOrderByType) {
    NXSharedWithMeFileListOrderByNameAscending = 0,
    NXSharedWithMeFileListOrderByNameDescending,
    NXSharedWithMeFileListOrderBySharedDateAscending,
    NXSharedWithMeFileListOrderBySharedDateDescending,
    NXSharedWithMeFileListOrderBySizeAscending,
    NXSharedWithMeFileListOrderBySizeDescending,
    NXSharedWithMeFileListOrderBySharedByAscending,
    NXSharedWithMeFileListOrderBySharedByDescending
};

typedef NS_ENUM(NSInteger, NXSharedWithMeFileListSearchFileByType) {
    NXSharedWithMeFileListSearchFileByName = 0,
};

@interface NXSharedWithMeFileListParameterModel : NSObject
@property (nonatomic ,assign) NSUInteger page;
@property (nonatomic ,assign) NSUInteger size;
@property (nonatomic ,strong) NSString *searchString;
@property (nonatomic ,assign) NXSharedWithMeFileListOrderByType orderByType;
@property (nonatomic ,assign) NXSharedWithMeFileListSearchFileByType searchByType;
@property (nonatomic ,strong) NSString *fromSpace;
@property (nonatomic ,strong) NSString *spaceId;

@end
