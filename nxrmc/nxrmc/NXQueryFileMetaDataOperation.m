//
//  NXQueryFileMetaDataOperation.m
//  nxrmc
//
//  Created by EShi on 2/28/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXQueryFileMetaDataOperation.h"
#import "NXServiceOperation.h"
#import "NXFileBase.h"
#import "NXCommonUtils.h"

@interface NXQueryFileMetaDataOperation()<NXServiceOperationDelegate>
@property(nonatomic, strong) id<NXServiceOperation> serviceOperation;
@property(nonatomic, strong) NXFileBase *destFile;
@property(nonatomic, strong) NXFileBase *metaData;
@end

@implementation NXQueryFileMetaDataOperation
- (instancetype)initWithFile:(NXFileBase *)file repository:(NXRepositoryModel *)repoModel
{
    if(self = [super init]){
        _serviceOperation = [NXCommonUtils getServiceOperationFromRepoItem:repoModel];
        [_serviceOperation setDelegate:self];
        _destFile = file;
    }
    return self;
}

- (void)executeTask:(NSError **)error
{
    [self.serviceOperation getMetaData:self.destFile];
}

- (void)workFinished:(NSError *)error
{
    if (self.completion) {
        self.completion(self.metaData, error);
    }
}
- (void)cancelWork:(NSError *)cancelError
{
    [self.serviceOperation cancelGetMetaData:self.destFile];
}

#pragma mark - NXServiceOperationDelegate
-(void)getMetaDataFinished:(NXFileBase*)metaData error:(NSError*)err
{
    self.metaData = metaData;
    [self finish:err];
}
@end
