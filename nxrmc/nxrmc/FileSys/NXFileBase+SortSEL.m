//
//  NXFileBase+SortSEL.m
//  nxrmc
//
//  Created by EShi on 6/18/15.
//  Copyright (c) 2015 nextlabs. All rights reserved.
//

#import "NXFileBase+SortSEL.h"
#import "NXSharePointFile.h"
#import "NXSharePointFolder.h"

#import "NXCommonUtils.h"
#import "NXSharedWithMeFile.h"

@implementation NXFileBase (SortSEL)
#pragma mark Sort curContentDataArray method

-(NSComparisonResult) sortContentByDateOldest:(NXFileBase*) item
{
    if ([item isKindOfClass:[NXFile class]]) {
        if ([self isKindOfClass:[NXFolder class]]) {
            return NSOrderedAscending;
        }
        
        if ([self isKindOfClass:[NXFile class]]) {
            NSDateFormatter* dateFormtter = [[NSDateFormatter alloc] init];
            [dateFormtter setDateStyle:NSDateFormatterShortStyle];
            [dateFormtter setTimeStyle:NSDateFormatterFullStyle];
            
            NSDate* selfModifyDate = [dateFormtter dateFromString:((NXFile*)self).lastModifiedTime];
            NSDate* itemModifyDate = [dateFormtter dateFromString:((NXFile*)item).lastModifiedTime];
            return [selfModifyDate compare:itemModifyDate];
        }
    }else  // item is a folder
    {
        if ([self isKindOfClass:[NXFile class]]) {
            return NSOrderedDescending;
        }
        
        if ([self isKindOfClass:[NXFolder class]]) {
            NSDateFormatter* dateFormtter = [[NSDateFormatter alloc] init];
            [dateFormtter setDateStyle:NSDateFormatterShortStyle];
            [dateFormtter setTimeStyle:NSDateFormatterFullStyle];
            
            NSDate* selfModifyDate = [dateFormtter dateFromString:((NXFolder*)self).lastModifiedTime];
            NSDate* itemModifyDate = [dateFormtter dateFromString:((NXFolder*)item).lastModifiedTime];
            return [selfModifyDate compare:itemModifyDate];
            
        }
    }
    return NSOrderedSame;
}

#pragma mark - NXSortItemProtocol
- (id)valueForSortOption:(NXSortOption)option {
    
//    NSRegularExpression *regex = [NXCommonUtils getSortRegularExpression];
    
    switch (option) {
        case NXSortOptionDateDescending:
        case NXSortOptionDateAscending:
        {
            return self.lastModifiedDate;
        }
            break;
        case NXSortOptionNameDescending:
        case NXSortOptionNameAscending:
        {
//            if ([regex numberOfMatchesInString:self.name options:NSMatchingReportProgress range:NSMakeRange(0, 1)] > 0) {
//                 return @"#";
//            } else {
//                return self.name;
//            }
            if ([NXCommonUtils IsEnglishLetterInitalCapitalAndLowercaseLetter:self.name]) {
                return self.name;
            }else {
                return @"#";
            }
        }
            break;
        case NXSortOptionDriveDescending:
        case NXSortOptionDriveAscending:
        {
//            if ([regex numberOfMatchesInString:self.serviceAlias options:NSMatchingReportProgress range:NSMakeRange(0, 1)] > 0) {
//                return @"#";
//            } else {
//                return self.serviceAlias;
//            }
            if ([NXCommonUtils IsEnglishLetterInitalCapitalAndLowercaseLetter:self.serviceAlias]) {
                return self.serviceAlias;
            }else {
                return @"#";
            }
        }
            break;
        
        case NXSortOptionSizeDescending:
        case NXSortOptionSizeAscending:
        {
            return [NSNumber numberWithLongLong:self.size];
        }
            break;
        case NXSortOptionSharedByDescending:
        case NXSortOptionSharedByAscending:
        {
            NXSharedWithMeFile *file = (NXSharedWithMeFile *)self;
            if ([NXCommonUtils IsEnglishLetterInitalCapitalAndLowercaseLetter:file.sharedBy]) {
                return file.sharedBy;
            }else {
                return @"#";
            }
        }
            break;
        default:
            break;
    }
    return @"";
}

