//
//  NXProjectModel.m
//  nxrmc
//
//  Created by EShi on 1/20/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectModel.h"
#import "NSString+NXExt.h"
#import "NXLFileValidateDateModel.h"
#import <objc/runtime.h>
@implementation NXProjectOwnerItem
-(void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
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
#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone
{
    NXProjectOwnerItem *newItem = [[NXProjectOwnerItem alloc] init];
    newItem.name = [self.name copy];
    newItem.email = [self.email copy];
    newItem.userId = [self.userId copy];
    return newItem;
}

@end
@implementation NXProjectModel
- (instancetype) initWithDictionary:(NSDictionary *)dic {
    self=[super init];
    if (self) {
        _homeShowMembers = [NSMutableArray array];
        [self setValuesForKeysWithDictionary:dic];
        self.name = [self.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.displayName = [self.displayName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.projectOwner.name =  [self.projectOwner.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.invitationMsg = [self.invitationMsg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.lastActionTime = self.createdTime;
        if (self.homeShowMembers) {
            self.homeShowMembers = [self commonInitHomeShowMembers:self.homeShowMembers];
        }
    }
    return self;
}

-(instancetype)initWithProject:(NXProject *)project
{
    self = [super init];
    if (self) {
        _projectId = [project.projectId copy];
        _name = [project.projectName copy];
        _parentTenantName = [project.parentTenantName copy];
        _projectDescription = [project.projectDescription copy];
        _createdTime = project.creationTime;
        _lastActionTime = project.lastActionTime;
        _displayName = [project.displayName copy];
        _isOwnedByMe = project.isCreatedByMe;
        _totalMembers = project.totalMembers;
        _totalFiles= project.totalFiles;
        _projectOwner = [project.owner copy];
//        _pendingMembers = [project.pendingMembers mutableCopy];
        _homeShowMembers = [project.homeShowMembers mutableCopy];
        _parentTenantId = [project.parentTenantId copy];
        _membershipId = [project.membershipId copy];
        _tokenGroupName = [project.tokenGroupName copy];
        _watermark = [project.watermark copy];
        _configurationModified = project.configurationModified;
        _validateModel = project.validateModel;
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"id"]) {
        self.projectId = value;
    }
    if ([key isEqualToString:@"owner"]) {
        NSDictionary *itemDic = (NSDictionary*)value;
        NXProjectOwnerItem *ownerItem = [[NXProjectOwnerItem alloc]init];
        [ownerItem setValuesForKeysWithDictionary:itemDic];
        self.projectOwner = ownerItem;
      }
    if ([key isEqualToString:@"description"]) {
        self.projectDescription = value;
        self.projectDescription = [self.projectDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    if ([key isEqualToString:@"ownedByMe"]) {
        self.isOwnedByMe = [value boolValue];
    }
    
    if ([key isEqualToString:@"creationTime"]) {
        self.createdTime = [value longLongValue];
    }
    
    if ([key isEqualToString:@"parentTenantName"]) {
        self.parentTenantName = [value stringValue];
    }
    
    if ([key isEqualToString:@"projectMembers"]) {
        NSDictionary *projectMembersDict = (NSDictionary *)value;
        self.totalMembers = ((NSNumber *)projectMembersDict[@"totalMembers"]).longValue;
        NSArray *membersArray = projectMembersDict[@"members"];
        for (NSDictionary *memberInfoDict in membersArray) {
            NXProjectMemberModel *projectMember = [[NXProjectMemberModel alloc] initWithDictionary:memberInfoDict];
            projectMember.projectId = self.projectId;
            [self.homeShowMembers addObject:projectMember];
        }
        
    }

    if ([key isEqualToString:@"expiry"]) {
        NSString *expiry = value;
        NSDictionary *expiryDic = [expiry toJSONFormatDictionary:nil];
        self.validateModel = [[NXLFileValidateDateModel alloc] initWithDictionaryFromRMS:expiryDic];
    }
}
- (NSMutableArray *)commonInitHomeShowMembers:(NSMutableArray*)homeShowMembers {
    NSMutableArray *newArray = homeShowMembers;
    BOOL isExistOwner = NO;
    for (NXProjectMemberModel *memberModel in homeShowMembers) {
        if ([memberModel.userId isEqualToNumber:self.projectOwner.userId]) {
            memberModel.isProjectOwner = YES;
            isExistOwner = YES;
            break;
        }
    }
    if (isExistOwner) {
        newArray = homeShowMembers;
    }else {
        NXProjectMemberModel *ownerMember = [[NXProjectMemberModel alloc]init];
        ownerMember.projectId = self.projectId;
        ownerMember.userId = self.projectOwner.userId;
        ownerMember.email = self.projectOwner.email;
        ownerMember.displayName = self.projectOwner.name;
        ownerMember.joinTime = self.createdTime/1000;
        ownerMember.isProjectOwner = YES;
        if (newArray.count) {
             [newArray replaceObjectAtIndex:0 withObject:ownerMember];
        }else {
            [newArray insertObject:ownerMember atIndex:0];
        }
    }
    return newArray;
}
#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone
{
    NXProjectModel *newModel = [[NXProjectModel alloc] init];
    newModel.projectId = [self.projectId copyWithZone:zone];
    newModel.name = [self.name copyWithZone:zone];
    newModel.parentTenantName = [self.parentTenantName copyWithZone:zone];
    newModel.projectDescription = [self.projectDescription copyWithZone:zone];
    newModel.createdTime = self.createdTime;
    newModel.lastActionTime = self.lastActionTime;
    newModel.invitationMsg = [self.invitationMsg copyWithZone:zone];
    newModel.displayName = [self.displayName copyWithZone:zone];
    newModel.isOwnedByMe = self.isOwnedByMe;
    newModel.totalMembers = self.totalMembers;
    newModel.totalFiles = self.totalFiles;
    newModel.projectOwner = [self.projectOwner copyWithZone:zone];
//    newModel.pendingMembers = [self.pendingMembers mutableCopyWithZone:zone];
    newModel.homeShowMembers = [self.homeShowMembers mutableCopyWithZone:zone];
    newModel.parentTenantId = [self.parentTenantId copyWithZone:zone];
    newModel.membershipId = [self.membershipId copyWithZone:zone];
    newModel.tokenGroupName = [self.tokenGroupName copyWithZone:zone];
    newModel.watermark = [self.watermark copyWithZone:zone];
    newModel.validateModel = [self.validateModel copyWithZone:zone];
    newModel.configurationModified = self.configurationModified;
    
    return newModel;
}

- (NSUInteger)hash
{
    return [self.projectId hash];
}
- (BOOL)isEqual:(id)other
{
    if (![other isKindOfClass:[self class]] && ![self.class isKindOfClass:[other class]]) {
        return NO;
    }
    NXProjectModel *otherFileItem = (NXProjectModel *)other;
    if ([otherFileItem.projectId isEqual:self.projectId] && [otherFileItem.name isEqual:self.name] && [otherFileItem.projectDescription isEqual:self.projectDescription]) {
        if (!otherFileItem.invitationMsg && !self.invitationMsg) {
            return YES;
        } else if (otherFileItem.invitationMsg && self.invitationMsg){
            if ([otherFileItem.invitationMsg isEqual:self.invitationMsg]) {
                return YES;
            }
        }
    }
    return NO;
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
