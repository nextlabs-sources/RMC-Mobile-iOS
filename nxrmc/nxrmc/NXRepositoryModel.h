//
//  NXRepository.h
//  nxrmc
//
//  Created by EShi on 12/20/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXBoundService+CoreDataClass.h"
#import "NXRMCStruct.h"


@class NXRepository;
@class NXLProfile;
@interface NXRepositoryModel : NSObject<NSCopying>
- (instancetype)initWithRepository:(NXRepository *)repository;
- (instancetype)initWithRMCRepoModel:(NXRMCRepoItem *)rmcRepoModel;
- (instancetype)initWithAccountInfoDict:(NSDictionary *)accountInfoDict;
- (instancetype)initWithBoundService:(NXBoundService *)boundService;

// This init method only used for sync repo, the result repo token is rms token, not locally token!
-(instancetype) initWithRMSRepoItem:(NXRMSRepoItem *)rmsRepoItem userProfile:(NXLProfile *)userProfile;

@property (nonatomic, readonly) NSString *service_account;
@property (nonatomic, readonly) NSString *service_account_id;
@property (nonatomic, readonly) NSString *service_account_token;
@property (nonatomic, readwrite) NSString *service_alias;
@property (nonatomic, readonly) NSString *service_id;
@property (nonatomic, readwrite) NSNumber *service_selected;
@property (nonatomic, readonly) NSNumber *service_type;
@property (nonatomic, readonly) NSNumber *user_id;
@property (nonatomic, readonly) NSNumber *service_isAuthed;
@property (nonatomic, assign)   BOOL isAddItem;
@property(nonatomic, strong) NSString *service_providerClass;
@end
