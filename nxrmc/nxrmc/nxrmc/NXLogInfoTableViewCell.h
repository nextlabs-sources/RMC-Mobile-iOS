//
//  NXLogInfoTableViewCell.h
//  nxrmc
//
//  Created by helpdesk on 10/4/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NXNXLFileLogModel;
@interface NXLogInfoTableViewCell : UITableViewCell
@property(nonatomic, strong)NXNXLFileLogModel *model;
@end
