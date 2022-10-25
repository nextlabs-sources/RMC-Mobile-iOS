//
//  NXProtectFileSelectLocationVC2.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/6/2.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class NXFileBase;
typedef NS_ENUM(NSInteger,NXSelectProtectMenuType) {
    NXSelectProtectMenuTypeRepo,
    NXSelectProtectMenuTypeSkyDRM,
    NXSelectProtectMenuTypeSkyDRMAndStopLeft
};
@interface NXProtectFileSelectLocationVC : UIViewController
@property(nonatomic, strong)NSArray *selectFilesArray;
@property(nonatomic, strong)NXFileBase *targetFolder;
@property(nonatomic, assign)NXSelectProtectMenuType selectType;
@end
NS_ASSUME_NONNULL_END
