//
//  NXVaultManageViewController.h
//  nxrmc
//
//  Created by nextlabs on 1/3/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXFileOperationPageBaseVC.h"

@class NXMyVaultFile;

@interface NXVaultManageViewController : NXFileOperationPageBaseVC

@property(nonatomic, strong) NXMyVaultFile *fileItem;

@property(nonatomic ,copy) void(^manageRevokeFinishedBlock) (NSError*error);

@end
