//
//  NXAddLocalNXLFileToOtherSpaceAPI.m
//  nxrmc
//
//  Created by Sznag on 2022/2/23.
//  Copyright © 2022 nextlabs. All rights reserved.
//

#import "NXAddLocalNXLFileToOtherSpaceAPI.h"
#import "NXCopyNxlFileTransformModel.h"
#import "NXMultipartFormDataMaker.h"
@interface NXAddLocalNXLFileToOtherSpaceAPIRequest ()
@property(nonatomic, strong)NSString *fileName;
@end

@implementation NXAddLocalNXLFileToOtherSpaceAPIRequest
-(NSURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NSAssert([object isKindOfClass:[NXCopyNxlFileTransformModel class]], @"NXWorkSpaceUploadFileRequest object should be NXCopyNxlFileTransformModel");
        NXCopyNxlFileTransformModel *transformModel = (NXCopyNxlFileTransformModel *)object;
        self.fileName = transformModel.fileName;
        NSDictionary *parametersDict = nil;
        NSDictionary *destDict = nil;
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
//            @"parameters":@{@"dest":destDict,@"overwrite":[NSNumber numberWithBool:transformModel.overwrite]}};
        // now server only support overwrite
        parametersDict = @{
            @"parameters":@{@"dest":destDict,@"overwrite":[NSNumber numberWithBool:YES]}};
        NSData *parameterData = [parametersDict toJSONFormatData:nil];
        self.reqRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/transform/transfer", [NXCommonUtils currentRMSAddress]]]];
        self.reqRequest.HTTPMethod = @"POST";
        [self.reqRequest setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
        [self.reqRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        NSData *fileData = [NSData dataWithContentsOfFile:transformModel.fileLocalPath];
        [self.reqRequest setValue:[NSString stringWithFormat:@"multipart/form-data;boundary=%@",@"boundaryLine"] forHTTPHeaderField:@"Content-Type"];
        NXMultipartFormDataMaker *formDataMaker = [[NXMultipartFormDataMaker alloc] initWithBoundary:@"boundaryLine"];
        [formDataMaker addFileParameter:@"file" fileName:transformModel.fileName fileData:fileData];
        [formDataMaker addTextParameter:@"API-input" parameterJsonDataValue:parameterData];
        [formDataMaker endFormData];
        [self.reqRequest setHTTPBody:[formDataMaker getFormData]];
    

    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        
        NXAddLocalNXLFileToOtherSpaceAPIResponse *response = [[NXAddLocalNXLFileToOtherSpaceAPIResponse alloc] init];
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
@implementation NXAddLocalNXLFileToOtherSpaceAPIResponse
- (NSData*)resultData
{
    if (!_fileData)
    {
        _fileData = [[NSData alloc] init];
    }
    
    return _fileData;
}
@end


