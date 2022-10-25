//
//  NXSharingRepositoryAPI1.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2019/12/6.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXRestAPI.h"
#import "NXSuperRESTAPI.h"
#import "NXFileBase.h"


NS_ASSUME_NONNULL_BEGIN

@interface NXSharingProjectFileModel : NSObject
@property(nonatomic, strong) NXFileBase *file;
@property(nonatomic, strong) NSArray *recipients;
@property(nonatomic, strong) NSString *comment;
@property(nonatomic, strong) NXProjectModel *projectModel;
@end


@interface NXSharingProjectFileRequest : NXSuperRESTAPIRequest
@end

@interface NXSharingProjectFileResponse : NXSuperRESTAPIResponse
@property(nonatomic, strong) NSString *duid;
@property(nonatomic, strong) NSString *filePathId;
@property(nonatomic, strong) NSString *fileName;
@property(nonatomic, strong) NSString *transactionId;
@property(nonatomic, strong) NSArray *alreadySharedList;
@property(nonatomic, strong) NSArray *anewSharedList;
@end


NS_ASSUME_NONNULL_END
