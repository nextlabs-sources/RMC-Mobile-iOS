//
//  NXSharingRepositoryAPI1.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2019/12/6.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXSharingProjectFileAPI.h"
#import "NXLFileValidateDateModel.h"
#import "NXLProfile.h"
#import "NXLRights.h"

@implementation NXSharingProjectFileModel : NSObject
@end

@implementation NXSharingProjectFileRequest
-(NSMutableURLRequest *) generateRequestObject:(id) object
{
    if (self.reqRequest == nil) {
        NSAssert([object isKindOfClass:[NXSharingProjectFileModel class]], @"NXSharingRepositoryRequest must be object of NXSharingRepositoryReqModel");
        NXSharingProjectFileModel *model = (NXSharingProjectFileModel *)object;
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/share/repository", [NXCommonUtils currentRMSAddress]]]];
        request.HTTPMethod = @"POST";
        
        NSMutableDictionary *sharedDocDict = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                               @"membershipId":model.projectModel.membershipId,
                                                                                               @"fromSpace":@"1",
                                                                                               @"metadata":@"{}",
                                                                                               @"fileName":model.file.name,
                                                                                               @"projectId":model.projectModel.projectId,
                                                                                               @"filePathId":model.file.fullServicePath,
                                                                                               @"filePath":model.file.fullPath,
                                                                                               @"recipients":model.recipients,
                                                                                               @"comment":model.comment?:@""
                                                                                               }];
        
        
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
        NXSharingProjectFileResponse *response = [[NXSharingProjectFileResponse alloc] init];
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

@implementation NXSharingProjectFileResponse

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
      
    if ([key isEqualToString:@"filePathId"]) {
              self.filePathId = value;
          }
      
    if ([key isEqualToString:@"fileName"]) {
                 self.fileName = value;
             }
}
@end
