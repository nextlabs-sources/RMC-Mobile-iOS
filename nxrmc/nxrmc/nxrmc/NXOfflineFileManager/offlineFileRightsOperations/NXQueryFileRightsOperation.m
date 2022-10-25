//
//  NXQueryFileRightsOperation.m
//  nxrmc
//
//  Created by Eren on 2018/8/10.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import "NXQueryFileRightsOperation.h"
#import "NXWebFileManager.h"
#import "NXRMCDef.h"
#import "NXLoginUser.h"
#import "NXLMetaData.h"
#import "NXCommonUtils.h"
#import "NXPerformPolicyEvaluationAPI.h"
#import "NXGetWorkSpaceFileMetadataAPI.h"
#import "NXWorkSpaceItem.h"


@interface NXQueryFileRightsOperation()
@property(nonatomic, strong) NXFileBase *file;
@property(nonatomic, strong) NSString *curOptID;

@property(nonatomic, strong) NXLRights *fileRights;
@property(nonatomic, strong) NSArray *watermark;
@property(nonatomic, strong) NSString *ownerId;
@property(nonatomic, assign) BOOL isOwner;
@property(nonatomic, strong) NSString *duid;
@property(nonatomic, strong) NSArray<NXClassificationCategory *> *classifications;

@property(nonatomic, strong) NXPerformPolicyEvaluationAPIRequest *policyEvaluationReq;
@property(nonatomic, strong) NXGetWorkSpaceFileMetadataRequest *getWorkSpaceFileMetadataReq;
@end

@implementation  NXQueryFileRightsOperation
- (instancetype)initWithFile:(NXFileBase *)file {
    if (self = [super init]) {
        _file = file;
    }
    return self;
}

