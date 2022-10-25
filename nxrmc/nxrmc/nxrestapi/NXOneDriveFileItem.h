//
//  NXOneDriveFileItem.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 26/12/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NXOneDriveFileItem : NSObject <NSCopying,NSCoding>
@property (nonatomic,strong) NSString * fileId;
@property (nonatomic,strong) NSString * createdDateTime;
@property (nonatomic,assign) long size;
@property (nonatomic,strong) NSString * lastModifiedDateTime;
@property (nonatomic,strong) NSString * name;
@property (nonatomic,strong) NSString * downloadUrl;
@property (nonatomic,assign) BOOL folderYes;
- (instancetype)initWithDictionary:(NSDictionary*)dict;
@end
