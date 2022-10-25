//
//  NXActionSheetItem.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 02/05/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class NXActionSheetItem;
@class NXCustomActionSheetWindow;

typedef void(^NXActionSheetItemHandler)(NXCustomActionSheetWindow *window);

@interface NXActionSheetItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *rightImage;
@property (nonatomic, strong) NSMutableArray *subItems;
@property (nonatomic, copy) NXActionSheetItemHandler action;

@property (nonatomic, copy) NSString *promptTitle;
@property (nonatomic, assign) BOOL shouldDisplayDividerLine;
@property (nonatomic, assign) BOOL isUnable;
+(instancetype)initWithTitle:(NSString *)title image:(UIImage *)image subItems:(NSMutableArray *)subItems action:(NXActionSheetItemHandler)handler;
+(instancetype)initWithTitle:(NSString *)title image:(UIImage *)image subItems:(NSMutableArray *)subItems andRightImage:(UIImage *)rightImage action:(NXActionSheetItemHandler)handler;

@end
