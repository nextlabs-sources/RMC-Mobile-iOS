//
//  NXMarkFavOrOffView.h
//  nxrmcUITest
//
//  Created by nextlabs on 11/9/16.
//  Copyright © 2016 zhuimengfuyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NXFileBase;

@interface NXMarkFavOrOffView : UIView

@property(nonatomic, strong) NXFileBase *model;
@property(nonatomic, assign) BOOL isFromFavoritePage;

@end
