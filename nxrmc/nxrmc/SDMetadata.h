//
//  SDMetadata.h
//  nxrmc
//
//  Created by nextlabs on 10/24/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NXMyDriveFileItem;
@class NXMyDriveUploadFileItem;
@interface SDMetadata : NSObject<NSCoding>

@property(nonatomic) BOOL isDirectory;
@property(nonatomic) long long fileSize;
@property(nonatomic) NSDate *lastmodifiedDate;
@property(nonatomic) NSString *filename;
@property(nonatomic) NSString *path; //display path.
@property(nonatomic) NSString *fileID; //path
@property(nonatomic) NSArray* contents;
- (instancetype)initWithItem:(NXMyDriveFileItem*)item;
- (instancetype)initWithUploadItem:(NXMyDriveUploadFileItem*)item;
//TBD other property.
@end
