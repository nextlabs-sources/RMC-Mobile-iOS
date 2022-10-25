//
//  NXPhotoTool.m
//  xiblayout
//
//  Created by nextlabs on 10/14/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXPhotoTool.h"
#import "NXRMCDef.h"

#define kCustomAlbumName [[NSBundle mainBundle].infoDictionary valueForKey:(__bridge NSString *)kCFBundleNameKey]

@implementation NXAssetItem

@end

@implementation NXPhotoItem

@end

@implementation NXVideoItem

@end

@implementation NXPhotoAlbum

@end

@implementation NXPhotoTool

static NXPhotoTool *sharedInstance = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NXPhotoTool alloc]init];
        sharedInstance.selectedDictionary = [NSMutableDictionary dictionary];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _workType = NXPhotoToolWorkTypeMultiSelected;
    }
    return self;
}


+ (void)requestAuthorization:(void(^)(PHAuthorizationStatus status))handler {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (handler) {
            handler(status);
        }
    }];
}

+ (PHAuthorizationStatus)authorizationStatus {
    return [PHPhotoLibrary authorizationStatus];
}

- (NSArray<NXPhotoAlbum *> *)getAllAlbums {
    
    NSMutableArray<NXPhotoAlbum *> *photoAblumArray = [NSMutableArray array];
    
    //获取所有智能相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL *stop) {
        NXPhotoAlbum *album = [[NXPhotoAlbum alloc] init];
        
        album.title = collection.localizedTitle;
        album.assetCollection = collection;
        NSArray<NXAssetItem *> *photos = [self getItemsFromAlbum:album ascending:NO];
        album.count = photos.count;
        
        if (photos.count) {
            album.thumbAsset = photos.lastObject;
            [photoAblumArray addObject:album];
        }
    }];
    
    //获取用户创建的相册
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        NXPhotoAlbum *album = [[NXPhotoAlbum alloc] init];
        album.title = collection.localizedTitle;
        album.assetCollection = collection;
        NSArray<NXAssetItem *> *photos = [self getItemsFromAlbum:album ascending:NO];
        album.count = photos.count;
        if (photos.count) {
            album.thumbAsset = [photos lastObject];
            [photoAblumArray addObject:album];
        }
    }];
    
    return photoAblumArray;
}

//- (NSArray<NXAssetItem *> *)getItemswithAscending:(BOOL)ascending {
//    NSMutableArray<NXAssetItem *> *photosArray = [NSMutableArray array];
//    
//    PHFetchOptions *option = [[PHFetchOptions alloc] init];
//    
//    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
//    
//    //photo resources
//    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:option];
//    [result enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NXPhotoItem *photo = [[NXPhotoItem alloc]init];
//        photo.localIdentifier = obj.localIdentifier;
//        [photosArray addObject:photo];
//    }];
//    
//    if (self.sourceType != NXPhotoToolSourceTypePhotos) {
//        //video resources
//        result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:option];
//        [result enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            NXVideoItem *photo = [[NXVideoItem alloc]init];
//            photo.localIdentifier = obj.localIdentifier;
//            [photosArray addObject:photo];
//            
//        }];
//        
//        //audio resources
//        result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:option];
//        [result enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            NXAssetItem *photo = [[NXVideoItem alloc]init];
//            photo.localIdentifier = obj.localIdentifier;
//            [photosArray addObject:photo];
//        }];
//    }
//    
//    return photosArray;
//}

