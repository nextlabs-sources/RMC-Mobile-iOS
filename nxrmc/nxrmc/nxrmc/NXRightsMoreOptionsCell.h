//
//  NXRightsMoreOptionsCell.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/6/13.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NXRightsCellModel;
typedef void(^SwitchActionBlock)(BOOL active);
@interface NXRightsMoreOptionsCell : UITableViewCell
@property(nonatomic, strong) SwitchActionBlock actionBlock;
@property(nonatomic, strong) NXRightsCellModel *model;
@end

