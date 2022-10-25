//
//  NXHomeMySpaceStateView.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 27/4/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface NXHomeMySpaceStateView : UIView
@property (nonatomic ,copy) void(^clickSpaceItemFinishedBlock) (NSInteger index);
- (void) makeUIBaseWithItemInfo:(NSDictionary *)dic;
- (void)updateOneItems:(NSInteger)index withDict:(NSDictionary *)dic;
- (void)updateMySpaceItemFilesCount:(NSUInteger)filesCount;
//- (void)updateAllFilesItemFilesCount:(NSUInteger)filesCount;
@end