// select/unselect file item operations
- (void)selectItem:(NXAssetItem *)item
{
    if (self.workType == NXPhotoToolWorkTypeSingleSelected) { // single selected can only selected one
        [self.selectedDictionary removeAllObjects];
    }
    [self.selectedDictionary setObject:item forKey:item.localIdentifier];
    if (self.workType == NXPhotoToolWorkTypeSingleSelected) {  // we need to un-selected not selected item, so do need reload data to refresh UI.
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PHOTO_SELECTED object:nil];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PHOTO_SELECTOR_STATE_CHANGE object:nil];
}
- (void)unselectItem:(NXAssetItem *)item
{
    [self.selectedDictionary removeObjectForKey:item.localIdentifier];
    if (self.workType == NXPhotoToolWorkTypeSingleSelected) {  // we need to un-selected not selected item, so do need reload data to refresh UI.
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PHOTO_SELECTED object:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PHOTO_SELECTOR_STATE_CHANGE object:nil];

}
- (BOOL)isItemSelected:(NXAssetItem *)item
{
    if (self.selectedDictionary[item.localIdentifier]) {
        return YES;
    }else{
        return NO;
    }
}
- (void)removeAllSelectedItems
{
    [self.selectedDictionary removeAllObjects];
}
- (NSDictionary *)getAllSelectedItems
{
    return self.selectedDictionary;
}

- (NSArray<NXAssetItem *> *)getItemsFromAlbum:(NXPhotoAlbum *)album ascending:(BOOL)ascending {
    NSMutableArray<NXAssetItem *> *photosArray = [NSMutableArray array];
    
    PHFetchResult *result = [self fetchAssetsInAssetCollection:album.assetCollection ascending:ascending];
    [result enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.mediaType == PHAssetMediaTypeImage) {
            NXPhotoItem *photo = [[NXPhotoItem alloc] init];
            photo.localIdentifier = obj.localIdentifier;
            photo.asset = obj;
            [photosArray addObject:photo];
        }
        
        //filter all other resources except images.
        if (self.sourceType != NXPhotoToolSourceTypePhotos) {
            if (obj.mediaType == PHAssetMediaTypeVideo) {
                NXVideoItem *video = [[NXVideoItem alloc] init];
                video.localIdentifier = obj.localIdentifier;
                video.asset = obj;
                [photosArray addObject:video];
            }
            
            if (obj.mediaType == PHAssetMediaTypeUnknown || obj.mediaType == PHAssetMediaTypeAudio) {
                NXAssetItem *video = [[NXAssetItem alloc] init];
                video.asset = obj;
                video.localIdentifier = obj.localIdentifier;
                [photosArray addObject:video];
            }
        }
    }];
    
    return photosArray;
}

//image
- (void)requestImageFromPhoto:(NXAssetItem *)photo size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode synchronous:(BOOL) isSync completion:(void (^)(UIImage *image, NSDictionary *info))completion {
    
    static PHImageRequestID requestID = -1;
    if (requestID >= 1 ) {
        [[PHCachingImageManager defaultManager] cancelImageRequest:requestID];
    }
    
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    
    option.resizeMode = resizeMode;
    option.networkAccessAllowed = YES;
    option.synchronous = isSync;
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    requestID = [[PHCachingImageManager defaultManager] requestImageForAsset:photo.asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey];
        if(downloadFinined && completion) {
            completion(image, info);
        }
    }];
}

- (void)requestImageFromPhoto:(NXAssetItem *)photo scale:(CGFloat)scale resizeMode:(PHImageRequestOptionsResizeMode)resizeMode synchronous:(BOOL) isSync  completion:(void (^)(UIImage *image, NSString *photoName))completion {
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = resizeMode;//控制照片尺寸
    option.networkAccessAllowed = YES;
    option.synchronous = isSync;
    NSString *photoName = nil;
    NSArray<PHAssetResource *> *resourceArray = [PHAssetResource assetResourcesForAsset:photo.asset];
    if (resourceArray.count > 1) {
        for (PHAssetResource *resource in resourceArray) {
            if (resource.type == PHAssetResourceTypePhoto) {
              photoName = resource.originalFilename;
            }
        }
    }else{
        PHAssetResource *resource = resourceArray.lastObject;
        photoName = resource.originalFilename;
    }
    if (@available(iOS 13.0, *)) {
        [[PHCachingImageManager defaultManager] requestImageDataAndOrientationForAsset:photo.asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, CGImagePropertyOrientation orientation, NSDictionary * _Nullable info) {
            BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
            if (downloadFinined && completion) {
               CGFloat sca = imageData.length/(CGFloat)UIImageJPEGRepresentation([UIImage imageWithData:imageData], 1).length;
               NSData *data = UIImageJPEGRepresentation([UIImage imageWithData:imageData], scale==1?sca:sca/2);
               completion([UIImage imageWithData:data], photoName);
            }
        }];
    }else {
        [[PHCachingImageManager defaultManager] requestImageDataForAsset:photo.asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
            if (downloadFinined && completion) {
                CGFloat sca = imageData.length/(CGFloat)UIImageJPEGRepresentation([UIImage imageWithData:imageData], 1).length;
                NSData *data = UIImageJPEGRepresentation([UIImage imageWithData:imageData], scale==1?sca:sca/2);
                completion([UIImage imageWithData:data], photoName);
            }
        }];
    }
    
}

