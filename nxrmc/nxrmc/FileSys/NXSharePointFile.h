//
//  NXSharePointFile.h
//  nxrmc
//
//  Created by ShiTeng on 15/6/2.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import "NXFileBase.h"
#import "NXFile.h"

@interface NXSharePointFile : NXFile
@property(nonatomic, strong) NSString* ownerSiteURL;
@end
