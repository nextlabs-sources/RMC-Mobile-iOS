//
//  NXHomeHeaderView.h
//  nxrmc
//
//  Created by nextlabs on 1/12/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NXHomeReposTableView.h"
@class NXProcessPercentView;
@interface NXHomeHeaderCell : UITableViewCell

@property(nonatomic, weak, readonly) NXHomeReposTableView *repoTableView;
@property(nonatomic, weak, readonly) UILabel *nameLabel;
@property(nonatomic, weak, readonly) UIImageView *avaterImageView;
@property(nonatomic ,strong)NXProcessPercentView *percentView;

@end
