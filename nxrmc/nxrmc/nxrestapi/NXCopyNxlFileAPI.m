//
//  NXCopyNxlFileAPI.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2021/4/9.
//  Copyright © 2021 nextlabs. All rights reserved.
//

#import "NXCopyNxlFileAPI.h"
#import "NXCopyNxlFileTransformModel.h"

@interface NXCopyNxlFileAPIRequest ()
@property(nonatomic, strong)NSString *fileName;
@end
@implementation NXCopyNxlFileAPIRequest
-(NSURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NSAssert([object isKindOfClass:[NXCopyNxlFileTransformModel class]], @"NXWorkSpaceUploadFileRequest object should be NXCopyNxlFileTransformModel");
        NXCopyNxlFileTransformModel *transformModel = (NXCopyNxlFileTransformModel *)object;
        self.fileName = transformModel.fileName;
        NSDictionary *parametersDict = nil;;
        NSDictionary *scrDict = nil;
        NSDictionary *destDict = nil;
        
        switch (transformModel.fileSourceType) {
            case NXFileSourceTypeEnterWorkspace:
            case NXFileSourceTypeMyvault:
            {
                scrDict =
                    @{@"filePathId":transformModel.filePathId,@"spaceType":transformModel.sourceSpaceType};
            }
                break;
            case NXFileSourceTypeProject:
            case NXFileSourceTypeSharedWorkspace:
            case NXFileSourceTypePersonalRepository:
            {
                scrDict = @{@"filePathId":transformModel.filePathId,@"spaceType":transformModel.sourceSpaceType,@"spaceId":transformModel.scrSpaceId};
            }
                break;
            case NXFileSourceTypeSharedWithMe:
            {
                scrDict = @{@"transactionId":transformModel.transactionId,@"spaceType":transformModel.sourceSpaceType};
            }
                break;
           
            default:
                break;
        }
       
        
        switch (transformModel.fileDestSpaceType) {
            case NXFileDestSpaceTypeMyvault:
            {
                destDict = @{@"fileName":transformModel.fileName,@"spaceType":transformModel.destSpaceType};
            }
                break;
            case NXFileDestSpaceTypeEnterWorkspace:
            {
                destDict = @{@"fileName":transformModel.fileName,@"parentPathId":transformModel.destSpacePath,@"spaceType":transformModel.destSpaceType};
                   
            }
                break;
            case NXFileDestSpaceTypeProject:
            case NXFileDestSpaceTypePersonalRepository:
            case NXFileDestSpaceTypeSharedWorkspace:
            {
                destDict = @{@"fileName":transformModel.fileName,@"parentPathId":transformModel.destSpacePath,@"spaceType":transformModel.destSpaceType,@"spaceId":transformModel.destSpaceId};
                break;
                default:
                break;
            }
        }
//        parametersDict = @{
//            @"parameters":@{@"src":scrDict,@"dest":destDict,@"overwrite":[NSNumber numberWithBool:transformModel.overwrite]}};
        
        // now server only support overwrite
        parametersDict = @{
            @"parameters":@{@"src":scrDict,@"dest":destDict,@"overwrite":[NSNumber numberWithBool:YES]}};
        NSData *parameterData = [parametersDict toJSONFormatData:nil];
        self.reqRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/transform/transfer", [NXCommonUtils currentRMSAddress]]]];
        self.reqRequest.HTTPMethod = @"POST";
        [self.reqRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [self.reqRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [self.reqRequest setHTTPBody:parameterData];

        
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        
        NXCopyNxlFileAPIResponse *response = [[NXCopyNxlFileAPIResponse alloc] init];
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
//- (Analysis)analysisReturnData {
//    Analysis analysis = (id)^(NSString *returnData, NSError* error){
//        NXCopyNxlFileAPIResponse *response = [[NXCopyNxlFileAPIResponse alloc]init];
//        NSData *resultData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
//        if (resultData) {
//            [response analysisResponseStatus:resultData];
//        }
//        return response;
//    };
//    return analysis;
//}
@end

@implementation NXCopyNxlFileAPIResponse
- (NSData*)resultData
{
    if (!_fileData)
    {
        _fileData = [[NSData alloc] init];
    }
    
    return _fileData;
}
@end
