//
//  NXPhotoTool.h
//  xiblayout
//
//  Created by nextlabs on 10/14/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Photos/Photos.h>

@interface NXAssetItem : NSObject

@property(nonatomic, strong) PHAsset *asset;
@property(nonatomic, strong) NSString *localIdentifier;

@end

@interface NXPhotoItem : NXAssetItem

@end

@interface NXVideoItem : NXAssetItem

@end



@interface NXPhotoAlbum : NSObject

@property(nonatomic, strong) NSString *title;
@property(nonatomic, assign) NSInteger count; //count of photos in this album.

@property(nonatomic, strong) NXAssetItem *thumbAsset; //
@property(nonatomic, strong) PHAssetCollection *assetCollection;

@end

typedef NS_ENUM(NSInteger, NXPhotoToolWorkType){
    NXPhotoToolWorkTypeSingleSelected = 1,
    NXPhotoToolWorkTypeMultiSelected = 2,
};

typedef NS_ENUM(NSUInteger, NXPhotoToolSourceType) {
    NXPhotoToolSourceTypeLibrary,
    NXPhotoToolSourceTypePhotos,
};

@interface NXPhotoTool : NSObject

@property(nonatomic, strong) NSMutableDictionary *selectedDictionary;
@property(nonatomic, assign) NXPhotoToolWorkType workType;
@property(nonatomic, assign) NXPhotoToolSourceType sourceType;

+ (instancetype)sharedInstance;

+ (void)requestAuthorization:(void(^)(PHAuthorizationStatus status))handler;
+ (PHAuthorizationStatus)authorizationStatus;

- (NSArray<NXPhotoAlbum *> *)getAllAlbums;
//- (NSArray<NXAssetItem *> *)getItemswithAscending:(BOOL)ascending;
- (NSArray<NXAssetItem *> *)getItemsFromAlbum:(NXPhotoAlbum *)album ascending:(BOOL)ascending;

// select/unselect file item operations
- (void)selectItem:(NXAssetItem *)item;
- (void)unselectItem:(NXAssetItem *)item;
- (BOOL)isItemSelected:(NXAssetItem *)item;
- (void)removeAllSelectedItems;
- (NSDictionary *)getAllSelectedItems;

//image
- (void)requestImageFromPhoto:(NXAssetItem *)photo size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode synchronous:(BOOL) isSync  completion:(void (^)(UIImage *image, NSDictionary *info))completion;
- (void)requestImageFromPhoto:(NXAssetItem *)photo scale:(CGFloat)scale resizeMode:(PHImageRequestOptionsResizeMode)resizeMode synchronous:(BOOL) isSync  completion:(void (^)(UIImage *image, NSString *photoName))completion;

//video
- (void)requestExportSessionForVideo:(NXAssetItem *)video resultHandler:(void (^)(AVURLAsset *exportSession, NSURL *url, NSDictionary *info))resultHandler;

//save image
- (void)saveImageToAlbum:(UIImage *)image completion:(void (^)(BOOL success, NXPhotoItem *photo))completion;

//save video
- (void)saveVideoToAlbum:(NSURL *)url completion:(void (^)(BOOL success, NXVideoItem *video))completion;

@end
