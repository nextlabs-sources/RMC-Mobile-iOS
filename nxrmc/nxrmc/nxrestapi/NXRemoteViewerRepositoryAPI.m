//
//  NXRemoteViewerRepositoryAPI.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 7/6/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXRemoteViewerRepositoryAPI.h"
#import "NXLProfile.h"
@implementation NXRemoteViewerRepositoryModel

- (instancetype)initWithRepoFile:(NXFileBase *)file rights:(NSInteger)operations {
    if (self = [super init]) {
        self.file = file;
        self.operations = operations;
    }
    return self;
}
@end

@implementation NXRemoteViewerRepositoryResquest
-(NSMutableURLRequest *) generateRequestObject:(NXRemoteViewerRepositoryModel *)object
{
    if (self.reqRequest == nil) {
        if (![object isKindOfClass:[NXRemoteViewerRepositoryModel class]]) {
            return nil;
        }
        NXRemoteViewerRepositoryModel *model = (NXRemoteViewerRepositoryModel *)object;
    
        
        NSString *repoId = model.file.repoId;
        NSString *repoName = model.file.serviceAlias?:@"";
        NSString *repoType = [NXCommonUtils rmcToRMSRepoType:model.file.serviceType];
        
        NSString *pathId = model.file.fullServicePath?:@"";
        NSString *pathDisplay = model.file.fullPath?:@"";
        
        long long longModifiedTime = [model.file.lastModifiedDate timeIntervalSince1970]*1000;
        NSString *tenantName = [NXCommonUtils currentTenant];
        
        NSInteger operations = object.operations;
        [[NSTimeZone localTimeZone] secondsFromGMT];
        NSInteger offSet = [[NSTimeZone localTimeZone] secondsFromGMT]/60;
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/remoteView/repository", [NXCommonUtils currentRMSAddress]]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//        [request setValue:@"application/json" forHTTPHeaderField:@"consume"];
        
        NSDictionary *jsonDict = @{@"parameters":@{@"repoId":repoId,
                                                   @"pathId":pathId,
                                                   @"pathDisplay":pathDisplay,
                                                   @"offset":@(-offSet),
                                                   @"repoName":repoName,
                                                   @"repoType":repoType,
                                                   @"email":[NXLoginUser sharedInstance].profile.email,
                                                   @"tenantName":tenantName,
                                                   @"lastModifiedDate":@(longModifiedTime),
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
