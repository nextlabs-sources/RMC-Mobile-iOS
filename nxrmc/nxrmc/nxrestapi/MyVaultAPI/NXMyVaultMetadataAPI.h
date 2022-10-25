//
//  NXMyVaultMetadataAPI.h
//  nxrmc
//
//  Created by nextlabs on 1/17/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"
#import "NXMyVaultFile.h"
@class NXLFileValidateDateModel;
@interface NXMyVaultMetadataRequest : NXSuperRESTAPIRequest

@end

@interface NXMyVaultMetadataResponse : NXSuperRESTAPIResponse

@property(nonatomic, strong) NSString *filename;
@property(nonatomic, strong) NSString *fileLink;
@property(nonatomic, strong) NSNumber *protectedOn;
@property(nonatomic, strong) NSNumber *sharedOn;
@property(nonatomic, strong) NXLFileValidateDateModel *validateDateModel;
@property(nonatomic, strong) NSArray<NSString *> *recipients;
@property(nonatomic, strong) NSArray<NSString *> *rights;

@end
