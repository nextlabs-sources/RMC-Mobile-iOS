//
//  NXSharingRepositoryAPI.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 7/5/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"
#import "NXFileBase.h"
@class NXLFileValidateDateModel;
@interface NXSharingRepositoryReqModel : NSObject
@property(nonatomic, strong) NXLRights *rights;
@property(nonatomic, strong) NXFileBase *file;
@property(nonatomic, strong) NXLFileValidateDateModel *validateDateModel;
@property(nonatomic, strong) NSArray *watermarkArray;
@property(nonatomic, strong) NSArray *recipients;
@property(nonatomic, strong) NSString *comment;
@end


@interface NXSharingRepositoryRequest : NXSuperRESTAPIRequest

@end

@interface NXSharingRepositoryResponse : NXSuperRESTAPIResponse
@property(nonatomic, strong) NSString *duid;
@property(nonatomic, strong) NSString *transactionId;
@property(nonatomic, strong) NSArray *alreadySharedList;
@property(nonatomic, strong) NSArray *anewSharedList;
@end
