//
//  NXRepoInfoViewController.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 5/4/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXRepositoryModel.h"

@interface NXRepositoryInfoViewController : UIViewController
- (instancetype)initWithRepository:(NXRepositoryModel *)repo;
@end
