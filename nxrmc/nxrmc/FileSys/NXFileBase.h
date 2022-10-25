//
//  NXFileProtocol.h
//  nxrmc
//
//  Created by Kevin on 15/5/7.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^queryLastModifiedDateCompBlock)(NSDate *lastModifiedDate,NSError *error);

@class NXFileBase;

//for favorite and offline.
@interface NXCustomFileList : NSObject<NSCoding>

- (void) addNode:(NXFileBase *)node;
- (void) removeNode:(NXFileBase *)node;
- (NSArray *) allNodes;
- (BOOL) containsObject:(NXFileBase *)node;
- (NSInteger) count;
- (NXFileBase *) objectAtIndex:(NSInteger)index;
- (NSUInteger) IndexOfObject:(NXFileBase *) node;
@end

typedef NS_ENUM(NSInteger, NXFileBaseSorceType)
{
    NXFileBaseSorceTypeUnknown = 0,
    NXFileBaseSorceTypeRepoFile = 1,
    NXFileBaseSorceTypeMyVaultFile = 2,
    NXFileBaseSorceTypeLocal = 3,
    NXFileBaseSorceTypeProject = 4,
    NXFileBaseSorceType3rdOpenIn = 5,
    NXFileBaseSorceTypeShareWithMe = 6,
    NXFileBaseSorceTypeWorkSpace = 7,
    NXFileBaseSorceTypeSharedWithProject = 8,
    NXFileBaseSorceTypeLocalFiles = 9,
    NXFileBaseSorceTypeSharedWorkspaceFile = 10
    
};

@interface  NXFileBase: NSObject <NSCoding, NSCopying>
@property(nonatomic, assign) NXFileBaseSorceType sorceType;
@property(nonatomic, strong) NSString *repoId;
@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong) NSString* fullPath;  // format: /xxxx/xxxx/xx.pdf
@property(nonatomic, strong) NSString* fullServicePath;  // dropbox, /xxx/xxx, onedrive: abdfadf
@property(nonatomic, strong) NSString *SPSiteId;
@property(nonatomic, strong) NSString *localPath;   // the file path which is strore on device
@property(nonatomic, strong) NSString* lastModifiedTime;
@property(nonatomic) long long size;
@property(nonatomic, strong) NSDate * refreshDate;
@property(nonatomic, strong) NSDate * lastModifiedDate;
@property(nonatomic, strong) NSDate * creationDate;
@property(nonatomic, weak) NXFileBase* parent;
@property(nonatomic, strong) NXFileBase *strongRefParent; // the strong ref parent is used in getAllFilesInFolder, the child file need keep strong ref of there parents. In case dead ref, must use folder copy to set strongRefParent value
@property(nonatomic,) BOOL isRoot;
@property(nonatomic,) BOOL isSelected;
//this two property to define which service this file belong, rootFolder have null value for those.
@property(nonatomic, strong) NSString *serviceAlias;
@property(nonatomic, strong) NSString *serviceAccountId;
@property(nonatomic, strong) NSNumber *serviceType;

@property(nonatomic,) BOOL isFavorite;
@property(nonatomic,) BOOL isOffline;
@property(nonatomic, strong) NXCustomFileList* favoriteFileList;  //for file directory cache, only root folder have this property.
@property(nonatomic, strong) NXCustomFileList* offlineFileList;   //only root folder

- (id)initWithFileBaseSourceType:(NXFileBaseSorceType )type;

-(void) addChild: (NXFileBase*) child;
-(void) removeChild: (NXFileBase*) child;
-(NSArray*) getChildren;

- (NXFileBase *) ancestor;

- (void) setIsFavorite:(BOOL)isFavorite;

- (void) setIsOffline:(BOOL)isOffline;

- (void)queryLastModifiedDate:(queryLastModifiedDateCompBlock)compBlock;
@end
