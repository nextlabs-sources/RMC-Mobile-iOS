//
//  NXWorkSpaceVC.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/9/23.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXWorkSpaceFileNavVC.h"
NS_ASSUME_NONNULL_BEGIN
@interface NXWorkSpaceVC : UIViewController
@property(nonatomic, strong)NXWorkSpaceFileNavVC *fileNavVC;
//- (void)clickWorkSpaceDown:(id)sender;
@end

NS_ASSUME_NONNULL_END
