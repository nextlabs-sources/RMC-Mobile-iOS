//
//  NXBoxUploadFileAPI.m
//  nxrmc
//
//  Created by Eren on 2020/5/13.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXBoxUploadFileAPI.h"
#import "NXMultipartFormDataMaker.h"

@implementation NXBoxUploadFileRequest
- (NSMutableURLRequest *)generateRequestObject:(id)object{
    if (self.reqRequest == nil) {
        NSDictionary *modelDict = (NSDictionary *)object;
        NXFolder *parentFolder = modelDict[BOX_UPLOAD_PARENT_FOLDER_KEY];
        NSString *uploadFileName = modelDict[BOX_UPLOAD_FILE_NAME_KEY];
        NSString *uploadFilePath =modelDict[BOX_UPLOAD_FILE_PATH_KEY];
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://upload.box.com/api/2.0/files/content"]];
        [req setHTTPMethod:@"POST"];
        NSDictionary *paramDict = @{
            @"name" : uploadFileName,
            @"parent" : @{@"id" : parentFolder.fullServicePath},
        };
        NSData *paramData = [paramDict toJSONFormatData:nil];
        NSData *fileData = [NSData dataWithContentsOfFile:uploadFilePath];
        [req setValue:[NSString stringWithFormat:@"multipart/form-data;boundary=%@",@"boundaryLine"] forHTTPHeaderField:@"Content-Type"];
        NXMultipartFormDataMaker *formDataMaker = [[NXMultipartFormDataMaker alloc] initWithBoundary:@"boundaryLine"];
        [formDataMaker addTextParameter:@"attributes" parameterJsonDataValue:paramData];
        [formDataMaker addFileParameter:@"file" fileName:uploadFileName fileData:fileData];
        [formDataMaker endFormData];
        [req setHTTPBody:[formDataMaker getFormData]];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[req.HTTPBody length]];
        [req setValue:postLength forHTTPHeaderField:@"Content-Length"];
        self.reqRequest = req;
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error){
        NXBoxUploadFileResponse *response = [[NXBoxUploadFileResponse alloc] init];
        if (error == nil) {
            NSError *convertError = nil;
            NSDictionary *uploadFileJSONDict = [returnData toJSONFormatDictionary:&convertError];
            if (convertError == nil) {
                NXFile *fileBase = [[NXFile alloc] initWithFileBaseSourceType:NXFileBaseSorceTypeRepoFile];
               
                NSArray *array = uploadFileJSONDict[@"entries"];
                if (array.count > 0) {
                    NSDictionary *fileItem = array[0];
                    
                    // fetch info
                    fileBase.name = fileItem[@"name"];
                    fileBase.fullServicePath = fileItem[@"id"];
                    fileBase.size = ((NSNumber *)fileItem[@"size"]).longLongValue;
                    NSString *updateTime = fileItem[@"modified_at"];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZ"];
                    NSDate* lastModifydate = [dateFormatter dateFromString:updateTime];
                    NSString *lastModifydateString = [NSDateFormatter localizedStringFromDate:lastModifydate
                                                                                    dateStyle:NSDateFormatterShortStyle
                                                                                    timeStyle:NSDateFormatterFullStyle];

                    fileBase.lastModifiedDate = lastModifydate;
                    fileBase.lastModifiedTime = lastModifydateString;
                    fileBase.serviceAccountId = self.repo.service_account_id;
                    fileBase.serviceType = self.repo.service_type;
                    fileBase.serviceAlias = self.repo.service_alias;
                }
                
                response.uploadedFile = fileBase;
            }
        }
        return response;
    };
    return analysis;
}
@end

@implementation NXBoxUploadFileResponse

@end
