//
//  NXHomeHeaderView.h
//  nxrmc
//
//  Created by helpdesk on 10/2/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NXProcessPercentView;
@interface NXHomeHeaderView : UIView
@property(nonatomic, weak, readonly) UILabel *nameLabel;
@property(nonatomic, weak, readonly) UIImageView *avaterImageView;
@property(nonatomic ,strong)NXProcessPercentView *percentView;
@property (nonatomic ,copy) void(^goToMySpaceFinishedBlock) (id sender);
@end
