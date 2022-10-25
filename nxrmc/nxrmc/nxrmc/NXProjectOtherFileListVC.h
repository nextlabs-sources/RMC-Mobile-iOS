//
//  NXProjectOtherFileListVC.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/12/11.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXProjectFileListSearchResultViewController.h"
#import "NXSearchViewController.h"
#import "NXFileSort.h"

typedef NS_ENUM(NSInteger, NXProjectFileListByOperationType){
    NXProjectFileListByOperationTypeAllFiles = 0,
    NXProjectFileListByOperationTypeSharebyFiles,
    NXProjectFileListByOperationTypeShareWithFiles,
    NXProjectFileListByOperationTypeRevokedFiles
};



@class NXProjectModel;
@interface NXProjectOtherFileListVC : UIViewController
@property(nonatomic, assign) NXSortOption sortOption;
@property(nonatomic, strong) NSArray *allSortByTypes;
@property(nonatomic, assign) NXProjectFileListByOperationType operationType;
- (instancetype)initWithProjectModel:(NXProjectModel *)projectModel;
@end


