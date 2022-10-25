//
//  NXSaveAsToLocalAPI.h
//  nxrmc
//
//  Created by Sznag on 2022/2/15.
//  Copyright © 2022 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface NXSaveAsToLocalAPIRequest: NXSuperRESTAPIRequest

@end
@interface NXSaveAsToLocalAPIResponse : NXSuperRESTAPIResponse
@property (nonatomic,strong,nullable)NSData *fileData;
@property (nonatomic,strong)NSString *fileName;
@end
NS_ASSUME_NONNULL_END
