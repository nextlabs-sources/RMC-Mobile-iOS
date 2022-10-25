//
//  NXHomeReposTableView.h
//  nxrmc
//
//  Created by nextlabs on 1/12/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NXHomeReposTableView : UITableView

@property(nonatomic, strong) NSArray *dataArray;

@property(nonatomic, strong) void(^selectBlock)(id);

@end
