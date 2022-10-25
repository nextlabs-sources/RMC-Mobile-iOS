//
//  NXReAddFileToProjectVC.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/3/18.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXAddToProjectVC.h"

@class NXFileBase;;
@class NXProjectModel;
@class NXProjectFolder;
@class NXFolder;
@interface NXReAddFileToProjectVC : UIViewController

@property (nonatomic, strong) NXFileBase *currentFile;
@property (nonatomic, strong) NXProjectModel *toProject;
@property (nonatomic, strong) NSArray *currentClassifiations;
@property (nonatomic, strong) NXFolder *folder;
@property (nonatomic, strong) NSString *originalFileOwnerId;
@property (nonatomic, strong) NSString *originalFileDUID;
@property (nonatomic, assign) NXFileOperationType fileOperationType;
@end


