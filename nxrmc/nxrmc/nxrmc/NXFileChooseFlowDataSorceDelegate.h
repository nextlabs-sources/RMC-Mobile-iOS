//
//  NXFileChooseFlowDataSorce.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 5/9/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXFolder.h"

typedef void(^NXFileChooseFlowGetFileListCompletion)(NSArray *fileList, NSError *error);
@protocol NXFileChooseFlowDataSorceDelegate <NSObject>
@optional
// for data sorce
- (void)fileListUnderFolder:(NXFolder *)parentFolder withCallBackDelegate:(id<NXFileChooseFlowDataSorceDelegate>)delegate;
- (NXFileBase *)queryParentFolderForFolder:(NXFileBase *)folder;
// for the caller
- (void)fileChooseFlowDidGetFileList:(NSArray *)fileList underParentFolder:(NXFolder *)parentFolder error:(NSError *)error;
@end
