//
//  NXSharedWithMeReshareProjectFileAPI.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2020/1/9.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXRestAPI.h"
#import "NXSuperRESTAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface NXSharedWithMeReshareProjectFileRequestModel : NSObject
@property (nonatomic, strong) NSString *transactionId;
@property (nonatomic, strong) NSString *transactionCode;
@property (nonatomic, strong) NSString *spaceId;
@property (nonatomic, strong) NSArray *recipients;
@property (nonatomic, strong) NSString *reshareComment;
@end

@interface NXSharedWithMeReshareProjectFileResponseModel : NSObject <NSCopying>
@property (nonatomic, strong) NSString *freshTransactionId;// newTransactionId
@property (nonatomic, strong) NSString *sharedLink;
@property (nonatomic, strong) NSArray *alreadySharedList;
@property (nonatomic, strong) NSArray *freshSharedList;// newSharedList

- (instancetype)initWithNSDictionary:(NSDictionary *)dict;
@end


@interface NXSharedWithMeReshareProjectFileAPIRequest : NXSuperRESTAPIRequest <NXRESTAPIScheduleProtocol>
-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;
@end
@class NXSharedWithMeReshareProjectFileResponseModel;
@interface NXSharedWithMeReshareProjectFileAPIResponse : NXSuperRESTAPIResponse
@property (nonatomic ,strong)NXSharedWithMeReshareProjectFileResponseModel *responseModel;
@end

NS_ASSUME_NONNULL_END
