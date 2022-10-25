//
//  NXProjectReclassifyFileAPI.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/5/8.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXProjectReclassifyFileAPI.h"
@interface NXProjectReclassifyFileAPIRequest ()
@property(nonatomic, strong)NSNumber *projectId;

@end
@implementation NXProjectReclassifyFileAPIRequest
- (NSURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        if ([object isKindOfClass:[NXProjectUploadFileParameterModel class]]) {
            NXProjectUploadFileParameterModel *parameterMD=(NXProjectUploadFileParameterModel*)object;
            self.projectId = parameterMD.projectId;
            NSError *parseError = nil;
            NSString *tagStr;
            if (@available(iOS 11.0, *)) {
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameterMD.tags options:NSJSONWritingSortedKeys error:&parseError];
                tagStr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
            } else {
                NSData *jsonData1 = [NSJSONSerialization dataWithJSONObject:parameterMD.tags options:NSJSONWritingPrettyPrinted error:&parseError];
                tagStr = [[NSString alloc]initWithData:jsonData1 encoding:NSUTF8StringEncoding];
                tagStr = [tagStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                tagStr = [tagStr stringByReplacingOccurrencesOfString:@" " withString:@""];
            }
           
             NSDictionary *parameters =@{@"parameters":@{@"fileName":parameterMD.fileName,@"parentPathId":parameterMD.destFilePathId,@"fileTags":tagStr}};
            NSURL *apiUrl = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/project/%@/file/classification",[NXCommonUtils currentRMSAddress],self.projectId]];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiUrl];
            NSError *error = nil;
             NSData *bodyData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&error];
            [request setHTTPMethod:@"PUT"];
            [request setHTTPBody:bodyData];
            [request setValue:@"application/json" forHTTPHeaderField:@"consumes"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            
            self.reqRequest = request;
         }
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData {
    Analysis anslysis = (id)^(NSString *returnData, NSError* error){
       NXProjectReclassifyFileAPIResponse  *response =[[NXProjectReclassifyFileAPIResponse alloc]init];
        NSData *resultData =[returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (resultData) {
            [response analysisResponseStatus:resultData];
            NSDictionary *dic =[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *resultsDic = dic[@"results"][@"entry"];
            NXProjectFile *fileItem =[[NXProjectFile alloc]initFileFromResultProjectUploadFileDic:resultsDic];
            fileItem.projectId = self.projectId;
            NSString *parentPath = [fileItem.fullServicePath stringByDeletingLastPathComponent];
            if (![parentPath isEqualToString:@"/"]) {
               parentPath = [parentPath stringByAppendingString:@"/"];
            }
            fileItem.parentPath = parentPath;
            fileItem.creationTime = fileItem.lastModifiedTime;
            response.fileItem = fileItem;
           
            }
        return response;
    };
    return anslysis;
}
@end
@implementation NXProjectReclassifyFileAPIResponse

@end
