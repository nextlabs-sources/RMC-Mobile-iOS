//
//  NXWorkSpaceReclassifyFileAPI.m
//  nxrmc
//
//  Created by Eren on 2019/8/28.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXWorkSpaceReclassifyFileAPI.h"
#import "NXWorkSpaceItem.h"
@implementation NXWorkSpaceReclassifyFileModel
@end
@implementation NXWorkSpaceReclassifyFileRequest
-(NSURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NXWorkSpaceReclassifyFileModel *reclassifyFileInfo = (NXWorkSpaceReclassifyFileModel *)object;
        NSError *parseError = nil;
        NSString *tagStr;
        if (@available(iOS 11.0, *)) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:reclassifyFileInfo.fileTags options:NSJSONWritingSortedKeys error:&parseError];
            tagStr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        } else {
            NSData *jsonData1 = [NSJSONSerialization dataWithJSONObject:reclassifyFileInfo.fileTags options:NSJSONWritingPrettyPrinted error:&parseError];
            tagStr = [[NSString alloc]initWithData:jsonData1 encoding:NSUTF8StringEncoding];
            tagStr = [tagStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            tagStr = [tagStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
        self.reqRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/enterprisews/file/classification", [NXCommonUtils currentRMSAddress]]]];
        self.reqRequest.HTTPMethod = @"PUT";
        NSDictionary *parametersDict = @{@"parameters":@{@"fileName":reclassifyFileInfo.file.name,@"parentPathId":reclassifyFileInfo.parentPathId,@"fileTags":tagStr}};
        [self.reqRequest setHTTPBody:[parametersDict toJSONFormatData:nil]];
        [self.reqRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData {
    Analysis anslysis = (id)^(NSString *returnData, NSError* error){
        NXWorkSpaceReclassifyFileResponse  *response =[[NXWorkSpaceReclassifyFileResponse alloc]init];
        NSData *resultData =[returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (resultData) {
            [response analysisResponseStatus:resultData];
            NSDictionary *dic =[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *resultsDic = dic[@"results"][@"entry"];
            NXWorkSpaceFile *fileItem =[[NXWorkSpaceFile alloc]initWithDictionary:resultsDic];
            response.workSpaceItem = fileItem;
            
        }
        return response;
    };
    return anslysis;
}

@end

@implementation NXWorkSpaceReclassifyFileResponse



@end
