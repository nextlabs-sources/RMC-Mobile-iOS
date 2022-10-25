//
//  NXMySpaceHomePageTableViewCell.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2020/4/23.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"
#import "NXMySpaceHomePageRepoModel.h"

@interface NXMySpaceHomePageTableViewCell : UITableViewCell

@property (nonatomic ,strong) NXMySpaceHomePageRepoModel *model;

- (void)setModel:(NXMySpaceHomePageRepoModel *)model;

@end

