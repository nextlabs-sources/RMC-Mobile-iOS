//
//  NXClassificationCategory.m
//  nxrmc
//
//  Created by Eren on 14/03/2018.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import "NXClassificationCategory.h"
#import <objc/runtime.h>
@implementation NXClassificationCategory

#pragma mark - Get/Set
- (NSMutableArray *)selectedLabs {
    if (_selectedLabs == nil) {
        _selectedLabs = [[NSMutableArray alloc] init];
    }
    return _selectedLabs;
}
- (void)setLabs:(NSArray<NXClassificationLab *> *)labs{
    _labs = [self sortByKey:@"name.length" fromArray:labs];
}
- (NSMutableArray *)sortByKey:(NSString *)key fromArray:(NSArray *)array {
    NSMutableArray * resultArray = [NSMutableArray arrayWithArray:array];
    NSSortDescriptor *sortCreateTime = [[NSSortDescriptor alloc] initWithKey:key ascending:YES];
    [resultArray sortUsingDescriptors:@[sortCreateTime]];
    return resultArray;
}
- (NSMutableArray *)selectedItemPostions {
    if (_selectedItemPostions == nil) {
        _selectedItemPostions = [[NSMutableArray alloc]init];
    }
    return _selectedItemPostions;
}
#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone
{
    NXClassificationCategory *newItem = [[[self class] alloc] init];
    newItem.name = [_name copy];
    newItem.multiSelect = self.multiSelect;
    newItem.mandatory = self.mandatory;
    newItem.labs = [_labs copy];
    newItem.selectedLabs = [_selectedLabs copy];
    newItem.selectedItemPostions = [_selectedItemPostions copy];
    
    return newItem;
}
#pragma mark -----> NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    unsigned int ivarCount = 0;
    Ivar *vars = class_copyIvarList([self class], &ivarCount);
    for (int i =0; i<ivarCount; i++) {
        
        Ivar var = vars[i];
        NSString *varName = [NSString stringWithUTF8String:ivar_getName(var)];
        id value = [self valueForKey:varName];
        [aCoder encodeObject:value forKey:varName];
    }
    free(vars);
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        unsigned int ivarCount = 0;
        Ivar *vars = class_copyIvarList([self class], &ivarCount);
        for (int i = 0; i<ivarCount; i++) {
            Ivar var = vars[i];
            NSString *varName = [NSString stringWithUTF8String:ivar_getName(var)];
            id value = [aDecoder decodeObjectForKey:varName];
            [self setValue:value forKey:varName];
        }
        free(vars);
    }
    return self;
}
@end
