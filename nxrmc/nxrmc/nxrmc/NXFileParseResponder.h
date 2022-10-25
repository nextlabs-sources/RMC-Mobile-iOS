//
//  NXFileParseResponder.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 7/12/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NXFileBase.h"
typedef NS_ENUM(NSInteger, NXFileContentType){
    NXFileContentTypeNotSupport = 1,
    NXFileContentTypeNormal,
    NXFileContentTypeMedia,
    NXFileContentTypePDF,
    NXFileContentType3D,
    NXFileContentType3DNeedConvert,
    NXFileContentTypeRemoteView,

};

@class NXFileParseResponder;
typedef void(^parseFileCompletion)(NXFileParseResponder *fileParseResponder, NXFileBase *file, UIView *renderView, NSError *error);
typedef void(^getSnapShotCompletionBlock)(id image);

@interface NXFileParseResponder : NSObject
- (void)parseFile:(NXFileBase *)file withCompleteBlock:(parseFileCompletion)completion;
- (void)snapShot:(getSnapShotCompletionBlock)block;
- (void)addOverlay:(UIView *)overLay;
- (void)closeFile;
- (void)pauseMediaFile;
@property(nonatomic, strong) NXFileParseResponder *nextResponder;
@property(nonatomic, strong) NSError *defaultError;
@property(nonatomic, assign) NXFileContentType contentType;
@end