//livephoto

- (void)requestLivePhotoFromPhoto:(NXAssetItem *)photo size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode synchronous:(BOOL) isSync  completion:(void (^)(PHLivePhoto *livePhoto, NSDictionary *info))completion {
    PHLivePhotoRequestOptions *option = [[PHLivePhotoRequestOptions alloc] init];
    option.networkAccessAllowed = YES;
    
    PHAssetImageProgressHandler handler = ^(double progress, NSError *__nullable error, BOOL *stop, NSDictionary *__nullable info) {
        NSLog(@"%f", progress);
    };
    option.progressHandler = handler;
    [[PHCachingImageManager defaultManager] requestLivePhotoForAsset:photo.asset targetSize:size contentMode:PHImageContentModeDefault options:option resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
        if (livePhoto && completion) {
            completion(livePhoto, info);
        }
    }];
}

//video
- (void)requestExportSessionForVideo:(NXAssetItem *)video resultHandler:(void (^)(AVURLAsset *exportSession,NSURL *url, NSDictionary *info))resultHandler {
    
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc]init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = YES;
    
    [[PHCachingImageManager defaultManager] requestAVAssetForVideo:video.asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            if ([asset isKindOfClass:[AVURLAsset class]]) {
                if (resultHandler) {
                    resultHandler((AVURLAsset *)asset,((AVURLAsset *)asset).URL, info);
                }
            }
        });
    }];
}

//save image
- (void)saveImageToAlbum:(UIImage *)image completion:(void (^)(BOOL success, NXPhotoItem *photo))completion {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusDenied) {
        if (completion) completion(NO, nil);
    } else if (status == PHAuthorizationStatusRestricted) {
        if (completion) completion(NO, nil);
    } else {
        __block NSString *assetId = nil;
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            assetId = [PHAssetCreationRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (!success) {
                if (completion) completion(NO, nil);
                return;
            }
            
            PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].lastObject;
            
            PHAssetCollection *desCollection = [self getDestinationCollection];
            if (!desCollection) completion(NO, nil);
            
            //save image 
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [[PHAssetCollectionChangeRequest changeRequestForAssetCollection:desCollection] addAssets:@[asset]];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                NXPhotoItem *item = [[NXPhotoItem alloc] init];
                item.asset = asset;
                item.localIdentifier = asset.localIdentifier;
                if (completion) completion(success, item);
            }];
        }];
    }
}

//get custom album.
- (PHAssetCollection *)getDestinationCollection {
    //
    PHFetchResult<PHAssetCollection *> *collectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collectionResult) {
        if ([collection.localizedTitle isEqualToString:kCustomAlbumName]) {
            return collection;
        }
    }
    //create custom album.
    __block NSString *collectionId = nil;
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        collectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:kCustomAlbumName].placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    if (error) {
        NSLog(@"create album %@ failed", kCustomAlbumName);
        return nil;
    }
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[collectionId] options:nil].lastObject;
}

//save video
- (void)saveVideoToAlbum:(NSURL *)url completion:(void (^)(BOOL success, NXVideoItem *video))completion {
    
}

#pragma mark - private method.

- (PHFetchResult *)fetchAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending {
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:NULL];
    return result;
}

@end
