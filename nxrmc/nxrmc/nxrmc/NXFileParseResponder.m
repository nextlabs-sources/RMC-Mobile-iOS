//
//  NXFileParseResponder.m
//  nxrmc
//
//  Created by Eren (Teng) Shi on 7/12/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXFileParseResponder.h"
#import "NXRMCDef.h"

@implementation NXFileParseResponder
- (instancetype)init
{
    self = [super init];
    if (self) {
        _defaultError = [[NSError alloc] initWithDomain:NX_ERROR_RENDER_FILE code:NXRMC_ERROR_CODE_RENDER_FAILED userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_LOAD_FILE_FAIL", nil)}];
    }
    return self;
}
- (void)parseFile:(NXFileBase *)file withCompleteBlock:(parseFileCompletion)completion
{
    NSError *error = [[NSError alloc] initWithDomain:NX_ERROR_RENDER_FILE code:NXRMC_ERROR_CODE_RENDER_FILE_NOT_SUPPORT userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_HINT_USER_MESSAGE", nil)}];
    completion(self, file, nil, error);
}

- (void)snapShot:(getSnapShotCompletionBlock)block
{
    block(nil);
}

- (void)addOverlay:(UIView *)overLay
{
}

- (void)closeFile
{
}
- (void)pauseMediaFile {
    
}
@end
