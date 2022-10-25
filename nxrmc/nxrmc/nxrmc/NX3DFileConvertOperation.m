//
//  NX3DFileConvertOperation.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 7/4/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NX3DFileConvertOperation.h"

#import "NXFileBase.h"
#import "NXRMCDef.h"
#import "NXConvert3DFileAPI.h"

typedef NS_ENUM(NSInteger, NX3DFileConvertOperationState) {
    NX3DFileConvertState = 1,
    NX3DFileConvertStateFinished,
};

@interface NX3DFileConvertOperation ()

@property(nonatomic, strong) NXFileBase *file;
@property(nonatomic, strong) NSString *fileName;
@property(nonatomic, strong) NSData *originData;

@property(nonatomic, strong) NSData *resultData;

@property(nonatomic, strong) NXConvert3DFileRequest *request;

@end

@implementation NX3DFileConvertOperation
- (instancetype)initWithFile:(NSString *)fileName data:(NSData *)data name:(NXFileBase *)fileItem {
    if (self = [super init]) {
        _file = fileItem;
        _originData = data;
        _fileName = fileName;
    }
    return self;
}

- (void)executeTask:(NSError **)error
{
    NXConvert3DFileRequest *request = [[NXConvert3DFileRequest alloc] init];
    self.request = request;
    
    NXConvert3DFileModel *model = [[NXConvert3DFileModel alloc]init];
    model.fileName = self.fileName;
    model.originData = self.originData;
    WeakObj(self);
    [request requestWithObject:model withUploadProgress:self.progerss downloadProgress:nil Completion:^(NXSuperRESTAPIResponse *response, NSError *error) {
        StrongObj(self);
        if (error) {
            self.resultData = nil;
        } else {
            NXConvert3DFileResponse *responseModel = (NXConvert3DFileResponse *)response;
            self.resultData = responseModel.data;
        }
        [self finish:error];
    }];
}

- (void)workFinished:(NSError *)error
{
    if (self.completion) {
        self.completion(self.file, self.resultData, error);
    }
}

- (void)cancelWork:(NSError *)cancelError
{
    [self.request cancelRequest];
    NSError *error = [[NSError alloc]initWithDomain:NX_ERROR_NXOPERATION_DOMAIN code:NXRMC_ERROR_CODE_CANCEL userInfo:nil];
    self.completion(self.file, self.resultData, error);
}

@end
