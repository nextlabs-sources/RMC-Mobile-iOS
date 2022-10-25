//
//  NXUpdateProjectSharingRecipientsAPI.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/12/10.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXUpdateProjectSharingRecipientsAPI.h"
@implementation NXUpdateSharingRecipientsModel
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
@implementation NXUpdateProjectSharingRecipientsRequest

- (NSMutableURLRequest *)generateRequestObject:(id)object
{
    if (!self.reqRequest) {
        NSAssert([object isKindOfClass:[NXUpdateSharingRecipientsModel class]], @"NXUpdateSharingRecipientsRequest should use NXUpdateSharingRecipientsReqModel model");
        NXUpdateSharingRecipientsModel *reqModel = (NXUpdateSharingRecipientsModel *)object;
        
        NSString *comment = reqModel.comment;
        
        NSDictionary *jsonDict = @{@"parameters":@{@"newRecipients":reqModel.addedRecipients?:@[], @"removedRecipients":reqModel.removedRecipients?:@[], @"comment":comment?:@""}};
        NSData *jsonData = [jsonDict toJSONFormatData:nil];
        
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/share/%@/update", [NXCommonUtils currentRMSAddress],((NXProjectFile *)reqModel.file).duid]]];
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
        NXUpdateProjectSharingRecipientsAPIResponse *response = [[NXUpdateProjectSharingRecipientsAPIResponse alloc] init];
        NSData *data = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        [response analysisResponseStatus:data];
        if (response.rmsStatuCode == NXRMS_ERROR_CODE_SUCCESS) {
            NSDictionary *jsonDict = [data toJSONDict:nil];
            NSDictionary *result = jsonDict[@"results"];
            response.addedRecipients = result[@"newRecipients"];
            response.removedRecipients = result[@"removedRecipients"];
            response.alreadySharingRecpipents = result[@"alreadySharedList"];
        }
        return  response;
    };
    return analysis;
}
@end
@implementation NXUpdateProjectSharingRecipientsAPIResponse

@end
