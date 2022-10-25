//
//  NXRMCStruct.h
//  nxrmc
//
//  Created by EShi on 6/15/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NXRMCRepoItem : NSObject
@property (nonatomic, strong) NSString * service_id;
@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) NSNumber * service_type;
@property (nonatomic, strong) NSString * service_alias;
@property (nonatomic, strong) NSString * service_account;
@property (nonatomic, strong) NSString * service_account_id;
@property (nonatomic, strong) NSString * service_account_token;
@property (nonatomic, strong) NSNumber *service_selected;
@property (nonatomic, strong) NSString *providerClass;
@property (nonatomic) BOOL service_isAuthed;
@end

@interface NXRMSRepoItem : NSObject
@property(nonatomic, strong) NSString * repoId;
@property(nonatomic, strong) NSString *displayName;
@property(nonatomic, strong) NSString *repoType;
@property(nonatomic, assign) BOOL isShared;
@property(nonatomic, assign) BOOL isAuthed;
@property(nonatomic, assign) BOOL isDefault;
@property(nonatomic, assign) NSTimeInterval creationTime;
@property(nonatomic, strong) NSString *account;
@property(nonatomic, strong) NSString *accountId;
@property(nonatomic, strong) NSString *refreshToken;
@property(nonatomic, strong) NSString *providerClass;
@end