#pragma mark - Overwrite NXOperationBase
- (void)executeTask:(NSError **)error {
    WeakObj(self);
    self.curOptID = [((NXFile *)self.file) getNXLHeader:^(NXFileBase *file, NSData *fileData, NSError *error) {
       StrongObj(self);
        if (self.isCancelled) {
            return;
        }
        if (error) {
            [self finish:error];
        }else {
            NSDictionary *sharedInfoDict = nil;
            if ([file isKindOfClass:[NXSharedWithProjectFile class]]) {
                sharedInfoDict = @{
                    @"sharedSpaceType": @1,
                    @"sharedSpaceId": ((NXSharedWithProjectFile *)file).sharedProject.projectId,
                    @"sharedSpaceUserMembership": ((NXSharedWithProjectFile *)file).sharedProject.membershipId
                };
            }
            
            [NXLMetaData getPolicySection:file.localPath clientProfile:[NXLoginUser sharedInstance].profile sharedInfo:sharedInfoDict complete:^(NSDictionary *policySection, NSDictionary *classificationSection, NSError *error){
                if (self.isCancelled) {
                    return;
                }
                if(error){
                    if (error.code == 403) {
                        error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_ACCESS_DENY userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_NO_ACCESS_RIGHT", nil)}];
                    }else{
                        error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_GETPOLICY userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_GET_RIGHTS_FAILED", nil)}];
                    }
                }
                
                NSString *duid = [NXLMetaData getNXLFileDUID:file.localPath];
                self.duid = duid;
                NSString *ownerId = [NXLMetaData getNXLFileOwnerId:file.localPath];
                self.ownerId = ownerId;
                // get right header success, now check is enrypt by AD hoc or center policy
                if (policySection) { // if enrypt by AD hoc
                    NSArray* policies = [policySection objectForKey:@"policies"];
                    NSDictionary *policy = policies[0];
                    NSArray* namedRights = [policy objectForKey:@"rights"];
                    NSArray* namedObs = [policy objectForKey:@"obligations"];
                    NXLRights *rights = [[NXLRights alloc]initWithRightsObs:namedRights obligations:namedObs];
                   
                    NSArray *watermark = nil;
                    BOOL isOwner = [NXCommonUtils isStewardUser:ownerId forFile:file];
                    // parse watermark
                    if ([rights getObligation:NXLOBLIGATIONWATERMARK]) {
                        watermark = [[rights getWatermarkString] parseWatermarkWords];
                    }
                    // parse expire time
                    NXLFileValidateDateModel *validateDateModel = [self extractFileValidateDateFromPolicySection:policy];
                    [rights setFileValidateDate:validateDateModel];
                    
                    // save the result
                    self.duid = duid;
                    self.fileRights = rights;
                    self.watermark = watermark;
                    self.ownerId = ownerId;
                    self.isOwner = isOwner;
                    [self finish:error];
                }else if(classificationSection){ // if enrypt by classficationSection
                    NSMutableArray *classifications = [NSMutableArray array];
                    [classificationSection enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSArray * obj, BOOL * _Nonnull stop) {
                        NXClassificationCategory *classificaitonCategory = [[NXClassificationCategory alloc] init];
                        classificaitonCategory.name = key;
                        for (NSString *lab in obj) {
                            NXClassificationLab *classificaitonLab = [[NXClassificationLab alloc] init];
                            classificaitonLab.name = lab;
                            [classificaitonCategory.selectedLabs addObject:classificaitonLab];
                        }
                        [classifications addObject:classificaitonCategory];
                    }];
                    
                    // for shareWithProjectFile use shared project membershipID,not source project membershipID
                     NSString *owner = ownerId;
                     if (file.sorceType == NXFileBaseSorceTypeSharedWithProject){
                         NXSharedWithProjectFile *shareFromProjectFile = (NXSharedWithProjectFile *)file;
                         if(shareFromProjectFile.sharedProject.membershipId){
                             owner = shareFromProjectFile.sharedProject.membershipId;
                         }
                     }else if(file.sorceType == NXFileBaseSorceTypeProject){
                         NXProjectFile *projectFile = (NXProjectFile *)file;
                         NXProjectModel *projectModel = [[NXLoginUser sharedInstance].myProject getProjectModelForProjectId:projectFile.projectId];
                         if (projectModel.membershipId) {
                             owner = projectModel.membershipId;
                         }
                     }else{
                         owner = [NXLoginUser sharedInstance].profile.tenantMembership.ID;
                     }
                    // before return, get rights
                    NSDictionary *dictModel = @{MEMBER_SHIP_ID:owner,
                                                RESOURCE_NAME:file.name,
                                                EVAL_NAME:@"RMS",
                                                DUIDKEY:duid,
                                                RIGHTS:@(NXLRIGHTVIEW|NXLRIGHTPRINT|NXLRIGHTSDOWNLOAD|NXLRIGHTEDIT|NXLRIGHTDECRYPT|NXLRIGHTSHARING|NXLRIGHTSCREENCAP),
                                                USERID:[NXLoginUser sharedInstance].profile.userId,
                                                EVALTYPE:@0,
                                                CATEGORIES_ARRAY:classifications
                                                };
                    self.policyEvaluationReq = [[NXPerformPolicyEvaluationAPIRequest alloc] init];
                    WeakObj(self);
                    [self.policyEvaluationReq requestWithObject:dictModel Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
                        StrongObj(self);
                        if (self == nil) {
                            return;
                        }
                        if (self.isCancelled) {
                            return;
                        }
                        
                        if (error) {
                            error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_DECRYPT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_EVALUATION_FAILED", nil)}];
                            [self finish:error];
                            
                        }else {
                            if (response.rmsStatuCode != NXRMS_ERROR_CODE_SUCCESS) {
                                NSString *errorDescription = NSLocalizedString(@"MSG_COM_EVALUATION_FAILED", nil);
                                if (response.rmsStatuCode == NXRMS_PROJECT_CLASSIFICATION_NOT_MATCH_RIGHTS) {
                                    errorDescription = NSLocalizedString(@"MSG_COM_NO_POLICY_TO_EVALUATE", nil);
                                }
                                error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_DECRYPT userInfo:@{NSLocalizedDescriptionKey:errorDescription}];
                                [self finish:error];
                            } else {
                                NXPerformPolicyEvaluationAPIResponse *evaResponse = (NXPerformPolicyEvaluationAPIResponse *)response;
                                NXLRights *right = evaResponse.evaluationRight;
                                BOOL isOwner = NO; // policy encrypt file do not have owner
                                // save result
                                self.fileRights = right;
                                self.duid = duid;
                                self.isOwner = isOwner;
                                self.watermark = [[right getWatermarkString] parseWatermarkWords];
                                self.ownerId = ownerId;  // only project file can enrypt with center policy
                                self.classifications = classifications;
                                [self finish:error];
                            }
                        }
                    }]; // end NXPerformPolicyEvaluationAPIRequest
                }else {
                    NSAssert(NO, @"Encrypt type should be adhoc or classification");
                    NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_NXLFILE_DOMAIN code:NXRMC_ERROR_CODE_NXFILE_INVALID userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_INVALID_NXL_FILE", nil)}];
                    [self finish:error];
                }
            }];
        }
    }];
}


