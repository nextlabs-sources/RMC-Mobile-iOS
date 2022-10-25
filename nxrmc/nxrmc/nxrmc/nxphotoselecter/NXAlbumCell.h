//
//  NXAlbumCell.h
//  xiblayout
//
//  Created by nextlabs on 10/17/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NXAlbumCell : UITableViewCell

@property(nonatomic, weak) UIImageView *thumbImageView;

@property(nonatomic, weak) UILabel *titleLabel;
@property(nonatomic, weak) UILabel *countLabel;

@end
