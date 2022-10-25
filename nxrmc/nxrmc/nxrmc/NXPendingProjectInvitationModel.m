//
//  NXProjectInvitation.m
//  nxrmc
//
//  Created by EShi on 2/6/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXPendingProjectInvitationModel.h"
#import "NXProjectModel.h"
#import <objc/runtime.h>
@implementation NXPendingProjectInvitationModel
- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dict];
        self.createdTime = self.inviteTime;
        self.displayName = self.inviteeEmail;
        self.email = self.inviteeEmail;
        self.inviterDisplayName = [self.inviterDisplayName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        self.invitationMsg = [self.invitationMsg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        self.name = self.projectInfo.name;
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"project"] && [value isKindOfClass:[NSDictionary class]]) {
        _projectInfo = [[NXProjectModel alloc] initWithDictionary:(NSDictionary *)value];
        _projectInfo.isOwnedByMe = NO;
        self.projectId = _projectInfo.projectId;
    }
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone
{
    NXPendingProjectInvitationModel *newModel = [[NXPendingProjectInvitationModel alloc] init];
    newModel.invitationId = [self.invitationId copyWithZone:zone];
    newModel.inviteeEmail = [self.inviteeEmail copyWithZone:zone];
    newModel.inviterDisplayName = [self.inviterDisplayName copyWithZone:zone];
    newModel.inviterEmail = [self.inviterEmail copyWithZone:zone];
    newModel.inviteTime = self.inviteTime;
    newModel.code = [self.code copyWithZone:zone];
    newModel.invitationMsg = [self.invitationMsg copyWithZone:zone];
    newModel.projectInfo = [self.projectInfo copyWithZone:zone];
    newModel.displayName = [self.displayName copyWithZone:zone];
    newModel.email = [self.email copyWithZone:zone];
    newModel.name = [self.name copyWithZone:zone];
    return newModel;
}

// for use nxrepomodel as continer key
- (NSUInteger)hash
{
    return [self.invitationId hash] ^ [self.projectId hash];
}

- (BOOL)isEqual:(id)other
{
    if (![other isKindOfClass:[self class]] && ![self.class isKindOfClass:[other class]]) {
        return NO;
    }
    NXPendingProjectInvitationModel *otherFileItem = (NXPendingProjectInvitationModel *)other;
    if (otherFileItem.invitationId.integerValue == self.invitationId.integerValue) {
        if (otherFileItem.projectId.integerValue == self.projectId.integerValue) {
            return YES;
        }
    }
    return NO;
}
#pragma mark -----> NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    unsigned int ivarCount = 0;
    Ivar *vars = class_copyIvarList([self class], &ivarCount);
    for (int i = 0; i<ivarCount; i++) {
        
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
