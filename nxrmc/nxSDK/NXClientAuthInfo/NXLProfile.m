//
//  Profile.m
//  nxrmc
//
//  Created by Kevin on 15/4/29.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import "NXLProfile.h"

#define kProfileRmserver    @"ProfileCodingRmserver"

#define kProfileUsername            @"ProfileCodingUsername"
#define kProfileUserId              @"ProfileCodingUserId"
#define kProfileTicket              @"ProfileCodingTicket"
#define kProfileTTL                 @"ProfileCodingTtl"
#define kProfileEmail               @"ProfileCodingEmail"
#define kProfileDefaultMembership   @"ProfileCodingDefaultMembership"
#define KProfileMemberships         @"ProfileCodingMemberships"

#define kMembershipsId          @"MembershipsCodingId"
#define kMembershipsType        @"MembershipsCodingType"
#define kMembershipsTenantId    @"MembershipsCodingTenantId"


#pragma mark
@implementation NXLMembership

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.ID = [aDecoder decodeObjectForKey:kMembershipsId];
        self.type = [aDecoder decodeObjectForKey:kMembershipsType];
        self.tenantId = [aDecoder decodeObjectForKey:kMembershipsTenantId];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_ID forKey:kMembershipsId];
    [aCoder encodeObject:_type forKey:kMembershipsType];
    [aCoder encodeObject:_tenantId forKey:kMembershipsTenantId];
}

- (BOOL)equalMemberships:(NXLMembership *)membership {
    if ([self.ID caseInsensitiveCompare:membership.ID] == NSOrderedSame ){
        return YES;
    } else {
        return NO;
    }
}

@end

#pragma mark
@implementation NXLProfile

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.rmserver = [aDecoder decodeObjectForKey:kProfileRmserver];
        self.userName = [aDecoder decodeObjectForKey:kProfileUsername];
        self.userId = [aDecoder decodeObjectForKey:kProfileUserId];
        self.ticket = [aDecoder decodeObjectForKey:kProfileTicket];
        self.ttl = [aDecoder decodeObjectForKey:kProfileTTL];
        self.email = [aDecoder decodeObjectForKey:kProfileEmail];
        self.defaultMembership = [aDecoder decodeObjectForKey:kProfileDefaultMembership];
        self.memberships = [aDecoder decodeObjectForKey:KProfileMemberships];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_rmserver forKey:kProfileRmserver];
    [aCoder encodeObject:_userName forKey:kProfileUsername];
    [aCoder encodeObject:_userId forKey:kProfileUserId];
    [aCoder encodeObject:_ticket forKey:kProfileTicket];
    [aCoder encodeObject:_ttl forKey:kProfileTTL];
    [aCoder encodeObject:_email forKey:kProfileEmail];
    [aCoder encodeObject:_defaultMembership forKey:kProfileDefaultMembership];
    [aCoder encodeObject:_memberships forKey:KProfileMemberships];
}

- (BOOL)equalProfile:(NXLProfile *)profile {
    if ([self.userId caseInsensitiveCompare:profile.userId] == NSOrderedSame &&
        [self.defaultMembership.tenantId caseInsensitiveCompare:profile.defaultMembership.tenantId] == NSOrderedSame) {
        return YES;
    } else {
        return NO;
    }
}

@end
