//
//  NXWorkSpaceUploadFileAPI.m
//  nxrmc
//
//  Created by Eren on 2019/8/28.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXWorkSpaceUploadFileAPI.h"
#import "NXMultipartFormDataMaker.h"
#import "NSDictionary+NXExt.h"
#import "NXLMetaData.h"

@implementation NXWorkSpaceUploadFileModel

@end

@implementation NXWorkSpaceUploadFileRequest
-(NSURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NSAssert([object isKindOfClass:[NXWorkSpaceUploadFileModel class]], @"NXWorkSpaceUploadFileRequest object should be NXWorkSpaceUploadFileModel");
        NXWorkSpaceUploadFileModel *uploadFileInfo = (NXWorkSpaceUploadFileModel *)object;
        self.reqRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/enterprisews/file", [NXCommonUtils currentRMSAddress]]]];
        self.reqRequest.HTTPMethod = @"POST";
        
        BOOL isNXL = [NXLMetaData isNxlFile:uploadFileInfo.file.localPath];
        NSDictionary *parametersDict = nil;
        if (isNXL) {
            if (!uploadFileInfo.isOverWrite) {
                parametersDict = @{
                    @"parameters":@{
                        @"name":uploadFileInfo.file.name,
                        @"parentPathId":uploadFileInfo.parentFolder.fullServicePath,
                        @"type":@0
                    },
                };
                
            }else{
                parametersDict = @{
                    @"parameters":@{
                        @"name":uploadFileInfo.file.name,
                        @"parentPathId":uploadFileInfo.parentFolder.fullServicePath,
                        @"userConfirmedFileOverwrite":@"true",
                    },
                };
                
            }
            
        }else {
            NSString *waterMarkString = nil;
            NSString *expiryString = nil;
            if (uploadFileInfo.digitalRight) {
                waterMarkString = uploadFileInfo.digitalRight.getWatermarkString;
                NSDictionary * expiryDict = uploadFileInfo.digitalRight.getVaildateDateModel? uploadFileInfo.digitalRight.getVaildateDateModel.getRMSRESTAPIShareFormatDictionary:nil;
                expiryString = expiryDict? [expiryDict toJSONFormatString:nil]:nil;
            }
            
            // The following code just for temp solution, because server tread watermark as rights, must wait for they fix this bug and remove the code
            NSString *rightsJSON = @"";
            if (uploadFileInfo.digitalRight) {
                if (waterMarkString) {
                      NSMutableString *rightsString = [[NSMutableString alloc] initWithString:@"["];
                      NSInteger count = [uploadFileInfo.digitalRight getNamedRights].count;
                      for (NSInteger index = 0; index < count; index++) {
                          NSString *namedRight = [uploadFileInfo.digitalRight getNamedRights][index];
                          [rightsString appendString:namedRight];
                          [rightsString appendString:@","];
                      }
                      [rightsString appendString:@"WATERMARK"];
                      [rightsString appendString:@"]"];
                      rightsJSON = rightsString;
                }else {
                    rightsJSON = uploadFileInfo.digitalRight.getRightsString;
                }
            }
            /////////////// following code end
           parametersDict = @{@"parameters":@{
                                     @"name":uploadFileInfo.file.name,
                                     @"rightsJSON":rightsJSON,
                                     @"tags":uploadFileInfo.tags?:@{},
                                     @"parentPathId":uploadFileInfo.parentFolder.fullServicePath,
                                     @"watermark":waterMarkString?:@"",
                                     @"expiry":expiryString?:@"",
                                     @"userConfirmedFileOverwrite":@"true",
                                     }};
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
        NXWorkSpaceUploadFileResponse *response = [[NXWorkSpaceUploadFileResponse alloc]init];
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
                lastModifiedTime /= 1000;
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

@implementation NXWorkSpaceUploadFileResponse

@end
