//
//  NXFavoriteMarkFilesAsFavoriteAPI.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 21/08/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXFavoriteMarkFilesAsFavoriteAPI.h"

@implementation NXFavoriteMarkFilesAsFavoriteAPIRequest

/**
 Request Object Format Is Just Like Follows:
 {
     "parameters":{
         "files":[
             {
             "pathId":"id:bDWMOKRPeTAAAAAAAAAACA",
             "pathDisplay":"/MyDocuments/Engine.doc",
             "parentFileId": "id:Nf5wTXNQiIAAAAAAAAAA7g",
             "fileSize": 332,
             "fileLastModified": 1474590650465
             },
             {
             "pathId":"id:bDWMOKRPeTAAAA56789ACA",
             "pathDisplay":"/MyDocuments/Motors.doc",
             "parentFileId": "id:Nf5wTXNQiIAAAAAAAAAA7g"
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
        
        NSString *pathId = fileBase.fullServicePath;
        NSString *pathDisplay = fileBase.fullPath;
        
        NSString *parentPathId = nil;
        if (fileBase.sorceType == NXFileBaseSorceTypeMyVaultFile) {
            parentPathId = @"/nxl_myfault_nxl/";
            NXRepositoryModel *myDrive = [[NXLoginUser sharedInstance].myRepoSystem getNextLabsRepository];
            fileBase.repoId = myDrive.service_id;
        }else{
            NXFileBase *parentFile = [[NXLoginUser sharedInstance].myRepoSystem parentForFileItem:fileBase];
            parentPathId = parentFile.fullServicePath;
                
        }
        
     long long lastModifiedTime = ([fileBase.lastModifiedDate timeIntervalSince1970] *1000);
        
        if (lastModifiedTime == 0 && [fileBase isKindOfClass:[NXMyVaultFile class]]) {
            NXMyVaultFile *myvaultFile = (NXMyVaultFile *)fileBase;
            lastModifiedTime = (myvaultFile.sharedOn.longLongValue *1000);
        }
        
        NSError *error;
        NSDictionary *jDict = @{@"parameters":@{@"files":@[@{@"pathId":pathId,@"pathDisplay":pathDisplay,@"parentFileId":parentPathId,@"fileSize":[NSNumber numberWithLongLong:fileBase.size],@"fileLastModified":[NSNumber numberWithLongLong:lastModifiedTime]}]}};
        
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:jDict options:NSJSONWritingPrettyPrinted error:&error];
        NSURL *apiURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/rs/favorite/%@",[NXCommonUtils currentRMSAddress],fileBase.repoId]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:bodyData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        self.reqRequest = request;
    }
    return self.reqRequest;
}

/**
 Produces: application/json
 {
 "statusCode":200,
 "message":"Files successfully marked as favorite",
 "serverTime":1474591219931
 }
*/

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        
        NXFavoriteMarkFilesAsFavoriteAPIResponse *response = [[NXFavoriteMarkFilesAsFavoriteAPIResponse alloc] init];
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

@implementation NXFavoriteMarkFilesAsFavoriteAPIResponse
@end
