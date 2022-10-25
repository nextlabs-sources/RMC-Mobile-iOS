//
//  NXSharedWithMeFile.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 26/7/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import "NXFile.h"

@interface NXSharedWithMeFile : NXFile
@property (nonatomic ,strong) NSString *duid;
@property (nonatomic ,strong) NSString *spaceId;
@property (nonatomic ,strong) NSString *fileType;
@property (nonatomic ,strong) NSString *sharedBy;
@property (nonatomic ,strong) NSString *transactionId;
@property (nonatomic ,strong) NSString *transactionCode;
@property (nonatomic ,strong) NSString *sharedLink;
@property (nonatomic ,strong) NSString *comment;
@property (nonatomic, strong) NSNumber *lastModified;
@property (nonatomic ,assign) BOOL isOwner;
@property (nonatomic ,strong) NSArray<NSString *>*rights;
@property (nonatomic ,assign) NSTimeInterval sharedDate;
@property (nonatomic ,strong) NSString *shareWith;// need set nil after reshare
@property (nonatomic ,strong) NSString *reshareComment;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
-(instancetype)initFileFromResultSharedWithMeDownloadFileDic:(NSDictionary *)dict;

@end
