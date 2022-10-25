//
//  NXRepoTableViewCell.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/9/16.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>


@class NXRepositoryModel;
@interface NXRepoTableViewCell : UITableViewCell
@property(nonatomic, strong) NXRepositoryModel *model;
@end


