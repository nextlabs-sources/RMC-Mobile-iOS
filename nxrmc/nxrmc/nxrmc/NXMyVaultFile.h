//
//  NXMyVaultFile.h
//  nxrmc
//
//  Created by EShi on 12/29/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXFile.h"
#import "NXWebFileManager.h"
@class NXLFileValidateDateModel;
@interface NXMyVaultFileCustomMetadata : NSObject<NSCopying,NSCoding>
@property(nonatomic, strong) NSString *sourceRepoName;
@property(nonatomic, strong) NSString *sourceRepoType;
@property(nonatomic, strong) NSString *sourceFilePathDisplay;
@property(nonatomic, strong) NSString *SourceFilePathId;
@property(nonatomic, strong) NSString *sourceRepoId;
@end


@interface NXMyVaultFile : NXFile<NXWebFileDownloadItemProtocol>
@property(nonatomic, strong) NSArray<NSString *>*sharedWith;
@property(nonatomic, strong) NSNumber *sharedOn; //millisecond
@property(nonatomic, strong) NSString *duid;
@property(nonatomic, assign) BOOL isShared;
@property(nonatomic, assign) BOOL isRevoked;
@property(nonatomic, assign) BOOL isDeleted;
@property(nonatomic, strong) NSString *displayName;
@property(nonatomic, strong) NSArray<NSString *> *recipients;
@property(nonatomic, strong) NSArray<NSString *> *rights;
@property(nonatomic, strong) NSNumber *protectedOn;
@property(nonatomic, strong) NSString *fileLink;
@property(nonatomic, strong) NXLFileValidateDateModel *validateFileModel;
@property(nonatomic, strong) NXMyVaultFileCustomMetadata *metaData;
- (instancetype)initWithDictory:(NSDictionary*)dic;
@end
