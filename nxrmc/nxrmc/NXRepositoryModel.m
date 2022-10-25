//
//  NXRepository.m
//  nxrmc
//
//  Created by EShi on 12/20/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXRepositoryModel.h"
#import "NXRepository.h"
#import "NXRMCDef.h"
#import "NXCommonUtils.h"
#import "NXBoundService+CoreDataClass.h"
#import "NXLProfile.h"
@interface NXRepositoryModel()
@property (nonatomic, readwrite) NSString *service_account;
@property (nonatomic, readwrite) NSString *service_account_id;
@property (nonatomic, readwrite) NSString *service_account_token;
@property (nonatomic, readwrite) NSString *service_id;
@property (nonatomic, readwrite) NSNumber *service_type;
@property (nonatomic, readwrite) NSNumber *user_id;
@property (nonatomic, readwrite) NSNumber *service_isAuthed;
@end

@implementation NXRepositoryModel
-(instancetype) initWithRepository:(NXRepository *)repository
{
    self = [super init];
    if (self) {
        _service_account = [repository.service_account copy];
        _service_account_id = [repository.service_account_id copy];
        _service_account_token = [repository.service_account_token copy];
        _service_alias = [repository.service_alias copy];
        _service_id = [repository.service_id copy];
        _service_selected = [repository.service_selected copy];
        _service_type = [repository.service_type copy];
        _user_id = [repository.user_id copy];
        _service_isAuthed = [repository.service_isAuthed copy];
        _service_providerClass  = [repository.service_providerClass copy];
    }
    return self;
}

- (instancetype)initWithRMCRepoModel:(NXRMCRepoItem *)rmcRepoModel
{
    if (self = [super init]) {
        _service_account = [rmcRepoModel.service_account copy];
        _service_account_id = [rmcRepoModel.service_account_id copy];
        _service_account_token = [rmcRepoModel.service_account_token copy];
        _service_alias = [rmcRepoModel.service_alias copy];
        _service_id = [rmcRepoModel.service_id copy];
        _service_selected = [rmcRepoModel.service_selected copy];
        _service_type = [rmcRepoModel.service_type copy];
        _user_id = [rmcRepoModel.user_id copy];
        _service_isAuthed = [NSNumber numberWithBool:rmcRepoModel.service_isAuthed];
        _service_providerClass = [rmcRepoModel.providerClass copy];
    }
    return self;
}

-(instancetype) initWithAccountInfoDict:(NSDictionary *)accountInfoDict
{
    self = [super init];
    if (self) {
        _service_account = accountInfoDict[AUTH_RESULT_ACCOUNT];
        _service_account_token = @"";
        _service_account_id = accountInfoDict[AUTH_RESULT_ACCOUNT_ID];
        _service_type = accountInfoDict[AUTH_RESULT_REPO_TYPE];
        _service_id = accountInfoDict[AUTH_RESULT_REPO_ID];
        _service_selected = [NSNumber numberWithBool:YES];
        _user_id = accountInfoDict[AUTH_RESULT_USER_ID];
        _service_isAuthed = [NSNumber numberWithBool:YES];
        _service_alias = accountInfoDict[AUTH_RESULT_ALIAS];
        
    }
    return self;
}

-(instancetype) initWithRMSRepoItem:(NXRMSRepoItem *)rmsRepoItem userProfile:(NXLProfile *)userProfile
{
    self = [super init];
    if (self) {
        _service_account = [rmsRepoItem.account copy];
        _service_account_token = [rmsRepoItem.refreshToken copy];
        _service_account_id = [rmsRepoItem.accountId copy];
        _service_type = [NXCommonUtils rmsToRMCRepoType:rmsRepoItem.repoType];
        _service_id = [rmsRepoItem.repoId copy];
        _service_selected = [NSNumber numberWithBool:YES];
        _user_id = [NSNumber numberWithInteger:userProfile.userId.integerValue];
        _service_isAuthed = [NSNumber numberWithBool:rmsRepoItem.isAuthed];
        _service_alias = [rmsRepoItem.displayName copy];
        _service_providerClass  = [rmsRepoItem.providerClass copy];
        if ([rmsRepoItem.repoType isEqualToString:@"SHAREPOINT_ONLINE"] && [rmsRepoItem.providerClass isEqualToString:@"APPLICATION"]) {
            _service_type = [NSNumber numberWithInteger:KServiceSharepointOnlineApplication];
        }
    }
    return self;
}

- (instancetype)initWithBoundService:(NXBoundService *)boundService
{
    self = [super init];
    if (self) {
        _service_account = [boundService.service_account copy];
        _service_account_token = [boundService.service_account_token copy];
        _service_account_id = [boundService.service_account_id copy];
        _service_type = [boundService.service_type copy];
        _service_id = [boundService.service_id copy];
        _service_selected = [NSNumber numberWithBool:YES];
        _user_id = [boundService.user_id copy];
        _service_isAuthed = [boundService.service_isAuthed copy];
        _service_alias = [boundService.service_alias copy];
        _service_providerClass  = [boundService.service_providerClass copy];
    }
    return self;
}

#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone
{
    NXRepositoryModel *newRepo = [[NXRepositoryModel alloc] init];
    newRepo.service_id = [self.service_id copy];
    newRepo.service_account = [self.service_account copy];
    newRepo.service_account_id = [self.service_account_id copy];
    newRepo.service_account_token = [self.service_account_token copy];
    newRepo.service_alias = [self.service_alias copy];
    newRepo.service_selected = [self.service_selected copy];
    newRepo.service_type = [self.service_type copy];
    newRepo.user_id = [self.user_id copy];
    newRepo.service_isAuthed = [self.service_isAuthed copy];
    newRepo.service_providerClass = [self.service_providerClass copy];
    return newRepo;
}
// for use nxrepomodel as continer key
- (NSUInteger)hash
{
    return [self.service_id hash] ^ [self.service_account_id hash];
}
- (BOOL)isEqual:(id)other
{
    if (![other isKindOfClass:[self class]] && ![self.class isKindOfClass:[other class]]) {
        return NO;
    }
    NXRepositoryModel *otherModel = (NXRepositoryModel *)other;
    if ([otherModel.service_id isEqualToString:self.service_id]  && [otherModel.service_account_id isEqualToString:self.service_account_id]) {
        return YES;
    }
    return NO;
}

#pragma mark - Discription
- (NSString *)description
{
    NSString *descriptionStr = [[NSString alloc] initWithFormat:@"service_id=%@\n \
                                                                service_account=%@\n \
                                                                service_account_id=%@\n \
                                                                service_account_token=%@\n \
                                                                service_alias=%@\n \
                                                                service_selected=%@\n \
                                                                service_type=%@\n \
                                                                user_id=%@\n \
                                                                service_isAuthed=%@", self.service_id, self.service_account, self.service_account_id, self.service_account_token,
                                                                                      self.service_alias, self.service_selected, [NXCommonUtils convertRepoTypeToDisplayName:self.service_type], self.user_id,self.service_isAuthed];
    return descriptionStr;
}
@end
