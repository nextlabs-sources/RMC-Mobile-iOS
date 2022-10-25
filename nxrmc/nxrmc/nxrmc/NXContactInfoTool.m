//
//  NXContactInfoTool.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/4/18.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXContactInfoTool.h"
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
@implementation NXContactInfoTool

+ (NXContactAuthStatus)checkAuthorizationStatus {
    CNAuthorizationStatus staus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    switch (staus) {
        case CNAuthorizationStatusDenied:
            return NXContactAuthStatusAlreadyDenied;
            break;
        case CNAuthorizationStatusAuthorized:
            return NXContactAuthStatusAlreadyAuthorized;
            break;
        case CNAuthorizationStatusNotDetermined:
            return NXContactAuthStatusNotDetermined;
            break;
        default:
            return NXContactAuthStatusAlreadyDenied;
            break;
    }
    
}
+ (void)requestAccessEntityWithCompletion:(contactRequestAccessCompletion)completion {
    CNContactStore *contactStore = [[CNContactStore alloc]init];
    [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (completion) {
            completion(granted,error);
        }
    }];
}

+ (void)getContactsWithType:(NXContactInfoType)type withCompletion:(getContactsCompletion)completion {
    NSMutableArray *keys = [NSMutableArray array];
    NSMutableArray *keysToFetch = [NSMutableArray array];
    // Default have full name
    [keysToFetch addObject:[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName]];
    
    if (type & NXContactInfoTypePhoneNumbers) {
        [keysToFetch addObject:CNContactPhoneNumbersKey];
        [keys addObject:phoneNumbersKey];
    }
    if (type & NXContactInfoTypeEmails) {
        [keysToFetch addObject:CNContactEmailAddressesKey];
        [keys addObject:emailsKey];
    }
    if (type & NXContactInfoTypeOrganizationName) {
        [keysToFetch addObject:CNContactOrganizationNameKey];
        [keys addObject:organizationNameKey];
    }
    if (type & NXContactInfoTypepostalAddresses) {
        [keysToFetch addObject:CNContactPostalAddressesKey];
        [keys addObject:postalAddressesKey];
    }

    NSError *error = nil;
    NSMutableArray *contacts = [NSMutableArray array];
    CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
    CNContactStore *contactStore = [[CNContactStore alloc]init];
    [contactStore enumerateContactsWithFetchRequest:fetchRequest error:&error usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        NSMutableDictionary *contactDict = [NSMutableDictionary dictionary];
        [contactDict setValue:[CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName] forKey:fullNameKey];
        
        if ([contact isKeyAvailable:CNContactOrganizationNameKey]) {
            [contactDict setValue:contact.organizationName forKey:organizationNameKey];
        }
        
        if ([contact isKeyAvailable:CNContactEmailAddressesKey]) {
            NSMutableDictionary *emailDict = [NSMutableDictionary dictionary];
            for (CNLabeledValue *emailValue in contact.emailAddresses) {
                NSString *key = [NXContactInfoTool renameWhenTheoriginalString:[CNLabeledValue localizedStringForLabel:emailValue.label] isExistInAarry:emailDict.allKeys];
                [emailDict setValue:emailValue.value forKey:key];
            }
            [contactDict setValue:emailDict forKey:emailsKey];
        }
       
        if ([contact isKeyAvailable:CNContactPhoneNumbersKey]) {
            NSMutableDictionary *phoneNumberDict = [NSMutableDictionary dictionary];
            for (CNLabeledValue *phoneNumberValue in contact.phoneNumbers) {
                CNPhoneNumber *phoneNumber = phoneNumberValue.value;
                NSString *key = [NXContactInfoTool renameWhenTheoriginalString:[CNLabeledValue localizedStringForLabel:phoneNumberValue.label] isExistInAarry:phoneNumberDict.allKeys];
                [phoneNumberDict setValue:phoneNumber.stringValue forKey:key];
            }
            [contactDict setValue:phoneNumberDict forKey:phoneNumbersKey];
        }
       
        if ([contact isKeyAvailable:CNContactPostalAddressesKey]) {
            NSMutableDictionary *addressDict = [NSMutableDictionary dictionary];
            for (CNLabeledValue *addressValue in contact.postalAddresses) {
                CNPostalAddress *address = addressValue.value;
                NSString *ad = [CNPostalAddressFormatter stringFromPostalAddress:address style:CNPostalAddressFormatterStyleMailingAddress];
                NSString *key = [NXContactInfoTool renameWhenTheoriginalString:[CNLabeledValue localizedStringForLabel:addressValue.label] isExistInAarry:addressDict.allKeys];
                [addressDict setValue:ad forKey:key];
            }
            [contactDict setObject:addressDict forKey:postalAddressesKey];
        }
        int emptyCount = 0;
        for (NSString *key in keys) {
            id vaule = [contactDict valueForKey:key];
            if ([vaule isKindOfClass:[NSString class]]) {
                NSString *str = (NSString *)vaule;
                if (!str | [str isEqualToString:@""]) {
                    emptyCount++;
                }
            }else if ([vaule isKindOfClass:[NSMutableDictionary class]]){
               
                if ([(NSMutableDictionary *)vaule allValues].count == 0) {
                    emptyCount++;
                }
            }
        }
        // Remove contacts whose vaules are empty for the all selected keys
        if (keys.count > emptyCount) {
             [contacts addObject:contactDict];
        }
    }];
    if (completion) {
        completion(contacts, error);
    }
}

+(NSString *)renameWhenTheoriginalString:(NSString *)originalStr isExistInAarry:(NSArray *)keys {
    NSString *finalKey = originalStr;
    int repetNum = 0;
    for (NSString *key in keys) {
        if ([key containsString:originalStr]) {
            repetNum++;
        }
    }
    if (repetNum > 0) {
        finalKey = [NSString stringWithFormat:@"%@(%d)",originalStr,repetNum];
    }
    return finalKey;
}
+ (void)getOnlyEmailContactsWithCompletion:(getContactsCompletion)completion {
    NSError *error = nil;
    NSMutableArray *contacts = [NSMutableArray array];
    NSArray *keysToFetch = @[CNContactEmailAddressesKey,[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName]];
    CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
    CNContactStore *contactStore = [[CNContactStore alloc]init];
    [contactStore enumerateContactsWithFetchRequest:fetchRequest error:&error usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        if (contact.emailAddresses.count) {
            NSMutableDictionary *contactDict = [NSMutableDictionary dictionary];
            NSMutableArray *emails = [NSMutableArray array];
            for (CNLabeledValue *labelValue in contact.emailAddresses) {
                [emails addObject:labelValue.value];
            }
            [contactDict setValue:emails forKey:emailsKey];
            NSString *fullName = [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName];
            if (!fullName) {
                fullName = emails.firstObject;
            }
            if ([fullName isEqualToString:@""]) {
                fullName = emails.firstObject;
            }
            [contactDict setValue:fullName forKey:fullNameKey];
            [contacts addObject:contactDict];
        }
    }];
    if (completion) {
        completion(contacts,error);
    }
}
@end
