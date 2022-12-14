//
//  NXSharePointFolder.h
//  nxrmc
//
//  Created by ShiTeng on 15/5/28.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import "NXFileBase.h"
#import "NXFolder.h"

typedef enum{
    kSPNormalFolder = 1,
    kSPDocList,
    kSPSite,
}SPFolderType; 

@interface NXSharePointFolder : NXFolder

@property(nonatomic) SPFolderType folderType;
@property(nonatomic, strong) NSString* ownerSiteURL;
@end
