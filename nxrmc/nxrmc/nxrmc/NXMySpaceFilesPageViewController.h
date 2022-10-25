//
//  NXMySpaceFilesPageViewController.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2020/4/26.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NXMySpaceFilesPageSelectedType)
{
    NXMySpaceFilesPageSelectedTypeMyDrive = 0,
    NXMySpaceFilesPageSelectedTypeMyVault = 1,
};

NS_ASSUME_NONNULL_BEGIN

@interface NXMySpaceFilesPageViewController : UIViewController

@property (nonatomic,assign) NXMySpaceFilesPageSelectedType selectedType;

@end

NS_ASSUME_NONNULL_END
