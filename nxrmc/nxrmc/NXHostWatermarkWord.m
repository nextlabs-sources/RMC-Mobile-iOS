//
//  NXHostWatermarkWord.m
//  nxrmc
//
//  Created by Sznag on 2022/3/24.
//  Copyright © 2022 nextlabs. All rights reserved.
//

#import "NXHostWatermarkWord.h"
#import "NXCommonUtils.h"
@implementation NXHostWatermarkWord
- (instancetype)initWithWatermarkPolicyString:(NSString *)policyString watermarkLocalizedString:(NSString *)localizedString {
    if (self = [super init]) {
       
    }
    return self;
}

- (NSString *)watermarkPolicyString {
    return @"$(Host)";
}

- (NSString *)watermarkLocalizedString {
    NSString *host;
    NSString *serverUrl =  [NXCommonUtils isCompanyAccountLogin] ? [NXCommonUtils getUserCurrentSelectedLoginURL] : [NXCommonUtils getDefaultPresonalLoginURL];
    if ([serverUrl containsString:@"https://"]) {
        host = [serverUrl stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    }else if ([serverUrl containsString:@"http://"]){
        host = [serverUrl stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    }else{
        host = serverUrl;
    }
    return host;
//    char baseHostName[256]; // Thanks, Gunnar Larisch
//    int success = gethostname(baseHostName, 255);
//    if (success != 0) return nil;
////    baseHostName[255] = '/0';
//
//#if TARGET_IPHONE_SIMULATOR
//     return [NSString stringWithFormat:@"%s", baseHostName];
//#else
//    return [NSString stringWithFormat:@"%s.local", baseHostName];
//#endif
    
}

- (NSString *)watermarkTextViewUIString {
   
    return @"Host";
}
@end
