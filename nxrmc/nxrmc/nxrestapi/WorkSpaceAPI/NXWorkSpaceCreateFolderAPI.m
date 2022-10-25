//
//  NXWorkSpaceCreateFolderAPI.m
//  nxrmc
//
//  Created by Eren on 2019/8/28.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXWorkSpaceCreateFolderAPI.h"
#import "NXLoginUser.h"

@implementation NXWorkSpaceCreateFolderModel

@end

@implementation NXWorkSpaceCreateFolderRequest
-(NSURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NSAssert([object isKindOfClass:[NXWorkSpaceCreateFolderModel class]], @"NXWorkSpaceCreateFolderRequest model shold be NXWorkSpaceCreateFolderModel");
        NXWorkSpaceCreateFolderModel *createFolderModel = (NXWorkSpaceCreateFolderModel *)object;
        self.reqRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/enterprisews/createFolder", [NXCommonUtils currentRMSAddress]]]];
        self.reqRequest.HTTPMethod = @"POST";
        NSDictionary *parametersDict = @{@"parameters":@{@"parentPathId":createFolderModel.parentFolder.fullServicePath,
                                                         @"name":createFolderModel.folderName,
                                                         @"autorename":[NSNumber numberWithBool:createFolderModel.autoRename]
                                                         }};
        [self.reqRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [self.reqRequest setHTTPBody:[parametersDict toJSONFormatData:nil]];
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        NXWorkSpaceCreateFolderResponse *response = [[NXWorkSpaceCreateFolderResponse alloc]init];
        NSData *resultData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (resultData) {
            [response analysisResponseStatus:resultData];
            if (response.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) {
                NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
                NSDictionary *resultsDic = dic[@"results"][@"entry"];
                NXWorkSpaceFolder *createdFolder = [[NXWorkSpaceFolder alloc] init];
                createdFolder.name = resultsDic[@"name"];
                createdFolder.fullPath = resultsDic[@"pathDisplay"];
                createdFolder.fullServicePath = resultsDic[@"pathId"];
                createdFolder.size = ((NSNumber *)resultsDic[@"size"]).longLongValue;
                long long lastModifiedTime = ((NSNumber *)resultsDic[@"lastModified"]).longLongValue;
                lastModifiedTime /= 1000;
                createdFolder.lastModifiedDate = [NSDate dateWithTimeIntervalSince1970:lastModifiedTime];
                NXWorkSpaceFileItemUploader *uploder = [[NXWorkSpaceFileItemUploader alloc] init];
                uploder.userId = [NXLoginUser sharedInstance].profile.userId.integerValue;
                uploder.email = [NXLoginUser sharedInstance].profile.email;
                uploder.displayName = [NXLoginUser sharedInstance].profile.userName;
                createdFolder.fileUploader = uploder;
                response.createdFolder = createdFolder;
            }
        }
        return response;
    };
    return analysis;
}
@end

@implementation NXWorkSpaceCreateFolderResponse


@end
