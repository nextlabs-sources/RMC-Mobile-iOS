//
//  NXMessageView.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 5/4/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NXMessageViewManagerType){
    NXMessageViewManagerTypeGreen = 1,
    NXMessageViewManagerTypeWhite,
};

@interface NXMessageViewManager : NSObject
+ (void) showMessageViewWithTitle:(NSString *)title details:(NSString *)details appendInfo:(NSString *)appendInfo image:(UIImage *)image type:(NXMessageViewManagerType)type;
+ (void) showMessageViewWithTitle:(NSString *)title details:(NSString *)details appendInfo:(NSString *)appendInfo image:(UIImage *)image dismissAfter:(NSTimeInterval)afterSecond type:(NXMessageViewManagerType)type;
+ (void) showMessageViewWithTitle:(NSString *)title details:(NSString *)details appendInfo:(NSString *)appendInfo appendInfo2:(NSString *)appendInfo2 image:(UIImage *)image type:(NXMessageViewManagerType)type;
+ (void) showMessageViewWithTitle:(NSString *)title details:(NSString *)details appendInfo:(NSString *)appendInfo appendInfo2:(NSString *)appendInfo2 image:(UIImage *)image dismissAfter:(NSTimeInterval)afterSecond type:(NXMessageViewManagerType)type;

@end
