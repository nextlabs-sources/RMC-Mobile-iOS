//
//  NXSharedWithProjectFile.h
//  nxrmc
//
//  Created by 时滕 on 2019/12/11.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXFile.h"
#import "NXProjectModel.h"

@interface NXSharedWithProjectFile : NXFile
@property (nonatomic ,strong) NSString *duid;
@property (nonatomic ,strong) NSString *spaceId;
@property (nonatomic ,strong) NSString *fileType;
@property (nonatomic ,strong) NSString *sharedBy;
@property (nonatomic, strong) NSString *sharedByProject;
@property (nonatomic ,strong) NSString *transactionId;
@property (nonatomic ,strong) NSString *transactionCode;
@property (nonatomic ,strong) NSString *sharedLink;
@property (nonatomic ,strong) NSString *comment;
@property (nonatomic ,assign) BOOL isOwner;
@property (nonatomic ,strong) NSArray<NSString *>*rights;
@property (nonatomic ,assign) NSTimeInterval sharedDate;
@property (nonatomic, strong) NSNumber *lastModified;
@property (nonatomic ,strong) NSString *shareWith;// need set nil after reshare
@property (nonatomic ,strong) NSString *reshareComment;
@property (nonatomic, strong) NXProjectModel *sharedProject;
- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
