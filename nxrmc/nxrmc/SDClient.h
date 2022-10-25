//
//  SDClient.h
//  nxrmc
//
//  Created by nextlabs on 10/24/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXFileBase.h"

@class SDMetadata;
@protocol SDClientDelegate;
@class NXLoginUser;

@interface SDClient : NSObject

@property(nonatomic, weak) id<SDClientDelegate> delegate;

- (instancetype)initWithUser:(NXLoginUser *)user;

- (NSInteger)requestCount;

- (void)cancelAllRequests;

- (void)loadMemadata:(NSString *)path recursive:(BOOL)recursive;
- (BOOL)cancelLoadMetadata:(NSString *)path;

- (void)downloadFile:(NSString *)path length:(NSUInteger)length intoPath:(NSString *)destPath;
- (void)downloadFile:(NSString *)path intoPath:(NSString *)destPath;
- (void)downloadFile:(NSString *)path;
- (BOOL)cancelFileLoad:(NSString *)path;

- (void)uploadfile:(NSString *)filename fromPath:(NSString *)srcPath toPath:(NSString *)parentFolder overWriteFile:(NSString *)filePath;
- (BOOL)cancelFileUpload:(NSString *)srcpath;

- (void)createFolder:(NSString *)name underParent:(NXFileBase *)parentFolder;
- (void)deletePath:(NSString *)path;
- (void)searchPath:(NSString *)path keywords:(NSString *)keyword;

- (void)getRepositoryInfo;
@end

@protocol SDClientDelegate <NSObject>

@optional
- (void)client:(SDClient *)client loadedMetaData:(SDMetadata *)metaData error:(NSError *)error;

- (void)client:(SDClient *)client downloadedFile:(NSString *)path metadata:(SDMetadata *)metadata error:(NSError *)error;
- (void)client:(SDClient *)client downloadedContent:(NSData *)content metadata:(SDMetadata *)metadata error:(NSError *)error;
- (void)client:(SDClient *)client loadProgress:(float)progress forFile:(NSString *)path;

- (void)client:(SDClient *)client uploadFile:(NSString *)destpath fromPath:(NSString *)srcpath metadata:(SDMetadata *)metadata error:(NSError *)error;
- (void)client:(SDClient *)client uploadProgress:(float)progress forFile:(NSString *)destpath fromPath:(NSString *)srcpath;

- (void)client:(SDClient*)client createdFolder:(SDMetadata*)folder;
- (void)client:(SDClient*)client createFolderFailedWithError:(NSError*)error;

- (void)client:(SDClient*)client deletedPath:(NSString *)path;
- (void)client:(SDClient*)client deletePathFailedWithError:(NSError*)error;


- (void)client:(SDClient *)client loadedSearchResults:(NSArray *)searchResults forPath:(NSString *)path keywords:(NSString *)keyword;

- (void)client:(SDClient *)client loadedSharedLink:(NSString *)link forFile:(NSString *)file;

- (void)client:(SDClient *)client getRepositoryInfo:(NSString *)userName userEmail:(NSString *)userEmail totalQuota:(NSNumber *)totalQuota usedQuota:(NSNumber *)usedQuota error:(NSError *)error;

@end
