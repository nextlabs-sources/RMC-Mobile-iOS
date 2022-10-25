//
//  NXChangeServerURLView.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2018/4/25.
//  Copyright © 2018年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^onSaveClickHandle)(NSString *urlStr);
typedef void (^removeURLClickHandle)(NSString *urlStr);
typedef NS_ENUM(NSInteger,NXChangeServerURLViewType) {
    NXChangeServerURLViewTypeAddURL = 0,
    NXChangeServerURLViewTypeEditURL
};

@interface NXChangeServerURLView : UIView

@property (nonatomic, copy) onSaveClickHandle onSaveClickHandle;
@property (nonatomic, copy) removeURLClickHandle removeHandle;
@property (nonatomic, strong) NSString *urlStr;
@property (nonatomic, assign) NXChangeServerURLViewType changeType;
@property (nonatomic, assign) BOOL isRememberURL;
- (instancetype)initWithurlStr:(NSString *)urlStr InviteHander:(onSaveClickHandle)hander;
- (void)show;
- (void)close;
- (void)showErrorMessage;
- (void)showLoadingView;
- (void)hiddenLoadingView;
@end
