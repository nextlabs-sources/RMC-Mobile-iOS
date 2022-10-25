//
//  NXNXLFileSharingSelectVC.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/12/12.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class NXFileBase;
@class NXProjectModel;
@interface NXNXLFileSharingSelectVC : UIViewController
@property(nonatomic, strong)NXFileBase *fileItem;
@property(nonatomic, strong,nullable)NXProjectModel *fromProjectModel;
@property(nonatomic, strong)NSArray *sharedProjects;
@property(nonatomic, weak)id delegate;
@end
@protocol NXNXLFileSharingSelectVCDelegate <NSObject>

- (void)successShareFileToTargets:(NSArray *)array;

@end
NS_ASSUME_NONNULL_END
