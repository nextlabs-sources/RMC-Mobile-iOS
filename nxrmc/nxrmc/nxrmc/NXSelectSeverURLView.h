//
//  NXSelectSeverURLView.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2018/6/26.
//  Copyright © 2018年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^cancelBlock)(void);
typedef void(^doneBlock)(NSString *urlStr);
@interface NXSelectSeverURLView : UIView
@property (nonatomic, strong) NSArray *allURLs;
@property (nonatomic, strong) NSString *selectURL;
@property (nonatomic, copy) cancelBlock cancelHandle;
@property (nonatomic, copy) doneBlock doneHandle;
@end
