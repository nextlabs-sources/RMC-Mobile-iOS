//
//  NXSharedWithProjectFileMatadataAPI.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/6/1.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface NXSharedWithProjectFileMatadataAPIRequest : NXSuperRESTAPIRequest

@end
@interface NXSharedWithProjectFileMatadataAPIResponse : NXSuperRESTAPIResponse
@property(nonatomic, strong)NXSharedWithProjectFile *fileItem;
@end
NS_ASSUME_NONNULL_END
