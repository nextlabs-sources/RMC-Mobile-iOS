//
//  NXSharedWorkspaceGetNXLFileHeaderAPI.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2020/9/8.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXSharedWorkspaceGetNXLFileHeaderAPI.h"
#import "NXSharedWorkspaceFile.h"
@implementation NXSharedWorkspaceGetNXLFileHeaderAPIRequest
- (NSMutableURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        if (object) {
            NXSharedWorkspaceFile *file = (NXSharedWorkspaceFile *)object;
           NSString *filePath  = file.fullPath;
            NSString *repoId  = file.repoId;
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/sharedws/v1/%@/fileHeader",[NXCommonUtils currentRMSAddress],repoId]];
            NSDictionary *paramDict = @{
                @"parameters":@{
                        @"path":filePath,
                },
            };
            NSData *body = [paramDict toJSONFormatData:nil];
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
            [req setHTTPMethod:@"POST"];
            [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [req setHTTPBody:body];
            self.reqRequest = req;
        }
       
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        
       NXSharedWorkspaceGetNXLFileHeaderAPIResponse *response = [[NXSharedWorkspaceGetNXLFileHeaderAPIResponse alloc] init];
        NSData *contentData = nil;
        
        if ([returnData isKindOfClass:[NSString class]])
        {
            contentData=[returnData dataUsingEncoding:NSUTF8StringEncoding];
        }
        else
        {
            contentData =(NSData*)returnData;
        }
        
        if (contentData)
        {
            [response analysisResponseStatus:contentData];
            response.rmsStatuCode = 200;
        }
        
        response.fileData = contentData;
        return response;
        
    };
    
    return analysis;
}
@end

@implementation NXSharedWorkspaceGetNXLFileHeaderAPIResponse



@end

