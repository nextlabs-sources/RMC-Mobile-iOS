//
//  NXGoogleDriveFileListQuery.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 18/07/2017.
//  Copyright © 2017 Stepanoval (Xinxin) Huang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NXGoogleDriveFileListQuery :NSObject<NSCopying,NSSecureCoding>

@property (nonatomic, copy, nullable) NSString *corpora;
@property (nonatomic, copy, nullable) NSString *corpus;
@property (nonatomic, assign) BOOL includeTeamDriveItems;
@property (nonatomic, copy, nullable) NSString *orderBy;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, copy, nullable) NSString *pageToken;
@property (nonatomic, copy, nullable) NSString *q;
@property (nonatomic, copy, nullable) NSString *spaces;
@property (nonatomic, assign) BOOL supportsTeamDrives;
@property (nonatomic, copy, nullable) NSString *teamDriveId;
@property (nonatomic, copy, nullable) NSString *fields;

+ (instancetype)query;

@end

NS_ASSUME_NONNULL_END
