//
//  NXProjectFileManageShareVC.h
//  nxrmc
//
//  Created by Sznag on 2020/2/11.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXFileOperationPageBaseVC.h"
@class NXFileBase;
@class NXProjectModel;
@interface NXProjectFileManageShareVC : NXFileOperationPageBaseVC
@property(nonatomic, strong) NXFileBase *fileItem;
@property(nonatomic, strong) NXProjectModel *fromProjectModel;
@end
