//
//  NXSeverURLTableViewCell.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2018/6/27.
//  Copyright © 2018年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^editURLBlock)(NSString *currentUrlStr);
@interface NXSeverURLTableViewCell : UITableViewCell
@property (nonatomic, strong) NSString *urlStr;
@property (nonatomic, copy) editURLBlock editURLHandle;
@end
