//
//  NXWorkSpaceFileGetNXLHeaderAPI.m
//  nxrmc
//
//  Created by 时滕 on 2020/6/8.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXWorkSpaceFileGetNXLHeaderAPI.h"

@implementation NXWorkSpaceFileGetNXLHeaderRequest
- (NSMutableURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NXWorkSpaceFile *file = (NXWorkSpaceFile *)object;
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/enterprisews/fileHeader", [NXCommonUtils currentRMSAddress]]];
        NSDictionary *paramDict = @{
            @"parameters":@{
                    @"pathId":file.fullServicePath,
            },
        };
        NSData *body = [paramDict toJSONFormatData:nil];
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
        [req setHTTPMethod:@"POST"];
        [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [req setHTTPBody:body];
        self.reqRequest = req;
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        
        NXWorkSpaceFileGetNXLHeaderResponse *response = [[NXWorkSpaceFileGetNXLHeaderResponse alloc] init];
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

@implementation NXWorkSpaceFileGetNXLHeaderResponse



@end
