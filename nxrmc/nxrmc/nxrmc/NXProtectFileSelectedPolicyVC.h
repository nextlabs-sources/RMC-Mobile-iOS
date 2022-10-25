//
//  NXProjectFileSelectedPolicyVC.h
//  nxrmc
//
//  Created by Sznag on 2020/12/28.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXProtectFileAfterSelectedLocationVC.h"
NS_ASSUME_NONNULL_BEGIN
@class NXProjectModel;
@class NXFolder;
@interface NXProtectFileSelectedPolicyVC : UIViewController
@property(nonatomic, strong)NSArray *selectedFileArray;
@property(nonatomic, strong)NSString *savePath;
@property(nonatomic, strong)NSArray *selectedClassifiations;
@property(nonatomic, strong)NXProjectModel *targetProject;
@property(nonatomic, assign)NXProtectSaveLoactionType locationType;
@property(nonatomic, strong)NXFolder *saveFolder;
@end

NS_ASSUME_NONNULL_END
