//
//  NXSharedWithMeDownloadFileAPI.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 12/06/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"
#import "NXSharedWithMeFile.h"

@interface  NXSharedWithMeDownloadFileAPIRequest : NXSuperRESTAPIRequest<NXRESTAPIScheduleProtocol>

@property (nonatomic,strong) NXSharedWithMeFile *sharedWithMefile;
@property (nonatomic,assign) BOOL forViewer;
@property(nonatomic, assign) NSUInteger downloadSize;

- (instancetype)initWithDownloadSize:(NSUInteger)downloadSize isForView:(BOOL)forView;
-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;

@end

@interface  NXSharedWithMeDownloadFileAPIResponse : NXSuperRESTAPIResponse

@property (nonatomic,strong)NSData *fileData;
@property (nonatomic,strong)NXSharedWithMeFile *file;

@end
