//
//  NXSaveAsToLocalAPI.m
//  nxrmc
//
//  Created by Sznag on 2022/2/15.
//  Copyright © 2022 nextlabs. All rights reserved.
//

#import "NXSaveAsToLocalAPI.h"
#import "NXCopyNxlFileTransformModel.h"


@interface NXSaveAsToLocalAPIRequest ()
@property(nonatomic, strong)NSString *fileName;
@end

@implementation NXSaveAsToLocalAPIRequest
-(NSURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NSAssert([object isKindOfClass:[NXCopyNxlFileTransformModel class]], @"NXWorkSpaceUploadFileRequest object should be NXCopyNxlFileTransformModel");
        NXCopyNxlFileTransformModel *transformModel = (NXCopyNxlFileTransformModel *)object;
        self.fileName = transformModel.fileName;
        NSDictionary *parametersDict = nil;;
        switch (transformModel.fileSourceType) {
            case NXFileSourceTypeEnterWorkspace:
            case NXFileSourceTypeMyvault:
            {
                parametersDict = @{
                    @"parameters":@{@"src":@{@"fileName":transformModel.fileName,@"filePathId":transformModel.filePathId,@"spaceType":transformModel.sourceSpaceType},@"dest":@{@"spaceType":transformModel.destSpaceType}}};
            }
                break;
            case NXFileSourceTypeProject:
            case NXFileSourceTypeSharedWorkspace:
            case NXFileSourceTypePersonalRepository:
            {
                parametersDict = @{
                    @"parameters":@{@"src":@{@"fileName":transformModel.fileName,@"filePathId":transformModel.filePathId,@"spaceType":transformModel.sourceSpaceType,@"spaceId":transformModel.scrSpaceId},@"dest":@{@"spaceType":transformModel.destSpaceType}}};
            }
                break;
            case NXFileSourceTypeSharedWithMe:
            {
                parametersDict = @{
                    @"parameters":@{@"src":@{@"transactionCode":transformModel.transactionCode,@"transactionId":transformModel.transactionId,@"spaceType":transformModel.sourceSpaceType},@"dest":@{@"spaceType":transformModel.destSpaceType}}};
            }
                break;
           
            default:
                break;
        }
       
        
        NSData *parameterData = [parametersDict toJSONFormatData:nil];
        self.reqRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/transform/transfer", [NXCommonUtils currentRMSAddress]]]];
        self.reqRequest.HTTPMethod = @"POST";
        [self.reqRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [self.reqRequest setValue:@"application/json,application/octet-stream" forHTTPHeaderField:@"Accept"];
        [self.reqRequest setHTTPBody:parameterData];

    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        
        NXSaveAsToLocalAPIResponse *response = [[NXSaveAsToLocalAPIResponse alloc] init];
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
        }
       
        if(error){
            response.rmsStatuCode = error.code;
            response.fileData = nil;
        }else{
            response.fileData = contentData;
        }
        if(response.rmsStatuCode == -1){ // God RMS API, only return error status code, but no success status code -_-|||
            response.rmsStatuCode = 200;
        }
        response.fileName = self.fileName; // JUST FOR TEMP USE, need RMS header info
        
        return response;
        
    };
    
    return analysis;
}
@end
@implementation NXSaveAsToLocalAPIResponse
- (NSData*)resultData
{
    if (!_fileData)
    {
        _fileData = [[NSData alloc] init];
    }
    
    return _fileData;
}
@end
