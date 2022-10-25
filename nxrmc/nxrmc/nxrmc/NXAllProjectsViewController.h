//
//  NXAllProjectsViewController.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 30/10/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXFileSort.h"
typedef NS_ENUM(NSInteger, NXAllProjectsVCShowType){
  NXAllProjectsVCShowTypeFromHome,
  NXAllProjectsVCShowTypeFromProject
};
@class NXProjectModel;
@interface NXAllProjectsViewController : UIViewController
@property(nonatomic, assign)NXAllProjectsVCShowType showType;
@property(nonatomic, strong)NXProjectModel *fromProjectModel;
@property(nonatomic, assign) NXSortOption sortOption;
- (void)showProjectFilesPageWithModel:(NXProjectModel *)currentModel;
@end