- (void)workFinished:(NSError *)error {
    if (self.completed) {
        self.completed(self.duid, self.fileRights, self.classifications, self.watermark, self.ownerId, self.isOwner, error);
    }
}


- (void)cancelWork:(NSError *)cancelError {
    [[NXWebFileManager sharedInstance] cancelDownload:self.curOptID];
    [self.policyEvaluationReq cancelRequest];
}

#pragma mark - Private method
- (NXLFileValidateDateModel *)extractFileValidateDateFromPolicySection:(NSDictionary *)policySection {
    NXLFileValidateDateModel *validateDateModel = nil;
    NSDictionary *conditions = [policySection objectForKey:@"conditions"];
    NSDictionary *environment = conditions[@"environment"];
    if (environment == nil) {
        validateDateModel = [[NXLFileValidateDateModel alloc] initWithNXFileValidateDateModelType:NXLFileValidateDateModelTypeNeverExpire withStartTime:nil endTIme:nil];
    }else {
        // environment type 0: means two operator type1 : means one operator
        if (((NSNumber *)environment[@"type"]).integerValue == 0) {
            NSArray *expressions = environment[@"expressions"];
            
            NSDictionary *firstDict = expressions[0];
            NSDictionary *secondDict = expressions[1];
            NSDictionary *startDateDict = nil;
            NSDictionary *endDateDict = nil;
            
            if ([firstDict[@"operator"] isEqualToString:@">="]) {
                startDateDict = firstDict;
                endDateDict = secondDict;
            }else {
                startDateDict = secondDict;
                endDateDict = firstDict;
            }
            long long startSeconds = (((NSNumber *)startDateDict[@"value"]).longLongValue)/1000;
            long long endSeconds = (((NSNumber *)endDateDict[@"value"]).longLongValue)/1000;
            
            validateDateModel = [[NXLFileValidateDateModel alloc] initWithNXFileValidateDateModelType:NXLFileValidateDateModelTypeRange withStartTime:[NSDate dateWithTimeIntervalSince1970:startSeconds] endTIme:[NSDate dateWithTimeIntervalSince1970:endSeconds]];
        }else if(((NSNumber *)environment[@"type"]).integerValue == 1) {
            long long endSeconds = ((NSNumber *)environment[@"value"]).longLongValue/1000;
            validateDateModel = [[NXLFileValidateDateModel alloc] initWithNXFileValidateDateModelType:NXLFileValidateDateModelTypeAbsolute withStartTime:[NSDate date] endTIme:[NSDate dateWithTimeIntervalSince1970:endSeconds]];
            
        }
    }
    return validateDateModel;
}

@end
