//
//  NXSharingProjectFileToUserSelectVC.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2020/1/9.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NXFileBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface NXSharingProjectFileToUserSelectVC : UIViewController

@property(nonatomic, strong,nonnull) NXFileBase *currentFile;

@end

NS_ASSUME_NONNULL_END
