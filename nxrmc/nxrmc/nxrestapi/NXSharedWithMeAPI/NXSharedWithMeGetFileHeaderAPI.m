//
//  NXSharedWithMeGetFileHeaderAPI.m
//  nxrmc
//
//  Created by Sznag on 2020/11/7.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXSharedWithMeGetFileHeaderAPI.h"

@implementation NXSharedWithMeGetFileHeaderAPIRequest
- (NSMutableURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NXSharedWithMeFile *file = (NXSharedWithMeFile *)object;
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/sharedWithMe/fileHeader", [NXCommonUtils currentRMSAddress]]];
        NSDictionary *paramDict = @{
            @"parameters":@{
                    @"transactionCode":file.transactionCode,
                    @"transactionId":file.transactionId,
                    @"spaceId":@(3)
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
            
            NXSharedWithMeGetFileHeaderAPIResponse *response = [[NXSharedWithMeGetFileHeaderAPIResponse alloc] init];
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
@implementation NXSharedWithMeGetFileHeaderAPIResponse

@end
