//
//  NXPhotoViewController.h
//  xiblayout
//
//  Created by nextlabs on 10/17/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NXPhotoTool.h"

@interface NXPhotoViewController : UIViewController
@property(nonatomic, strong) NXPhotoAlbum *album;
@property(nonatomic, assign) BOOL multSelected;
@end
