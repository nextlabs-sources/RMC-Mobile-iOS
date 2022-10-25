//
//  NXProjectFolder.h
//  nxrmc
//
//  Created by EShi on 1/20/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXFolder.h"
@class NXProjectFileOwnerModel;
@interface NXProjectFolder : NXFolder
@property(nonatomic, strong) NSNumber *projectId;
@property(nonatomic, strong) NSString *Id;
@property(nonatomic, assign) BOOL folder;
@property(nonatomic, strong) NSString *creationTime;
@property(nonatomic, strong)  NSString *parentPath;
@property(nonatomic, strong) NXProjectFileOwnerModel *projectFileOwner;
-(instancetype)initFileFromResultProjectFileListDic:(NSDictionary*)dic;
@end
