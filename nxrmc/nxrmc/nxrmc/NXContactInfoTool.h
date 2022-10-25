//
//  NXContactInfoTool.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/4/18.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ContactsUI/ContactsUI.h>

typedef NS_OPTIONS(long,NXContactInfoType) {
    NXContactInfoTypePhoneNumbers       = 0x00000001,
    NXContactInfoTypeEmails             = 0x00000002,
    NXContactInfoTypepostalAddresses    = 0x00000004,
    NXContactInfoTypeOrganizationName   = 0x00000008,
};
typedef NS_ENUM(NSInteger,NXContactAuthStatus) {
    NXContactAuthStatusAlreadyDenied =      1,
    NXContactAuthStatusAlreadyAuthorized,
    NXContactAuthStatusNotDetermined
};
// vaule is NSString type
NSString *const fullNameKey =           @"fullName";//default exist full name
NSString *const organizationNameKey =   @"organizationName";
// vaule is NSDictionary type
NSString *const phoneNumbersKey =       @"phoneNumber";
NSString *const emailsKey =             @"emails";
NSString *const postalAddressesKey = @"postalAddresses";

@interface NXContactInfoTool : NSObject
typedef void(^contactRequestAccessCompletion)(BOOL granted, NSError *error);
typedef void(^getContactsCompletion)(NSArray<NSDictionary *>* contacts,NSError *error);
// First need get the status of authorization
+ (NXContactAuthStatus)checkAuthorizationStatus;
// If status is NXContactAuthStatusNotDetermined,need requst access to user
+ (void)requestAccessEntityWithCompletion:(contactRequestAccessCompletion)completion;
// Call the interface only when the status is NXContactAuthStatusAlreadyAuthorized
+ (void)getContactsWithType:(NXContactInfoType)type withCompletion:(getContactsCompletion)completion;
// The vaule of dictionary is array contains all addresses not detail email type
+ (void)getOnlyEmailContactsWithCompletion:(getContactsCompletion)completion;


@end


