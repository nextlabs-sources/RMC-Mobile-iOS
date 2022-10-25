//
//  NXUpdateSharingRecipientsAPI.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 7/5/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXUpdateSharingRecipientsAPI.h"
@implementation NXUpdateSharingRecipientsReqModel
- (instancetype)initWithFile:(NXMyVaultFile *)file addedRecipients:(NSArray *)addedRecipients removedRecipients:(NSArray *)removedRecipients comment:(NSString *)comment
{
    if (self = [super init]) {
        _file = file;
        _addedRecipients = addedRecipients;
        _removedRecipients = removedRecipients;
        _comment = comment;
    }
    return self;
}
@end

@implementation NXUpdateSharingRecipientsRequest
- (NSMutableURLRequest *)generateRequestObject:(id)object
{
    if (!self.reqRequest) {
        NSAssert([object isKindOfClass:[NXUpdateSharingRecipientsReqModel class]], @"NXUpdateSharingRecipientsRequest should use NXUpdateSharingRecipientsReqModel model");
        NXUpdateSharingRecipientsReqModel *reqModel = (NXUpdateSharingRecipientsReqModel *)object;
        NSMutableArray *newRep = [NSMutableArray array];
        NSMutableArray *removeRep = [NSMutableArray array];
        
        for (NSString *email in reqModel.addedRecipients) {
            NSDictionary *node = @{@"email":email};
            [newRep addObject:node];
        }
        
        for (NSString *email in reqModel.removedRecipients) {
            NSDictionary *node = @{@"email":email};
            [removeRep addObject:node];
        }
        
        NSString *comment = reqModel.comment;
        
        NSDictionary *jsonDict = @{@"parameters":@{@"newRecipients":newRep, @"removedRecipients":removeRep, @"comment":comment?:@""}};
        NSData *jsonData = [jsonDict toJSONFormatData:nil];
        
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/share/%@/update", [NXCommonUtils currentRMSAddress], reqModel.file.duid]]];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:jsonData];
        self.reqRequest = request;
    }
    
    return (NSMutableURLRequest *)self.reqRequest;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError *error) {
        //restCode
        NXUpdateSharingRecipientsResponse *response = [[NXUpdateSharingRecipientsResponse alloc]init];
        NSData *data = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        [response analysisResponseStatus:data];
        if (response.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) {
            NSDictionary *jsonDict = [data toJSONDict:nil];
            NSDictionary *result = jsonDict[@"results"];
            response.addedRecipients = result[@"newRecipients"];
            response.removedRecipients = result[@"removedRecipients"];
        }
        return  response;
    };
    return analysis;
}
@end

@implementation NXUpdateSharingRecipientsResponse


@end
