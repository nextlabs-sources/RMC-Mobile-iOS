//
//  NXFilesInfo.h
//  nxrmc
//
//  Created by Kevin on 15/5/11.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NXBoundService+CoreDataClass.h"



typedef NS_ENUM(NSInteger, NXUploadType)
{
    NXUploadTypeNormal = 0,    //normal upload, upload a file. if file(same name)exist in server, the uploaded file will be renamed, both files exist,
    NXUploadTypeOverWrite,//overwrite upload, uoload a file. if file(same name)exist in server, the exist file will be replaced by new uploaded file, only uploaded file existed.
    //TBD add other situation eg, when after protect normal file, delete the normal file, only nxl file will existed in server.
    NXUploadTypeNXLFile = 4
};
@protocol NXServiceOperationDelegate;
@class NXFileBase;
@protocol NXServiceOperation <NSObject>
@required
-(BOOL) getFiles:(NXFileBase*)folder;
-(BOOL) cancelGetFiles:(NXFileBase*)folder;


-(BOOL) downloadFile:(NXFileBase*)file size:(NSUInteger)size;
-(BOOL) cancelDownloadFile:(NXFileBase*)file;

-(BOOL) getUserInfo;
-(BOOL) cancelGetUserInfo;

-(void) setDelegate: (id<NXServiceOperationDelegate>) delegate;
-(BOOL) isProgressSupported;

-(void) setAlias:(NSString *) alias;
-(NSString *) getServiceAlias;

//@required -(BOOL) rangeDownloadFile:(NXFileBase *)file withSize:(NSUInteger)length toPath:(NSString *)dstPath;
//@required -(BOOL) cancelRangeDownloadFile:(NXFileBase *)file;
@optional
-(BOOL) downloadFile:(NXFileBase *)file size:(NSUInteger)size downloadType:(NSInteger)downloadType;
-(BOOL) deleteFileItem:(NXFileBase*)file;
-(BOOL) addFolder:(NSString *)folderName toPath:(NXFileBase *)parentFolder;

/**
 *  upload file to service
 *  filename : name of new uploading file.
 *  folder: where the file to upload.
 *  srcPath: local file path.
 *  overWriteFile: if user select NXUploadTypeOverWrite, this will be overwrite by new uploaded file. if select others ,this parameter is useless.
 *
 */
-(BOOL) uploadFile:(NSString*)filename toPath:(NXFileBase*)folder fromPath:(NSString *)srcPath uploadType:(NXUploadType) type overWriteFile:(NXFileBase *)overWriteFile;
-(BOOL) cancelUploadFile:(NSString*)filename toPath:(NXFileBase*)folder;

-(BOOL) getMetaData:(NXFileBase*)file;
-(BOOL) cancelGetMetaData:(NXFileBase*)file;
@end


@protocol NXServiceOperationDelegate <NSObject>

@optional -(void)getFilesFinished:(NSArray*) files error: (NSError*)err;
@optional -(void)getAllFiles:(NSArray *) files fromFolder:(NXFileBase *) folder error:(NSError *) error;
@optional -(void)deleteItemFinished:(NSError *)error;
@optional -(void)addFolderFinished:(NXFileBase *)fileItem error:(NSError *)error;
@optional -(void)serviceOpt:(id<NXServiceOperation>) serviceOpt getFilesFinished:(NSArray *) files error:(NSError *) err;

@optional -(void)downloadFileFinished:(NXFileBase *)file fileData:(NSData *)fileData error:(NSError *)error;
@optional -(void)downloadFileProgress:(CGFloat) progress forFile:(NSString*)servicePath;

@optional -(void)uploadFileFinished:(NSString*)servicePath fromPath:(NSString*)localCachePath error:(NSError*)err;
@optional -(void)uploadFileFinished:(NXFileBase *)fileItem fromLocalPath:(NSString *)localCachePath error:(NSError *)error; // new interface
@optional -(void)uploadFileProgress:(CGFloat)progress forFile:(NSString*)servicePath fromPath:(NSString*)localCachePath;

@optional -(void)getMetaDataFinished:(NXFileBase*)metaData error:(NSError*)err;

@optional -(void) getUserInfoFinished:(NSString *) userName userEmail:(NSString *) email totalQuota:(NSNumber *) totalQuota usedQuota:(NSNumber *) usedQuota error:(NSError *) error;

@end
