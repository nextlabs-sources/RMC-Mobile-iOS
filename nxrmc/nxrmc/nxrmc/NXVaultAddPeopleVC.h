//
//  NXVaultAddPeopleVC.h
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/4/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXFileOperationPageBaseVC.h"

@class NXMyVaultFile;

@interface NXVaultAddPeopleVC : NXFileOperationPageBaseVC

@property(nonatomic,strong)NXMyVaultFile *fileItem;

@end
