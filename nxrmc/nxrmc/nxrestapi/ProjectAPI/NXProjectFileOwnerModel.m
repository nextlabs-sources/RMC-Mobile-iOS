//
//  NXProjectFileOwnerModel.m
//  nxrmc
//
//  Created by helpdesk on 23/1/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXProjectFileOwnerModel.h"
#import <objc/runtime.h>
@implementation NXProjectFileOwnerModel

#pragma mark - NSCoping
- (id)copyWithZone:(NSZone *)zone
{
    NXProjectFileOwnerModel *model = [[NXProjectFileOwnerModel alloc]init];
    model.displayName = [self.displayName copy];
    model.userId = [self.userId copy];
    model.email = [self.email copy];
    return model;
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

-(void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}
@end
