//
//  NXPolicyTransformModel.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2022/5/20.
//  Copyright © 2022 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NXPolicyTransformModel : NSObject
@property (nonatomic,strong) NSString *scrFilePathId;
@property (nonatomic,strong) NSString *sourceSpaceType;
@property (nonatomic,strong) NSString *sourceSpaceId;
@property (nonatomic,strong) NSString *destSpaceType;
@property (nonatomic,strong) NSString *destMembershipId;
@property (nonatomic,strong) NSString *destFileName;
@property (nonatomic,strong) NSData *headerData;
@end

NS_ASSUME_NONNULL_END
