//
//  NXWorkSpaceReclassifyFileAPI.h
//  nxrmc
//
//  Created by Eren on 2019/8/28.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

NS_ASSUME_NONNULL_BEGIN
@class NXWorkSpaceFile;
@interface NXWorkSpaceReclassifyFileModel : NSObject
@property(nonatomic, strong) NXFile *file;
@property(nonatomic, strong) NSDictionary *fileTags;
@property(nonatomic, strong) NSString *parentPathId;
@end
@interface NXWorkSpaceReclassifyFileRequest : NXSuperRESTAPIRequest

@end

@interface NXWorkSpaceReclassifyFileResponse : NXSuperRESTAPIResponse
@property (nonatomic, strong)NXWorkSpaceFile *workSpaceItem;
@end

NS_ASSUME_NONNULL_END
