//
//  NXProjectMemberDetailViewController.h
//  nxrmc
//
//  Created by xx-huang on 06/02/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXBaseViewController.h"
#import "NXProjectMemberModel.h"
#import "NXProjectModel.h"

@interface NXProjectMemberDetailViewController : NXBaseViewController
@property (nonatomic, assign) BOOL isOwerByMe;

- (void)configureProjectMemberModel:(NXProjectMemberModel *)memberModel;
@end
