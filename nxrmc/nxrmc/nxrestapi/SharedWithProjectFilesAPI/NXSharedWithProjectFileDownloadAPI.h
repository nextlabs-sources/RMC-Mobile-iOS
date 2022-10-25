//
//  NXSharedWithProjectFileDownloadAPI.h
//  nxrmc
//
//  Created by 时滕 on 2020/1/10.
//  Copyright © 2020 nextlabs. All rights reserved.
//
#import "NXSuperRESTAPI.h"
#import "NXSharedWithProjectFile.h"

NS_ASSUME_NONNULL_BEGIN
@interface  NXSharedWithProjectFileDownloadRequest : NXSuperRESTAPIRequest<NXRESTAPIScheduleProtocol>

@property (nonatomic,strong) NXSharedWithProjectFile *sharedWithProjectfile;
@property (nonatomic,assign) BOOL forViewer;
@property(nonatomic, assign) NSUInteger downloadSize;

- (instancetype)initWithDownloadSize:(NSUInteger)downloadSize isForView:(BOOL)forView;
-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;

@end

@interface  NXSharedWithProjectFileDownloadResponse : NXSuperRESTAPIResponse

@property (nonatomic,strong)NSData *fileData;
@property (nonatomic,strong)NXSharedWithProjectFile *file;

@end

NS_ASSUME_NONNULL_END
