//
//  NXConvertFile.h
//  nxrmc
//
//  Created by helpdesk on 7/7/15.
//  Copyright (c) 2015 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^completionBlock)(NSString* filePath, NSError* error);

@protocol NXConvertFileDelegate;

typedef NS_ENUM(NSUInteger, NXConvertFileState) {
    NXConvertFileStateNotWork = 1,
    NXConvertFileStateConverting = 2,
};
@interface NXConvertFile : NSObject

@property(nonatomic, weak) id<NXConvertFileDelegate> delegate;
@property(nonatomic, strong) NSProgress *uploadProgress;
@property(nonatomic, assign) NXConvertFileState state;


- (void)convertFile:(int) agentId fileName: (NSString *)filename data:(NSData*)data toFormat: (NSString*) fmt isNxl: (BOOL) nxl completion:(completionBlock)block;

-(void) cancel;

@end

@protocol NXConvertFileDelegate <NSObject>

@optional
- (void) nxConvertFile:(NXConvertFile *) convertFile convertProgress:(NSNumber *)progress forFile:(NSString *)fileName;

@end
