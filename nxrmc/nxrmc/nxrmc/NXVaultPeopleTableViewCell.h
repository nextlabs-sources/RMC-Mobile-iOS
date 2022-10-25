//
//  NXVaultPeopleTableViewCell.h
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/4/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXRMCDef.h"

@interface NXVaultPeopleTableViewCell : UITableViewCell

@property(nonatomic, readonly, strong) UIView *accessoryButton;

@property(nonatomic, copy) ClickActionBlock clickActionBlock;
@property(nonatomic, strong) NSString *model; //email address

@end
