//
//  NXPhotoSelecter.h
//  xiblayout
//
//  Created by nextlabs on 10/18/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, NXPhotoSelectType){
    NXPhotoSelectTypeCamera = 1, // camera can take video and photo
    NXPhotoSelectTypeCameraPhotoOnly, //camera only take photo
    NXPhotoSelectTypeCameraVideoOnly, //camera only take video
    NXPhotoSelectTypePhotoLibrary,  // local album contain video and photos.
    NXPhotoSelectTypePhotoLibraryPhotoOnly, //local album only contain photo.
    NXPhotoSelectTypePhotoLibraryVideoOnly, //local album only contain video.
};

typedef NS_ENUM(NSInteger, NXPhotoSelectRetunType) {
    NXPhotoSelectRetunTypeDefault = 0,
    NXPhotoSelectRetunTypeFilePath = 1,
};

typedef void (^selectedblock)(NSArray *selectedItems, BOOL authen);
typedef NS_ENUM(NSInteger, NXPhotoSelectorType){
    NXPhotoSelectorTypeSingleSelect = 1,
    NXPhotoSelectorTypeMultiSelect = 2,
};
@interface NXPhotoSelector : NSObject

@property(nonatomic, assign) NXPhotoSelectRetunType type;
@property(nonatomic, strong) NSString *selectedFileLocationFolder;
@property(nonatomic, assign, readonly) NXPhotoSelectorType selectType; //default YES.

- (void)showPhotoPicker:(NXPhotoSelectType)type complete:(selectedblock)completion;
- (instancetype) initWithSelectedType:(NXPhotoSelectorType) selectType;
@end
