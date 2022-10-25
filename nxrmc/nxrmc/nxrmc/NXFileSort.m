//
//  NXFileSort.m
//  nxrmc
//
//  Created by nextlabs on 1/6/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXFileSort.h"

#import "NXFileBase.h"
#import "NXFileBase+SortSEL.h"
#import "NXCommonUtils.h"

@implementation NXFileSort

NSComparisonResult myCompareFunction(id<NXSortItemProtocol> obj1, id<NXSortItemProtocol> obj2, void *context) {
    NXSortOption option = *(NXSortOption *)context;
   
    id value1 = [obj1 valueForSortOption:option];
    id value2 = [obj2 valueForSortOption:option];

    switch (option) {
        case NXSortOptionDateAscending:
        {
            if(value2 == nil  && value1 == nil){
                return NSOrderedSame;
            }
            
            if (value1 ==nil && value2 != nil) {
                return NSOrderedDescending;
            }
            
            if (value1 != nil && value2 == nil) {
                return NSOrderedAscending;
            }
            
            return [value1 compare:value2];
        }
            break;
        case NXSortOptionDateDescending:
        {
            if(value1 == nil  && value2 == nil){
                return NSOrderedSame;
            }
            
            if (value2 ==nil && value1 != nil) {
                return NSOrderedDescending;
            }
            
            if (value2 != nil && value1 == nil) {
                return NSOrderedAscending;
            }
            
            return [value2 compare:value1];
        }
            break;
        case NXSortOptionNameAscending:
        case NXSortOptionDriveAscending:
        case NXSortOptionSharedByAscending:
        {
            return myCompareStringFunction(value1, value2, NULL);
        }
            break;
        case NXSortOptionNameDescending:
        case NXSortOptionDriveDescending:
        case NXSortOptionSharedByDescending:
        {
            return myCompareStringFunction(value2, value1, NULL);
        }
            break;
        default:
            break;
    }
    return NSOrderedSame;
}

NSComparisonResult myCompareStringFunction(NSString  *obj1, NSString *obj2, void *context) {
    if (obj1 == nil && obj2 == nil) {
        return NSOrderedSame;
    }
    
    if (obj1 != nil && obj2 == nil) {
        return NSOrderedAscending;
    }
    
    if (obj1 == nil && obj2 != nil) {
        return NSOrderedDescending;
    }
    return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
}

#pragma mark
+ (NSMutableArray<NSDictionary *> *)keySortObjects:(NSMutableArray*)dataArray option:(NXSortOption)option {
    return [self sortOb:dataArray option:option];
}

+ (NSMutableArray *)sortObjects:(NSMutableArray *)dataArray option:(NXSortOption)option {
    [dataArray sortUsingFunction:myCompareFunction context:&option];
    return dataArray;
}

+ (NSMutableArray<NSDictionary *> *)sortOb:(NSMutableArray<id<NXSortItemProtocol>> *)dataArray option:(NXSortOption)option{
    if (option == NXSortOptionSizeAscending || option == NXSortOptionSizeDescending) {
        if (dataArray) {
//            CFAbsoluteTime start2 = CFAbsoluteTimeGetCurrent();
            [dataArray sortUsingSelector:@selector(sortContentBySizeSmallest:)];
//            CFAbsoluteTime end2 = CFAbsoluteTimeGetCurrent();
            
            //NSLog(@"time cost :%0.4f",end2 - start2);
            return @[@{@"Size Ascending":dataArray}.copy].mutableCopy;
        }else {
            return nil;
        }
        
    }
    
//    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    
    NSArray *df = [dataArray sortedArrayUsingFunction:myCompareFunction context:&option];
    
    NSMutableArray *groupedKeys = [NSMutableArray array];
    NSMutableDictionary *groupedFileListDic = [NSMutableDictionary dictionary];
    
    NSString *preKey = nil;
    for (id<NXSortItemProtocol> file in df) {
        NSString *key = [file keyForSortOption:option];
        NSMutableArray *fileArray = groupedFileListDic[key];
        if (!fileArray) {
            fileArray = [[NSMutableArray alloc] initWithObjects:file, nil];
            [groupedFileListDic setObject:fileArray forKey:key];
        }else {
            [fileArray addObject:file];
        }
        
        if (preKey == nil) {
            [groupedKeys addObject:key];
            preKey = key;
        }else{
            if ([key compare:preKey ] != NSOrderedSame) {
                [groupedKeys addObject:key];
                preKey = key;
            }
        }
    }

    NSMutableArray *sortedArray = [NSMutableArray array];
    [groupedKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [sortedArray addObject:@{obj: [groupedFileListDic objectForKey:obj]}];
    }];
    
//    CFAbsoluteTime end1 = CFAbsoluteTimeGetCurrent();
    
  //  NSLog(@"++++++++++++++++++++++time cost :%0.4f ms",(end1 - start)*1000);
    
    return sortedArray;
}

@end
