//
//  NXFileMarker.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 8/22/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXFileBase.h"

typedef void(^markFileCompleteBlock)(NXFileBase *file);
typedef void(^unmarkFileCompleteBlock)(NXFileBase *file);
typedef void(^removeFavFileCompleteBlock)(NXFileBase *file, NSError *error);
typedef void(^getAllFavFileCompleteBlock)(NSArray *fileListArray, NSError *error);

@interface NXFileMarker : NSObject

- (void)markFileAsFav:(NXFileBase *)file withCompleton:(markFileCompleteBlock)completion;
- (void)unmarkFileAsFav:(NXFileBase *)file withCompletion:(unmarkFileCompleteBlock)completion;
- (void)removeFileFromFavList:(NXFileBase *)file withCompletion:(removeFavFileCompleteBlock)completion;
- (NSArray *)allFavFileList;
- (NSArray *)allFavFileListInMydrive;
- (NSArray *)allFavFileItemsInMyVault;
- (void)getAllFavFileListFromNetWorkWithCompletion:(getAllFavFileCompleteBlock)completion;

-(void)startSyncFavFromRMS;
- (void)stopSyncFavFromRMS;
@end
