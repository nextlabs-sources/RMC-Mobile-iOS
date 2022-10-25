//
//  NXVaultManagePeopleVC.h
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/4/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXMyVaultFile.h"

#import "NXFileOperationPageBaseVC.h"

@interface NXVaultManagePeopleVC : NXFileOperationPageBaseVC

@property(nonatomic, strong) NXMyVaultFile *fileItem;

@end
