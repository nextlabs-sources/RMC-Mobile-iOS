//
//  NXProjectFileOwnerModel.h
//  nxrmc
//
//  Created by helpdesk on 23/1/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NXProjectFileOwnerModel : NSObject <NSCopying>
@property (nonatomic, strong) NSString * displayName;
@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSNumber * userId;
@end
