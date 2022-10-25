//
//  NXSharingRepositoryAPI.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 7/5/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXSharingRepositoryAPI.h"
#import "NXLFileValidateDateModel.h"
#import "NXLProfile.h"
#import "NXLRights.h"
@implementation NXSharingRepositoryReqModel
@end

@implementation NXSharingRepositoryRequest
-(NSMutableURLRequest *) generateRequestObject:(id) object
{
    if (self.reqRequest == nil) {
        NSAssert([object isKindOfClass:[NXSharingRepositoryReqModel class]], @"NXSharingRepositoryRequest must be object of NXSharingRepositoryReqModel");
        NXSharingRepositoryReqModel *model = (NXSharingRepositoryReqModel *)object;
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/share/repository", [NXCommonUtils currentRMSAddress]]]];
        request.HTTPMethod = @"POST";
        
        NSDictionary *validateDateInfoDict = nil;
        if (model.validateDateModel) {
            validateDateInfoDict = [model.validateDateModel getRMSRESTAPIShareFormatDictionary];
        }
        
        NSMutableDictionary *sharedDocDict = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                               @"membershipId":[NXLoginUser sharedInstance].profile.individualMembership.ID,
                                                                                               @"permissions":@([model.rights getPermissions]),
//                                                                                               @"tags":@{
//                                                                                                       @"Classification":@[@"ITAR"],
//                                                                                                       @"Clearance":@[@"Confidiential",@"Top Secret"],
//                                                                                                       },
                                                                                               @"metadata":@"{}",
                                                                                               @"fileName":model.file.name,
                                                                                               @"repositoryId":model.file.repoId,
                                                                                               @"filePathId":model.file.fullServicePath,
                                                                                               @"filePath":model.file.fullPath,
                                                                                               @"recipients":model.recipients,
                                                                                               @"comment":model.comment?:@"",
                                                                                               @"expiry":validateDateInfoDict,
                                                                                               @"userConfirmedFileOverwrite":@"true",
                                                                                               }];
        
        NSMutableString *watermarkString = [NSMutableString string];
        for (NXWatermarkWord *watermarkWord in model.watermarkArray) {
            [watermarkString appendString:[watermarkWord watermarkPolicyString]];
        }
        
        if (watermarkString.length > 0) {
            [sharedDocDict setObject:watermarkString forKey:@"watermark"];
        }
        
        NSDictionary *jsonDict = @{@"parameters":@{@"asAttachment":@"false",
                                                   @"sharedDocument":sharedDocDict,
                                                   }};
        
        [request setHTTPBody:[jsonDict toJSONFormatData:nil]];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        self.reqRequest = request;
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        NXSharingRepositoryResponse *response = [[NXSharingRepositoryResponse alloc] init];
        NSData *resultData=[returnData dataUsingEncoding:NSUTF8StringEncoding];
        [response analysisResponseStatus:resultData];
        NSDictionary *returnDic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
        if (response.rmsStatuCode == 200) {
            [response setValuesForKeysWithDictionary:returnDic[@"results"]];
        }
        return response;
    };
    return analysis;
}
@end

@implementation NXSharingRepositoryResponse

- (instancetype) init{
    if (self = [super init]) {
        _alreadySharedList = [[NSArray alloc] init];
        _anewSharedList = [[NSArray alloc] init];
    }
    return self;
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"newSharedList"]) {
        self.anewSharedList = value;
    }
}

@end
