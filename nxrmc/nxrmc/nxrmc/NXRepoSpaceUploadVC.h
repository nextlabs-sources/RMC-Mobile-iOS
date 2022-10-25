//
//  NXRepoSpaceUploadVC.h
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/3/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXFileOperationPageBaseVC.h"

@class NXFileBase;

@interface NXRepoSpaceUploadVC : NXFileOperationPageBaseVC

@property(nonatomic, strong) NXFileBase *fileItem;
@property(nonatomic, strong) NXFileBase *folder; //folder which will be uploaded;

@end
