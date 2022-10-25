//
//  NXInviteMessageCell.h
//  nxrmc
//
//  Created by nextlabs on 1/12/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NXInviteMessageCell : UICollectionViewCell

@property(nonatomic, strong) id model;
@property (nonatomic ,copy) void(^clickAcceptFinishedBlock) (NSError *err);
@property (nonatomic ,copy) void(^clickIgnoreFinishedBlock) (NSError *err);
@end
