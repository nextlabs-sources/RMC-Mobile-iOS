//
//  SDOperation.h
//  nxrmc
//
//  Created by nextlabs on 10/25/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SDMethodType) {
    SDMethodTypeList,
    SDMethodTypeSearch,
    SDMethodTypeDownload,
    SDMethodTypeRangeDownload,
    SDMethodTypeCreateFolder,
    SDMethodTypeUpload,
    SDMethodTypeDelete,
    SDMethodTypeCreateShareLink
};

@class NXSuperRESTAPIRequest;

@interface SDOperation : NSObject

@property(nonatomic, strong) NSString *path;
@property(nonatomic, assign) SDMethodType method;

@property(nonatomic, weak) NXSuperRESTAPIRequest *restAPI;

@property(nonatomic, strong) id userdata;

- (instancetype)initWithPath:(NSString *)path method:(SDMethodType)method api:(NXSuperRESTAPIRequest *)api;

@end
