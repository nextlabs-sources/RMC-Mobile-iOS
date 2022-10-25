//
//  NXSkyDrmBox.h
//  nxrmc
//
//  Created by nextlabs on 10/25/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXServiceOperation.h"
#import "NXRepositoryModel.h"

@interface NXSkyDrmBox : NSObject<NXServiceOperation> {
    NXFileBase *_overWriteFile;
    NXFileBase* _curFolder;
    NSString* _userId;
}

- (instancetype)initWithUserId:(NSString *)userID repoModel:(NXRepositoryModel *)repoModel; //TBD
- (instancetype)initWithUserId:(NSString *)userID;
@end
