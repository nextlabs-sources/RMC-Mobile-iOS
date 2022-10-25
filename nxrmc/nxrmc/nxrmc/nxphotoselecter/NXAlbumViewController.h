//
//  NXAlbumViewController.h
//  xiblayout
//
//  Created by nextlabs on 10/17/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, NXAlbumViewControllerSelectedType)
{
    NXAlbumViewControllerSelectedTypeSingleSelected = 1,
    NXAlbumViewControllerSelectedTypeMultiSelected,
};

//for now only support filter photos.
typedef NS_ENUM(NSUInteger, NXAlbumSourceType) {
    NXAlbumSourceTypePhotoLibrary, // all resources type
    NXAlbumSourceTypePhotos, // only contain photos
};

@interface NXAlbumViewController : UIViewController

@property(nonatomic, assign, readonly) NXAlbumViewControllerSelectedType selectedType;
@property(nonatomic, assign) NXAlbumSourceType sourceType; //default NXAlbumSourceTypePhotoLibrary

- (instancetype)initWithSelectedType:(NXAlbumViewControllerSelectedType)selectedType;

@end
