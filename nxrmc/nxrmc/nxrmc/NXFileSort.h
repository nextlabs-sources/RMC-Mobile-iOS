//
//  NXFileSort.h
//  nxrmc
//
//  Created by nextlabs on 1/6/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, NXSortOption) {
    NXSortOptionNameAscending = 1,
    NXSortOptionNameDescending,

    NXSortOptionDateAscending,
    NXSortOptionDateDescending,
    
    NXSortOptionDriveAscending,
    NXSortOptionDriveDescending,
    
    NXSortOptionSizeAscending,
    NXSortOptionSizeDescending,
    
    NXSortOptionSharedByAscending,
    NXSortOptionSharedByDescending,
    
    NXSortOptionOperationAscending,
    
    NXSortOptionOperationResultAscending,
    
    NXSortOptionModifiedDate
};

@protocol NXSortItemProtocol <NSObject>

@required
- (id)valueForSortOption:(NXSortOption)option;
- (NSString *)keyForSortOption:(NXSortOption)option;

@end

@interface NXFileSort : NSObject

+ (NSMutableArray<NSDictionary *> *)keySortObjects:(NSMutableArray *)dataArray option:(NXSortOption)option;
+ (NSMutableArray *)sortObjects:(NSMutableArray *)dataArray option:(NXSortOption)option;

@end
