//
//  NXOneDriveFileItem.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 26/12/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXOneDriveFileItem.h"
#import <objc/runtime.h>
@implementation NXOneDriveFileItem
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"id"]) {
        self.fileId = value;
    }
    if ([key isEqualToString:@"folder"]) {
        self.folderYes = YES;
    }
    if ([key isEqualToString:@"@content.downloadUrl"]) {
        self.downloadUrl = value;
    }
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
#pragma mark ----> NSCopying
- (instancetype)copyWithZone:(NSZone *)zone {
    NXOneDriveFileItem *item = [[NXOneDriveFileItem alloc]init];
    item.name = [self.name copyWithZone:zone];
    item.downloadUrl = [self.downloadUrl copyWithZone:zone];
    item.size = self.size;
    item.lastModifiedDateTime = [self.lastModifiedDateTime copyWithZone:zone];
    item.createdDateTime = [self.createdDateTime copyWithZone:zone];
    item.fileId = [self.fileId copyWithZone:zone];
    item.folderYes = self.folderYes;
    return item;
}
@end
