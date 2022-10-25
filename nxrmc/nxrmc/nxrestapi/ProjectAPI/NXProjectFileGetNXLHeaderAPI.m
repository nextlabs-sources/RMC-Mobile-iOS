//
//  NXProjectFileGetNXLHeaderAPI.m
//  nxrmc
//
//  Created by 时滕 on 2020/6/8.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXProjectFileGetNXLHeaderAPI.h"

@implementation NXProjectFileGetNXLHeaderRequest
- (NSMutableURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NXProjectFile *file = (NXProjectFile *)object;
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/project/%ld/fileHeader", [NXCommonUtils currentRMSAddress], (long)file.projectId.integerValue]];
        NSDictionary *paramDict = @{
            @"parameters":@{
                    @"pathId":file.fullServicePath,
            },
        };
        NSData *body = [paramDict toJSONFormatData:nil];
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
        [req setHTTPMethod:@"POST"];
        [req setHTTPBody:body];
        [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        self.reqRequest = req;
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        
        NXProjectFileGetNXLHeaderResponse *response = [[NXProjectFileGetNXLHeaderResponse alloc] init];
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
            response.fileData = contentData;
        }
        
        return response;
        
    };
    
    return analysis;
}

@end


@implementation NXProjectFileGetNXLHeaderResponse

@end
