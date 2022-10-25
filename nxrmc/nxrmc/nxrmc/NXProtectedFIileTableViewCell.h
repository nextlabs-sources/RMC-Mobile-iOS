//
//  NXProtectedFIileTableViewCell.h
//  nxrmc
//
//  Created by Sznag on 2020/12/27.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class NXFileBase;
@interface NXProtectedFIileTableViewCell : UITableViewCell
@property(nonatomic, strong)NXFileBase *model;
@end

NS_ASSUME_NONNULL_END
