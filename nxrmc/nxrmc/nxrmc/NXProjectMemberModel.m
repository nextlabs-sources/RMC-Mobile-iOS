//
//  NXProjectMemberModel.m
//  nxrmc
//
//  Created by EShi on 1/20/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectMemberModel.h"
#import <objc/runtime.h>
@implementation NXProjectMemberModel
-(instancetype)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self){
        [self setValuesForKeysWithDictionary:dictionary];
        self.displayName = [self.displayName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        self.email = [self.email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        self.inviterDisplayName = [self.inviterDisplayName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"creationTime"]) {
        self.joinTime = ((NSNumber *)value).doubleValue/1000;
    }
    
    if ([key isEqualToString:@"picture"]) {
        
        NSArray *array = [value componentsSeparatedByString:@","];
        self.avatarBase64 = [array lastObject];
    }
}


// for use nxrepomodel as continer key
- (NSUInteger)hash
{
    return [self.userId hash] ^ [self.email hash] ^[self.projectId hash];
}

- (BOOL)isEqual:(id)other
{
    if (![other isKindOfClass:[self class]] && ![self.class isKindOfClass:[other class]]) {
        return NO;
    }
    NXProjectMemberModel *otherItem = (NXProjectMemberModel *)other;
    if (otherItem.userId.integerValue == self.userId.integerValue ) {
        if (otherItem.projectId.integerValue == self.projectId.integerValue) {
            if ([otherItem.displayName isEqualToString:self.displayName]) {
                if (otherItem.avatarBase64 && self.avatarBase64 && [otherItem.avatarBase64 isEqualToString:self.avatarBase64]) {
                    return YES;
                }else if(self.avatarBase64 == nil && otherItem.avatarBase64 == nil){
                    return YES;
                }
            }
        }
    }
    return NO;
}
#pragma mark ----> NSCoding
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
