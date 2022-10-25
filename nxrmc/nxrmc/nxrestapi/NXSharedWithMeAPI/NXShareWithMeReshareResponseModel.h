//
//  NXShareWithMeReshareResponseModel.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 27/7/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NXShareWithMeReshareResponseModel : NSObject <NSCopying>
@property (nonatomic, strong) NSString *freshTransactionId;// newTransactionId
@property (nonatomic, strong) NSString *sharedLink;
@property (nonatomic, strong) NSArray *alreadySharedList;
@property (nonatomic, strong) NSArray *freshSharedList;// newSharedList

- (instancetype)initWithNSDictionary:(NSDictionary *)dict;
@end
