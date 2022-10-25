//
//  NXConvert3DFileRequest.h
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 7/4/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

@interface NXConvert3DFileModel : NSObject

@property(nonatomic, strong) NSString *fileName;
@property(nonatomic, strong) NSData *originData;

@end

@interface NXConvert3DFileRequest : NXSuperRESTAPIRequest

@end

@interface NXConvert3DFileResponse : NXSuperRESTAPIResponse

@property(nonatomic, strong) NSString *convertedFilePath;
@property(nonatomic, strong) NSData *data;

@end
