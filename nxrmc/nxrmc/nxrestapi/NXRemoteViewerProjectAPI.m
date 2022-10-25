//
//  NXRemoteViewerProjectAPI.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 7/6/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXRemoteViewerProjectAPI.h"
#import "NXLProfile.h"
@implementation NXRemoteViewerProjectModel

- (instancetype)initWithProjectFile:(NXProjectFile *)file rights:(NSInteger)operations {
    if (self = [super init]) {
        self.file = file;
        self.operations = operations;
    }
    return self;
}

@end

@implementation NXRemoteViewerProjectRequest
-(NSMutableURLRequest *) generateRequestObject:(NXRemoteViewerProjectModel *)object
{
    if (self.reqRequest == nil) {
        if (![object isKindOfClass:[NXRemoteViewerProjectModel class]]) {
            return nil;
        }
        NXRemoteViewerProjectModel *model = (NXRemoteViewerProjectModel *)object;
        
        NSString *email = [NXLoginUser sharedInstance].profile.email;
        
        NSNumber *projectId = model.file.projectId;
        NSString *pathId = model.file.fullServicePath?:@"";
        NSString *pathDisplay = model.file.fullPath?:@"";
        
        long long longModifiedTime = [model.file.lastModifiedDate timeIntervalSince1970]* 1000;
        NSString *tenantName = [NXCommonUtils currentTenant];
        
        [[NSTimeZone localTimeZone] secondsFromGMT];
        NSInteger offSet = [[NSTimeZone localTimeZone] secondsFromGMT];
        
        NSInteger operations = model.operations;
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/remoteView/project", [NXCommonUtils currentRMSAddress]]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        NSDictionary *jsonDict = @{@"parameters":@{@"projectId":projectId,
                                                   @"pathId":pathId,
                                                   @"pathDisplay":pathDisplay,
                                                   @"offset":@(-offSet),
                                                   @"email":email,
                                                   @"tenantName":tenantName,
                                                   @"lastModifitedDate":@(longModifiedTime),
                                                   @"operations":@(operations)
                                                   }};
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
        if (error) {
            DLog(@"%ld%@", (long)error.code, error.localizedDescription);
        } else {
            [request setHTTPBody:jsonData];
        }
        
        self.reqRequest = request;
        
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error){
        NXRemoteViewerResponse *response = [[NXRemoteViewerResponse alloc] init];
        NSData *data = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (data) {
            [response analysisResponseData:data];
        }
        return response;
    };
    return analysis;
}
@end
