//
//  NXPhotoNavigationController.h
//  xiblayout
//
//  Created by nextlabs on 10/18/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^completeBlock)(BOOL isCanceled);

@interface NXPhotoNavigationController : UINavigationController

@property(nonatomic, strong)completeBlock completionblock;

@end
