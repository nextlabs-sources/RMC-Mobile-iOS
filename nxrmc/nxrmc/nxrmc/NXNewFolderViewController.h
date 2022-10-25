//
//  NXNewFolderViewController.h
//  nxrmc
//
//  Created by nextlabs on 12/15/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXFileBase.h"
#import "NXProjectFolder.h"

@interface NXNewFolderViewController : UIViewController

@property(nonatomic, strong) NXFileBase *parentFolder;

@property (nonatomic ,copy) void(^createFolderFinishedBlock) (NXFileBase *newFolder, NSError*error);

@end
