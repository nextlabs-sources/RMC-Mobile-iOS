//
//  NXTreeFolderCell.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/6/2.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class NXFileBase;
@interface NXFolderModel : NSObject
@property(nonatomic, assign)int level;
@property(nonatomic, strong)NSString *title;
@property(nonatomic, assign)BOOL selected;
@property(nonatomic, strong)NSString *path;
@property(nonatomic, assign)BOOL expanded;
@property(nonatomic, strong)NSString *fullPath;
@property(nonatomic, strong)NXFileBase *fileBase;
@end
@interface NXTreeFolderCell : UITableViewCell
- (void)refreshArrowDirection:(CGFloat)angle animated:(BOOL)animated;
@property(nonatomic, strong) NXFolderModel * model;
@end

NS_ASSUME_NONNULL_END
