//
//  NXProjectFile.h
//  nxrmc
//
//  Created by EShi on 1/20/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXFile.h"
#import "NXProjectFileOwnerModel.h"

@interface NXProjectFile : NXFile
@property(nonatomic, strong) NSNumber *projectId;
@property(nonatomic, strong) NSString *Id;
@property(nonatomic, strong) NSString *duid;
@property(nonatomic, strong) NSString *creationTime;
@property(nonatomic, strong) NSArray *rights;
@property(nonatomic, strong) NSString *fileType;
@property(nonatomic, strong) NSString *parentPath;
@property(nonatomic, strong) NXProjectFileOwnerModel *projectFileOwner;
@property(nonatomic, strong) NSMutableArray<NSNumber *> *sharedWithProjectList;
@property(nonatomic, assign) BOOL isShared;
@property(nonatomic, assign) BOOL revoked;
-(instancetype)initFileFromResultProjectFileListDic:(NSDictionary*)dic;
-(instancetype)initFileFromResultProjectUploadFileDic:(NSDictionary *)dic;
-(instancetype)initFileFromResultProjectFileMetadataDic:(NSDictionary *)dic;
@end
