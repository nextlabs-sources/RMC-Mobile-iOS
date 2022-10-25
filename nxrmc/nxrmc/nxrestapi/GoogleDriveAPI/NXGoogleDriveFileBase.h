//
//  NXGoogleDriveFileBase.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 18/07/2017.
//  Copyright © 2017 Stepanoval (Xinxin) Huang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NXGoogleDriveFileBase : NSObject

@property (nonatomic, copy, nullable) NSString *kind;
@property (nonatomic, copy, nullable) NSString *fileId;
@property (nonatomic, copy, nullable) NSString *name;
@property (nonatomic, copy, nullable) NSString *mimeType;
@property (nonatomic, copy, nullable) NSDate *lastModifiedTime;
@property (nonatomic, strong,nullable) NSNumber *size;
@property(nonatomic, strong, nullable) NSArray<NSString *> *parents;

@end

NS_ASSUME_NONNULL_END
