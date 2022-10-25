//
//  NXCopyNxlFileAPI.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2021/4/9.
//  Copyright © 2021 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

@interface NXCopyNxlFileAPIRequest : NXSuperRESTAPIRequest

@end
@interface NXCopyNxlFileAPIResponse : NXSuperRESTAPIResponse
@property (nonatomic,strong)NSData *fileData;
@property (nonatomic,strong)NSString *fileName;
@end

