//
//  NXSharedFilesWithProjectAPI.h
//  nxrmc
//
//  Created by 时滕 on 2019/12/11.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"
#import "NXSharedWithProjectFile.h"
NS_ASSUME_NONNULL_BEGIN

@interface NXSharedWithProjectFilesRequest : NXSuperRESTAPIRequest

@end

@interface NXSharedWithProjectFilesResponse : NXSuperRESTAPIResponse
@property(nonatomic, strong) NSArray<NXSharedWithProjectFile *> *itemsArray;
@end

NS_ASSUME_NONNULL_END
