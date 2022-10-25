//
//  NXProjectUploadFileAPI.m
//  nxrmc
//
//  Created by helpdesk on 18/1/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXProjectUploadFileAPI.h"
#import "NXCommonUtils.h"
#import "NXMultipartFormDataMaker.h"
#import "NXProjectUploadFileParameterModel.h"
#import "NXProjectFile.h"
@interface NXProjectUploadFileAPIRequest ()
@property(nonatomic, strong)NSNumber *projectId;

@end
@implementation NXProjectUploadFileAPIRequest
-(NSURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest==nil) {
        if ([object isKindOfClass:[NXProjectUploadFileParameterModel class]]) {
            NXProjectUploadFileParameterModel *parameterMD=(NXProjectUploadFileParameterModel*)object;
        
            NSData *fileData = parameterMD.fileData;
            NSString *fileName = parameterMD.fileName;
            NSNumber *projectId = parameterMD.projectId;
            self.projectId = parameterMD.projectId;
            
          // delete this after change server in future
            NSString *userRightStr = nil;
            if (parameterMD.rights) {
                NSString *allRightStr=@"";
                for (int i=0; i<parameterMD.rights.count; i++) {
                    NSString *aRightStr=parameterMD.rights[i];
                    if (i==0) {
                        allRightStr=[allRightStr stringByAppendingString:aRightStr];
                    }else {
                        allRightStr=[allRightStr stringByAppendingString:[NSString stringWithFormat:@"%@%@",@",",aRightStr]];
                    }
                }
                userRightStr =[NSString stringWithFormat:@"[%@]",allRightStr];
            }
            
          // parameterMD.rights replace useRightStr in future
                
            NSDictionary *parameters = nil;
            if (userRightStr && parameterMD.tags){
                if (!parameterMD.isoverWrite) {
                    parameters =@{@"parameters":@{@"name":parameterMD.fileName,@"rightsJSON":userRightStr,@"parentPathId":parameterMD.destFilePathId,@"tags":parameterMD.tags, @"type":parameterMD.type}};

                }else{
                    parameters =@{@"parameters":@{@"name":parameterMD.fileName,@"rightsJSON":userRightStr,@"parentPathId":parameterMD.destFilePathId,@"tags":parameterMD.tags,@"userConfirmedFileOverwrite":@"true"}};
                }
               
            }else {
                if (!parameterMD.isoverWrite) {
                    parameters = @{@"parameters":@{@"name":parameterMD.fileName,@"parentPathId":parameterMD.destFilePathId, @"type":parameterMD.type}};
                }else{
                    parameters = @{@"parameters":@{@"name":parameterMD.fileName,@"parentPathId":parameterMD.destFilePathId, @"userConfirmedFileOverwrite":@"true"}};
                }
            }
               
            
            // @"tags":@{@"Confidentiality":@[@"SECRET"]}
            NSData *jsonData = [self toJSONData:parameters];
            
            NSURL *apiURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/rs/project/%@/upload",[NXCommonUtils currentRMSAddress],projectId]];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
            
            [request setHTTPMethod:@"POST"];
            [request setValue:[NSString stringWithFormat:@"multipart/form-data;boundary=%@",@"boundaryLine"] forHTTPHeaderField:@"Content-Type"];
            
            NXMultipartFormDataMaker *formDataMaker = [[NXMultipartFormDataMaker alloc] initWithBoundary:@"boundaryLine"];
            [formDataMaker addTextParameter:@"API-input" parameterJsonDataValue:jsonData];
            [formDataMaker addFileParameter:@"file" fileName:fileName fileData:fileData];
            [formDataMaker endFormData];
            request.HTTPBody = [formDataMaker getFormData];
                
            NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[request.HTTPBody length]];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            self.reqRequest = request;
        }
    }
    return self.reqRequest;
}
-(Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        NXProjectUploadFileAPIResponse *response = [[NXProjectUploadFileAPIResponse alloc]init];
        NSData *resultData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (resultData) {
            [response analysisResponseStatus:resultData];
            NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *resultsDic = dic[@"results"][@"entry"];
            NXProjectFile *fileItem =[[NXProjectFile alloc]initFileFromResultProjectUploadFileDic:resultsDic];
            fileItem.projectId = self.projectId;
            NSString *parentPath = [fileItem.fullServicePath stringByDeletingLastPathComponent];
            if (![parentPath isEqualToString:@"/"]) {
               parentPath = [parentPath stringByAppendingString:@"/"];
            }
            fileItem.parentPath = parentPath;
            fileItem.creationTime = fileItem.lastModifiedTime;
            response.fileItem=fileItem;
        }
        return response;
    };
    return analysis;
}
- (NSData *)toJSONData:(id)theData{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theData
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if ([jsonData length] != 0 && error == nil){
        return jsonData;
    }else{
        return nil;
    }
}
@end

@implementation NXProjectUploadFileAPIResponse

-(NXProjectFile*)fileItem {
    if (!_fileItem) {
        _fileItem=[[NXProjectFile alloc]init];
    }
    return _fileItem;
}

@end
