//
//  NXBoxGetFileListRequest.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 12/7/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXBoxGetFileListAPI.h"

@implementation NXBoxGetFileListRequest
-(NSMutableURLRequest *)generateRequestObject:(id)object
{
    if (self.reqRequest == nil)
    {
        if (object)
        {
            NSString *fileId = (NSString *)object;
            NSString *fileListURL = [NSString stringWithFormat:@"https://api.box.com/2.0/folders/%@/items?fields=modified_at,size,name", fileId];
            NSURL *apiURL = [[NSURL alloc] initWithString:fileListURL];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
            [request setHTTPMethod:@"GET"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            self.reqRequest = request;
        }
    }
    
    return (NSMutableURLRequest *)self.reqRequest;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError *error){
        NXBoxGetFileListResponse *response = [[NXBoxGetFileListResponse alloc] init];
        if (error == nil) {
            NSError *convertError = nil;
            NSDictionary *fileListJSONDict = [returnData toJSONFormatDictionary:&convertError];
            if (convertError == nil) {
                NSArray *fileItemList = fileListJSONDict[@"entries"];
                if (fileItemList) {
                    for (NSDictionary *fileItem in fileItemList) {
                        NXFileBase *fileBase = nil;
//                        BOOL isFolder = NO;
                        if ([fileItem[@"type"] isEqualToString:@"folder"]) {
//                            isFolder = YES;
                            fileBase = [[NXFolder alloc] initWithFileBaseSourceType:NXFileBaseSorceTypeRepoFile];
                        }else if([fileItem[@"type"] isEqualToString:@"file"]) {
                            fileBase = [[NXFile alloc] initWithFileBaseSourceType:NXFileBaseSorceTypeRepoFile];
                        }
                        // fetch info
                        fileBase.name = fileItem[@"name"];
                        fileBase.fullServicePath = fileItem[@"id"];
                        fileBase.size = ((NSNumber *)fileItem[@"size"]).longLongValue;
                        NSString *updateTime = fileItem[@"modified_at"];
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZ"];
                        NSDate* lastModifydate = [dateFormatter dateFromString:updateTime];
                        NSString *lastModifydateString = [NSDateFormatter localizedStringFromDate:lastModifydate
                                                                                        dateStyle:NSDateFormatterShortStyle
                                                                                        timeStyle:NSDateFormatterFullStyle];
                        
                        fileBase.lastModifiedDate = lastModifydate;
                        fileBase.lastModifiedTime = lastModifydateString;
                        fileBase.serviceAccountId = self.repo.service_account_id;
                        fileBase.serviceType = self.repo.service_type;
                        fileBase.serviceAlias = self.repo.service_alias;
                        [response.fileListArray addObject:fileBase];
                    }
                }
            }
        }else if(error.code == 401){
            response.isAccessTokenExpireError = YES;
        }
        return response;
    };
    
    return analysis;
}


@end


@implementation NXBoxGetFileListResponse
- (NSMutableArray *)fileListArray {
    if (_fileListArray == nil) {
        _fileListArray = [[NSMutableArray alloc] init];
    }
    return _fileListArray;
}
@end
