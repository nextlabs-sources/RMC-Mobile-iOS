//
//  NXFileDownloadBaseOperation.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 20/10/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXFileBase.h"
#import "NXWebFileDownloadOperation.h"

@interface NXFileDownloadOperationFactory :NSObject
+ (id<NXWebFileDownloadOperation>)createWithFile:(NXFileBase *)file size:(NSUInteger)size downloadType:(NSInteger)downloadType;
@end