- (NSString *)keyForSortOption:(NXSortOption)option {
    switch (option) {
        case NXSortOptionDateAscending:
        case NXSortOptionDateDescending:
        {
            if (self.lastModifiedDate) {
                NSDateFormatter* dateFormtter = [[NSDateFormatter alloc] init];
                [dateFormtter setDateFormat:@"MMMM yyyy"];
                return [dateFormtter stringFromDate:self.lastModifiedDate];
            }
        }
            break;
        case NXSortOptionNameAscending:
        case NXSortOptionNameDescending:
        {
            if (self.name) {
                NSString *firstString = [[self.name substringToIndex:1] capitalizedString];
                unichar firstChar = [firstString characterAtIndex:0];
                if (firstChar >= 'A' && firstChar <='Z'){
                    return [NSString stringWithCharacters:&firstChar length:1];
                } else {
                    return @"#";
                }
            }
        }
            break;
        case NXSortOptionDriveAscending:
        case NXSortOptionDriveDescending:
        {
            if (self.serviceAlias) {
                return self.serviceAlias;
            }
        }
            break;
        case NXSortOptionSizeAscending:
        case NXSortOptionSizeDescending:
        {
            if (self.size) {
                return @"Size";
            }
        }
            break;
        case NXSortOptionSharedByAscending:
        case NXSortOptionSharedByDescending:
        {
            NXSharedWithMeFile *file = (NXSharedWithMeFile *)self;
            if (file.sharedBy) {
                NSString *firstString = [[file.sharedBy substringToIndex:1] capitalizedString];
                unichar firstChar = [firstString characterAtIndex:0];
                if (firstChar >= 'A' && firstChar <='Z'){
                    return [NSString stringWithCharacters:&firstChar length:1];
                } else {
                    return @"#";
                }
            }
        }
            break;
        default:
            break;
    }
    return @"#";
}

-(NSComparisonResult) sortContentByDateNewest:(NXFileBase*) item
{
    NSComparisonResult result = [((NXFileBase*)self).lastModifiedDate compare:((NXFileBase*)item).lastModifiedDate];
    if (result == NSOrderedAscending) {
        return NSOrderedDescending;
    }
    
    if (result == NSOrderedDescending) {
        return NSOrderedAscending;
    }
    return NSOrderedSame;
}

-(NSComparisonResult) sortContentBySizeLargest:(NXFileBase*) item
{
    if ([item isKindOfClass:[NXFile class]]) {
        if ([self isKindOfClass:[NXFolder class]]) {
            return NSOrderedAscending;
        }
        
        if ([self isKindOfClass:[NXFile class]]) {
            if (item.size < ((NXFile*)self).size) {
                return NSOrderedAscending;
            }else if(item.size > ((NXFile*)self).size)
            {
                return NSOrderedDescending;
            }else
            {
                return NSOrderedSame;
            }
        }
        
    }else  // item is a folder
    {
        if ([self isKindOfClass:[NXFile class]]) {
            return NSOrderedDescending;
        }
        
        if ([self isKindOfClass:[NXFolder class]]) {
            if (item.size < ((NXFolder*)self).size) {
                return NSOrderedAscending;
            }else if(item.size > ((NXFolder*)self).size)
            {
                return NSOrderedDescending;
            }else
            {
                return NSOrderedSame;
            }
            
        }
    }
    return NSOrderedSame;
}

-(NSComparisonResult) sortContentBySizeSmallest:(NXFileBase*) item
{
    if ([item isKindOfClass:[NXFile class]]) {
        if ([self isKindOfClass:[NXFolder class]]) {
            return NSOrderedAscending;
        }
        
        if ([self isKindOfClass:[NXFile class]]) {
            if (item.size > ((NXFile*)self).size) {
                return NSOrderedAscending;
            }else if(item.size < ((NXFile*)self).size)
            {
                return NSOrderedDescending;
            }else
            {
                return NSOrderedSame;
            }
        }
        
    }else  // item is a folder
    {
        if ([self isKindOfClass:[NXFile class]]) {
            return NSOrderedDescending;
        }
        
        if ([self isKindOfClass:[NXFolder class]]) {
            if (item.size > ((NXFolder*)self).size) {
                return NSOrderedAscending;
            }else if(item.size < ((NXFolder*)self).size)
            {
                return NSOrderedDescending;
            }else
            {
                return NSOrderedSame;
            }
            
        }
    }
    return NSOrderedSame;
}

