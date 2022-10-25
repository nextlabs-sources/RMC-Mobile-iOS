//
//  NXProjectsListParameterModel.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 12/7/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, NXProjectsListOrderByType) {
    NXProjectsListOrderByTypeNameAscending = 0,
    NXProjectsListOrderByTypeNameDescending,
    NXProjectsListOrderByTypeLastActionTimeAscending,
    NXProjectsListOrderByTypeLastActionTimeDescending
};
typedef NS_ENUM(NSInteger, NXProjectsListOwnerByType) {
    NXProjectsListOwnerByTypeforAll = 0,
    NXProjectsListOrderByTypeForMe,
    NXProjectsListOwnerByTypeForOther
};
@interface NXProjectsListParameterModel : NSObject
@property (nonatomic, strong) NSString *page;
@property (nonatomic, strong) NSString *size;
@property (nonatomic, assign) NXProjectsListOrderByType orderByType;
@property (nonatomic, assign) NXProjectsListOwnerByType ownerByType;
@end
