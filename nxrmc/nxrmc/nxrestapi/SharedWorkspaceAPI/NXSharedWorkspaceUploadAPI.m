//
//  NXSharedWorkspaceUploadAPI.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2020/9/3.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXSharedWorkspaceUploadAPI.h"
#import "NXMultipartFormDataMaker.h"
#import "NSDictionary+NXExt.h"
#import "NXLMetaData.h"

@implementation NXSharedWorkspaceUploadFileModel
@end

@implementation NXSharedWorkspaceUploadAPIRequest
- (instancetype)initWithRepo:(NXRepositoryModel *)repo {
    self = [super init];
    if (self) {
        _repo = repo;
    }
    return self;
}
-(NSURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NSAssert([object isKindOfClass:[NXSharedWorkspaceUploadFileModel class]], @"NXWorkSpaceUploadFileRequest object should be NXWorkSpaceUploadFileModel");
        NXSharedWorkspaceUploadFileModel *uploadFileInfo = (NXSharedWorkspaceUploadFileModel *)object;
        self.reqRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/sharedws/v1/%@/file", [NXCommonUtils currentRMSAddress],self.repo.service_id]]];
        self.reqRequest.HTTPMethod = @"POST";
        
        BOOL isNXL = [NXLMetaData isNxlFile:uploadFileInfo.file.localPath];
        NSDictionary *parametersDict = nil;
        NSString *parentPathId = [NSString stringWithFormat:@"%@%@",uploadFileInfo.parentFolder.fullPath,@"/"];
        if (isNXL) {
            if (uploadFileInfo.overwrite) {
                parametersDict = @{
                    @"parameters":@{
                        @"name":uploadFileInfo.file.name,
                        @"parentPathId":parentPathId,
                        @"type":@(uploadFileInfo.uploadType),
                        @"userConfirmedFileOverwrite":[NSNumber numberWithBool:uploadFileInfo.overwrite]
                    },
                };
                
            }else{
                parametersDict = @{
                    @"parameters":@{
                        @"name":uploadFileInfo.file.name,
                        @"parentPathId":parentPathId,
                        @"type":@(uploadFileInfo.uploadType)
                        
                    },
                };
            }
           
        }
        
        NSData *parameterData = [parametersDict toJSONFormatData:nil];
        NSData *fileData = [NSData dataWithContentsOfFile:uploadFileInfo.file.localPath];
        [self.reqRequest setValue:[NSString stringWithFormat:@"multipart/form-data;boundary=%@",@"boundaryLine"] forHTTPHeaderField:@"Content-Type"];
        NXMultipartFormDataMaker *formDataMaker = [[NXMultipartFormDataMaker alloc] initWithBoundary:@"boundaryLine"];
        [formDataMaker addFileParameter:@"file" fileName:uploadFileInfo.file.name fileData:fileData];
        [formDataMaker addTextParameter:@"API-input" parameterJsonDataValue:parameterData];
        [formDataMaker endFormData];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[self.reqRequest.HTTPBody length]];
        [self.reqRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [self.reqRequest setHTTPBody:[formDataMaker getFormData]];
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        NXSharedWorkspaceUploadAPIResponse *response = [[NXSharedWorkspaceUploadAPIResponse alloc]init];
        NSData *resultData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (resultData) {
            [response analysisResponseStatus:resultData];
            if (response.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
                NSDictionary *resultsDic = dic[@"results"][@"entry"];
                NXWorkSpaceFile *workSpaceFile = [[NXWorkSpaceFile alloc] init];
                workSpaceFile.name = resultsDic[@"name"];
                workSpaceFile.fullServicePath = resultsDic[@"pathId"];
                workSpaceFile.size = ((NSNumber *)resultsDic[@"size"]).longLongValue;
                long long lastModifiedTime = ((NSNumber *)resultsDic[@"lastModified"]).longLongValue;
                lastModifiedTime = lastModifiedTime/1000;
                workSpaceFile.lastModifiedDate = [NSDate dateWithTimeIntervalSince1970:lastModifiedTime];
                NXWorkSpaceFileItemUploader *uploadUser = [[NXWorkSpaceFileItemUploader alloc] init];
                NXWorkSpaceFileItemLastModifiedUser *modifiedUser = [[NXWorkSpaceFileItemLastModifiedUser alloc] init];
                uploadUser.userId = modifiedUser.userId = [NXLoginUser sharedInstance].profile.userId.integerValue;
                uploadUser.displayName = modifiedUser.displayName = [NXLoginUser sharedInstance].profile.displayName;
                uploadUser.email = modifiedUser.email = [NXLoginUser sharedInstance].profile.email;
                workSpaceFile.fileUploader = uploadUser;
                workSpaceFile.fileModifiedUser = modifiedUser;
                
                response.uploadedFile = workSpaceFile;
            }
        }
        return response;
    };
    return analysis;
}
@end

@implementation NXSharedWorkspaceUploadAPIResponse

@end

