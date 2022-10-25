//
//  NXAddToProejctBaseVC.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/4/2.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXAddToProjectVC.h"
@class NXPreviewFileView;
@class NXProjectModel;
@class NXFolder;
@class NXFileBase;
@class NXLRights;
@class NXRepositoryModel;
@class NXProtectedFileListView;
@class NXAddFileSavePathView;
@interface NXAddToProjectBaseVC : UIViewController

@property (nonatomic, strong) UIScrollView *bgScrollView;
@property (nonatomic, strong) NXPreviewFileView *preview;
@property (nonatomic, strong) NXFileBase *folder;
@property (nonatomic, strong) UIView *specifyView;
@property (nonatomic, strong) UIButton *bottomBtn;
@property (nonatomic, strong) NXProjectModel *toProject;
@property (nonatomic, strong) NXRepositoryModel *toRepoModel;
@property (nonatomic, strong) NXFileBase *currentFile;
@property (nonatomic, strong) NSArray *currentClassifiations;
@property (nonatomic, strong) NXLRights *fileRights;
@property (nonatomic, strong) NSString *originalFileOwnerId;
@property (nonatomic, strong) NSString *originalFileDUID;
@property (nonatomic, assign) NXFileOperationType fileOperationType;
@property (nonatomic, assign) BOOL isLocalFile;
@property (nonatomic, strong) NXProtectedFileListView *fileListView;
@property (nonatomic, strong) NXAddFileSavePathView *locationView;
@end

