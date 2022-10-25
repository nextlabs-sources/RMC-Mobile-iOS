//
//  NXFileParser.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 7/12/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NXFileBase.h"
#import "NXFileParseResponder.h"

typedef void(^getSnapShotCompBlock)(id image);

@class NXFileParser,NXLRights;

@protocol NXFileParserDelegate <NSObject>
- (void)NXFileParser:(NXFileParser *)fileParser didFinishedParseFile:(NXFileBase *)file resultView:(UIView *)resultView error:(NSError *)error;
- (void)NXFileParser:(NXFileParser *)fileParser didFinishedParseNXLFile:(NXFileBase *)nxlFile resultView:(UIView *)resultView rights:(NXLRights *)rights isSteward:(BOOL)isSteward stewardID:(NSString *)stewardID error:(NSError *)error;
@end



@interface NXFileParser : NSObject
@property(nonatomic, weak) id<NXFileParserDelegate>delegate;
@property(nonatomic, strong) NXFileBase *curFile;
@property(nonatomic, assign) NXFileContentType fileContentType;
- (void)parseFile:(NXFileBase *)file;
// NOTE: ALL the method file below must same with curFile, otherwise will return error
- (void)addOverlayer:(UIView *)overlay toFile:(NXFileBase *)file;
- (void)snapShot:(NXFileBase *)file compBlock:(getSnapShotCompBlock)block;
- (void)closeFile:(NXFileBase *)file;
- (void)pauseMediaFile:(NXFileBase *)file;


//  special for nxl file
@property(nonatomic, assign) BOOL isNXLFile;
@property(nonatomic, strong) NXLRights *fileRights;
@property(nonatomic, strong) NSString *stewardID;
@property(nonatomic, assign) BOOL isSteward;
@end
