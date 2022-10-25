//
//  NXFavoriteUnMarkFilesAsFavoriteAPI.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 21/08/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXFavoriteUnMarkFilesAsFavoriteAPI.h"

@implementation NXFavoriteUnMarkFilesAsFavoriteAPIRequest

/**
 Request Object Format Is Just Like Follows:
 {
     "parameters":{
         "files":[
         {
         "pathId":"id:bDWMOKRPeTAAAAAAAAAACA",
         "pathDisplay":"/MyDocuments/Engine.doc"
         },
         {
         "pathId":"id:bDWMOKRPeTAAAA56789ACA",
         "pathDisplay":"/MyDocuments/Motors.doc"
         }
         ]
     }
 }
*/

-(NSURLRequest *)generateRequestObject:(id)object
{
    if (self.reqRequest == nil)
    {
        NXFileBase *fileBase = (NXFileBase *)object;
        if (fileBase.sorceType == NXFileBaseSorceTypeMyVaultFile) {
            NXRepositoryModel *myDrive = [[NXLoginUser sharedInstance].myRepoSystem getNextLabsRepository];
            fileBase.repoId = myDrive.service_id;
        }
      
        NSString *pathId = fileBase.fullServicePath;
        NSString *pathDisplay = fileBase.fullPath;
        
        NSError *error;
        NSDictionary *jDict = @{@"parameters":@{@"files":@[@{@"pathId":pathId,@"pathDisplay":pathDisplay}]}};
        
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:jDict options:NSJSONWritingPrettyPrinted error:&error];
        
        NSURL *apiURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/rs/favorite/%@",[NXCommonUtils currentRMSAddress],fileBase.repoId]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        [request setHTTPMethod:@"DELETE"];
        [request setHTTPBody:bodyData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        self.reqRequest = request;
    }
    return self.reqRequest;
}

/**
 {
 "statusCode":200,
 "message":"Files successfully unmarked as favorite",
 "serverTime":1474591551519
 }
*/

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        
        NXFavoriteUnMarkFilesAsFavoriteAPIResponse *response = [[NXFavoriteUnMarkFilesAsFavoriteAPIResponse alloc] init];
        NSData *contentData = nil;
        
        if ([returnData isKindOfClass:[NSString class]])
        {
            contentData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        }
        else
        {
            contentData =(NSData*)returnData;
        }
        
        if (contentData)
        {
            [response analysisResponseStatus:contentData];
        }
        
        return response;
    };
    
    return analysis;
}
@end

@implementation NXFavoriteUnMarkFilesAsFavoriteAPIResponse
@end