-(NSComparisonResult) sortContentByNameAsc:(NXFileBase*) item
{
return [((NXFileBase*)self).name compare:item.name options:NSCaseInsensitiveSearch];
}

-(NSComparisonResult) sortContentByRepoAlians:(NXFileBase *) item
{
    
    if ([((NXFileBase*)self).serviceAlias compare:item.serviceAlias options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return [((NXFileBase*)self).name compare:item.name options:NSCaseInsensitiveSearch];
    }else
    {
        return [((NXFileBase*)self).serviceAlias compare:item.serviceAlias options:NSCaseInsensitiveSearch];
        
    }
}

-(NSComparisonResult) sortContentByNameDesc:(NXFileBase*) item
{
    NSComparisonResult result = [((NXFolder*)self).name compare:item.name options:NSCaseInsensitiveSearch];
    if (result == NSOrderedAscending) {
        return NSOrderedDescending;
    }
    
    if (result == NSOrderedDescending) {
        return NSOrderedAscending;
    }
    
    return result;
    

    //BOOL isSharePointFile = [self isKindOfSharePointFile:item];
//    if (isSharePointFile) {
//        NSComparisonResult compResult = [self compareItemType:item];
//        if (compResult == NSOrderedSame) {
//            compResult = [self.name compare:item.name];
//            if (compResult == NSOrderedAscending) {
//                compResult = NSOrderedDescending;
//            }else if(compResult == NSOrderedDescending)
//            {
//                compResult = NSOrderedAscending;
//            }
//        }
//        
//        return compResult;
//        
//    }else
//    {
//        if ([item isKindOfClass:[NXFile class]]) {
//            if ([self isKindOfClass:[NXFolder class]]) {
//                return NSOrderedAscending;
//            }
//            
//            if ([self isKindOfClass:[NXFile class]]) {
//                NSComparisonResult result = [((NXFile*)self).name compare:item.name];
//                if (result == NSOrderedAscending) {
//                    return NSOrderedDescending;
//                }
//                
//                if (result == NSOrderedDescending) {
//                    return NSOrderedAscending;
//                }
//            }
//            
//        }else  // item is a folder
//        {
//            if ([self isKindOfClass:[NXFile class]]) {
//                return NSOrderedDescending;
//            }
//            
//            if ([self isKindOfClass:[NXFolder class]]) {
//                NSComparisonResult result = [((NXFolder*)self).name compare:item.name];
//                if (result == NSOrderedAscending) {
//                    return NSOrderedDescending;
//                }
//                
//                if (result == NSOrderedDescending) {
//                    return NSOrderedAscending;
//                }
//                
//            }
//        }
//
//    }
//        return NSOrderedSame;
}

-(NSComparisonResult) compareItemType:(NXFileBase*) item;
{
    
    if ([item isKindOfClass:[NXSharePointFolder class]]) {
        if ([self isKindOfClass:[NXSharePointFolder class]]) {
            NXSharePointFolder* spSelf = (NXSharePointFolder*) self;
            NXSharePointFolder* spItem = (NXSharePointFolder*) item;
            
            if (spSelf.folderType > spItem.folderType) {
                return NSOrderedAscending;
            }else if(spSelf.folderType < spItem.folderType)
            {
                return NSOrderedDescending;
            }else
            {
                return NSOrderedSame;
            }
        }else  // item is folder, self is file, just return descending
            return NSOrderedDescending;
    }
    
    if ([item isKindOfClass:[NXSharePointFile class]]) {
        if ([self isKindOfClass:[NXSharePointFolder class]]) {
            return NSOrderedAscending;
        }
    }
    
    return NSOrderedSame;
}

-(BOOL) isKindOfSharePointFile:(NXFileBase *) item
{
    if ([item isKindOfClass:[NXSharePointFile class]] || [item isKindOfClass:[NXSharePointFolder class]]) {
        return YES;
    }
    return NO;
}
@end
